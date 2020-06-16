
Sys.setenv(XDG_CACHE_HOME="/tmp")
Sys.getenv(x="BIOMART_CACHE")

#Equaliser - if number of genes differs in the TPM files (different Ensembl versions)
# Based on agilp with a few edits for RNAseq

Equaliser <-
  function(input=file.path(system.file(package="agilp"),"input",""),output=file.path(system.file(package="agilp"),"output","")){
    arrays<-dir(input)
    n<-length(arrays)
    
    i<-1
    name<-paste(input,arrays[i], sep="")
    error<-paste("First file is absent so this data is not reliable")
    if(file.exists(name)){
      data<-read.table(file = name, row.names=1, header=FALSE, sep = "\t", fill = TRUE,  stringsAsFactors=FALSE)
    }else message("First file is absent so this data is not reliable")
    
    
    #########################################################################################################
    #first pass runs though all files and finds common demoninator in file data
    for (i in 2:n) {
      name<-paste(input,arrays[i], sep="")
      error<-paste("Arrays number",arrays[i], "is not present")
      if(file.exists(name)){
        data1<-read.table(file = name, row.names=1, header=FALSE, sep = "\t", fill = TRUE,  stringsAsFactors=FALSE)
        common <- merge(data,data1,by.x="row.names",by.y="row.names")
        data <-common[,-3]
        data<-data.frame(data[,-1])
        rownames(data)<-common[,1]
      }else message("Array number ",arrays[i], " is not present")
    }
    
    #########################################################################################################
    #second pass runs though all files again and merges with common demoninator and then saves with same name
    for (i in 1:n) {
      
      name<-paste(input,arrays[i], sep="")
      if(file.exists(name)){
        data1<-read.table(file = name, row.names=1, header=FALSE, sep = "\t", fill = TRUE,  stringsAsFactors=FALSE)
        common <- merge(data,data1,by.x="row.names",by.y="row.names")
        
        outfile<-data.frame(common[,3])
        rownames(outfile)<-common[,1]
        colnames(outfile)<-colnames(data1)
        
        #Output
        array_name<-arrays[i]
        dg<-paste(output,array_name,sep = "")
        write.table(outfile,dg,sep="\t",col.names=FALSE,row.names=TRUE)
      } else message("Arrays number",arrays[i], "is not present")
      #end of for loop inputing files
    }
    #end of function
  }


###Annotation function - to get gene names


annotation = function(Species,datafile,fileout){  
  
  #Read of the output of SARTools
  data2=read.csv(toString(datafile), header =T) ##change csv if you have that
  
  #annotation
  bmdataset = toString(Species)
  #mart <- biomaRt::useMart(biomart = "ensembl", dataset =  "hsapiens_gene_ensembl", host ="http://jul2019.archive.ensembl.org")
  mart=useMart(biomart="ENSEMBL_MART_ENSEMBL", dataset= bmdataset)
  #mart = useMart(biomart = "ENSEMBL_MART_ENSEMBL",dataset=bmdataset, host = "dec2016.archive.ensembl.org")
  
  #data2$ensembl_gene_id <- data2$V1; data2$V1 <- NULL
  ann <- biomaRt::getBM(attributes = c("ensembl_gene_id", "external_gene_name", "description", "gene_biotype"), filters="ensembl_gene_id",values=data2$ensembl_gene_id,mart = mart)
  #data2$ensembl_gene_id<-data2$Id
  #data2$Id<-NULL
  data_ann<-merge(data2,ann,by="ensembl_gene_id")
  fileout<- paste("Annotated",datafile,sep="")
  write.csv(data_ann,fileout,row.names=FALSE)
}

#fileNames <- Sys.glob("*.txt")
#for (fileName in fileNames) {
 # annotation_meow("hsapiens_gene_ensembl",fileName) #change here if you have another species
  
#}


##function to remove duplicates 

dedup_genesymbol <- function(filein,fileoutdedup){
  tpm <- read.csv(filein)
  tpm <- tpm %>% select(ensembl_gene_id,external_gene_name,description,gene_biotype,everything())
  tpm$mean <- rowMeans(tpm[,c(5:ncol(tpm))])
  tpm <- tpm[order(tpm$external_gene_name, -(tpm$mean) ), ] #sort by id and reverse of abs(value)
  tpm <- tpm[ !duplicated(tpm$external_gene_name), ]  # take the first row within each id
  tpm <- tpm[-ncol(tpm)] # remove the mean col
  write.csv(tpm,fileoutdedup,row.names = FALSE)
}


#install.packages(c("dplyr", "tidyr","data.table"), dependencies = T)
library(plyr)
library(dplyr)
library(tidyr)
library(data.table)

tpm_df <- read.csv("tpm.csv",header = TRUE,as.is = TRUE,row.names = 1) # CHANGE HERE the input file name


tpm_df <- tpm_df + 0.001
tpmlog <- log2(tpm_df)
tpmlog$ensembl_gene_id <- row.names(tpmlog)
tpmlog <- tpmlog %>% select(ensembl_gene_id,everything()) ##make sure biomart is not loaded, it creates problems with dplyr
write.csv(tpmlog,"example_tpm_PC0.001_log2.csv",quote=FALSE,row.names = FALSE) ##CHANGE HERE the output file name


## try http:// if https:// URLs are not supported
#source("https://bioconductor.org/biocLite.R")
#biocLite("biomaRt")
library(biomaRt) #important to load it after
fileName <- "example_tpm_PC0.001_log2.csv"
#fileName <- "tpm.csv"
annotation("hsapiens_gene_ensembl",fileName,fileout)


library(ggplot2)
library(reshape)
data_melted <- melt(tpmlog)
p <- ggplot(data_melted,aes(x=value, col= variable)) + geom_density() + theme_bw() + theme(legend.position = "None")
plot(p)

##if you want to save the plot in a pdf file - uncomment the following
pdf("density_plot_PC0.001.pdf")
plot(p)
dev.off()
