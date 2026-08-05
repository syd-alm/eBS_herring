###
# modified from Eleni Petrou
# at https://github.com/EleniLPetrou/pacific_herring_RADseq/blob/master/IBD/mantel_test_IBD.R

# load libraries
library(dplyr)
library(geosphere)
library(reshape2)
library(ggplot2)
library(viridis)
library(scales)
library(vegan)
library(readxl)
library(ggtext)
library(patchwork)

setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/fst_pairwise")

############################################################################################
# Read in data

# The input file should be a tab delimited text file that has data about:
# 1. Population name
# 2. Latitude for population
# 3. Longitude  population2
# 4. Pairwise FST for each population
# 5. dummy date of spawning (in the same year) used to calculate julian date
# 6. Other optional columns

fst_data <- read_excel("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/fst_pairwise/global_pairwise_fst.xlsx", sheet = "weighted", col_names= T, col_types = "numeric")
#fst_data <- fst_data[,-1]

bs_locations <- read.csv("/Users/sydneyalmgren/Documents/SA_P_Herring/sample_collection_info/bering_sea_spawning_locations.csv")

############################################################################################
# from Eleni
# Calculate the geographic and temporal distance between sampling locations

# calculate the straight-line distance between two sampling points,
# using the The shortest distance between two points 
# (i.e., the 'great-circle-distance' or 'as the crow flies'), 
# according to the 'Vincenty (ellipsoid)' method. 
# This method uses an ellipsoid and the results are very accurate.

# Note that the function distVincentyEllipsoid is not vectorized, 
# so I used the mutate function in dplyr to apply
# it over the whole data frame, row by row.
# In addition, this distance I divided by 1000, to get in in km units.

#fst_data <- fst_data %>% 
#  rowwise() %>% 
#  mutate(distance_km = ( distVincentyEllipsoid(c(longpop1, latpop1), c(longpop2, latpop2))/1000))

# make fst data frame into matrix
# from https://sebastianraschka.com/Articles/heatmaps_in_r.html 
fst_matrix <- data.matrix(fst_data[,2:ncol(fst_data)])  # transform column 2-5 into a matrix
# add pop names 
pops <- c("Kotzebue", "Norton Sound",	"Nelson Island", "Goodnews Bay",	"Togiak","Port Moller","Unalaska")                            
rownames(fst_matrix) <- pops 

# melt data
fst_matrix <- reshape2::melt(fst_matrix)
  # pairwise fst ends up in "value" column 

# add in fst/1-fst row 
fst_matrix <- fst_matrix %>% 
  rowwise() %>%
  mutate(linearized_fst = (value/(1-value)))

### calculate pairwise distances between pops
# [this part is from Copilot]

# initialize an empty matrix to store distances
n <- nrow(bs_locations)
distance_matrix <- matrix(0, nrow = n, ncol = n, dimnames = list(bs_locations$Location, bs_locations$Location))

# calculate pairwise distances
for (i in 2:n) {  # Start from the second row
  for (j in 1:(i - 1)) {  # Iterate only over the lower triangle
    # Get the coordinates for the two populations
    coord1 <- c(bs_locations$Longitude[i], bs_locations$Latitude[i])
    coord2 <- c(bs_locations$Longitude[j], bs_locations$Latitude[j])
    # calculate the distance using distVincentyEllipsoid()
    distance <- distVincentyEllipsoid(coord1, coord2)
      # values are in meters (package documentation)
    # store the distance in the matrix (both upper and lower triangle)
    distance_matrix[i, j] <- distance
  }
}


## something is weird with these distances, need to fix ###

# melt data
distance_matrix <- reshape2::melt(distance_matrix)

#distance_matrix <- distance_matrix[distance_matrix$Freq > 0, ]  # Keep only non-zero distances

# try adding columns together
#fst_matrix$distance_km <- distance_matrix$value
  # not good, different orders

