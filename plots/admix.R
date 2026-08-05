
setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/admix")

# install pophelper package
remotes::install_github('royfrancis/pophelper')
library(pophelper)

# libraries needed for grid.arrange
library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)
library(tidyverse)
library(stringr)
library(tidyr)
library(dplyr)
library(readxl)
library(pophelper)
library(ggpubr)

#################################
# from pophelp documentation + Laura's markdown
#################################
## pops need to be in bam order!
pop_all <- c(
  rep("8. Kodiak", 20),
  rep("1. Kotzebue", 19),
  rep("7. Unalaska", 20),
  rep("5. Togiak", 20),
  rep("9. Cordova", 20),
  rep("4. Goodnews Bay", 20),
  rep("3. Nelson Island", 20),
  rep("2. Norton Sound", 20),
  rep("6. Port Moller", 20))

pop_ebs <- c(
  rep("1. Kotzebue", 19),
  rep("5. Togiak", 20),
  rep("4. Goodnews Bay", 20),
  rep("3. Nelson Island", 20),
  rep("2. Norton Sound", 20),
  rep("6. Port Moller", 20))

Location <- data.frame(Population = pop_all)
pop_ebs <- data.frame(pop_ebs = pop_ebs)

Population <- data.frame(pop_all, stringsAsFactors = F)
pop_ebs <- data.frame(pop_ebs, stringsAsFactors = F)

#clustercol=c("#3288BD","#D53E4F","#8c86d2","#ABDDA4","#f18ea4","#FDAE61","#E6F598","#33a02c","#16D1E9"),


################
# all pops, linked, 0 replicate 
################
all_linked_slist <- list.files(path="/all_linked", pattern="-0.qopt", full.names=TRUE)
# read in string list of all files

# turn strings into Q list that pophelper can read 
all_linked_qlist <- readQ(all_linked_slist)

# this will plot everything in it's own png
#plotQ(qlist=qlist, exportpath=getwd())

# ! has to be in same order that it is in the bamlist that made the beagle file!

# make K = label list 
all_k_list <- rep(2:5) # change for K values and replicate values 
#all_k_list <- rep(1:7, each = 3) remove each= if no replicates 
all_k_list <- paste("K =", all_k_list)

# plots all replicates for k = whatever 
all_linked <- plotQ(alignK(qlist=all_linked_qlist),
                      grplab = Location,
                      clustercol=c("#3288BD","#D53E4F","#8c86d2","#ABDDA4","#f18ea4","#FDAE61","#E6F598","#33a02c","#16D1E9"),
                      #subsetgrp=c("Kodiak", "Kotzebue","Norton Sound","Nelson Island", "Goodnews Bay", "Togiak", "Cordova", Port Moller", "Unalaska"),
                      ordergrp = T,  
                      #selgrp = cluster_id$cluster, 
                      showlegend=F, legendpos="right",
                      showsp = T, 
                      splab=all_k_list, splabcol="black",spbgcol="white", splabsize = 10,    # K= text size/color, background 
                      barbordersize = 0.3, barbordercolour = "darkgrey",
                      divsize = 0.5, divcol = "lightgrey", divtype=1,      #divider color, size, line
                      grplabangle = 0,grplabcol = "black",grplabpos = 0.6, grplabheight = 2, grplabjust = 0.5, grplabsize = 4,  # bottom group label settings
                      pointbgcol = "lightgrey",
                      panelratio = c(2,2),
                      indlabsize= 4,
                      #bindlabwithgrplab=T,
                      showticks=F,
                      showyaxis = F,
                      panelspacer=0.15,     # changes how far apart strip panels are
                      imgoutput = "join",
                      returnplot = T,
                      exportplot = F,
                      showdiv= T,
                      sortind = "all",   # sorts bars in descending order
                      sharedindlab = F,
                      #showindlab=F,
                      imgtype = "jpeg",
                      width = 12,
                      height = 6,
                      units = "in",
                      dpi = 600)
# to arrange all outputs in a grid
all_linked_k1_7_plot <- grid.arrange(all_linked$plot[[1]])


############### 
# all unlinked, K=2-5, only 1 replicate 
###############
all_unlinked_slist <- list.files(path="all_unlinked/k2_5_unlinked_rep0", pattern="-0.qopt", full.names=TRUE)
all_unlinked_qlist <- readQ(all_unlinked_slist)

