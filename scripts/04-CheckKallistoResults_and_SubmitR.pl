#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use File::Basename;

my $here = `pwd`;
chomp($here);

my @temp = split('/',$here);
my $asd = pop(@temp);
my $oneup = join('/',@temp);


if(!-e ".ucluser") {
   die "It appears you are trying to run this script without first running the earlier setup scripts. Please run everything in order and try again.\n";
}

if(!-e ".container") {
   die "It appears you are trying to run this script without first running the earlier setup scripts. Please run everything in order and try again.\n";
}


my $CONTAINER = `cat .container`;
chomp($CONTAINER);


#Sort out input
die "Usage: $0 RunFileSpecsFile [RDS PATH]\n" if(!@ARGV);
my $filename = $ARGV[0];

#Check for a sample list file
open(IN, "$filename") or die "Could not open input file: $!\n";
my @samples;
while (my $line = <IN>) {
   chomp($line);
   next if($line eq "");
   my @data = split("\t", $line);

   push(@samples,$data[0]);
}

close IN;


print STDERR "Hold tight, we are now checking if your ".scalar(@samples)." samples have processed correctly and are ready for aggregation... (may take a bit)\n";

my @failed;
open(FAIL, ">failedSamples.txt") or die;

for my $sample (@samples) {

   my $logfile = "$oneup/logfiles/${sample}.log.txt";

   #Check for fails
   my $success = `grep -c bstrp $logfile`;
   chomp($success);

   if($success == 0){
      print STDERR "ERROR: Sample $sample FAILED kallisto\n";
      push(@failed, $sample);
      print FAIL "$sample\n";
   }
}
close FAIL;

if(scalar(@failed) > 0){
   die "ERROR: Unfortunately it appears that some of your samples [N=".scalar(@failed)."/".scalar(@samples)."] have failed to process correctly. For your convenience, these have been written to the failedSamples.txt file that can be used to re-submit them once the problem is corrected.\nPlease resolve the problem and re-start processing from the previous step\n";
}



# Add a script here for running the R bit
my $qsubHere = <<"QSUB";
#!/bin/bash -l
#\$ -S /bin/bash
#\$ -o $oneup/logfiles/make_matrix.log.txt
#\$ -e $oneup/logfiles/make_matrix.log.txt
#\$ -l h_rt=01:00:00
#\$ -l tmem=11.9G,h_vmem=11.9G
#\$ -N make_matrix
#\$ -hold_jid kallisto
#\$ -wd $oneup/results/
#\$ -V
#\$ -R y

cd $oneup/results/
export BIOMART_CACHE=\"$oneup/ref/.biomaRt/\"
singularity exec -B $oneup --no-home $CONTAINER R --vanilla -f $oneup/scripts/RNAseq_Matrix_Generation_Script.R 

singularity exec -B $oneup --no-home $CONTAINER R --vanilla -f $oneup/scripts/extraStep_05_makeSARtools_input.R 
singularity exec -B $oneup --no-home $CONTAINER R --vanilla -f $oneup/scripts/extraStep_06_Annotate_TPM_matrix.R 
singularity exec -B $oneup --no-home $CONTAINER R --vanilla -f $oneup/scripts/extraStep_07_deduplicate_TPM.R 

QSUB



open(QSUB, "| qsub") or die;
   print QSUB $qsubHere;
close QSUB;



print STDERR "Happy Days! Since you are seeing this message, all samples appear to have successfully finished the previous steps.\nFurthermore, R is now queued for running to create the final data matrices for this run. Thanks for using the pipeline, have a great day!\n";





sub promptUser {


   my ($promptString,$defaultValue) = @_;

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


