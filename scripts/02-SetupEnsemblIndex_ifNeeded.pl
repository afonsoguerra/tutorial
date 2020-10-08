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
#my $latestReleases = ` cat .listing | grep release | sort -g | tail -n 3 | rev | cut -b -24 | rev`;
my $latestReleases = `cat .listing | grep -oP "[A-Za-z]{3}\\ \\d{2}\\ +\\S{4,5}\\ release-\\d{2,3}" | sort -t '-' -g -k2,2 | tail -n 5`;

system("rm -rf .listing");
#print $latestReleases;
#exit();

print STDERR "\n\nWelcome to the script to download and index Ensembl genomes\n\n";

print STDERR "The latest Ensembl versions are :\n".$latestReleases."\n\n";


my @tmp = split("\n", $latestReleases);
my $latest = "NA";
$latest = $1 if($tmp[-1]=~ m/release-(\d+)/);

#Ask about version
my $ensVer = &promptUser("What is the Ensembl version you want to download? ", $latest);

my $archiveHostString = 'www.ensembl.org'; #Use the latest/main site by default

if($ensVer ne $latest){
   #Regenerate and Parse Ensembl Archive list
   open(IN, 'curl \'https://www.ensembl.org/Help/ArchiveList\' | grep .archive.ensembl.org | sed -e \'s/li>/\n/g\' | grep cp-external | grep GRCh | egrep -o \'Ensembl .*: ... 20..\' | tr -d \':\' | ') or die "Could not retrieve archive list file: $!\n";

   my $archive = 'NA';

   while (my $line = <IN>) {
      chomp($line);
      next if($line eq "");
      my @data = split(" ", $line);

      print STDERR "DEBUG: @data\n";

      if($data[1] eq $ensVer) {
         $archive = $data[2].$data[3];
      }
   }
   close IN;

   die "ERROR: Unfortunately I couldn't find the requested Ensembl version, please try again\n" if($archive eq 'NA');

   #save matching ensembl host
   print STDERR "DEBUG: BioMart archive site is at: ".lc($archive).".archive.ensembl.org\n";
   #aug2017.archive.ensembl.org
   $archiveHostString = lc($archive).".archive.ensembl.org";
}


#Ask about species

my $ensSP = &promptUser("What is the Ensembl species you want to download?\nLikely choices are \"homo_sapiens\" or \"danio_rerio\"\nThe default is ", "homo_sapiens");

#Save the current biomart dataset thingy here
my @temp2 = split('_',$ensSP);
my $datasetString = substr($temp2[0],0,1).$temp2[1]."_gene_ensembl";

#die "$datasetString\n";


### Setup/update R script to match dataset

my $RScript1 = <<'RSCRIPT1';

#Processing Kallisto results
#- read kallisto output
#- gene level data 
#- calculate cpm/tpm
#- write matrix
#- summary of read counts

Sys.setenv(XDG_CACHE_HOME="/tmp")
Sys.getenv(x="BIOMART_CACHE")

library(base)
library(tximport)
library(biomaRt)
library(reshape)
library(dplyr)

biomartCacheInfo()

accessions <- list.dirs(full.names=FALSE,recursive = FALSE)
#accessions


RSCRIPT1

my $RScript2 = 'mart <- biomaRt::useMart(biomart="ensembl",dataset="'.$datasetString.'", host="'.$archiveHostString.'")';

my $RScript3 = <<'RSCRIPT3';


t2g <- biomaRt::getBM(attributes = c("ensembl_transcript_id", "transcript_version", "ensembl_gene_id", "external_gene_name", "description", "transcript_biotype"), mart = mart)
t2g$target_id <- paste(t2g$ensembl_transcript_id, t2g$transcript_version, sep=".") # append version number to the transcript ID
t2g[,c("ensembl_transcript_id","transcript_version")] <- list(NULL) # delete the ensembl transcript ID and transcript version columns
t2g <- dplyr::rename( t2g, gene_symbol = external_gene_name, full_name = description, biotype = transcript_biotype )
t2g<-t2g[,c(ncol(t2g),1:(ncol(t2g)-1))]

#Let's use tximport to summarize results into genes
kallisto.dir<-paste0(accessions)
kallisto.files<-file.path(kallisto.dir,"abundance.tsv")
names(kallisto.files)<- accessions
tx.kallisto <- tximport(kallisto.files, type = "kallisto", tx2gene = t2g, countsFromAbundance ="no")


gb <- getBM(attributes=c("ensembl_gene_id","gene_biotype"), mart=mart)
detach("package:biomaRt", unload=TRUE) #unload biomart because it creates problems with dplyr
#gb_coding<-subset(gb, gb$gene_biotype=="protein_coding") #Select only protein coding genes
genes<-gb$ensembl_gene_id
counts<-as.data.frame(tx.kallisto$counts[row.names(tx.kallisto$counts) %in% genes, ])

tpm <- as.data.frame(tx.kallisto$abundance[row.names(tx.kallisto$abundance) %in% genes, ])

#tpm$GeneName<-t2g$gene_symbol[match(rownames(tpm), t2g$ensembl_gene_id)]                                                                                      │··············

#Let's divide the count for the total read counts - we then split the count file and write a new file for each sample

ids<-rownames(counts)

total_counts<-apply(counts,2,sum)
counts_divided<-sweep(counts, 2, total_counts, `/`)
cpm<-counts_divided*1000000
write.csv(round(total_counts),"total_counts_mapped.csv")

#write results
write.csv(counts, "rawcounts.csv")
write.csv(cpm, "cpm.csv")
write.csv(tpm, "tpm.csv")

RSCRIPT3



open(RSCRIPT, ">RNAseq_Matrix_Generation_Script.R") or die;
   print RSCRIPT $RScript1.$RScript2.$RScript3."\n";
close RSCRIPT;


print STDERR "Downloading Transcriptome file, please wait ...\n\n";

my $FASTA = "$oneup/Data/Ensembl-${ensSP}-${ensVer}-cdna.fa.gz";
my $OUT = "$oneup/ref/Ensembl-${ensSP}-${ensVer}.index";

system("echo \"$OUT\" > .kallistoindex");


if(-e $OUT) {
   print STDERR "Index already exists for that version/species combination, setting it as default and exiting without further action\n";
   exit(0);
}


system("mkdir -p $oneup/Data/");
system("mkdir -p $oneup/logfiles/");
system("mkdir -p $oneup/ref/cluster/");

#Download file
if(!-e $FASTA) {
   system("$WGET --no-parent --no-remove-listing -O $FASTA ftp://ftp.ensembl.org/pub/release-${ensVer}/fasta/${ensSP}/cdna/*.all.fa.gz");
   #ftp://ftp.ensembl.org/pub/release-98/fasta/danio_rerio/cdna/
}

#Setup kallisto index run and set it going

my $qsubHere = <<"QSUB";
#!/bin/bash -l
#\$ -S /bin/bash
#\$ -o $oneup/logfiles/IndexingEnsembl-${ensSP}-${ensVer}.logfile.txt
#\$ -e $oneup/logfiles/IndexingEnsembl-${ensSP}-${ensVer}.logfile.txt
#\$ -l h_rt=04:00:00
#\$ -l tmem=8.9G,h_vmem=8.9G
#\$ -N making_index_kallisto

$KALLISTO index -i $OUT $FASTA

QSUB

open(QSUB, "| qsub") or die;
   print QSUB $qsubHere;
close QSUB;

open(DBG, ">.debug.qsub") or die;
   print DBG $qsubHere;
close DBG;


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


