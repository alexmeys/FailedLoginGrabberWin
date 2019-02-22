# FailedLoginGrabberWin
Perl script to get failed logins in Windows

Howto

Install activestate perl (5.12.4)

Download Net::SMTP (used for sending mail)

Create this structure on your server
  C:\BackupeventLog\Security
  C:\evgrep
  
Copy files to C:\evgrep\* (1 pl, 1 bat file)
Schedule the bat file

Edit script:
* Line 78: outbound mailserver ($zend)
* Line 79 & 80, the details from/to
* 100 depending on your choice, you can adjust. 
