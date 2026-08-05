# individual heterozygosity 
# code from Copilot

library(ggplot2)

########
# for all spawning pops
########
setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/heterozygosity/spawning_pops_all")

# where files are
hetero_directory <- "/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/heterozygosity/spawning_pops_all"

# list directory files
file_list <- list.files(hetero_directory, full.names = TRUE)

# make empty dataframe to store results
individual_hetero <- data.frame(individual_id = character(), heterozygosity = numeric(), stringsAsFactors = FALSE)

# loop through each file
for (file in file_list) {
  # read file
  numbers <- scan(file, quiet = TRUE)
  # take sample ID from the file name (remove the directory path)
  individual_id <- tools::file_path_sans_ext(basename(file))
  # calculate heterozygosity: second number divided by the sum of the first two numbers
    # first num = total number of sites (including seq error, so sum of genotype likelihoods, which is why it isn't a whole number)
    # second num = number of heterozygous sites
  heterozygosity <- numbers[2] / (numbers[1] + numbers[2])
  # Append the result to the dataframe
  individual_hetero <- rbind(individual_hetero, data.frame(individual_id = individual_id, heterozygosity = heterozygosity))
}

print(individual_hetero)

# add pops to data frame
pop_spawning <- c(rep("Kotzebue", 19),rep("Unalaska", 20),rep("Togiak", 20),  rep("Goodnews Bay", 20), 
                  rep("Nelson Island", 20), rep("Norton Sound", 20), rep("Port Moller", 20))
individual_hetero$population <- pop_spawning

# re-order by lat
individual_hetero$population <- factor(individual_hetero$population, 
                                       levels=c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak",  "Port Moller", "Unalaska"))

#  average heterozygosity by population
average_heterozygosity <- aggregate(heterozygosity ~ population, data = individual_hetero, mean)

## plot hetero
vertical_boxplot <- ggplot(individual_hetero, aes(x = population, y = heterozygosity, fill = population)) +
  geom_boxplot() +
  geom_text(
    data = average_heterozygosity,
    aes(x = population, y = heterozygosity, label= sprintf("%0.2f", heterozygosity)), 
    inherit.aes = FALSE,
    size = 4, hjust = .5, vjust=-9,  
    color = "black") +
  theme_minimal() +
  labs(
    title = "Heterozygosity by Population",
    x = "Population",
    y = "Heterozygosity") +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(hjust = 0.5, color = "black", size =10),
    axis.text.y = element_text(hjust = 1, color = "black", size = 10),
    axis.title.x = element_text(vjust=-1),
    axis.title.y = element_text(vjust=1),
    legend.position = "none") +
  scale_fill_manual(values = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD", "#8c86d2"))

                     
                     labels = c("Goodnews Bay", "Kotzebue", "Nelson Island", "Norton Sound", "Port Moller", "Togiak", "Unalaska")) 
## horizontal

## change order of pops
individual_hetero$population <- factor(individual_hetero$population, 
                                       levels=c("Unalaska", "Port Moller", "Togiak", "Goodnews Bay", "Nelson Island", "Norton Sound", "Kotzebue"))
horizontal_boxplot <- 
  ggplot(individual_hetero, aes(x = population, y = heterozygosity, fill = population)) +
  geom_boxplot() +
  geom_text(
    data = average_heterozygosity,
    aes(x = population, y = heterozygosity, label= sprintf("%0.2f", heterozygosity)), 
    inherit.aes = FALSE,
    size = 4, hjust = -4,
    color = "black") +
  theme_minimal() +
  labs(
    title = "Heterozygosity by Population",
    x = "Population",
    y = "Heterozygosity") +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(hjust = 0.5, color = "black", size =10),
    axis.text.y = element_text(hjust = 1, color = "black", size = 10),
    axis.title.x = element_text(vjust=-1),
    axis.title.y = element_text(vjust=1),
    legend.position = "none") +
  scale_fill_manual(values = c("#8c86d2","#3288BD","#33a02c","#ABDDA4","#E6F598","#FDAE61", "#D53E4F"))+
  coord_flip()
  
# violin plot
a <- ggplot(individual_hetero, aes(x = population, y = heterozygosity, fill = population)) +
  geom_violin() +
  geom_text(
    data = average_heterozygosity,
    aes(x = population, y = heterozygosity, label= sprintf("%0.2f", heterozygosity)), 
    inherit.aes = FALSE,
    size = 6, hjust = .5,
    color = "black",
    position = position_dodge(width=0.5)) +
  theme_minimal() +
  scale_y_continuous(limits = c(0.2, 0.5)) + # get rid of space underneath 0
  labs(
    x = "Location",
    y = "Heterozygosity") +
  theme(
    panel.grid.major = element_line(color = "darkgrey", size = 0.3),
    panel.grid.minor = element_line(color = "darkgrey", size = 0.3),
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(hjust = 0.5, color = "black", size =14),
    axis.text.y = element_text(hjust = -0.5, color = "black", size = 14),
    axis.title.x = element_text(vjust=-0.5, size = 16),
    axis.title.y = element_text(vjust=2, hjust=0.5, size = 16),
    legend.position = "none",
    panel.border = element_rect(color = "darkgrey", fill = NA, size = 1)) +
  scale_fill_manual(values = c("#D53E4F","#FDAE61","#E6F598","#ABDDA4", "#33a02c","#3288BD", "#8c86d2"))


