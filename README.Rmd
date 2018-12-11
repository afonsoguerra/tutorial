---
title: "CS cluster RNAseq tutorial"
author: "Cristina Venturini"
date: "`r Sys.Date()`"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Vignette Title}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

First, you need to connect to the cluster. Options:

- Putty (for Windows)

- Mac/Linux: open terminal:
```{bash,eval = FALSE}
ssh <userid>@bchuckle.cs.ucl.ac.uk
```

Some useful unix/bash commands:
```{bash,eval = FALSE}
ls -lhrt #list dir contents
mkdir tutorial #make a new dir called "tutorial"
cd tutorial #change to dir "tutorial"
pwd #check your current dir
```


Download the tutorial from github:


Prepare the data: 

```{bash,eval = FALSE}
nano samples.tab #copy and paste your samples here. To come out: ctrl+x, press "Y"
perl -lane 'print $F[0],"",$F[1],"*"' data/samples.tab > data/samples_todownload.tab #add * after each sample
nano scripts/getting_data_RSD.sh #change user id
sh scripts/getting_data_RSD.sh #this will download data from RSD storage. You will be prompted to insert your password twice - NB.it's your RSD/UCL password, not the CS cluster one!
```

Create index (only needed at the beginning or when it changes - now we are at release 94)

```{bash,eval = FALSE}
wget -O data/Homo_sapiens.GRCh38_rel94.cdna.all.fa.gz 'ftp://ftp.ensembl.org/pub/release-94/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz'
```

```{bash,eval = FALSE}
nano scripts/making_index.sh #change user id/ dir
mkdir ref
mkdir ref/cluster
qsub scripts/making_index.sh #submit the job - the job will go into a queue and then start to run
qstat #to check your job: qw - waiting in the queue; r - running; Eqw - some problems!
```

Run kallisto 
```{bash,eval = FALSE}

```


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

