
ssh -N -f -L3333:ssh.rd.ucl.ac.uk:22 REPLACEMEbyUCLUSERNAME@socrates.ucl.ac.uk
rsync -rav --include-from=/home/REPLACEMEbyCSUSERNAME/tutorial/data/samples_todownload.tab --exclude="**" -e "ssh -p 3333" REPLACEMEbyUCLUSERNAME@localhost:/rd/live/ritd-ag-project-rd002u-mnour10/RNAseq/fastq/ /home/REPLACEMEbyCSUSERNAME/tutorial/data/
