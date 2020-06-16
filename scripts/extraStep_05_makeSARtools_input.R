matrix <- read.csv("rawcounts.csv", header=TRUE)
matrix_int <- round(matrix[,2:ncol(matrix)])

# save list of gene symbols
#### change here column with gene identifier ####
genes <- as.data.frame(matrix[,1])

# save list of samples
names <- colnames(matrix_int)

# loop through samples, merge with list of genes and save as .txt file with sample name
for (i in 1:length(names)){
  sample <- matrix_int[,i]
  merged <- cbind(genes,sample)
  write.table(merged,file=paste0(names[i],".txt"),row.names=FALSE,col.names=FALSE,sep="\t")
}


