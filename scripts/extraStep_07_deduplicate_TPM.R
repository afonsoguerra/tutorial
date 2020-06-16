rm(list=ls())
library(dplyr)
library(textshape)

working.directory <- getwd()
input.file <- "Annotatedexample_tpm_PC0.001_log2.csv"
output.file <- "example_tpm_PC0.001_log2_genesymbol_dedup.csv"

wd <- working.directory
dir1 <- paste0(wd,"/Files_per_sample")
dir.create(dir1)

dir2 <- paste0(wd, "/Files_per_sample_dedup")
dir.create(dir2)

setwd(wd)

tpm <- read.csv(input.file)
genes <- as.data.frame(tpm %>% dplyr::select(external_gene_name))
tpm <- tpm %>% dplyr::select(-c(ensembl_gene_id,external_gene_name,description,gene_biotype))
names <- colnames(tpm) 

setwd(dir1)
  
for (i in 1:length(names)){
  sample <- tpm[,i]
  merged <- cbind(genes,sample)
  write.csv(merged,file=paste0(names[i],".csv"),row.names = F)
}

setwd(dir1)

allfiles <- list.files(pattern = ".csv")

for (i in 1:length(allfiles)){
  dat <- read.csv(allfiles[i],header=TRUE)
  dat <- dat[order(dat$external_gene_name, -(dat$sample)), ]
  dat <- dat[!duplicated(dat$external_gene_name), ]
 
  nam <- gsub('\\.csv','',allfiles[i])
  colnames(dat)[2] <- nam
  
  write.csv(dat,file=paste0(dir2,"/",nam,"_dedup.csv"),row.names = F)
}

# read in first deduplicated sample file and set first column name to GeneSymbol
setwd(dir2)
allfiles.dedup <- list.files(pattern = ".csv")

df <- read.csv(allfiles.dedup[1], header=T) 
colnames(df)[1] <- "GeneSymbol" 

# loop through all remaining files and merge with the first one, using GeneSymbol as common column
for(f in 2:length(allfiles.dedup)){ 
  dat <- read.csv(allfiles.dedup[f],header=TRUE)
  colnames(dat)[1] <- "GeneSymbol"
  df <- merge(df,dat,by="GeneSymbol")
}

# order columns alphabetically
df <- df[,order(colnames(df))]

# use GeneSymbol as rownames
df <- df %>% column_to_rownames("GeneSymbol")

# write to file
setwd(wd)
write.csv(df,output.file)