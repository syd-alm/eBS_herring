## count reads in raw and trimmed .fastq files
# use with count_reads.sh scripts
# generated with Copilot 

setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output")

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(scales)


########
# raw reads plot
########

# read the CSV file
raw_reads_count <- read.csv("raw_read_counts.csv", header = FALSE)

# rename columns and add pop column
#
colnames(raw_reads_count) <- c("sample", "raw_reads")
#raw_reads_count$pop <- rep(c("CB", "PM"), each = 20)
raw_reads_count$pop <- rep(c("KZ", "UA", "CB", "GB", "JP", "KB", "NI", "NS", "PM"), each = 40)

# keep just sample ID from file name 
raw_reads_count$sample <- sub("_.*", "", raw_reads_count$sample)

# plot raw reads count
ggplot(raw_reads_count, aes(x = sample, y = raw_reads, fill = pop)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_y_continuous(labels = comma) +
  labs(title = "raw read count", x = "File Name", y = "Read Count")

# total raw reads
total_reads <- sum(raw_reads_count$raw_reads, na.rm = TRUE)
print(total_reads)
  # 5,156,360,904 for TG & CD
  # 4,570,169,504 for CB and PM

######
# trimmed reads plot
######
trimmed_reads_count <- read.csv("read_counts_TG_CB_trimmed.csv")

# Rename the columns
colnames(trimmed_reads_count) <- c("sample", "trimmed_reads")

# Separate the data into paired and unpaired files
paired_data <- trimmed_reads_count %>% filter(grepl("_paired.fq.gz$", sample))
unpaired_data <- trimmed_reads_count %>% filter(grepl("_unpaired.fq.gz$", sample))

# Plot paired data
ggplot(paired_data, aes(x = sample, y = trimmed_reads)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_y_continuous(labels = comma) +
  labs(title = "trimmed read counts", x = "Sample", y = "Reads")

# Save the paired plot to a file
ggsave("paired_read_counts_plot.png", plot = paired_plot)

# Plot unpaired data
ggplot(unpaired_data, aes(x = sample, y = trimmed_reads)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "unpaired read count", x = "Sample", y = "Reads")

# Save the unpaired plot to a file
ggsave("unpaired_read_counts_plot.png", plot = unpaired_plot)
