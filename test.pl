# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Term::ReadPassword;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# Well, this would be hard to test unless I set up a ptty and sockets and
# my head hurts....
INTERACTIVE: {
  # Don't fail if there's no tty handy
  unless (-t) {
    print "# Can't test interactively\n";
    print "ok 2\n";
    last INTERACTIVE;
  }

  my $secret = '';
  { 
    # Naked block for scoping and redo
    print "# (Don't worry - you're not changing your system password!)\n";
    my $new_pw = read_password("Enter your new password: ", 10);
    if (not defined $new_pw) {
      print "# Time's up!\n";
      print "# Were you scared, or are you merely an automated test?\n";
      print "ok 2\n";
      last INTERACTIVE;
    } elsif ($new_pw =~ /([^\x20-\x7E])/) {
      my $bad = unpack "H*", $1;
      print "# Your password may not contain the ";
      print "character with hex code $bad.\n";
      redo;
    } elsif (length($new_pw) < 5) {
      print "# Your password must be longer than that!\n";
      redo;
    } elsif ($new_pw ne read_password("Enter it again: ")) {
      print "# Passwords don't match.\n";
      redo;
    } else {
      $secret = $new_pw;
      print "# Your password is now changed.\n";
    }
  }

  print "# \n# Time passes... you come back the next day... and you see...\n";
  while (1) {
    my $password = read_password('password: ');
    redo unless defined $password;
    if ($password eq $secret) {
      print "# Access granted.\n";
      print "ok 2\n";
      last;
    } else {
      print "# Access denied.\n";
      print "# (But I'll tell you: The password is '$secret'.)\n";
      redo;
    }
  }
}