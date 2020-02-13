#!/usr/bin/env perl

my $here = `pwd`;
chomp($here);

my @temp = split('/',$here);
my $asd = pop(@temp);
my $oneup = join('/',@temp);

###Quick debug
#die "$here\n$oneup\n";

my $CONTAINER = `cat .container`;
chomp($CONTAINER);

my $WGET = "singularity exec $CONTAINER wget ";
my $KALLISTO = "singularity exec $CONTAINER kallisto ";

#Check for latest versions

system("$WGET --spider --no-remove-listing -q ftp://ftp.ensembl.org/pub/");
my $latestReleases = ` cat .listing | grep release | tail -n 3 | rev | cut -b -24 | rev`;
system("rm -rf .listing");


print STDERR "\n\nWelcome to the script to download and index Ensembl genomes\n\n";

print STDERR "The latest Ensembl versions are :\n".$latestReleases."\n\n";


my @tmp = split("\n", $latestReleases);
my $latest = "NA";
$latest = $1 if($tmp[-1]=~ m/release-(\d+)/);

#Ask about version
my $ensVer = &promptUser("What is the Ensembl version you want to download? ", $latest);

#Ask about species

my $ensSP = &promptUser("What is the Ensembl species you want to download?\nLikely choices are \"homo_sapiens\" or \"danio_rerio\"\nThe default is ", "homo_sapiens");


print STDERR "Downloading Transcriptome file, please wait ...\n\n";

my $FASTA = "$oneup/Data/Ensembl-${ensSP}-${ensVer}-cdna.fa.gz";
my $OUT = "$oneup/ref/Ensembl-${ensSP}-${ensVer}.index";

system("echo \"$OUT\" > .kallistoindex");


if(-e $OUT) {
   print STDERR "Index already exists for that version/species combination, setting it as default and exiting without further action\n";
   exit(0);
}


system("mkdir -p $oneup/Data/");
system("mkdir -p $oneup/ref/");

#Download file
if(!-e $FASTA) {
   system("$WGET --no-parent --no-remove-listing -O $FASTA ftp://ftp.ensembl.org/pub/release-${ensVer}/fasta/${ensSP}/cdna/*.all.fa.gz");
   #ftp://ftp.ensembl.org/pub/release-98/fasta/danio_rerio/cdna/
}

#Setup kallisto index run and set it going

my $qsubHere = <<"QSUB";
#!/bin/bash -l
#\$ -S /bin/bash
#\$ -o $oneup/ref/cluster/out
#\$ -e $oneup/ref/cluster/error
#\$ -l h_rt=04:00:00
#\$ -l tmem=2.9G,h_vmem=2.9G
#\$ -N making_index_kallisto

$KALLISTO index -i $OUT $FASTA

QSUB

open(QSUB, ">.latestIndexing.qsub") or die;
   print QSUB $qsubHere;
close QSUB;
system("qsub .latestIndexing.qsub");


print STDERR "The index has now been queued for processing, you can proceed setting up your run. If the index is not ready when you submit the main samples, they will be patient and wait.\n";



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

