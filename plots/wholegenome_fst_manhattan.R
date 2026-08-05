# set up R
setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/wholegenome_fst")

library(readr)
library(dplyr)
library(ggplot2)
library(purrr)
library(qqman)
library(cowplot)

# read in chromosome list 
chroms <- as.data.frame(read.csv("chromosome_list_clupal.csv"))
# make sure that numbered column in chromosome list (header for 1,2,3,...) is CHR for easier use with qqman

###################
# manhattan plot function 
#########################
manhattan_plot <- function(manhattan_format,title) {
  # plot data
  manhattan_plot <- ggplot(manhattan_format, aes(x=midposcum, y=fst)) +
    geom_point(aes(color=as.factor(CHR)), alpha=0.9, size=1.2) +
    scale_color_manual(values = rep(c("#183059", "#8c8c8c"), 26 )) +
    # custom X axis:
    scale_x_continuous(label = axisdf$CHR, 
                       breaks= axisdf$center, 
                       expand = c(0, 0))+  # remove space between the y-axis and the first chromosome ) +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +     # remove space between plot area and x axis
    ggtitle(title)+
    labs(
      x = "Chromosome",  
      y = expression(italic(F)[ST]))+
    theme_bw() +
    theme( 
      legend.position="none",
      plot.title = element_text(hjust = 0.5),
      panel.border = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(), 
      axis.text.x = element_text(angle = 0, hjust = 0.5, size = 10, color = "black"),
      axis.text.y = element_text(size = 10,  hjust = 1, color = "black"),
      axis.line = element_line(color = "#656464")  # add axis lines
    )
  manhattan_plot
}

#######################################################
## EBS SPAWNING POPS
#######################################################
# EBS vs KZ popARRAY
############
### calculated by chrom, concatenate
ebs.kz <- as.data.frame(read_delim("EBS-Kotzebue.fst.txt", 
                                   skip = 1, 
                                   col_types = cols(), 
                                   col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                   delim = "\t"))

# filter out sites <0, make MB pos column 
ebs.kz <- ebs.kz %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ebs.kz <- left_join(ebs.kz, chroms, by = "chr")

# subsample and test for faster plotting 
#ebs.kz_subsample <- ebs.kz %>% sample_n(1000)
###########
# EBS vs UA popARRAY
##########
ebs.ua <- as.data.frame(read_delim("EBS-Unalaska.fst.txt", 
                                   skip = 1, 
                                   col_types = cols(), 
                                   col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                   delim = "\t"))
# filter out sites <0, make MB pos column 
ebs.ua <- ebs.ua %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)
# add chroms to fst dataframe
ebs.ua <- left_join(ebs.ua, chroms, by = "chr")
# format data 
ebs.ua <- ebs.ua %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ebs.ua, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ebs.ua %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

