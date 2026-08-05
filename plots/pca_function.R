## from physalia tutorial 
# https://github.com/nt246/physalia-lcwgs/blob/main/day_3/markdowns/day3_PCA_Admixture_practicals.md
# put into function with copilot 

setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/pca")

library(tidyverse)
library(ggplot2)
library(paletteer)
library(readxl)
library(cowplot)

# pca function --> from co-pilot 
pca <- function(cov_matrix, 
                population_data, 
                pop_levels = NULL,
                colors = c("#D53E4F","#FDAE61","#E6F598","#ABDDA4","#33a02c","#3288BD", "#8c86d2", "#4FA3F7","#E78AC3","#D9488B"),
                pop_labels = NULL,
                plot_title = "") {
  # eigen values
  pca_result <- eigen(cov_matrix)
  # make dataframe with vectors and pop list 
  pca_vectors <- as_tibble(cbind(population_data, data.frame(pca_result$vectors)))
  pca_vectors$population_data <- as.factor(pca_vectors$population_data)
  pca_vectors <- as.data.frame(pca_vectors)
  # set pop levels for legend ordering 
  if (!is.null(pop_levels)) {
    pca_vectors$population_data <- factor(pca_vectors$population_data, levels = pop_levels)
  }
  # get PC variances
  eigenval_sum <- sum(pca_result$values)
  varPC1 <- (pca_result$values[1]/eigenval_sum)*100
  varPC2 <- (pca_result$values[2]/eigenval_sum)*100
  # plot
  pca_plot <- ggplot(data = pca_vectors, aes(x=X1, y=X2, colour = population_data)) + 
    geom_point(size=4.5, alpha=0.9) +
    xlab(paste0("PC1 - ", sprintf("%0.2f", varPC1), "%")) +
    ylab(paste0("PC2 - ", sprintf("%0.2f", varPC2), "%")) +
    ggtitle(plot_title) +  
    labs(colour = "Location") +
    theme(
      legend.position = "right",
      plot.title = element_text(size = 14), 
      axis.text = element_text(size = 12),
      axis.title = element_text(size = 14),
      axis.title.x = element_text(margin = margin(t = 18)),
      legend.text = element_text(size = 12), 
      legend.title = element_text(size = 14),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      axis.line = element_line(color = "black")
    )
  # add colors
  if (!is.null(pop_labels)) {
    pca_plot <- pca_plot + scale_color_manual(values = colors, labels = pop_labels)
  } else {
    pca_plot <- pca_plot + scale_color_manual(values = colors)
  }
  
  # make eigenvalue plot
  eigenvalues_df <- data.frame(
    principal_component = paste0(1:length(pca_result$values)),
    eigenvalue = pca_result$values
  ) %>%
    slice(1:9)
  
  eigenvalue_plot <- ggplot(eigenvalues_df, aes(x = principal_component, y = eigenvalue)) +
    geom_bar(stat = "identity", fill = "darkgray") +
    geom_line(aes(group = 1), color = "#545353", size = 0.8) +
    geom_point(aes(group = 1), color = "#545353", size = 0.8) +
    xlab("PC") +
    ylab("") +
    ggtitle("Eigenvalues") +
    theme_minimal() +
    theme(
      text = element_text(size = 7),
      axis.text.x = element_text(angle = 0, hjust = 1),
      plot.title = element_text(size = 7),  
      axis.title.x = element_text(size = 7),  
      axis.title.y = element_text(size = 7)   
    )
  # add eigenvalue plot to PCA
  combined_plot <- ggdraw() +
    draw_plot(pca_plot) +
    draw_plot(eigenvalue_plot, x = 0.82, y = 0.08, width = 0.17, height = 0.17)
  # give plot
  return(list(
    pca_result = pca_result,
    pca_vectors = pca_vectors,
    pca_plot = pca_plot,
    eigenvalue_plot = eigenvalue_plot,
    combined_plot = combined_plot,
    variance_explained = c(PC1 = varPC1, PC2 = varPC2)
  ))
}

###########
# set-up
##########
# ! pops need to be listed in the same order as they are in the bam list!
pop_all <- c(
  rep("Kodiak", 20),
  rep("Kotzebue", 19),
  rep("Unalaska", 20),
  rep("Togiak", 20),
  rep("Cordova", 20),
  rep("Goodnews Bay", 20),
  rep("Nelson Island", 20),
  rep("Norton Sound", 20),
  rep("Port Moller", 20))

pop_all_2pruned <- c(
  rep("Kodiak", 20),
  rep("Kotzebue", 19),
  rep("Unalaska", 20),
  rep("Togiak", 18),
  rep("Cordova", 20),
  rep("Goodnews Bay", 20),
  rep("Nelson Island", 20),
  rep("Norton Sound", 20),
  rep("Port Moller", 20))


