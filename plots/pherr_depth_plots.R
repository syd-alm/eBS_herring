### from Laura Timm ####

# set up R
packages_needed <- c("dplyr", "tidyverse", "ggplot2", "readxl", "RColorBrewer", "ggpubr", "stats")

for(i in 1:length(packages_needed)){
  if(!(packages_needed[i] %in% installed.packages())){install.packages(packages_needed[i])}
  library(packages_needed[i], character.only = TRUE)
}

library(readxl)

setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output")

###########################################################################################################################

# set paths to run locally
BASEDIR <- "/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/" #the directory where the metadata file lives
PREFIX <- "pherr" #the prefix for the lcWGS run
METADATAFILE <- paste0(BASEDIR, "BS_metadata.xlsx") #metadatafile name (excel file)
SHEET <- "biometric_metadata" #sheet containing the pertinent metadata
FEATURE_NAME <- "Location" #column name (in the metadata file) that contains the categorical variable you want to compare depth across (batch, region, sex, etc)
DEPTH_LOWER_BOUND <- 1 #this is the default, but feel free to tune as desired


# prepare data
  # full_metadata <- read_xlsx(METADATAFILE, sheet = SHEET)
full_metadata <- read_xlsx("BS_metadata.xlsx", sheet = "biometric_metadata")

features_df <- full_metadata[c("pherr_depths_BS.csv", FEATURE_NAME)]

#just_depths <- read.csv(paste0(BASEDIR, PREFIX, "_depths_BS.csv"), header = TRUE)
just_depths <- read.csv("pherr_depths_BS.csv", header = TRUE)
just_depths <- just_depths[-c(3:8)]
  # to remove extra stuff that was in the depths.csv file 
colnames(just_depths) <- c("sample_name", "mean_depth")

# join depths file and metadata file by sample name (must match)
depths_df <- left_join(full_metadata, just_depths, by = "sample_name")

###########################################################################################################################

# average depth plot, ordered by depth and colored by location 
ggplot(data = depths_df, aes(x = reorder(sample_name, -mean_depth), y = mean_depth, fill = Location)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  xlab("individual") +
  ylab("mean depth") +
  geom_hline(yintercept = DEPTH_LOWER_BOUND) +
  theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(), axis.text.x = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

ggsave(paste0(BASEDIR, PREFIX, "-", FEATURE_NAME, "_mean_depths.jpg"), width = 8, height = 5, units = "in", dpi = 300)


# average depth organized by pop, not depth
ggplot(data = depths_df, aes(x = sample_name, y = mean_depth, fill = Location)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  xlab("individual") +
  ylab("mean depth") +
  geom_hline(yintercept = DEPTH_LOWER_BOUND) +
  theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(), axis.text.x = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))


# average depth line plot 
  ## good = all locations following the same depth distribution curve 
(depths_dists_plot <- ggplot(depths_df, aes(x = mean_depth, color = Location)) +
    geom_density(n = 50, linewidth = 1) +
    geom_vline(aes(xintercept = DEPTH_LOWER_BOUND), colour = "black") +
    ggtitle("individual mean sequence depth distributions"))

ggsave(paste0(BASEDIR, PREFIX, "_region_mean_depths.jpg"), width = 8, height = 5, units = "in", dpi = 300)
