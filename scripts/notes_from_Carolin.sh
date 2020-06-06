
grep -nH "estimated average fragment length" logfiles/*.log.txt > results/fragLength.csv




Hi Afonso,
 
Could we build into the RNAseq pipeline the extraction of average fragment length, too, please?
I previously did this with the awk command in the email below. I can see that the information is now in the logfiles folders. It would be great if creating an insert_size_summary file could be part of your script 4.
 
Everything else ran smoothly – on 357 samples. Really nice automation – and the fact that we can run so many samples in one go will be saving tonnes of time!
 
Carolin
 
From: Turner, Carolin 
Sent: 05 September 2019 10:49
To: Rosenheim, Joshua <j.rosenheim@ucl.ac.uk>; Chandran, Aneesh <a.chandran@ucl.ac.uk>
Subject: RNAseq data processing
 
Dear both,
 
Here are a couple of command lines that we should include in our default RNAseq pipeline:
 
On the cluster: Hidden in a Kallisto output file is the average fragment size per sample. Since we normally delete all Kallisto output once we’ve created the tpm/cpm/rawcount matrices, this information gets lost. However, it is required when submitting RNAseq data to ArrayExpress (one of the databases where any RNAseq data should be deposited upon publication). I have therefore written a command line that you can run on the cluster once the Kallisto script has finished, and that produces in the results folder a file called ‘insert_size_summary.csv’. Just download together with any other cluster output, forward to end users, who can keep it safe until required upon submission.
 
awk -F '[/ ]' '/pair 1/{sub(/_R1_001.fastq.gz/,"");name=$NF}/average fragment length/{print name"," $NF}' ./results/*/cluster/error >> ./results/insert_size_summary.csv
 
On the Linux computer following demultiplexing: In order to make life easier, and avoid typing errors when filling out the RNAseq data template with sequencing file names, I’ve written another little line that produces a csv file containing all filenames. We can then simply copy and paste from there to the template. This can be run on the Linux computer console once demultiplexing has finished.
 
ls *_R1_001.fastq.gz | sed 's/_R1_001.fastq.gz//' > filenames.csv
 
As always, any questions/problems, please ask! Once the next set of RNAseq data is available, we can also go through these two additions together if you like.
 
Best wishes,
Carolin
 
 
Dr Carolin Turner
Post-Doctoral Research Associate
UCL, Division of Infection and Immunity
Cruciform Building (wing 1.4.07), 90 Gower St, London, WC1E 6BT
 
Working hours
Mon, Tue, Thu: 08.15-12.45
Wed, Fri: 08.45-17.15
 