all_unlinked <- plotQ(alignK(qlist=all_unlinked_qlist),
                   grplab = Population,
                   clustercol=c("#3343F5","#FF5600","#E1F1F5","#518CF0","#FFCD77"),
                   #subsetgrp=c("Kodiak", "Kotzebue","Norton Sound","Nelson Island", "Goodnews Bay", "Togiak", "Cordova", Port Moller", "Unalaska"),
                   ordergrp = T,  
                   #selgrp = cluster_id$cluster, 
                   showlegend=F, legendpos="right",
                   showsp = T, 
                   splab=all_k_list, splabcol="black",spbgcol="white", splabsize = 10,    # K= text size/color, background 
                   barbordersize = 0.3, barbordercolour = "darkgrey",
                   divsize = 0.5, divcol = "lightgrey", divtype=1,      #divider color, size, line
                   grplabangle = 0,grplabcol = "black",grplabpos = 0.6, grplabheight = 2, grplabjust = 0.5, grplabsize = 4,  # bottom group label settings
                   pointbgcol = "lightgrey",
                   panelratio = c(2,2),
                   indlabsize= 4,
                   #bindlabwithgrplab=T,
                   showticks=F,
                   showyaxis = F,
                   panelspacer=0.15,     # changes how far apart strip panels are
                   imgoutput = "join",
                   returnplot = T,
                   exportplot = F,
                   showdiv= T,
                   sortind = "all",   # sorts bars in descending order
                   sharedindlab = F,
                   #showindlab=F,
                   imgtype = "jpeg",
                   width = 12,
                   height = 6,
                   units = "in",
                   dpi = 600)
# to arrange all outputs in a grid
all_unlinked_plot <- grid.arrange(all_unlinked$plot[[1]])

############### 
# EBS linked, K=1-5, only 1 replicate 
###############
ebs_linked_slist <- list.files(path="/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/admix/ebs_linked", pattern="-0.qopt", full.names=TRUE)
ebs_linked_qlist <- readQ(ebs_linked_slist)

# make K = label list 
ebs_k_list <- rep(1:5) # change for K values and replicate values 
ebs_k_list <- paste("K =", ebs_k_list)

ebs_linked <- plotQ(alignK(qlist=ebs_linked_qlist),
                      grplab = pop_ebs,
                      clustercol=c("#D53E4F","#3288BD","#8c86d2","#ABDDA4","#f18ea4","#FDAE61","#E6F598","#33a02c","#16D1E9"),
                      #subsetgrp=c("Kodiak", "Kotzebue","Norton Sound","Nelson Island", "Goodnews Bay", "Togiak", "Cordova", Port Moller", "Unalaska"),
                      ordergrp = T,  
                      #selgrp = cluster_id$cluster, 
                      showlegend=F, legendpos="right",
                      showsp = T, 
                      splab=ebs_k_list, splabcol="black",spbgcol="white", splabsize = 10,    # K= text size/color, background 
                      barbordersize = 0.3, barbordercolour = "darkgrey",
                      divsize = 0.5, divcol = "lightgrey", divtype=1,      #divider color, size, line
                      grplabangle = 0,grplabcol = "black",grplabpos = 0.6, grplabheight = 2, grplabjust = 0.5, grplabsize = 4,  # bottom group label settings
                      pointbgcol = "lightgrey",
                      panelratio = c(2,2),
                      indlabsize= 4,
                      #bindlabwithgrplab=T,
                      showticks=F,
                      showyaxis = F,
                      panelspacer=0.15,     # changes how far apart strip panels are
                      imgoutput = "join",
                      returnplot = T,
                      exportplot = F,
                      showdiv= T,
                      sortind = "all",   # sorts bars in descending order
                      sharedindlab = F,
                      #showindlab=F,
                      imgtype = "jpeg",
                      width = 12,
                      height = 6,
                      units = "in",
                      dpi = 600)
# to arrange all outputs in a grid
ebs_linked_plot <- grid.arrange(ebs_linked$plot[[1]])

############### 
# EBS unlinked, K=1-5, only 1 replicate 
###############
ebs_unlinked_slist <- list.files(path="/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/admix/ebs_unlinked", pattern="-0.qopt", full.names=TRUE)
ebs_unlinked_qlist <- readQ(ebs_unlinked_slist)