pop_ebs <- c(rep("Kotzebue", 19), rep("Togiak", 20), rep("Goodnews Bay", 20), 
             rep("Nelson Island", 20), rep("Norton Sound", 20), rep("Port Moller", 20))

pop_ebs_1pruned <- c(rep("Kotzebue", 19), rep("Togiak", 19), rep("Goodnews Bay", 20), 
             rep("Nelson Island", 20), rep("Norton Sound", 20), rep("Port Moller", 20))

pop_ebs_2pruned <- c(rep("Kotzebue", 19), rep("Togiak", 18), rep("Goodnews Bay", 20), 
                     rep("Nelson Island", 20), rep("Norton Sound", 20), rep("Port Moller", 20))

pop_ebs_core <- c(rep("Togiak", 20), rep("Goodnews Bay", 20), 
                rep("Nelson Island", 20), rep("Norton Sound", 20), rep("Port Moller", 20))

pop_ebs_core_1pruned <- c(rep("Togiak", 19), rep("Goodnews Bay", 20), 
                  rep("Nelson Island", 20), rep("Norton Sound", 20), rep("Port Moller", 20))

pop_ebs_core_2pruned <- c(rep("Togiak", 18), rep("Goodnews Bay", 20), 
                          rep("Nelson Island", 20), rep("Norton Sound", 20), rep("Port Moller", 20))

##########
# all linked
###########
all_linked <- as.matrix(read.table("whole_genome/CPAL-CPAL260-GOA-UN-EBS-KOTZ_wgph.cov", header = F))
all_linked_plot <- 
  pca(
    cov_matrix = all_linked,
    population_data = pop_all,
    pop_levels = c("Kotzebue","Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller", "Unalaska", "Kodiak", "Cordova"),
    colors = c("#0A0068","#2C3CBF","#518CF0","#5298A1","#5DC7DE","#B4C1C4","#FFCD77","#FF9B38","#FF5600"),
    pop_labels = NULL,
    plot_title = ""
  )
#colors = c("#D53E4F","#FDAE61","#E6F598","#ABDDA4","#33a02c","#3288BD", "#8c86d2", "#E78AC3","#D9488B", "#4FA3F7")
##########
# all unlinked
###########
all_unlinked <- as.matrix(read.table("whole_genome/CPAL-CPAL260-GOA-UN-EBS-KOTZ_wgphu.cov", header = F))
all_unlinked_plot <- 
  pca(
    cov_matrix = all_unlinked,
    population_data = pop_all,
    pop_levels = c("Kotzebue","Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller", "Unalaska", "Kodiak", "Cordova"),
    colors = c("#0A0068","#2C3CBF","#518CF0","#5298A1","#5DC7DE","#B4C1C4","#FFCD77","#FF9B38","#FF5600"),
    pop_labels = NULL,
    plot_title = "")

##########
# all unlinked, nix7 nix12, 1 TG outlier pruned
###########
all_unlinked_nix7_nix12_2pruned <- as.matrix(read.table("whole_genome/CPAL-CPAL260-GOA-UN-EBS-KOTZ-nix7-nix12_wgphu_2pruned.cov", header = F))
all_unlinked_nix7_nix12_2pruned_plot <- 
  pca(
    cov_matrix = all_unlinked_nix7_nix12_2pruned,
    population_data = pop_all_2pruned,
    pop_levels = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller", "Unalaska", "Kodiak - Uganik", "Kodiak - Kiliuda", "Cordova"),
    colors = c("#D53E4F","#FDAE61","#E6F598","#ABDDA4","#33a02c","#3288BD", "#8c86d2", "#E78AC3","#D9488B", "#4FA3F7"),
    pop_labels = NULL,
    plot_title = "All samples, 2 TG outliers removed (without chroms 7 & 12, unlinked data)")


###########
# ebs + kotz linked
##########
ebs_linked <- as.matrix(read.table("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/pca/whole_genome/CPAL-CPAL260-EBS-KOTZ_wgph.cov", header = F))
ebs_linked_plot <- 
  pca(
    cov_matrix = ebs_linked,
    population_data = pop_ebs,
    pop_levels = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#0A0068","#2C3CBF","#518CF0","#5EB4BF","#8ECBD8","#E1F1F5","#FFCD77","#FF9B38","#FF5600"),
    pop_labels = NULL,
    plot_title = "EBS & Kotzebue (linked data)")

############
# ebs + kotz 1pruned, linked
#############
ebs_kotz_1pruned_linked <- as.matrix(read.table("Togiak_outlier_pruned/CPAL-CPAL260-EBS-KOTZ_wgph_1pruned.cov", header = F))

