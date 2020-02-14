---
title: "CS cluster RNAseq tutorial"
author: "José Afonso Guerra-Assunção, based on original by Cristina Venturini"
---

# The RNAseq Pipeline for MN Group to be run in the new CS HPC Cluster

These are brief instructions to run the RNAseq pipeline scripts within the new computer science cluster, automatically getting data from the MN RDS space.

Automation has been coded in as much as possible, so things don't have to be done over and over again, but with also a few checkpoints for people to double-check things are are expected. 

The indexing script connect to Ensembl to retrieve the list of versions available. No need to check the website before running this. 

Only one index (species/version combination) can be used at any one time, so at the moment it isn't possible to map things to Human and Zebrafish at the same time. Nevertheless it is very easy to map one, change the index and set the second run up. 

All scripts are now interactive and will ask a few questions before running things. Answers that are unlikely to change (e.g. usernames) are saved in the same directory the scripts are run from, and won't be asked again if the answer is already found. 

The scripts try to guess the answer that is most likely correct (e.g. latest ensembl version for human). If that is correct, pressing ENTER at the prompt should suffice. 

Some things are not checked, namely:
- that the sample name provided is unique (if a generic name is provided like, "A" it will match a lot of samples and cause mayhem)
- that the sample name provided exists (it will simply fail with file not found errors if this is a problem, but it isn't checked beforehand)

This pipeline is packaged as a Singularity container that is automatically downloaded at step 1 of the instructions below. If manual installation is required, it can be retrieved from SingularityHub at:
[![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/3656)


# How to run it


## First, you need to connect to the CS cluster

Options:
- Putty (for Windows)
- Mac/Linux: open terminal:
```{bash,eval = FALSE}
ssh <userid>@pchuckle.cs.ucl.ac.uk
```


## Getting the code for the first time

```{bash,eval = FALSE}
#Get the folder tutorial from github for the first time
git clone https://github.com/afonsoguerra/tutorial.git

```

## Making sure the latest version is in place / updating code

```{bash,eval = FALSE}
cd tutorial #change to dir "tutorial"
git pull # Update code from github if needed when the tutorial folder already exists
```


## Some useful unix/bash commands
```{bash,eval = FALSE}
ls -lhrt #list dir contents

cd tutorial #change to dir "tutorial"

pwd #check your current dir
```


# Downloading all needed software and setting up usernames 

This only needs to be run once, but if run multiple times it won't harm anything, just waste time...

```{bash,eval = FALSE}

#Make sure you are inside the tutorial folder

cd scripts/

perl 01-SetupFirst_andOnlyOnce.pl

```


# Adding an Ensembl Species/Version index 

This needs to be run when no index is present or to change the 'default' index currently being used by the pipeline. It will do the minimum amount of work needed each time. If things are already in place, it will just swap the default index to the new one. If index is new, it will generate it using qsub. 

```{bash,eval = FALSE}

#Make sure you are inside the tutorial folder

cd scripts/

perl 02-SetupEnsemblIndex_ifNeeded.pl

```




# Preparing data

All that will be retrieved at runtime, so the only thing needed here is a list of samples to be processed. This should be a text file with one or more tab delimited columns where the first column of the file has the sample name. This will be matched to the default MN RDS fastq folder to retrieve the R1 and R2 files at runtime. 

Note: There is no longer a limit to the number of samples that can be submitted at once.

This file can be generated in many different ways, one of which is:

```{bash,eval = FALSE}
nano samples.tab # (file can be named anything) copy and paste your sample names here. To come out: ctrl+x, press "Y"
```



# Submitting data for processing

```{bash,eval = FALSE}

perl 03-Setup_Run_and_Submit.pl samples.tab #Or whathever the sample list filename is

```


# Checking everything ran fine and running the R script to merge data into unified matrices

There is a waiting time between step 03, when things are running in the cluster. How long this takes is unpredictable and depends on the number of samples submitted and how busy the cluster is as a whole.

One way of checking if things have finished is to run:

```{bash,eval = FALSE}

qstat

```

This shall tell you what is running and what is queued for runnin on the cluster on your behalf. 

If there is nothing in there, it means that everything has finished. Unfortunately, it doesn't mean everything finished according to plan, so we first need to check that all kallisto runs reached the end, and then, if all is well, we can issue the final command to aggregate the data into a single matrix. These last steps are performed with script 04 that can be run as indicated below. 


```{bash,eval = FALSE}

perl 04-CheckKallistoResults_and_SubmitR.pl samples.tab #Or whathever the sample list filename is


```



<!-- 
Get temp cmp and tpm matrix
First time you run this: 
```{bash,eval = FALSE}
/share/apps/R-3.5.1/bin/R
```

```{r,eval = FALSE}
#copy and paste this and follow instruction for personal library
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
#then copy and paste this:
BiocManager::install("tximport", version = "3.8") #tximport
BiocManager::install("biomaRt", version = "3.8")  #biomart
install.packages("reshape","dplyr")

#to exit type: q() 

```

```{bash,eval = FALSE}
cd results/
/share/apps/R-3.5.1/bin/R CMD BATCH ../scripts/processing_rnaseq_step2.r
```

 -->