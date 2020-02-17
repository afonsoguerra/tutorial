#!/usr/bin/env perl


my $here = `pwd`;
chomp($here);


print STDERR "\n\nWelcome to the setup script. If you see anything between square brackets, and it is a correct answer, just press Enter, you only need to type the answer if I can not find it out automatically\n\n";
my $prompt = &promptUser("Press Enter now to continue the ", "setup");


print STDERR "\nPlease wait a moment while we check for the needed software... \n";

#Download Singularity Container if not there. 

if (!-e "tutorial_latest.sif") {
	system("singularity pull shub://afonsoguerra/tutorial");
	system("singularity exec tutorial_latest.sif ls /");
   system("echo \"$here/tutorial_latest.sif\" > .container");
}
else {
	print STDERR "It seems you have been here before... nice to see you again!\n";
}

#Ask about ensembl references that might be needed

print STDERR "\n\nNow, let's customise the scripts... \n";

if(-e '.ucluser') {
   print "Re-using previously provided UCL username: ".`cat .ucluser`."\n";
}
else {
   my $ucluser = &promptUser("Enter the main UCL username ");
   system("echo \"$ucluser\" > .ucluser");
}


if(-e '.csuser') {
   print "Re-using previously provided CS username: ".`cat .csuser`."\n";
}
else {
   my $csuser = `whoami`;
   chomp($csuser);

   $csuser = &promptUser("Enter the CS cluster username ", $csuser);
   system("echo \"$csuser\" > .csuser");
}

#print "$ucluser, $csuser\n";


#system(










sub promptUser {


   local($promptString,$defaultValue) = @_;

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN (presumably the keyboard)

   chomp;


   if ("$defaultValue") {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}