# export individually and edit manually in Excel
write.table(fst_matrix, file="weighted_pairwise_matrix.csv", sep=",", row.names=FALSE, col.names=FALSE)
write.table(distance_matrix, file="distance_matrix.csv", sep=",", row.names=FALSE, col.names=FALSE)

#### start from here 

# read back in big dataframe
fst_distance <- read_xlsx("ibd_matrices.xlsx", sheet="filtered")

# divide distance by 1000 (results in m, want in km)
fst_distance$distance_km <- fst_distance$distance_m/1000

# look at it real quick
ggplot(data = fst_distance, aes(x=distance_km, y=linearized_fst, color = loc2)) + 
  geom_point( size = 3, alpha = 0.9) +
  ylab(expression(italic(F[ST]/(1-F[ST])))) +                          
  xlab("Distance (km)")  +
  theme_classic()

############################################################################################
# Analyze the data using linear regressions
# Regression  of IBDwith all pops

# Linear regression
ibd_regression = lm(weighted_fst ~ distance_km, data = fst_distance)
summary(ibd_regression)
coef(ibd_regression)

# Plot the residuals of IBD for all pops 
plot(fitted(ibd_regression), residuals(ibd_regression))

# plot linearized fst, distance, with regression line
all_pops <- ggplot(data = fst_distance, aes(x=distance_km, y=linearized_fst)) + #specify dataframe
  geom_point( size = 4,  color = "#505050") +
  geom_abline(slope = 5.441661e-05, intercept = 2.904413e-03, color = "#440154ff", size = 1.5) + 
  ylab(expression(italic(F[ST]/(1-F[ST])))) +                           
  xlab("Distance (km)")  +
  scale_x_continuous(breaks = seq(0, 1500, by = 500), labels = scales::comma) +
  theme_classic()+
    theme( 
      title = element_text(size = 10, color = "black", hjust = 0.5),
      axis.text.x = element_text(size = 8, color = "black", vjust = 0.5),
      axis.title.y = element_text(margin = margin(t = 0, r = 0, b = 30, l = 0)),
      axis.text.y = element_text(size = 8, color = "black"),
      panel.background = element_rect(fill = "white"), 
      panel.spacing = unit(0,"lines"),
      strip.text.y = element_text(angle = 0))+
  annotate("text", x = 200, y = 0.12, label = paste0("Mantel r = 0.459, Mantel p = 0.134"), size = 3.5, color = "black")+
  annotate("text", x = 200, y = 0.05, label = paste0("y = 0.0000544 x + 0.0029"), size = 3, color = "black")+
  ggtitle("Isolation by distance: all spawning populations")

# mantel results
# r = 0.4591 
# Significance: 0.13387
# regression results
# (Intercept)  distance_km 
# 2.904413e-03 5.441661e-05
##############################################################################################
# Prepare data for the Mantel Test (from Eleni's code)
# mantel function unfortunately only accepts a matrix as input, bleh

# Use some base R to create two distance matrices from your pairwise dataframe

# Save the character values of the population names
pop_name <- with(fst_distance, sort(unique(c(as.character(loc1),
                                         as.character(loc2)))))

# Create some  empty 2-D  arrays to hold the pairwise data
dist_array <- array(data = 0, dim = c(length(pop_name), length(pop_name)), 
                    dimnames = list(pop_name, pop_name))

fst_array <- array(data = 0, dim = c(length(pop_name), length(pop_name)), 
                   dimnames = list(pop_name, pop_name))

# Save some vectors of the positions of first matches of the first argument to the second
i <- match(fst_distance$loc1, pop_name)
j <- match(fst_distance$loc2, pop_name)

# Populate the empty arrays with data saved in the vectors
dist_array[cbind(i,j)] <- dist_array[cbind(j,i)] <- fst_distance$distance_km
fst_array[cbind(i,j)] <- fst_array[cbind(j,i)] <- fst_distance$linearized_fst

##############################################################################################
# Analyze the IBD data using a mantel test
mantel(dist_array, fst_array, method="pearson", permutations=1000)


#######################################
# do it all again, but without Unalaska

