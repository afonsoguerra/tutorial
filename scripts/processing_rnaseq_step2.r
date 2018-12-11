#Processing Kallisto results
#- read kallisto output
#- gene level data 
#- calculate cpm/tpm
#- write matrix
#- summary of read counts


library(base)
#library(BiocParallel)
#library(RCurl)
library(tximport)
#library(readr)
library(biomaRt)
library(reshape)
library(dplyr)


accessions <- list.dirs(full.names=FALSE,recursive = FALSE)[-1]
accessions
mart <- biomaRt::useMart(biomart = "ensembl", dataset =  "hsapiens_gene_ensembl")
#mart = useMart(biomart = "ENSEMBL_MART_ENSEMBL",dataset="hsapiens_gene_ensembl", host = "dec2016.archive.ensembl.org")
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

#Select only protein coding genes



#load packages

#library(sm)
#install biomart
#source("https://bioconductor.org/biocLite.R")
#biocLite("biomaRt")
#library(biomaRt)
#mart <- biomaRt::useMart(biomart = "ensembl", dataset = "hsapiens_gene_ensembl")

gb <- getBM(attributes=c("ensembl_gene_id","gene_biotype"), mart=mart)
detach("package:biomaRt", unload=TRUE) #unload biomart because it creates problems with dplyr
gb_coding<-subset(gb, gb$gene_biotype=="protein_coding")
genes<-gb_coding$ensembl_gene_id
counts<-as.data.frame(tx.kallisto$counts[row.names(tx.kallisto$counts) %in% genes, ])

tpm <- as.data.frame(tx.kallisto$abundance[row.names(tx.kallisto$abundance) %in% genes, ])



#Let's divide the count for the total read counts - we then split the count file and write a new file for each sample
#Get cpm

ids<-rownames(counts)

total_counts<-apply(counts,2,sum)
counts_divided<-sweep(counts, 2, total_counts, `/`)
cpm<-counts_divided*1000000
write.csv(round(total_counts),"total_counts_mapped.csv")


#write results
write.csv(counts, "rawcounts.csv")
write.csv(cpm, "cpm.csv")
write.csv(tpm, "tpm.csv")







