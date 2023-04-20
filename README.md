# Chicken-sex-determination

This contains the scripts to determine the sex of chicken from the WGS data.
This requires an indexed bam file.

## Requirements

1. An indexed bam file per sample. To check if your bam files are indexed,
   look for file with same name as bam file and with extension .bai. The
   scripts could also run with non-indexed bam files, but it will take more
   time to complete.
2. Samtools installed (as `samtools`) in the user PATH.
3. R and Rscript installed with packages dplyr and tidyr.

## Usage

1. Run the shell script 'calculate-stats.sh' by command `./calculate-stats.sh`.
   This will generate a .stats file for each sample.
   For more control, one may manually modify and run these commands:

        $ mkdir -p bamstats-folder
        $ bampaths='/path/to/folder/with/bamfiles/and/bamindexes'
        $ for f in $(find "${bampath}" -name '*.bam') ; do
            g=$(basename "$f");
            samtools idxstats --threads 8 "$f" > bamstats-folder/"$g".stats
          done

2. Run the R script 'determine-sex.R': `./determine-sex.R bamstats-folder`.
   This will generate a combined per scaffold statistics for all samples and an
   Estimated-sex.txt file.

## Note

1. It is assumed that chromosomes are named as "chr1, chr2,..." and sex
   chromosomes are "chrW" and "chrZ". These sex chromosomes can be modified for
   other organisms as well. This could also be checked from the generated per
   scaffold statistics file.
