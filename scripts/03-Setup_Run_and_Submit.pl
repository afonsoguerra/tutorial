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


my $uclID = `cat .ucluser`;
chomp($uclID);

my $server = "rsync -Puva $uclID\@live.rd.ucl.ac.uk:";
my $RDSPATH = '/mnt/gpfs/live/ritd-ag-project-rd002u-mnour10/RNAseq/fastq/';


my $CONTAINER = `cat .container`;
chomp($CONTAINER);
;
my $KALLISTO = "singularity exec -B /scratch0/$uclID/ $CONTAINER kallisto ";

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

#Ask for index details
my $kallistoindex = `cat .kallistoindex`;
chomp($kallistoindex);

#Make sure index exists or tell user to go create it
if(!-e $kallistoindex) {
   die "Something has gone badly wrong here. Please re-create your index or ask for help. Things are likely broken due to an incomplete move or rogue file deletion. Beware!\n";
}

my $void1 = &promptUser("Found a request for ".scalar(@samples)." samples, does that sound about right? (press ENTER to continue or CTRL+C to exit the script)"
, "Yes");

my $void2 = &promptUser("Using the index that was most recently setup [".basename($kallistoindex)."] is that what you want to use? (press ENTER to continue or CTRL+C to exit the script)"
, "Yes");


#Should somehow check here that the key are in place for the SSH 



for my $sample (@samples) {

system("mkdir -p $oneup/results/$sample/");
system("mkdir -p $oneup/results/logfiles/");

my $qsubHere = <<"QSUB";
#!/bin/bash -l
#\$ -S /bin/bash
#\$ -o $oneup/results/logfiles/${sample}.log.txt
#\$ -e $oneup/results/logfiles/${sample}.log.txt
#\$ -l h_rt=01:00:00
#\$ -l tmem=11.9G,h_vmem=11.9G
#\$ -l tscratch=10G
#\$ -N  kallisto
#\$ -hold_jid making_index_kallisto
#\$ -wd $oneup/results/${sample}
#\$ -V
#\$ -R y

mkdir -p /scratch0/$uclID/\$JOB_ID/
#echo "DEBUG"
${server}${RDSPATH}${sample}*.fastq.gz /scratch0/$uclID/\$JOB_ID/
ls -lthr /scratch0/$uclID/\$JOB_ID/

time $KALLISTO quant -i $kallistoindex -b 5 -o $oneup/results/${sample}/ /scratch0/$uclID/\$JOB_ID/${sample}_R1*.fastq.gz /scratch0/$uclID/\$JOB_ID/${sample}_R2*.fastq.gz

rm -rf /scratch0/$uclID/\$JOB_ID/${sample}*

function finish {
    rm -rf /scratch0/$uclID/\$JOB_ID/${sample}*
}

trap finish EXIT ERR

QSUB



open(QSUB, "| qsub") or die;
   print QSUB $qsubHere;
close QSUB;

}



print STDERR "All samples should now have been submitted for processing. Please check if they finished by running qstat, and once they all exit (qstat returns nothing), check the log files to see if anything failed... If you need to re-run anything, create a list with just the failed samples in it and re-run this script with that...\n";





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