ebs_kotz_1pruned_linked_plot <- 
  pca(
    cov_matrix = ebs_kotz_1pruned_linked,
    population_data = pop_ebs_1pruned,
    pop_levels = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = "EBS & Kotzebue (linked data, 1 TG pruned)")

############
# ebs + kotz 2pruned, linked
#############
ebs_kotz_2pruned_linked <- as.matrix(read.table("wholegenome_Togiak_outlier_pruned/CPAL-CPAL260-EBS-KOTZ_wgph_2pruned.cov", header = F))
ebs_kotz_2pruned_linked_plot <- 
  pca(
    cov_matrix = ebs_kotz_2pruned_linked,
    population_data = pop_ebs_2pruned,
    pop_levels = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#0A0068","#2C3CBF","#518CF0","#5EB4BF","#8ECBD8","#E1F1F5","#FFCD77","#FF9B38","#FF5600"),
    pop_labels = NULL,
    plot_title = "")

############
# ebs + kotz unlinked
#############
ebs_unlinked <- as.matrix(read.table("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/pca/whole_genome/CPAL-CPAL260-EBS-KOTZ_wgphu.cov", header = F))

ebs_unlinked_plot <- 
  pca(
    cov_matrix = ebs_unlinked,
    population_data = pop_ebs,
    pop_levels = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = "EBS & Kotzebue (unlinked data)")

############
# ebs + kotz 1pruned, unlinked
#############
ebs_kotz_1pruned_unlinked <- as.matrix(read.table("Togiak_outlier_pruned/CPAL-CPAL260-EBS-KOTZ_wgphu_1pruned.cov", header = F))

ebs_kotz_1pruned_unlinked_plot <- 
  pca(
    cov_matrix = ebs_kotz_1pruned_unlinked,
    population_data = pop_ebs_1pruned,
    pop_levels = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = "EBS & Kotzebue (unlinked data, 1 TG pruned)")

############
# ebs + kotz 2pruned, unlinked
#############
ebs_kotz_2pruned_unlinked <- as.matrix(read.table("wholegenome_Togiak_outlier_pruned/CPAL-CPAL260-EBS-KOTZ_wgphu_2pruned.cov", header = F))
ebs_kotz_2pruned_unlinked_plot <- 
  pca(
    cov_matrix = ebs_kotz_2pruned_unlinked,
    population_data = pop_ebs_2pruned,
    pop_levels = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#0A0068","#2C3CBF","#518CF0","#5298A1","#5DC7DE","#B4C1C4","#FFCD77","#FF9B38","#FF5600"),
    pop_labels = NULL,
    plot_title = "")

############
# ebs + kotz nix7 nix 12, 2pruned, unlinked
#############
ebs_kotz_nix7_nix12_2pruned_unlinked <- as.matrix(read.table("whole_genome/CPAL-CPAL260-EBS-KOTZ-nix7-nix12_wgphu_2pruned.cov", header = F))

ebs_kotz_nix7_nix12_2pruned_unlinked_plot <- 
  pca(
    cov_matrix = ebs_kotz_nix7_nix12_2pruned_unlinked,
    population_data = pop_ebs_2pruned,
    pop_levels = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = "EBS & Kotzebue, 2 TG outliers removed (without chroms 7 & 12, unlinked data)")


############# 
# ebs core linked
#############
ebs_core_linked <- as.matrix(read.table("whole_genome/CPAL-CPAL260-EBS_wgph.beagle.gz.cov", header = F))

