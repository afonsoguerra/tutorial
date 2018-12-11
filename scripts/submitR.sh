#!/bin/bash
#$ -S /bin/bash
#$ -o /home/smgxcv0/tutorial/results/out
#$ -e /home/smgxcv0/tutorial/results/error
#$ -wd /home/smgxcv0/tutorial/results
#$ -l tmem=3.1G,h_vmem=3.1G
#$ -l h_rt=12:00:00
#$ -V
#$ -R y

cd /home/smgxcv0/tutorial/results/
/share/apps/R-3.5.1/bin/R --slave CMD BATCH --no-save --no-restore  ../scripts/processing_rnaseq_step2.r R_step.out
