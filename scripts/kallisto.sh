#STEP1 create index if neeeded 
#STEP2 mapping to kallisto
for sample in `cat data/samples.tab`; do
    echo $sample
mkdir /home/REPLACEMEbyCSUSERNAME/tutorial/results/
mkdir /home/REPLACEMEbyCSUSERNAME/tutorial/results/${sample}
mkdir /home/REPLACEMEbyCSUSERNAME/tutorial/results/${sample}/cluster

REF=/home/REPLACEMEbyCSUSERNAME/tutorial/ref/Human_rel95_ref.index
#REF=/home/REPLACEMEbyCSUSERNAME/tutorial/ref/Zebrafish_rel97_ref.index

        echo "

#!/bin/bash -l
#$ -S /bin/bash
#$ -o /home/REPLACEMEbyCSUSERNAME/tutorial/results/${sample}/cluster/out
#$ -e /home/REPLACEMEbyCSUSERNAME/tutorial/results/${sample}/cluster/error
#$ -l h_rt=03:00:00
#$ -l tmem=11.9G,h_vmem=11.9G
#$ -N  kallisto
#$ -wd  /home/REPLACEMEbyCSUSERNAME/tutorial/results/${sample}
#$ -V
#$ -R y


/share/apps/kallisto-0.46.0 quant -i ${REF} -b 5 -o /home/REPLACEMEbyCSUSERNAME/tutorial/results/${sample} /home/REPLACEMEbyCSUSERNAME/tutorial/data/${sample}_R1*.fastq.gz /home/REPLACEMEbyCSUSERNAME/tutorial/data/${sample}_R2*.fastq.gz

" > /home/REPLACEMEbyCSUSERNAME/tutorial/results/$sample/cluster/${sample}_kallisto.sh

     qsub /home/REPLACEMEbyCSUSERNAME/tutorial/results/$sample/cluster/${sample}_kallisto.sh

done 




