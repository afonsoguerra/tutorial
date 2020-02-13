#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;


my $here = `pwd`;
chomp($here);

my @temp = split('/',$here);
my $asd = pop(@temp);
my $oneup = join('/',@temp);


my $uclID = `cat .ucluser`;
chomp($uclID);

my $server = "scp $uclID\@live.rd.ucl.ac.uk:";
my $RDSPATH = '/mnt/gpfs/live/ritd-ag-project-rd002u-mnour10/RNAseq/fastq/';


my $CONTAINER = `cat .container`;
chomp($CONTAINER);
;
my $WGET = "singularity exec $CONTAINER wget ";
my $KALLISTO = "singularity exec $CONTAINER kallisto ";


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

   push($data[0],@samples);
}

close IN;

#Ask for index details
my $kallistoindex = `cat .kallistoindex`;
chomp($kallistoindex);

#Make sure index exists or tell user to go create it
if(!-e $kallistoindex) {
   die "Something has gone badly wrong here. Please re-create your index or ask for help. Things are likely broken due to an incomplete move or rogue file deletion. Beware!\n";
}

my $void1 = &promptUser("Found a request for ".scalar(@samples)." samples, does that sound about right? (press ENTER to continue or CTRL+C to exit the script)"
, "Yes");

my $void2 = &promptUser("Using the index that was most recently setup [$kallistoindex] is that what you want to use? (press ENTER to continue or CTRL+C to exit the script)"
, "Yes");


die;

#Check all samples exist in RDS? 


#Create necessary qsub files


#Submit qsub files




system("mkdir -p $oneup/Data/");
system("mkdir -p $oneup/ref/cluster/");

my $qsubHere = <<"QSUB";
#!/bin/bash -l
#\$ -S /bin/bash
#\$ -o $oneup/ref/cluster/out
#\$ -e $oneup/ref/cluster/error
#\$ -l h_rt=04:00:00
#\$ -l tmem=8.9G,h_vmem=8.9G
#\$ -N making_index_kallisto

$KALLISTO index -i \$OUT \$FASTA

QSUB

open(QSUB, ">.latestIndexing.qsub") or die;
   print QSUB $qsubHere;
close QSUB;
system("qsub .latestIndexing.qsub");


print STDERR "All samples should now have been submitted for processing. Please check if they finished by running qstat, and once they all exit (qstat returns nothing), check the log files to see if anything failed... If you need to re-run anything, create a list with just the failed samples and re-run this script with that...\n";






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

