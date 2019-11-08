#!/usr/bin/env perl


#Change usernames in the scripts if needed
my @scriptList = qw/getting_data_RSD.sh kallisto.sh making_index.sh processing_rnaseq_step2.r submitR.sh /;

my $here = `pwd`;
chomp($here);


print STDERR "\n\nWelcome to the setup script. If you see anything between square brackets, and it is a correct answer, just press Enter\n\n";
my $prompt = &promptUser("Press Enter now to continue the ", "setup");


print STDERR "\nPlease wait a moment while we check for the needed software... \n";

#Download Singularity Container if not there. 

if (!-e "tutorial_latest.sif") {
	system("singularity pull shub://afonsoguerra/tutorial");
	system("singularity exec tutorial_latest.sif ls /");
}

#Ask about ensembl references that might be needed

print STDERR "[DONE]\n\nLet's customise the scripts... \n";

my $ucluser = &promptUser("Enter the main UCL username ");
my $csuser = `whoami`;
chomp($csuser);

$csuser = &promptUser("Enter the CS cluster username ", $csuser);

print "$ucluser, $csuser\n";

for my $script (@scriptList) {

	$here =~ s/\//\/\//g;

	system('sed -i bck -e s/REPLACEMEbyCSUSERNAME/'.$csuser.'/ '.$script);
	system('sed -i bck2 -e s/REPLACEMEbyUCLUSERNAME/'.$ucluser.'/ '.$script);
	system('sed -i bck3 -e s/REPLACEMEbyKALLISTOPATH/singularity exec '.$here.'\/tutorial_latest.sif kallisto/ '.$script);


}





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