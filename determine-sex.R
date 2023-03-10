#!/usr/bin/env Rscript --vanilla

set.seed(100)
#Set working directory
setwd("C:/Users/ahinsu/Downloads/skim-data-pilot")
library("tidyverse")


#Chage the working directory again
filenames <- list.files(path = "C:/Users/ahinsu/Downloads/skim-data-pilot", pattern = ".bam.stats", full.names = TRUE)
# Read in the data for all the files, and create a new df with sample-name/filename as extra column.
my.df <- do.call(rbind,
                 lapply(filenames, function(x) 
                   cbind(read.delim(x, stringsAsFactors = FALSE, header = FALSE), 
                         name = tools::file_path_sans_ext(basename(x)))))
my.df$name <- as.character(my.df$name)

# Pivot the DF & modify to get per sample read mappings for each reference sequence which is then outputted as well.                       
my.df1 <- my.df %>% select(V1, V3, name) %>% tidyr::spread(key = "name", value = "V3", fill = 0)
temp <- my.df %>% select(V1, V2) %>% distinct(V1, V2)
new.df <- merge(x = temp, y = my.df1, by = "V1")
colnames(new.df)[1:2] <- c("Scaffold-name", "Scaffold-length")
write.table(x = new.df, file = "per-scaffold-read-mappings.txt", quote = FALSE, row.names = FALSE, col.names = TRUE, sep = "\t")

# Extract chrW and chrZ in the new df & calculate the ratio of reads in W/reads in Z. Also calucalte the ratio of lengths of chrW/chrZ which is threshold for decision.
new.df1 <- new.df[new.df$Scaffold-name %in% c("chrW", "chrZ"),2:ncol(new.df)] %>% t()
colnames(new.df1) <- c("chrW", "chrZ")
new.df1 <- as.data.frame(new.df1)
new.df1$proporiton <- new.df1$chrW/new.df1$chrZ
threshold <- new.df1["Scaffold-length","proporiton"]
new.df1 <- new.df1[-1,]
# Based on comparison with threshold, decide for each sample if it is male of female and output to file
new.df1$sex <- ifelse(new.df1$proporiton < threshold, "Male", ifelse(new.df1$proporiton > threshold, "Female", "Same"))
write.table(x = new.df1, file = "Estimated-sex.txt", quote = FALSE, sep = "\t", row.names = TRUE, col.names = TRUE)