ebs_unlinked <- plotQ(alignK(qlist=ebs_unlinked_qlist),
                    grplab = pop_ebs,
                    clustercol=c("#D53E4F","#3288BD","#8c86d2","#ABDDA4","#f18ea4","#FDAE61","#E6F598","#33a02c","#16D1E9"),
                    #subsetgrp=c("Kodiak", "Kotzebue","Norton Sound","Nelson Island", "Goodnews Bay", "Togiak", "Cordova", Port Moller", "Unalaska"),
                    ordergrp = T,  
                    #selgrp = cluster_id$cluster, 
                    showlegend=F, legendpos="right",
                    showsp = T, 
                    splab=ebs_k_list, splabcol="black",spbgcol="white", splabsize = 10,    # K= text size/color, background 
                    barbordersize = 0.3, barbordercolour = "darkgrey",
                    divsize = 0.5, divcol = "lightgrey", divtype=1,      #divider color, size, line
                    grplabangle = 0,grplabcol = "black",grplabpos = 0.6, grplabheight = 2, grplabjust = 0.5, grplabsize = 4,  # bottom group label settings
                    pointbgcol = "lightgrey",
                    panelratio = c(2,2),
                    indlabsize= 4,
                    #bindlabwithgrplab=T,
                    showticks=F,
                    showyaxis = F,
                    panelspacer=0.15,     # changes how far apart strip panels are
                    imgoutput = "join",
                    returnplot = T,
                    exportplot = F,
                    showdiv= T,
                    sortind = "all",   # sorts bars in descending order
                    sharedindlab = F,
                    #showindlab=F,
                    imgtype = "jpeg",
                    width = 12,
                    height = 6,
                    units = "in",
                    dpi = 600)
# to arrange all outputs in a grid
ebs_unlinked_plot <- grid.arrange(ebs_unlinked$plot[[1]])




############### 
# EBS unlinked, K=1-5, 0 replicate 
###############
ebs_unlinked_nix7_nix12_slist <- list.files(path="ebs_kotz_nix7_nix12_unlinked", pattern="-0.qopt", full.names=TRUE)
ebs_unlinked_nix7_nix12_qlist <- readQ(ebs_unlinked_nix7_nix12_slist)

ebs_unlinked_nix7_nix12_plot <- plotQ(alignK(qlist=ebs_unlinked_nix7_nix12_qlist),
                      grplab = pop_ebs,
                      clustercol=c("#D53E4F","#3288BD","#8c86d2","#ABDDA4","#f18ea4","#FDAE61","#E6F598","#33a02c","#16D1E9"),
                      #subsetgrp=c("Kodiak", "Kotzebue","Norton Sound","Nelson Island", "Goodnews Bay", "Togiak", "Cordova", Port Moller", "Unalaska"),
                      ordergrp = T,  
                      #selgrp = cluster_id$cluster, 
                      showlegend=F, legendpos="right",
                      showsp = T, 
                      splab=ebs_k_list, splabcol="black",spbgcol="white", splabsize = 10,    # K= text size/color, background 
                      barbordersize = 0.3, barbordercolour = "darkgrey",
                      divsize = 0.5, divcol = "lightgrey", divtype=1,      #divider color, size, line
                      grplabangle = 0,grplabcol = "black",grplabpos = 0.6, grplabheight = 2, grplabjust = 0.5, grplabsize = 4,  # bottom group label settings
                      pointbgcol = "lightgrey",
                      panelratio = c(2,2),
                      indlabsize= 4,
                      #bindlabwithgrplab=T,
                      showticks=F,
                      showyaxis = F,
                      panelspacer=0.15,     # changes how far apart strip panels are
                      imgoutput = "join",
                      returnplot = T,
                      exportplot = F,
                      showdiv= T,
                      sortind = "all",   # sorts bars in descending order
                      sharedindlab = F,
                      #showindlab=F,
                      imgtype = "jpeg",
                      width = 12,
                      height = 6,
                      units = "in",
                      dpi = 600)
# to arrange all outputs in a grid
ebs_unlinked_nix7_nix12_plot <- grid.arrange(ebs_unlinked_nix7_nix12_plot$plot[[1]])

###################
# get liklihoods 
# from Laura's markdown
###################

## functions
# this uses math to get average absolute distribution of k log values 
opt_k_fx <- function(LOG_FILENAMES, K_VAL) {
  bigData<-lapply(1:length(LOG_FILENAMES), FUN = function(i) readLines(LOG_FILENAMES[i]))
  foundset<-sapply(1:length(LOG_FILENAMES), FUN= function(x) bigData[[x]][which(str_sub(bigData[[x]], 1, 1) == 'b')])
  as.numeric( sub("\\D*(\\d+).*", "\\1", foundset) )
  logs<-data.frame(K = rep(1:K_VAL, each=3))
  logs$like<-as.vector(as.numeric( sub("\\D*(\\d+).*", "\\1", foundset) ))
  tapply(logs$like, logs$K, FUN= function(x) mean(abs(x))/sd(abs(x)))
}


