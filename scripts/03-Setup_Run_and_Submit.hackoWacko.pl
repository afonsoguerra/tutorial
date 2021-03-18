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

if(-e "$oneup/results/rawcounts.csv") {
   print STDERR "Warning: A previous run is already present in the results directory. To avoid unintended consequences, please move those results (and logfiles) before starting a new run.\n";
   exit(0);
}


my $uclID = `cat .ucluser`;
chomp($uclID);

my $server = "rsync -Puva $uclID\@live.rd.ucl.ac.uk:";
my $RDSPATH = '/mnt/gpfs/live/ritd-ag-project-rd002u-mnour10/RNAseq/fastq/';


my $CONTAINER = `cat .container`;
chomp($CONTAINER);

if(!-e $CONTAINER) {
   die "It appears you are trying to run this script without first running the earlier setup scripts. Please run everything in order and try again.\n";
}


my $KALLISTO = "singularity exec -B /scratch0/$uclID/ $CONTAINER kallisto ";

#Sort out input
die "Usage: $0 RunFileSpecsFile [RDS PATH]\n" if(!@ARGV);
my $filename = $ARGV[0];
$RDSPATH = $ARGV[1] if(defined($ARGV[1]));


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

#Ask for index details
my $kallistoindex = `cat .kallistoindex`;
chomp($kallistoindex);

#Make sure index exists or tell user to go create it
if(!-e $kallistoindex) {
   print STDERR "ERROR: Index file not found.\nIf you have just set it to regenerate, please ignore this message and proceed without fear. Otherwise, something has gone badly wrong here. Please re-create your index or ask for help.\n";
}

my $void1 = &promptUser("Found a request for ".scalar(@samples)." samples, does that sound about right? (press ENTER to continue or CTRL+C to exit the script)"
, "Yes");

my $void2 = &promptUser("Using the index that was most recently setup [".basename($kallistoindex)."] is that what you want to use? (press ENTER to continue or CTRL+C to exit the script)"
, "Yes");


#Should somehow check here that the key are in place for the SSH 

my $ttt = time();
system("mkdir -p $oneup/dataFiles/");
system("mkdir -p $oneup/logfiles/");

for my $sample (@samples) {

system("mkdir -p $oneup/results/$sample/");

my $qsubHere = <<"QSUB";
#!/bin/bash -l

cd $oneup/results/${sample}

mkdir -p $oneup/dataFiles/${ttt}/

${server}${RDSPATH}${sample}*.fastq.gz $oneup/dataFiles/${ttt}/
ls -lthr $oneup/dataFiles/${ttt}/${sample}*

#time $KALLISTO quant -i $kallistoindex -b 5 -o $oneup/results/${sample}/ $oneup/dataFiles/${ttt}/${sample}*_R1*.fastq.gz $oneup/dataFiles/${ttt}/${sample}*_R2*.fastq.gz
time $KALLISTO quant -i $kallistoindex -o $oneup/results/${sample}/ $oneup/dataFiles/${ttt}/${sample}*_R1*.fastq.gz $oneup/dataFiles/${ttt}/${sample}*_R2*.fastq.gz
rm -rf $oneup/dataFiles/${ttt}/${sample}*


QSUB

open(QSUB, "| bash") or die;
   print QSUB $qsubHere;
close QSUB;

}







print STDERR "All samples should now have finished processing...\n";





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


