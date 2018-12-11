#!/bin/bash -l
#$ -S /bin/bash
#$ -o /home/smgxcv0/tutorial/ref/cluster/out
#$ -e /home/smgxcv0/tutorial/ref/cluster/error
#$ -l h_rt=04:00:00
#$ -pe smp 4
#$ -l tmem=2.9G,h_vmem=2.9G
#$ -N  making_index_kallisto



FASTA=/home/smgxcv0/tutorial/data/Homo_sapiens.GRCh38_rel94.cdna.all.fa.gz
OUT=/home/smgxcv0/tutorial/ref/Human_ref.index

/share/apps/genomics/kallisto-0.44/bin/kallisto index -i $OUT $FASTA
