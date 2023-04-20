#!/usr/bin/env -S Rscript --vanilla

# Description: Assign sex from mapping ratio against W and Z chromosomes
#
# Usage: ./determine-sex.R folder-with-bamstats-files
#
# Input: .bam.stats files. Should be the output from (example):
#
#     mkdir -p folder-with-bamstats-files
#     for f in $(find /path/to/folder/with/bamfiles/and/bamindexes); do
#       g=$(basename "$f");
#       samtools idxstats "$f" > folder-with-bamstats-files/"$g".stats
#     done
#
# Output: per-scaffold-read-mappings.tsv
#         Estimated-sex.tsv

# Expect one argument: folder name or "-h"/"--help"
args <- commandArgs(TRUE)

if (length(args) == 0) {
    stop("Error: No input path to .bam.stats files", call. = FALSE)
}

if ("-h" %in% args || "--help" %in% args) {
    cat("Usage: determine-sex.R /path/to/bam.stats/folder", "\n")
    quit(save = "no")
}

bamstatspath <- args[1]
cat(paste0("Reading bam.stats files in folder ", bamstatspath, "\n"))

suppressPackageStartupMessages({
  library("dplyr")
  library("tidyr")
})

# Read in the data for all the files, and create a new df with
# sample-name/filename as extra column.
filenames <- list.files(path = bamstatspath, pattern = ".bam.stats",
                        full.names = TRUE)

my.df <- do.call(rbind,
                 lapply(filenames, function(x) 
                   cbind(read.delim(x, stringsAsFactors = FALSE, header = FALSE),
                         name = tools::file_path_sans_ext(basename(x)))))

my.df$name <- as.character(my.df$name)

# Pivot the DF & modify to get per sample read mappings for each reference
# sequence which is then outputted as well.
my.df1 <- my.df %>%
    select(V1, V3, name) %>%
    tidyr::spread(key = "name", value = "V3", fill = 0)

temp <- my.df %>%
    select(V1, V2) %>%
    distinct(V1, V2)

new.df <- merge(x = temp, y = my.df1, by = "V1")

colnames(new.df)[1:2] <- c("Scaffold-name", "Scaffold-length")

write.table(x = new.df, file = "per-scaffold-read-mappings.txt",
            quote = FALSE, row.names = FALSE, col.names = TRUE, sep = "\t")

# Extract chrW and chrZ in the new df and calculate the ratio of reads in
# W/reads in Z. Also calcualte the ratio of lengths of chrW/chrZ which is the
# threshold for decision.
new.df1 <- new.df[new.df$'Scaffold-name' %in%
                  c("chrW", "chrZ"), 2:ncol(new.df)] %>% t()

colnames(new.df1) <- c("chrW", "chrZ")

new.df1 <- as.data.frame(new.df1)

new.df1$proportion <- new.df1$chrW/new.df1$chrZ

threshold <- new.df1["Scaffold-length", "proportion"]

new.df1 <- new.df1[-1, ]

# Based on comparison with threshold, decide for each sample if it is male of
# female and output to file
new.df1$sex <- ifelse(new.df1$proportion < threshold, "Male",
                      ifelse(new.df1$proportion > threshold, "Female", "Same"))

write.table(x = new.df1, file = "Estimated-sex.txt",
            quote = FALSE, sep = "\t", row.names = TRUE, col.names = TRUE)

cat("End of script", "\n")
