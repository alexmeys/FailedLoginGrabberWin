#!/usr/bin/perl
#2012 Alex Meys

use Win32::EventLog;
use strict;
use warnings;
use Net::SMTP;

my @atijd;
my @awan;
my @aprobe;

sub motor{
my %type = (
    1  => "ERROR",
    2  => "WARNING",
    4  => "INFORMATION",
    16  => "AUDIT_FAILURE",
    8 => "AUDIT_SUCCES"
);

my $log = new Win32::EventLog("Security") 
  or die "Kan Security Log niet openen: $!\n";

 
while ($log->Read((EVENTLOG_SEQUENTIAL_READ | EVENTLOG_BACKWARDS_READ),0, my $entry))
{
    my $z = Win32::EventLog::GetMessageText($entry);
    if($entry->{EventType} == 16)
    {
        my @var = split(/\x00/, $entry->{Strings});
		
        foreach my $waarde (@var)
        {
	    if($waarde =~ /\b(\d{2,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b/)
            {
			    push(@atijd, scalar localtime($entry->{TimeGenerated}));
                push(@awan, $waarde);
                push(@aprobe, $var[5]);
	        }
        }

    }
}
return(\@atijd, \@awan, \@aprobe);
}

sub opruim
{
my $srv = "localhost";
my($tijd)=join("-", ((split(/\s+/, scalar(localtime)))[0,1,2,4]));
my($best);
my $handle;

for my $eventLog ("Security") {
        $handle=Win32::EventLog->new($eventLog, $srv)
                or die "Kan de Security Log niet openen op $srv.\n";

        $best="$tijd.evt";
        #$handle->Backup($best)
        #        or warn "Kan geen backup nemen of opruimen: $eventLog EventLog op $srv ($^E)\n";
        $handle->Clear('C:/BackupEventLogs/'.$eventLog. "/".$best);
        $handle->Close;
 }
}

sub sendme
{
  &motor();
  my (@amail, @bmail, @cmail);
  for(my $t=0; $t <= $#awan; $t++)
  {
	  push (@amail, $atijd[$t]);
	  push (@bmail, $awan[$t]);
	  push (@cmail, $aprobe[$t]);
  }
  if($#bmail+1 >0){
  my ($naar, $van, $onderwerp, $bericht, $host);
  my $zend = "uit.telenet.be"; #Uitgaande mailserver is variabel naargelang ISP.
  $van = "securitymonitor\@company.com"; #Fancy mailadres
  $naar = "mezelf\@email.com"; #mijn mailadres.
  my $smtp = Net::SMTP->new("$zend", Timeout => 50);
  my $verb = $smtp->domain;
  
  $smtp->mail($van);
  $smtp->to($naar);
  $smtp->data();
  
  $smtp->datasend("From: $van\n");
  $smtp->datasend("To: $naar\n");
  $smtp->datasend("Subject: Security Breach\n");
  $smtp->datasend("Priority: Urgent\n");
  $smtp->datasend("\n");
  $smtp->datasend("Beste,\n\nHieronder De Wan-IP's, loginnamen van de probers:\n\n");
  my $max = $#amail;
  my $s = 0;
  for(my $s=0; $s <= $max ; $s++)
  {
    $smtp->datasend("Tijdstip: ".$amail[$s]. "\tWan IP: ".$bmail[$s]. "\tLogin: ". $cmail[$s]."\n\n");
  }
  $smtp->datasend("Steeds tot uw dienst.\n\nMet vriendelijke groet,\n\nAlex Meys");
  $smtp->dataend();
  $smtp->quit;
  
  &opruim();
  }
  else{&opruim();}
}

&sendme();
