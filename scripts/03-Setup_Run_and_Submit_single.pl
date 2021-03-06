#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use File::Basename;

my $here = `readlink -f .`;
chomp($here);

my @temp = split('/',$here);
my $asd = pop(@temp);
my $oneup = join('/',@temp);
my $proj = "/cluster/project9/MaddyRNAseq";

my $maxSub = 100;

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

my $server = "scp $uclID\@live.rd.ucl.ac.uk:";
my $RDSPATH = '/mnt/gpfs/live/ritd-ag-project-rd002u-mnour10/RNAseq/fastq/';


my $CONTAINER = `cat .container`;
chomp($CONTAINER);

my $KALLISTO = "singularity exec -B $proj -B $oneup $CONTAINER kallisto ";

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



for my $sample (@samples) {


&sampleWaiter("kallisto",$maxSub);

system("mkdir -p $oneup/results/$sample/");
system("mkdir -p $proj/TEMP/");
system("mkdir -p $oneup/logfiles/");
system("${server}${RDSPATH}${sample}*.fastq.gz $proj/TEMP/");


my $qsubHere = <<"QSUB";
#!/bin/bash -l
#\$ -S /bin/bash
#\$ -o $oneup/logfiles/${sample}.log.txt
#\$ -e $oneup/logfiles/${sample}.log.txt
#\$ -l h_rt=12:00:00
#\$ -l tmem=11.9G,h_vmem=11.9G
#\$ -N  kallisto
#\$ -hold_jid making_index_kallisto
#\$ -wd $oneup/results/${sample}
#\$ -V
#\$ -R y



ls -lthr $proj/TEMP/

time $KALLISTO quant -i $kallistoindex -l 250.0 -s 50.0 --single -b 5 -o $oneup/results/${sample}/ $proj/TEMP/${sample}*.fastq.gz

rm -rf $proj/TEMP/${sample}*

function finish {
    rm -rf $proj/TEMP/${sample}*
}

trap finish EXIT ERR

QSUB



open(QSUB, "| qsub") or die;
   print QSUB $qsubHere;
close QSUB;

}


################### Setup email alert

my $qsubHere = <<"QSUB";
#!/bin/bash -l
#\$ -S /bin/bash
#\$ -o $oneup/logfiles/report.log.txt
#\$ -e $oneup/logfiles/report.log.txt
#\$ -l h_rt=00:10:00
#\$ -l tmem=1.9G,h_vmem=1.9G
#\$ -N report
#\$ -hold_jid kallisto
#\$ -cwd
#\$ -V
#\$ -R y

date
echo "All jobs finished"
date

function finish {
   (echo "Subject: Latest RNAseq run" ; echo ; echo "All samples submitted to the RNAseq pipeline have now finished on the cluster. Please go and run the last steps to merge the data." ) | ssh rds sendmail ${uclID}\@ucl.ac.uk
}

trap finish EXIT ERR

QSUB

open(QSUB, "| qsub") or die;
   print QSUB $qsubHere;
close QSUB;






print STDERR "All samples should now have been submitted for processing. Please check if they finished by running qstat, and once they all exit (qstat returns nothing), Run the next script in the pipeline to check the log files to see if anything failed and continue the processing...\n";



sub sampleWaiter {

   my $procName = shift;
   my $procN = shift;

   my $running = &countProc($procName);
   print STDERR "[".time()."] $running things running... \n"; 

   while ($running >= $procN) {
      print STDERR "[".time()."] There are already $running jobs running. Waiting a bit to avoid filling the temp space... \r"; 
      sleep(120);
      $running = &countProc($procName);
   }

   print STDERR "\n";
}



sub countProc {
   my $procName = shift;

   my $cnt = `qstat | grep kallisto | wc -l`;
   chomp($cnt);

   return $cnt;
}



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


