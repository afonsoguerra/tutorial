#!/bin/bash -l
#$ -S /bin/bash
#$ -o /home/REPLACEMEbyCSUSERNAME/tutorial/ref/cluster/out
#$ -e /home/REPLACEMEbyCSUSERNAME/tutorial/ref/cluster/error
#$ -l h_rt=04:00:00
#$ -pe smp 4
#$ -l tmem=2.9G,h_vmem=2.9G
#$ -N  making_index_kallisto



#FASTA=/home/REPLACEMEbyCSUSERNAME/tutorial/data/Homo_sapiens.GRCh38_rel95.cdna.all.fa.gz
FASTA=/home/REPLACEMEbyCSUSERNAME/tutorial/data/Danio_rerio.GRCz11.cdna.all.fa.gz
#OUT=/home/REPLACEMEbyCSUSERNAME/tutorial/ref/Human_rel95_ref.index
OUT=/home/REPLACEMEbyCSUSERNAME/tutorial/ref/Zebrafish_rel97_ref.index

/share/apps/kallisto-0.46.0  index -i $OUT $FASTA
