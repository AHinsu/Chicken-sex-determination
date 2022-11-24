# Chicken-sex-determination
This contains the scripts to determine the sex of chicken from the WGS data. This requires an indexed bam file.


Requirements:
1. An indexed bam files per samples. To check if you  bam files are indexed, look for file with same name as bam file and with extension .bai. The scripts could also run with non-indexed bam files, but it will take more time to complete.
2. Samtools installed in the system and should bea accessed globally.
3. R installed with packages: dplyr and tidyr


Usage:
1. Run the shell script 'calculate-stats.sh' by command "./calculate-stats.sh". This will generated .stats files for each samples.
2. Run the R script 'determine-sex.R'. This will generate a combined per scaffold statistics for all samples and an estimated-sex.txt file.


Note:
1. It is assumed that chromosomes are named as "chr1, chr2,..." and sex chromosomes are "chrW" and "chrZ". These sex chromosomes can be modified for other organisms as well. This could also be checked from the generated per scaffold statistics file.
