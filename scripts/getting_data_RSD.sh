
ssh -N -f -L3333:ssh.rd.ucl.ac.uk:22 smgxcv0@socrates.ucl.ac.uk
rsync -rav --include-from=/home/smgxcv0/tutorial/data/samples_todownload.tab --exclude="**" -e "ssh -p 3333" smgxcv0@localhost:/rd/live/ritd-ag-project-rd002u-mnour10/RNAseq/fastq/ /home/smgxcv0/tutorial/data/