#####################
# for cluster samples
#####################
setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/heterozygosity/cluster_samples")

# where files are
hetero_directory <- "/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/heterozygosity/cluster_samples"
  # cluster C
  # 417851, NS171
  # TG outliers (cluster A)
  # 417835, 417840

# list directory files
file_list <- list.files(hetero_directory, full.names = TRUE)

# make empty dataframe to store results
individual_hetero <- data.frame(individual_id = character(), heterozygosity = numeric(), stringsAsFactors = FALSE)

# loop through each file
for (file in file_list) {
  # read file
  numbers <- scan(file, quiet = TRUE)
  # take sample ID from the file name (remove the directory path)
  individual_id <- tools::file_path_sans_ext(basename(file))
  # calculate heterozygosity: second number divided by the sum of the first two numbers
  # first num = total number of sites (including seq error, so sum of genotype likelihoods, which is why it isn't a whole number)
  # second num = number of heterozygous sites
  heterozygosity <- numbers[2] / (numbers[1] + numbers[2])
  # Append the result to the dataframe
  individual_hetero <- rbind(individual_hetero, data.frame(individual_id = individual_id, heterozygosity = heterozygosity))
}

print(individual_hetero)

# add pops to data frame
# did this in excel, was faster to copy and paste cluster column than to code it
# read file back in

hetero_clusters <- read_xlsx("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/heterozygosity/heterozygosity_value_w_population.xlsx")

## change order of pops
hetero_clusters$population <- factor(hetero_clusters$population, 
                                       levels=c("Kotzebue", "cluster A", "cluster B", "cluster C", "Unalaska"))


# average heterozygosity by population
average_heterozygosity_clusters <- aggregate(heterozygosity ~ population, data = hetero_clusters, mean)

## plot hetero by cluster
ggplot(hetero_clusters, aes(x = population, y = heterozygosity, fill = population)) +
  geom_boxplot() +
  geom_text(
    data = average_heterozygosity_clusters,
    aes(x = population, y = heterozygosity, label= sprintf("%0.2f", heterozygosity)), 
    inherit.aes = FALSE,
    size = 4, hjust = .5, vjust=-7,  
    color = "black") +
  theme_minimal() +
  labs(
    title = "Heterozygosity by Population",
    x = "Population",
    y = "Heterozygosity") +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(hjust = 0.5, color = "black", size =10),
    axis.text.y = element_text(hjust = 1, color = "black", size = 10),
    axis.title.x = element_text(vjust=-1),
    axis.title.y = element_text(vjust=1),
    legend.position = "none") +
  scale_fill_manual(values = c("#D53E4F","cadetblue4","darksalmon","#DBC031", "#8c86d2"))

### violin plot
b <- ggplot(hetero_clusters, aes(x = population, y = heterozygosity, fill = population)) +
  geom_violin(color = "black", size = 0.4) +
  geom_text(
    data = average_heterozygosity_clusters,
    aes(x = population, y = heterozygosity, label= sprintf("%0.2f", heterozygosity)), 
    inherit.aes = FALSE,
    size = 6, vjust=-1, hjust =0 , 
    color = "black") +
  theme_minimal() +
  scale_y_continuous(limits = c(0.2, 0.5)) +
  labs(
    x = "Cluster",
    y = "Heterozygosity") +
  theme(
    panel.grid.major = element_line(color = "darkgrey", size = 0.3),
    panel.grid.minor = element_line(color = "darkgrey", size = 0.3),
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(hjust = 0.5, color = "black", size =14),
    axis.text.y = element_text(hjust = -0.5, color = "black", size = 14),
    axis.title.x = element_text(vjust=-0.5, size = 16),
    axis.title.y = element_text(vjust=2, hjust=0.5, size = 16),
    legend.position = "none",
    panel.border = element_rect(color = "darkgrey", fill = NA, size = 1)) +
  scale_fill_manual(values = c("#D53E4F","cadetblue4","darksalmon","#DBC031","#8c86d2"))



"#8c86d2","#3288BD","#33a02c","#ABDDA4","#E6F598","#FDAE61", "#D53E4F"

"darksalmon", "cadetblue4"

############
# combine into one plot
##############

library(cowplot)

hetero <- plot_grid(a, b, 
                      labels = c("A", "B"), label_size = 16, 
                      ncol = 1, rel_widths = c(1, 1))


