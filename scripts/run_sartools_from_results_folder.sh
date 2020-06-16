


singularity exec ../scripts/tutorial_latest.sif R --vanilla -f ../scripts/makeSartoolsTemp.txt
singularity exec ../scripts/tutorial_latest.sif R --vanilla -f ../scripts/step5_transformAnnotate_tpm.R
singularity exec ../scripts/tutorial_latest.sif R --vanilla -f ../scripts/step6_dedup.R

