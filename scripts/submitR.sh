#!/bin/bash
#$ -S /bin/bash
#$ -o /home/REPLACEMEbyCSUSERNAME/tutorial/results/out
#$ -e /home/REPLACEMEbyCSUSERNAME/tutorial/results/error
#$ -wd /home/REPLACEMEbyCSUSERNAME/tutorial/results
#$ -l tmem=3.1G,h_vmem=3.1G
#$ -l h_rt=12:00:00
#$ -V
#$ -R y

cd /home/REPLACEMEbyCSUSERNAME/tutorial/results/
/share/apps/R-3.6.1/bin/R --slave CMD BATCH --no-save --no-restore  ../scripts/processing_rnaseq_step2.r R_step.out