ebs_core_linked_plot <- 
  pca(
    cov_matrix = ebs_core_linked,
    population_data = pop_ebs_core,
    pop_levels = c("Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = ""
  )
########### 
# ebs core Togiak 1 pruned, linked
############
ebs_pruned1_linked <- as.matrix(read.table("Togiak_outlier_pruned/CPAL-CPAL260-EBS_wgph_1pruned.cov", header = F))

ebs_pruned1_linked_plot <- 
  pca(
    cov_matrix = ebs_pruned1_linked,
    population_data = pop_ebs_core_1pruned,
    pop_levels = c("Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = "EBS (linked data, 1 TG pruned)"
  )

########### 
# ebs core Togiak 2 pruned, linked
############
ebs_core_2pruned_linked <- as.matrix(read.table("wholegenome_Togiak_outlier_pruned/CPAL-CPAL260-EBS_wgph_2pruned.cov", header = F))
ebs_core_2pruned_linked <- 
  pca(
    cov_matrix = ebs_core_2pruned_linked,
    population_data = pop_ebs_core_2pruned,
    pop_levels = c("Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#2C3CBF","#518CF0","#5298A1","#5DC7DE","#B4C1C4","#FFCD77","#FF9B38","#FF5600"),
    pop_labels = NULL,
    plot_title = ""
  )

########### 
# ebs core unlinked
############
ebs_core_unlinked <- as.matrix(read.table("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/pca/whole_genome/CPAL-CPAL260-EBS_wgphu.beagle.gz.cov", header = F))

ebs_core_unlinked_plot <- 
  pca(
    cov_matrix = ebs_core_unlinked,
    population_data = pop_ebs_core,
    pop_levels = c("Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = "EBS (linked data)"
  )

########### 
# ebs core Togiak 1 pruned, unlinked
############
ebs_pruned1_linked <- as.matrix(read.table("Togiak_outlier_pruned/CPAL-CPAL260-EBS_wgphu_1pruned.cov", header = F))

ebs_pruned1_linked_plot <- 
  pca(
    cov_matrix = ebs_pruned1_linked,
    population_data = pop_ebs_core_1pruned,
    pop_levels = c("Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = "EBS (linked data, 1 TG pruned)"
  )

########### 
# ebs core Togiak 2 pruned, unlinked
############
ebs_2pruned_unlinked <- as.matrix(read.table("wholegenome_Togiak_outlier_pruned/CPAL-CPAL260-EBS_wgphu_2pruned.cov", header = F))
ebs_2pruned_unlinked_plot <- 
  pca(
    cov_matrix = ebs_2pruned_unlinked,
    population_data = pop_ebs_core_2pruned,
    pop_levels = c("Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#2C3CBF","#518CF0","#5298A1","#5DC7DE","#B4C1C4","#FFCD77","#FF9B38","#FF5600"),
    pop_labels = NULL,
    plot_title = ""
  )

########### 
# ebs core nix 7 nix 12, Togiak 2 pruned, unlinked
############
ebs_nix7_nix12_2pruned_unlinked <- as.matrix(read.table("whole_genome/CPAL-CPAL260-EBS-nix7-nix12_wgphu_2pruned.cov", header = F))

ebs_nix7_nix12_2pruned_unlinked_plot <- 
  pca(
    cov_matrix = ebs_nix7_nix12_2pruned_unlinked,
    population_data = pop_ebs_core_2pruned,
    pop_levels = c("Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller"),
    colors = c("#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD"),
    pop_labels = NULL,
    plot_title = ""
  )


###############
# combined plots into grid - linked
setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/pca/all_printed_pcas")

img1 <- "pca_wholegenome_all_unlinked.png"
img2 <- "pca_wholegenome_ebs_kz_2pruned_linked.png"
img3 <- "pca_wholegenome_ebs_2pruned_linked.png"
img4 <- "pca_wholegenome_ebs_nix7_nix12_unlinked.png"
map <- "sampled_all_inset.png"  

p1 <- ggdraw() + draw_image(img1)
p2 <- ggdraw() + draw_image(img2)
p3 <- ggdraw() + draw_image(img3)
p4 <- ggdraw() + draw_image(img4)
p_top <- ggdraw() + draw_image(map)

grid <- plot_grid(
  p1, p2, p3, p4,
  ncol = 2,
  labels = c("A", "B ", "C ", "D "),
  label_fontface = "bold"
)

final_grid <- plot_grid(
  p_top,
  grid,
  ncol = 1,
  rel_heights = c(1, 2)
)

# combined plots into grid - unlinked
setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/pca/all_printed_pcas")

img1 <- "all_unlinked_blue_revised.png"
img2 <- "pca_wholegenome_ebs_kotz_2pruned_unlinked_blue_revised.png"
img3 <- "pca_wholegenome_ebs_2pruned_unlinked_blue_revised.png"
img4 <- "pca_wholegenome_ebs_2pruned_linked_blue_revised.png"

p1 <- ggdraw() + draw_image(img1)
p2 <- ggdraw() + draw_image(img2)
p3 <- ggdraw() + draw_image(img3)
p4 <- ggdraw() + draw_image(img4)

grid <- plot_grid(
  p1, p2, p3, p4,
  ncol = 2,
  labels = c("A", "B ", "C", "D "),
  label_fontface = "bold"
)

final_grid <- plot_grid(
  p_top,
  grid,
  ncol = 1,
  rel_heights = c(1, 2)
)


##############
# unlinked, 1 columne (3 plots)
img1 <- "pca_wholegenome_all_unlinked.png"
img2 <- "pca_wholegenome_ebs_kotz_2pruned_unlinked.png"
img3 <- "pca_wholegenome_ebs_2pruned_unlinked.png"

p1 <- ggdraw() + draw_image(img1)
p2 <- ggdraw() + draw_image(img2)
p3 <- ggdraw() + draw_image(img3)

grid <- plot_grid(
  p1, p2, p3,
  ncol = 1,
  labels = c("A", "B", "C"),
  hjust = -17,
  label_fontface = "bold"
)

final_grid <- plot_grid(
  p_top,
  grid,
  ncol = 1,
  rel_heights = c(1, 2)
)
