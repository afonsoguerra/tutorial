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

my %failed;

for my $sample (@samples) {

   my $logfile = "$oneup/logfiles/${sample}.log.txt"

   #Check for fails
   system("tail -n 5 $logfile");
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
singularity exec -B $oneup --no-home $CONTAINER R --vanilla -f $oneup/scripts/RNAseq_Matrix_Generation_Script.R 

QSUB



open(QSUB, "| qsub") or die;
   print QSUB $qsubHere;
close QSUB;



print STDERR "Since you are seeing this message, no samples appear to have failed. Good news! Furthermore, R is now queued for running to create the final data matrices for this run. Thanks for using the pipeline, have a great day!\n";





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

