## pca by chromosome from physalia based code put into chatgpt for the loop 

library(ggplot2)
library(tibble)
library(paletteer)
library(gridExtra) 

setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/pca/chrom/all/unlinked")


# List of input file names (adjust as needed)
file_names <- paste0("CPAL-CPAL260-GOA-UN-EBS-KOTZ_Clupal_KotzSound_chrom", 1:26, "_filtered_unlinked.cov")

# Assign populations
pop_all <- c(rep("Kodiak", 20), rep("Kotzebue", 19), rep("Unalaska", 20), rep("Togiak", 20), rep("Cordova", 20), rep("Goodnews Bay", 20), 
             rep("Nelson Island", 20), rep("Norton Sound", 20), rep("Port Moller", 20))

# Empty list to store plots for the combined plot
plot_list <- list()

# Loop through each file
for (i in 1:length(file_names)) {
  
  # Read the input file
  chrom <- as.matrix(read.table(file_names[i], header = F))
  
  # Perform PCA
  pca <- eigen(chrom)
  
  # Extract eigenvectors
  eigenvectors <- pca$vectors
  
  # Combine eigenvectors with population information
  pca_vectors <- as_tibble(cbind(pop_all, data.frame(eigenvectors)))
  
  # set pop as factor so it can be reordered 
  pca_vectors$pop_all <- as.factor(pca_vectors$pop_all)
  pca_vectors <- as.data.frame(pca_vectors)
  
  # re-factor data for arrangement of pops from north to south 
  pca_vectors$pop_all <- factor(pca_vectors$pop_all, 
           levels=c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak", "Port Moller", "Unalaska", "Kodiak", "Cordova"))

  # Calculate percentage of variance explained by PC1 and PC2
  eigenval_sum <- sum(pca$values)
  varPC1 <- (pca$values[1] / eigenval_sum) * 100
  varPC2 <- (pca$values[2] / eigenval_sum) * 100
  
  # Create the PCA plot
  chromosome_number <- i
  p <- ggplot(data = pca_vectors, aes(x = X1, y = X2, colour = pop_all)) +
    geom_point(size = 2, alpha = 0.75) +
    theme(plot.title = element_text(size = 10, hjust =0.5), 
          axis.title.x = element_text(size = 7),
          axis.title.y = element_text(size = 7)) +
    theme(legend.position = "none",
          panel.grid.minor = element_blank(),  # remove minor grid lines
          panel.grid.major = element_blank(),  # remove major grid lines
          panel.background = element_rect(fill = "white", color = NA),  # white panel background
          plot.background = element_rect(fill = "white", color = NA),   # white plot background
          axis.line = element_line(color = "black"))+
    labs(x = (paste0("PC1 - ", sprintf("%0.2f", varPC1), "%")),
         y = (paste0("PC2 - ", sprintf("%0.2f", varPC2), "%"))) +
    ggtitle(paste0(chromosome_number))+   
    scale_color_manual(values = c("#D53E4F","#FDAE61","#E6F598","#ABDDA4","#33a02c","#3288BD", "#8c86d2", "#4FA3F7","#E78AC3","#D9488B"))
  
  # Save the individual plot
  ggsave(filename = paste0("pca_by_chrom_all_unlinked_", chromosome_number, ".png"), plot = p, width = 7, height = 5)
  
  # Add plot to the list for the combined plot
  plot_list[[i]] <- p
}

pdf("pca_by_chrom_all_unlinked_combined.pdf", width = 14, height = 10)
do.call(grid.arrange, c(plot_list, ncol = 4))
dev.off()
