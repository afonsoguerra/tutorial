


singularity exec ../scripts/tutorial_latest.sif R --vanilla -f ../scripts/extraStep_05_makeSARtools_input.R
singularity exec ../scripts/tutorial_latest.sif R --vanilla -f ../scripts/extraStep_06_Annotate_TPM_matrix.R
singularity exec ../scripts/tutorial_latest.sif R --vanilla -f ../scripts/extraStep_07_deduplicate_TPM.R