### plot with ggplot
ebs.ua.ggplot <- manhattan_plot(ebs.ua, "EBS - Unalaska")
ebs.ua.ggplot
### plot with qqman package 
ebs_ua_manhattan <- manhattan(ebs.ua, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                              main = "EBS - Unalaska",
                              logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

############# 
# format data
# from https://r-graph-gallery.com/101_Manhattan_plot.html 
# would be great to have this as a loop or function!! (can't figure it out lol)
###############
# format data 
ebs.kz <- ebs.kz %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ebs.kz, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ebs.kz %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

# plot data
ebs.kz.subsample.ggplot <- manhattan_plot(ebs.kz_subsample, "EBS - Kotzebue subsample")
ebs.kz.ggplot <- manhattan_plot(ebs.kz, "EBS - Kotzebue")

### plot with qqman package 
ebs_kz_qqman <- manhattan(ebs.kz, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                          main = "EBS - Kotzebue",
                          logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# KZ vs NI popARRAY
############
kz.ni <- as.data.frame(read_delim("Kotzebue-NelsonIsland.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
kz.ni <- kz.ni %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
kz.ni <- left_join(kz.ni, chroms, by = "chr")
# format data
kz.ni <- kz.ni %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(kz.ni, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = kz.ni %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
kz.ni.ggplot <- manhattan_plot(kz.ni, "Kotzebue - Nelson Island")
kz.ni.ggplot
### plot with qqman package 
kz.ni.manhattan <- manhattan(kz.ni, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Kotzebue - Nelson Island",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))
###########
# KZ vs NS popARRAY
############
kz.ns <- as.data.frame(read_delim("Kotzebue-NortonSound.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
kz.ns <- kz.ns %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
kz.ns <- left_join(kz.ns, chroms, by = "chr")
# format data
kz.ns <- kz.ns %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(kz.ns, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = kz.ns %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
kz.ns.ggplot <- manhattan_plot(kz.ns, "Kotzebue - Norton Sound")
kz.ns.ggplot
### plot with qqman package 
kz.ns.manhattan <- manhattan(kz.ns, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Kotzebue - Norton Sound",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))
###########
# KZ vs NS popARRAY
############
kz.ns <- as.data.frame(read_delim("Kotzebue-NortonSound.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
kz.ns <- kz.ns %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
kz.ns <- left_join(kz.ns, chroms, by = "chr")
# format data
kz.ns <- kz.ns %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(kz.ns, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = kz.ns %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
kz.ns.ggplot <- manhattan_plot(kz.ns, "Kotzebue - Norton Sound")
kz.ns.ggplot
### plot with qqman package 
kz.ns.manhattan <- manhattan(kz.pm, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Kotzebue - Norton Sound",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# KZ vs TG popARRAY
############
kz.tg <- as.data.frame(read_delim("Kotzebue-Togiak.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
kz.tg <- kz.tg %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
kz.tg <- left_join(kz.tg, chroms, by = "chr")
# format data
kz.tg <- kz.tg %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(kz.tg, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = kz.tg %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
kz.tg.ggplot <- manhattan_plot(kz.tg, "Kotzebue - Togiak")
kz.tg.ggplot
### plot with qqman package 
kz.tg.manhattan <- manhattan(kz.ni, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Kotzebue - Togiak",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# KZ vs PM popARRAY
############
kz.pm <- as.data.frame(read_delim("Kotzebue-PortMoller.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
kz.pm <- kz.pm %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
kz.pm <- left_join(kz.pm, chroms, by = "chr")
# format data
kz.pm <- kz.pm %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(kz.pm, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = kz.pm %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
kz.pm.ggplot <- manhattan_plot(kz.pm, "Kotzebue - Port Moller")
kz.pm.ggplot
### plot with qqman package 
kz.pm.manhattan <- manhattan(kz.pm, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Kotzebue - Port Moller",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

############
###########
# KZ vs GB popARRAY
##########
gb.kz <- as.data.frame(read_delim("GoodnewsBay-Kotzebue.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))
# filter out sites <0, make MB pos column 
gb.kz <- gb.kz %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)
# add chroms to fst dataframe
gb.kz <- left_join(gb.kz, chroms, by = "chr")
# format data 
gb.kz <- gb.kz %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(gb.kz, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = gb.kz %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

### plot with ggplot
gb.kz.ggplot <- manhattan_plot(gb.kz, "Kotzebue - Goodnews Bay")
gb.kz.ggplot
### plot with qqman package 
gb_kz_manhattan <- manhattan(gb.kz, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Kotzebue - Goodnews Bay",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))




###########
# GB vs NI popARRAY
############
gb.ni <- as.data.frame(read_delim("GoodnewsBay-NelsonIsland.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
gb.ni <- gb.ni %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
gb.ni <- left_join(gb.ni, chroms, by = "chr")
# format data
gb.ni <- gb.ni %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(gb.ni, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = gb.ni %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
gb.ni.ggplot <- manhattan_plot(gb.ni, "Goodnews Bay - Nelson Island")
gb.ni.ggplot
### plot with qqman package 
gb.ni.manhattan <- manhattan(gb.ni, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Goodnews Bay - Nelson Island ",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# GB vs PM popARRAY
############
gb.pm <- as.data.frame(read_delim("GoodnewsBay-PortMoller.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
gb.pm <- gb.pm %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
gb.pm <- left_join(gb.pm, chroms, by = "chr")
# format data
gb.pm <- gb.pm %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(gb.pm, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = gb.pm %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
gb.pm.ggplot <- manhattan_plot(gb.pm, "Goodnews Bay - Port Moller")
gb.pm.ggplot
### plot with qqman package 
gb.pm.manhattan <- manhattan(gb.pm, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Goodnews Bay - Port Moller ",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# GB vs NS popARRAY
############
gb.ns <- as.data.frame(read_delim("GoodnewsBay-NortonSound.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
gb.ns <- gb.ns %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
gb.ns <- left_join(gb.ns, chroms, by = "chr")
# format data
gb.ns <- gb.ns %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(gb.ns, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = gb.ns %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
gb.ns.ggplot <- manhattan_plot(gb.ns, "Goodnews Bay - Norton Sound")
gb.ns.ggplot
### plot with qqman package 
gb.ns.manhattan <- manhattan(gb.pm, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Goodnews Bay - Norton Sound ",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))
###########
# GB vs TG popARRAY
############
gb.tg <- as.data.frame(read_delim("GoodnewsBay-Togiak.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
gb.tg <- gb.tg %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
gb.tg <- left_join(gb.tg, chroms, by = "chr")
# format data
gb.tg <- gb.tg %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(gb.tg, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = gb.tg %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
gb.tg.ggplot <- manhattan_plot(gb.tg, "Goodnews Bay - Togiak")
gb.tg.ggplot
### plot with qqman package 
gb.tg.manhattan <- manhattan(gb.tg, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Goodnews Bay - Togiak ",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# NI vs NS popARRAY
############
ni.ns <- as.data.frame(read_delim("NelsonIsland-NortonSound.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ni.ns <- ni.ns %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ni.ns <- left_join(ni.ns, chroms, by = "chr")
# format data
ni.ns <- ni.ns %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ni.ns, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ni.ns %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ni.ns.ggplot <- manhattan_plot(ni.ns, "Nelson Island - Norton Sound")
ni.ns.ggplot
### plot with qqman package 
ni.ns.manhattan <- manhattan(ni.ns, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Nelson Island - Norton Sound",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))



###########
# NI vs PM popARRAY
############
ni.pm <- as.data.frame(read_delim("NelsonIsland-PortMoller.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ni.pm <- ni.pm %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ni.pm <- left_join(ni.pm, chroms, by = "chr")
# format data
ni.pm <- ni.pm %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ni.pm, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ni.pm %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ni.pm.ggplot <- manhattan_plot(ni.pm, "Nelson Island - Port Moller")
ni.pm.ggplot
### plot with qqman package 
ni.pm.manhattan <- manhattan(ni.ns, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Nelson Island - Norton Sound",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))
###########
# NI vs TG popARRAY
############
ni.tg <- as.data.frame(read_delim("NelsonIsland-Togiak.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ni.tg <- ni.tg %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ni.tg <- left_join(ni.tg, chroms, by = "chr")
# format data
ni.tg <- ni.tg %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ni.tg, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ni.tg %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ni.tg.ggplot <- manhattan_plot(ni.tg, "Nelson Island - Togiak")
ni.tg.ggplot
### plot with qqman package 
ni.tg.manhattan <- manhattan(ni.tg, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Nelson Island - Togiak",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# NS vs TG popARRAY
############
ns.tg <- as.data.frame(read_delim("NortonSound-Togiak.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ns.tg <- ns.tg %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ns.tg <- left_join(ns.tg, chroms, by = "chr")
# format data
ns.tg <- ns.tg %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ns.tg, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ns.tg %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ns.tg.ggplot <- manhattan_plot(ns.tg, "Norton Sound - Togiak")
ns.tg.ggplot
### plot with qqman package 
ns.tg.manhattan <- manhattan(ns.tg, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Norton Sound - Togiak",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# NS vs PM popARRAY
############
ns.pm <- as.data.frame(read_delim("NortonSound-PortMoller.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ns.pm <- ns.pm %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ns.pm <- left_join(ns.pm, chroms, by = "chr")
# format data
ns.pm <- ns.pm %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ns.pm, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ns.pm %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ns.pm.ggplot <- manhattan_plot(ns.pm, "Norton Sound - Port Moller")
ns.pm.ggplot
### plot with qqman package 
ns.tg.manhattan <- manhattan(ns.pm, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Norton Sound - Port Moller",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))

###########
# PM vs TG popARRAY
############
pm.tg <- as.data.frame(read_delim("PortMoller-Togiak.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
pm.tg <- pm.tg %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
pm.tg <- left_join(pm.tg, chroms, by = "chr")
# format data
pm.tg <- pm.tg %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(pm.tg, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = pm.tg %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
pm.tg.ggplot <- manhattan_plot(pm.tg, "Port Moller - Togiak")
pm.tg.ggplot
### plot with qqman package 
ns.tg.manhattan <- manhattan(ns.tg, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Norton Sound - Togiak",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))


#############
# Unalaska
#############
###########
# UA vs GB popARRAY
############
ua.gb <- as.data.frame(read_delim("GoodnewsBay-Unalaska.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ua.gb <- ua.gb %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ua.gb <- left_join(ua.gb, chroms, by = "chr")
# format data
ua.gb <- ua.gb %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ua.gb, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ua.gb %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ua.gb.ggplot <- manhattan_plot(ua.gb, "Unalaska - Goodnews Bay")
ua.gb.ggplot
### plot with qqman package 
ua.gb.manhattan <- manhattan(ua.gb, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Unalaska - Goodnews Bay",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))




###########
# UA vs PM popARRAY
############
ua.pm <- as.data.frame(read_delim("PortMoller-Unalaska.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ua.pm <- ua.pm %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ua.pm <- left_join(ua.pm, chroms, by = "chr")
# format data
ua.pm <- ua.pm %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ua.pm, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ua.pm %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ua.pm.ggplot <- manhattan_plot(ua.pm, "Unalaska - Port Moller")
ua.pm.ggplot
### plot with qqman package 
ua.pm.manhattan <- manhattan(ua.pm, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Unalaska - Port Moller",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))





###########
# UA vs TG popARRAY
############
ua.tg <- as.data.frame(read_delim("Togiak-Unalaska.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ua.tg <- ua.tg %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ua.tg <- left_join(ua.tg, chroms, by = "chr")
# format data
ua.tg <- ua.tg %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ua.tg, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ua.tg %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ua.tg.ggplot <- manhattan_plot(ua.tg, "Unalaska - Togiak")
ua.tg.ggplot
### plot with qqman package 
ua.tg.manhattan <- manhattan(ua.tg, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Unalaska - Togiak",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))
###########
# UA vs NS popARRAY
############
ua.ns <- as.data.frame(read_delim("NortonSound-Unalaska.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ua.ns <- ua.ns %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ua.ns <- left_join(ua.ns, chroms, by = "chr")
# format data
ua.ns <- ua.ns %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ua.ns, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ua.ns %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ua.ns.ggplot <- manhattan_plot(ua.ns, "Unalaska - Norton Sound")
ua.ns.ggplot
### plot with qqman package 
ua.ns.manhattan <- manhattan(ua.ns, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Unalaska - Norton Sound",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))
###########
# UA vs NI popARRAY
############
ua.ni <- as.data.frame(read_delim("NelsonIsland-Unalaska.fst.txt", 
                                  skip = 1, 
                                  col_types = cols(), 
                                  col_names = c("region", "chr", "midpos", "nsites", "fst"), 
                                  delim = "\t"))

# filter out sites <0, make MB pos column 
ua.ni <- ua.ni %>% 
  filter(fst >= 0) %>%
  mutate(midpos_Mb = midpos / 1000000)

# add chroms to fst dataframe
ua.ni <- left_join(ua.ni, chroms, by = "chr")
# format data
ua.ni <- ua.ni %>% 
  # Compute chromosome size
  group_by(CHR) %>% 
  summarise(chr_len=max(midpos)) %>% 
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  # Add this info to the initial dataset
  left_join(ua.ni, ., by=c("CHR"="CHR")) %>%
  # Add a cumulative position of each SNP
  arrange(CHR, midpos) %>%
  mutate(midposcum=midpos+tot)
axisdf = ua.ni %>%
  group_by(CHR) %>%
  summarize(center=( max(midposcum) + min(midposcum) ) / 2 )

## plot with ggplot
ua.ni.ggplot <- manhattan_plot(ua.ni, "Unalaska - Nelson Island")
ua.ni.ggplot
### plot with qqman package 
ua.ni.manhattan <- manhattan(ua.ni, chr = "CHR", bp = "midpos", p = "fst", snp = "nsites", 
                             main = "Unalaska - Nelson Island",
                             logp = FALSE, cex = 0.5, cex.axis = 0.8, ylab=expression(italic(F)[ST]))



##############
# make white placeholder for grid 
make_white_png <- function(width = 848, height = 576) {
  image_blank(width = width, height = height, color = "white")
}
# combine into grid
img1 <- "ebs-ua_fst_manhat.png"
img3 <- "kz-ua_fst_manhat.png"
img2 <- "ebs-kz_fst_manhat.png"

p1 <- ggdraw() + draw_image(img1)
p2 <- ggdraw() + draw_image(img2)
p3 <- ggdraw() + draw_image(img3)

grid <- plot_grid(
  p1, p2, p3,
  ncol = 1,
  hjust = -22,
  labels = c("A", "B", "C"),
  label_fontface = "bold"
)