fst_distance_wo_ua <- fst_distance <- read_xlsx("ibd_matrices.xlsx", sheet="wo_ua")

# divide distance by 1000 (results in m, want in km)
fst_distance_wo_ua$distance_km <- fst_distance_wo_ua$distance_m/1000

## regression 
ibd_regression_wo_ua = lm(weighted_fst ~ distance_km, data = fst_distance_wo_ua)
summary(ibd_regression_wo_ua)
coef(ibd_regression_wo_ua)

# Plot the residuals of IBD for all pops 
plot(fitted(ibd_regression_wo_ua), residuals(ibd_regression_wo_ua))

### mantel test without Unalaska

# Save the character values of the population names
pop_name_wo_ua <- with(fst_distance_wo_ua, sort(unique(c(as.character(loc1),
                                             as.character(loc2)))))

# Create some  empty 2-D  arrays to hold the pairwise data
dist_array_wo_ua <- array(data = 0, dim = c(length(pop_name_wo_ua), length(pop_name_wo_ua)), 
                    dimnames = list(pop_name_wo_ua, pop_name_wo_ua))

fst_array_wo_ua <- array(data = 0, dim = c(length(pop_name_wo_ua), length(pop_name_wo_ua)), 
                         dimnames = list(pop_name_wo_ua, pop_name_wo_ua))

# Save some vectors of the positions of first matches of the first argument to the second
i_wo_ua <- match(fst_distance_wo_ua$loc1, pop_name_wo_ua)
j_wo_ua <- match(fst_distance_wo_ua$loc2, pop_name_wo_ua)

# Populate the empty arrays with data saved in the vectors
dist_array_wo_ua[cbind(i_wo_ua,j_wo_ua)] <- dist_array_wo_ua[cbind(j_wo_ua,i_wo_ua)] <- fst_distance_wo_ua$distance_km
fst_array_wo_ua[cbind(i_wo_ua,j_wo_ua)] <- fst_array_wo_ua[cbind(j_wo_ua,i_wo_ua)] <- fst_distance_wo_ua$linearized_fst

# Analyze the IBD data using a mantel test
mantel(dist_array_wo_ua, fst_array_wo_ua, method="pearson", permutations=1000)

# plot linearized fst, distance, with regression line
wo_ua <- ggplot(data = fst_distance_wo_ua, aes(x=distance_km, y=linearized_fst)) + #specify dataframe
  geom_point( size = 4, color = "#505050") +
  geom_abline(slope = 2.077575e-05, intercept = 1.614051e-03, color = "#440154ff", size = 1.5) + 
  ylab(expression(italic(F[ST]/(1-F[ST])))) +                           
  xlab("Distance (km)")  +
  scale_x_continuous(limits = c(0,1500), breaks = seq(0, 1500, by = 500), labels = scales::comma) +
  scale_y_continuous(limits = c(0,0.1250), breaks = seq(0, 0.125, by = 0.025)) +
  theme_classic()+
  theme( 
    title = element_text(size = 10, color = "black", hjust = 0.5),
    axis.text.x = element_text(size = 8, color = "black", vjust = 0.5),
    axis.text.y = element_text(size = 8, color = "black"),
    panel.background = element_rect(fill = "white"), 
    panel.spacing = unit(0,"lines"),
    strip.text.y = element_text(angle = 0))+
  annotate("text", x = 200, y = 0.12, label = paste0("Mantel r = 0.652, Mantel p = 0.0069"), size = 3.5, color = "black")+
  annotate("text", x = 200, y = 0.05, label = paste0("y = 0.000021 x + 0.0016"), size = 3, color = "black")+
  ggtitle("Isolation by distance without Unalaska")

# regression coef
# (Intercept)  distance_km 
# 1.614051e-03 2.077575e-05 

# mantel test results
# Mantel statistic r: 0.6524 
# Significance: 0.0069444

###############################################
# again? without Kotzebue
#######################################
# do it all again, but without Unalaska

fst_distance_wo_kz <- fst_distance <- read_xlsx("ibd_matrices.xlsx", sheet="wo_kz")

