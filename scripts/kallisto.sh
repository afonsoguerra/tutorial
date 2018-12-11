#STEP1 create index if neeeded 
#STEP2 mapping to kallisto
for sample in `cat data/samples.tab`; do
    echo $sample
mkdir /home/smgxcv0/tutorial/results/
mkdir /home/smgxcv0/tutorial/results/${sample}
mkdir /home/smgxcv0/tutorial/results/${sample}/cluster

REF=/home/smgxcv0/tutorial/ref/Human_ref.index

        echo "

#!/bin/bash -l
#$ -S /bin/bash
#$ -o /home/smgxcv0/tutorial/results/${sample}/cluster/out
#$ -e /home/smgxcv0/tutorial/results/${sample}/cluster/error
#$ -l h_rt=03:00:00
#$ -l tmem=11.9G,h_vmem=11.9G
#$ -N  kallisto
#$ -wd  /home/smgxcv0/tutorial/results/${sample}
#$ -V
#$ -R y


/share/apps/genomics/kallisto-0.44/bin/kallisto quant -i ${REF} -b 5 -o /home/smgxcv0/tutorial/results/${sample} /home/smgxcv0/tutorial/data/${sample}*R1*fastq.gz /home/smgxcv0/tutorial/data/${sample}*R2*fastq.gz

" > /home/smgxcv0/tutorial/results/$sample/cluster/${sample}_kallisto.sh

     qsub /home/smgxcv0/tutorial/results/$sample/cluster/${sample}_kallisto.sh

done 




