library(readxl)
install.packages("Rcpp", repos="https://rcppcore.github.io/drat")
library(ggplot2)
library(reshape2)
library(tidyr)
library(scales)

setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/manuscript/pairwise_fst")

#######
# unweighted all
#######
# read excel file, specify which sheet
unweighted_fst <- read_excel("pairwise_fst_manuscript.xlsx", sheet = "all_unweighted", col_names= T, col_types = "numeric")

# turn dataframe into matrix, add pop row names
# from https://sebastianraschka.com/Articles/heatmaps_in_r.html 
pops <- c("Kotzebue", "Norton Sound",	"Nelson Island", "Goodnews Bay",	"Togiak","Port Moller","Unalaska")                            # assign labels in column 1 to "rnames"
unweighted_fst_matrix <- data.matrix(unweighted_fst[,2:ncol(unweighted_fst)])  # transform column 2-5 into a matrix
rownames(unweighted_fst_matrix) <- pops 

# re-order 
col.order <- c("Kotzebue", "Norton Sound",	"Nelson Island", "Goodnews Bay",	"Togiak","Port Moller","Unalaska")
unweighted_fst_matrix[ , col.order]

# melt data, round
unweighted_fst_matrix_melt$value <- round(unweighted_fst_matrix_melt$value, 3)

# Plot the heatmap using ggplot
ggplot(unweighted_fst_matrix_melt, aes(Var1, Var2, fill = value)) +
  geom_tile(color = "white") +
  #coord_fixed(ratio = .6)+
  #coord_flip()+     # change for chart orientation 
  scale_fill_gradient(low = "#0072B2", high = "#C43E87", na.value = "white", name = expression(italic(F)[ST])) +
  scale_y_discrete(position="left",limits = rev(levels(unweighted_fst_matrix_melt$Var2)))+
  scale_x_discrete(position="bottom", labels = wrap_format(10))+
  geom_text(aes(label = value), size = 5, color = "black")+
  guides(fill=guide_colorbar(barwidth=3, barheight=9, hjust = 0.5))+ # for legend
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5, vjust = 0),
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 14, color = "black"),
    axis.text.y = element_text(size = 14,  hjust = 1, color = "black"),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank()
  ) +
  ggtitle(expression("Unweighted Pairwise " * italic(F)[ST]))

########
# weighted
########
weighted_fst <- read_excel("pairwise_fst_manuscript.xlsx", sheet = "all_weighted", col_names= T, col_types = "numeric")

# turn dataframe into matrix, add pop row names
weighted_fst_matrix <- data.matrix(weighted_fst[,2:ncol(weighted_fst)])  # transform remaining columns to matrix
rownames(weighted_fst_matrix) <- pops 

# re-order 
weighted_fst_matrix[ , col.order]

# round data
weighted_fst_matrix_melt$value <- round(weighted_fst_matrix_melt$value, 3)

# weighted heatmap
weighted_spawning <- ggplot(weighted_fst_matrix_melt, aes(Var2, Var1, fill = value)) +
  geom_tile(color = "white") +
  #coord_fixed(ratio = .6)+
  #coord_flip()+     # change for chart orientation 
  scale_fill_gradient(low = "#0072B2", high = "#C43E87", na.value = "white", limits = c(0, 0.2), name = expression(italic(F)[ST])) +
  scale_y_discrete(position="left", limits = rev(levels(weighted_fst_matrix_melt$Var1)))+
  scale_x_discrete(position="bottom", labels = wrap_format(10))+
  geom_text(aes(label = round(value, 3)), size = 6, color = "black")+
  guides(fill=guide_colorbar(barwidth=2, barheight=8, hjust = 0.5))+
  theme(
    plot.title = element_text(size = 12, face = "bold", hjust = 0.5, vjust = 0),
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 14, color = "black"),
    axis.text.y = element_text(size = 14,  hjust = 1, color = "black"),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = c(0.9, 0.6),
    legend.text = element_text(size = 12),
    panel.background = element_blank()
  ) +
  ggtitle(expression("Weighted Pairwise " * italic(F)[ST]))

#0072B2
#CC79A7

################
# region weighted
#################
region_weighted <- read_excel("pairwise_fst_manuscript.xlsx", sheet = "region_weighted", col_names= T, col_types = "numeric")

# turn dataframe into matrix, add pop row names
region_weighted_matrix <- data.matrix(region_weighted[,2:ncol(region_weighted)])  # transform remaining columns to matrix

region_pops <- c("Kotzebue", "EBS","Unalaska")    # assign labels in column 1 to "rnames"
rownames(region_weighted_matrix) <- region_pops 
colnames(region_weighted_matrix) <- region_pops 

# re-order 
#weighted_fst_matrix[ , col.order]

# melt data
region_weighted_matrix_melt <- melt(region_weighted_matrix)

# weighted heatmap
weighted_region <- ggplot(region_weighted_matrix_melt, aes(Var2, Var1, fill = value)) +
  geom_tile(color = "white") +
  #coord_fixed(ratio = .6)+
  #coord_flip()+     # change for chart orientation 
  scale_fill_gradient(low = "#0072B2", high = "#C43E87", na.value = "white", limits = c(0, 0.2), name = expression(italic(F)[ST])) +
  scale_y_discrete(position="left", limits = rev(levels(region_weighted_matrix_melt$Var1)))+
  scale_x_discrete(position="bottom", labels = wrap_format(10))+
  geom_text(aes(label = round(value, 3)), size = 6, color = "black")+
  guides(fill=guide_colorbar(barwidth=2, barheight=8, hjust = 0.5))+
  theme_minimal() +
  theme(
    plot.title = element_text(size = 12, face = "bold", hjust = 0.5, vjust = 0),
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 14, color = "black"),
    axis.text.y = element_text(size = 14,  hjust = 1, color = "black"),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    legend.position = c(0.9, 0.6),
    legend.text = element_text(size = 12)
  ) +
  ggtitle(expression("Weighted Pairwise " * italic(F)[ST]))

#######
# combine to figure 
#######
library(cowplot)

heatmaps <- plot_grid(weighted_spawning, weighted_cluster, 
                      labels = c("A", "B"), 
                      ncol = 2, rel_widths = c(1, 1))

##########
# test
###########
# formatting tests 
# Get upper triangle of the correlation matrix
get_upper_tri <- function(unweighted_fst){
  unweighted_fst[lower.tri(unweighted_fst)]<- NA
  return(unweighted_fst)
}

unweighted_fst <- round(unweighted_fst)
unweighted_fst_long <- pivot_longer(data = unweighted_fst, 
                                    cols = everything(),
                                    names_to = "Population", 
                                    values_to = "Fst")

# Reshape the data into a long format for ggplot (if it's in wide format)
unweighted_fst_long <- melt(unweighted_fst, id.vars = NULL, variable.name = "X", value.name = "Value")

#####
# mtDNA heatmap
####
all_spawn_pairwise_fast <- ggplot(data = fst.df, aes(x = Site1, y = Site2, fill = Fst))+
  geom_tile(color = "black")+
  geom_text(aes(label = Fst), size = 5)+
  scale_fill_gradient2(low="blue", mid="pink", high="red", midpoint = mid, name =fst.label)+
  scale_x_discrete(expand = c(0,0))+
  scale_y_discrete(expand= c(0,0), position ="right")+
  theme(axis.text = element_text(colour = "black", size = 12, face = "bold"),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        panel.background = element_blank(),
        legend.position = "right",
        legend.title = element_text(size = 14, face = "bold"),
        legend.text = element_text(size = 10))+
  ggtitle("Pairwise Fst between all Spawning Populations")

all_spawn_pairwise_fast