# divide distance by 1000 (results in m, want in km)
fst_distance_wo_kz$distance_km <- fst_distance_wo_kz$distance_m/1000

## regression 
ibd_regression_wo_kz = lm(weighted_fst ~ distance_km, data = fst_distance_wo_kz)
summary(ibd_regression_wo_kz)
coef(ibd_regression_wo_kz)

# Plot the residuals of IBD for all pops 
plot(fitted(ibd_regression_wo_kz), residuals(ibd_regression_wo_kz))

### mantel test without Unalaska

# Save the character values of the population names
pop_name_wo_kz <- with(fst_distance_wo_kz, sort(unique(c(as.character(loc1),
                                                         as.character(loc2)))))

# Create some  empty 2-D  arrays to hold the pairwise data
dist_array_wo_kz <- array(data = 0, dim = c(length(pop_name_wo_kz), length(pop_name_wo_kz)), 
                          dimnames = list(pop_name_wo_kz, pop_name_wo_kz))

fst_array_wo_kz <- array(data = 0, dim = c(length(pop_name_wo_kz), length(pop_name_wo_kz)), 
                         dimnames = list(pop_name_wo_kz, pop_name_wo_kz))

# Save some vectors of the positions of first matches of the first argument to the second
i_wo_kz <- match(fst_distance_wo_kz$loc1, pop_name_wo_kz)
j_wo_kz <- match(fst_distance_wo_kz$loc2, pop_name_wo_kz)

# Populate the empty arrays with data saved in the vectors
dist_array_wo_kz[cbind(i_wo_kz,j_wo_kz)] <- dist_array_wo_kz[cbind(j_wo_kz,i_wo_kz)] <- fst_distance_wo_kz$distance_km
fst_array_wo_kz[cbind(i_wo_kz,j_wo_kz)] <- fst_array_wo_kz[cbind(j_wo_kz,i_wo_kz)] <- fst_distance_wo_kz$linearized_fst

# Analyze the IBD data using a mantel test
mantel(dist_array_wo_kz, fst_array_wo_kz, method="pearson", permutations=1000)

# plot linearized fst, distance, with regression line
wo_kz <- ggplot(data = fst_distance_wo_kz, aes(x=distance_km, y=linearized_fst)) + #specify dataframe
  geom_point( size = 3, color = "#505050") +
  geom_abline(slope = 2.521215e-06, intercept = 5.379190e-03, color = "#440154ff", size = 1.5) + 
  ylab(expression(italic(F[ST]/(1-F[ST])))) +                           
  xlab("Distance (km)")  +
  scale_x_continuous(limits = c(0,1500), breaks = seq(0, 1500, by = 500), labels = scales::comma) +
  scale_y_continuous(limits = c(0,0.1250), breaks = seq(0, 0.125, by = 0.025)) +
  theme_classic()+
  theme( 
    title = element_text(size = 10, color = "black", hjust = 0.5),
    axis.text.x = element_text(size = 8, color = "black", vjust = 0.5),
    axis.text.y = element_text(size = 8, color = "black"),
    panel.background = element_rect(fill = "white"), 
    panel.spacing = unit(0,"lines"),
    strip.text.y = element_text(angle = 0))+
  annotate("text", x = 200, y = 0.12, label = paste0("Mantel r = 0.685, Mantel p = 0.092"), size = 3.5, color = "black")+
  annotate("text", x =200, y = 0.05, label = paste0("y = 0.0000025 x + 0.0058"), size = 3, color = "black")+
  ggtitle("Isolation by distance without Kotzebue")


# mantel test
# Mantel statistic r: 0.6849 
# Significance: 0.091667 
# regression 
# (Intercept)  distance_km 
# 5.379190e-03 2.521215e-06 

#########################################
# combine into 1 plot

all_ibds <- all_pops / wo_ua / wo_kz
all_ibds


combined_plot <- plot_grid(all_pops, wo_ua,wo_kz, ncol = 1, align = "v", 
                           rel_heights = c(1, 1, 1))