########
# read in files for use with Laura's code 
#######
BASEDIR <- "/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/admixture/ebs_spawning_pops"
ADMIX_PREFIX <- "pherr_wholegenome-polymorphic_"
LOGS_all <- Sys.glob(paste0(BASEDIR, logs))
QOPTS_all <- Sys.glob(paste0(BASEDIR, ADMIX_PREFIX, "*-2.qopt"))  #this changes the replicate #
outname <- paste0(PREFIX, "_K7-admix")

## analyze log files
# read the .txt file containing file names
log_names <- read_lines("log_files.txt")  
# add base directory to each file name
log_names <- file.path(BASEDIR, log_names)
# read each file into R and store them in a list
logs <- lapply(log_names, readLines)

(all_samples_admix_plot <- admix_plot(features_df_all, QOPTS_all, BASEDIR, oname))

likelihoods <- opt_k_fx(log_names, 10)
# give log file names, K value used 

# just extract likelihood value
opt_k_fx_no_math <- function(LOG_FILENAMES, K_VAL) {
  bigData<-lapply(1:length(LOG_FILENAMES), FUN = function(i) readLines(LOG_FILENAMES[i]))
  foundset<-sapply(1:length(LOG_FILENAMES), FUN= function(x) bigData[[x]][which(str_sub(bigData[[x]], 1, 1) == 'b')])
  as.numeric( sub("\\D*(\\d+).*", "\\1", foundset) )
  logs<-data.frame(K = rep(1:K_VAL, each=3))
  logs$like<-as.vector(as.numeric( sub("\\D*(\\d+).*", "\\1", foundset) ))
  tapply(logs$like, logs$K, FUN= function(x)(abs(x)))
}

opt_logs <- opt_k_fx_no_math(log_names, 10)
## second entry will be k=10!! not k=2 (alphabetized)

LOGS_all <- Sys.glob(paste0(BASEDIR, ADMIX_PREFIX_all, "*.log"))
opt_k_fx(LOGS_all, 7)
QOPTS_all <- Sys.glob(paste0(BASEDIR, ADMIX_PREFIX_all, "_*-2.qopt"))
oname <- paste0(PREFIX, "_K7-admix")
(all_samples_admix_plot <- admix_plot(features_df_all, QOPTS_all, BASEDIR, oname))











#############
# plot likelihoods 
#############
BASEDIR <- "/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/admixture/ebs_spawning_pops"
ADMIX_PREFIX <- "pherr_wholegenome-polymorphic_"
LOGS_all <- Sys.glob(paste0(BASEDIR, logs))
QOPTS_all <- Sys.glob(paste0(BASEDIR, ADMIX_PREFIX, "*-2.qopt"))
outname <- paste0(PREFIX, "_K7-admix")

# read in list of files
admix_files <- list.files(path = "/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/admixture/PM_CB_TG", pattern = "*.qopt", full.names = TRUE)
log_files <- list.files(path = "/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/admixture/PM_CB_TG", pattern = "*.log", full.names = TRUE)

## analyze log files
# read the .txt file containing file names
log_names <- read_lines("log_files.txt")  
# add base directory to each file name
log_names <- file.path(BASEDIR, log_names)
# read each file into R and store them in a list
logs <- lapply(log_names, readLines)

(all_samples_admix_plot <- admix_plot(features_df_all, QOPTS_all, BASEDIR, oname))

likelihoods <- opt_k_fx(log_names, 10)
# give log file names, K value used 

# just extract likelihood value, no math
opt_k_fx_no_math <- function(LOG_FILENAMES, K_VAL) {
  bigData<-lapply(1:length(LOG_FILENAMES), FUN = function(i) readLines(LOG_FILENAMES[i]))
  foundset<-sapply(1:length(LOG_FILENAMES), FUN= function(x) bigData[[x]][which(str_sub(bigData[[x]], 1, 1) == 'b')])
  as.numeric( sub("\\D*(\\d+).*", "\\1", foundset) )
  logs<-data.frame(K = rep(1:K_VAL, each=3))
  logs$like<-as.vector(as.numeric( sub("\\D*(\\d+).*", "\\1", foundset) ))
  tapply(logs$like, logs$K, FUN= function(x)(abs(x)))
}

opt_logs <- opt_k_fx_no_math(log_names, 10)
## second entry will be k=10!! not k=2 (alphabetized)

## read log likes from excel 
opt_logs_xl <- read_excel("log_likelihoods_k1-10.xlsx", sheet="Sheet1")

ggplot(opt_logs_xl, aes(x = file, y = best_like)) +
  geom_point(color = "orange", size = 3) +  
  xlab("K") +                 
  ylab("opt like") +                 
  ggtitle("Bet likelihood k = 1 - 10 with 3 replicates") +  
  theme_minimal() 



