## nucleotide diversity 

setwd("/Users/sydneyalmgren/Documents/SA_P_Herring/bering_sea_pop_gen_output/nucleotide_diversity")

library(ggplot2)
library(dplyr)
library(cowplot)

# read each pop file in:
ua <- read.table("pherr_UA_wholegenome_polymorphic_folded.thetas.idx.pestPG.txt", header = F)
tg <- read.table("pherr_TG_wholegenome_polymorphic_folded.thetas.idx.pestPG.txt", header = F)
kz <- read.table("pherr_KZ_wholegenome_polymorphic_folded.thetas.idx.pestPG.txt", header = F)
ni <- read.table("pherr_NI_wholegenome_polymorphic_folded.thetas.idx.pestPG.txt", header = F)
ns <- read.table("pherr_NS_wholegenome_polymorphic_folded.thetas.idx.pestPG.txt", header = F)
pm <- read.table("pherr_PM_wholegenome_polymorphic_folded.thetas.idx.pestPG.txt", header = F)
gb <- read.table("pherr_GB_wholegenome_polymorphic_folded.thetas.idx.pestPG.txt", header = F)

# add column names (idk why they don't read in with the header = T)
colnames(ua) <- c("(indexStart,indexStop)(firstPos_withData,lastPos_withData)(WinStart,WinStop)","Chr","WinCenter","tW","tP","tF",	"tH",	"tL",	"Tajima",	"fuf",	"fud",	"fayh",	"zeng",	"nSites")
colnames(tg) <- c("(indexStart,indexStop)(firstPos_withData,lastPos_withData)(WinStart,WinStop)","Chr","WinCenter","tW","tP","tF",	"tH",	"tL",	"Tajima",	"fuf",	"fud",	"fayh",	"zeng",	"nSites")
colnames(kz) <- c("(indexStart,indexStop)(firstPos_withData,lastPos_withData)(WinStart,WinStop)","Chr","WinCenter","tW","tP","tF",	"tH",	"tL",	"Tajima",	"fuf",	"fud",	"fayh",	"zeng",	"nSites")
colnames(ni) <- c("(indexStart,indexStop)(firstPos_withData,lastPos_withData)(WinStart,WinStop)","Chr","WinCenter","tW","tP","tF",	"tH",	"tL",	"Tajima",	"fuf",	"fud",	"fayh",	"zeng",	"nSites")
colnames(ns) <- c("(indexStart,indexStop)(firstPos_withData,lastPos_withData)(WinStart,WinStop)","Chr","WinCenter","tW","tP","tF",	"tH",	"tL",	"Tajima",	"fuf",	"fud",	"fayh",	"zeng",	"nSites")
colnames(pm) <- c("(indexStart,indexStop)(firstPos_withData,lastPos_withData)(WinStart,WinStop)","Chr","WinCenter","tW","tP","tF",	"tH",	"tL",	"Tajima",	"fuf",	"fud",	"fayh",	"zeng",	"nSites")
colnames(gb) <- c("(indexStart,indexStop)(firstPos_withData,lastPos_withData)(WinStart,WinStop)","Chr","WinCenter","tW","tP","tF",	"tH",	"tL",	"Tajima",	"fuf",	"fud",	"fayh",	"zeng",	"nSites")

# match chroms 
chroms <- as.data.frame(read.csv("chromosome_list.csv"))
chroms <- as.data.frame(chroms)
chroms$CHR <- as.factor(chroms$CHR)

ua <- left_join(ua, chroms, by = "Chr")
tg <- left_join(tg, chroms, by = "Chr")
kz <- left_join(kz, chroms, by = "Chr")
ni <- left_join(ni, chroms, by = "Chr")
ns <- left_join(ns, chroms, by = "Chr")
pm <- left_join(pm, chroms, by = "Chr")
gb <- left_join(gb, chroms, by = "Chr")

# from physalia:
# tP (pairwise theta) can be used to estimate the window-based pairwise nucleotide diversity (π), 
# when we divide tP by the number of sites within the corresponding window (-nSites).

# add column for tW/nsites
ua$avg_pi <- ua$tW/ua$nSites
tg$avg_pi <- tg$tW/ua$nSites
kz$avg_pi <- kz$tW/ua$nSites
ni$avg_pi <- ni$tW/ua$nSites
ns$avg_pi <- ns$tW/ua$nSites
pm$avg_pi <- pm$tW/ua$nSites
gb$avg_pi <- gb$tW/ua$nSites

# calculate whole genome avreage by pop
kz.total <- mean(kz$avg_pi)
ns.total <- mean(ns$avg_pi)
ni.total <- mean(ni$avg_pi)
gb.total <- mean(gb$avg_pi)
tg.total <- mean(tg$avg_pi)
pm.total <- mean(pm$avg_pi)
ua.total <- mean(ua$avg_pi)

avg_pi_df <- data.frame(
  Population = c("Kotzebue", "Norton Sound","Nelson Island","Goodnews Bay", "Togiak",  "Port Moller", "Unalaska"),
  avg_pi = c(kz.total, ns.total, ni.total, gb.total, tg.total, pm.total, ua.total)
)
avg_pi_df$Population <- factor(avg_pi_df$Population, levels = avg_pi_df$Population)


########
# plot total avg by pop
#######
ggplot(avg_pi_df,aes(x=Population, y=avg_pi, color = Population))+
  geom_point(size=4)+
  geom_text(aes(label = round(avg_pi, 2)), vjust = -1.5, hjust = 0.5, size = 3, color = "black") +
  scale_color_manual(values = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD", "#8c86d2"))+
  scale_y_continuous(limits = c(0, 0.3), expand = c(0, 0)) + # get rid of space underneath 0
  theme_linedraw()+
  labs(
    x = "",  
    y = "Watterson's \u03C0", 
    title = "Nucleotide diversity by population")

#########
# plot avg chromosome value by pop
##########
# unalaska 
ua.plot <- ggplot(ua,aes(x=CHR, y=avg_pi))+
  geom_point(alpha=0.9, size=2,color = "#8c86d2")+
  scale_y_continuous(limits = c(0, 0.3), expand = c(0, 0)) + # get rid of space underneath 0
  theme_linedraw()+
  labs(
    x = "Chromosome",  
    y = "Watterson's \u03C0", 
    title = "Unalaska nucleotide diversity by chromosome")
# togiak  
tg.plot <- ggplot(tg,aes(x=CHR, y=avg_pi))+
  geom_point(alpha=0.9, size=2,color = "#33a02c")+
  scale_y_continuous(limits = c(0, 0.3), expand = c(0, 0)) + # get rid of space underneath 0
  theme_linedraw()+
  labs(
    x = "Chromosome",  
    y = "Watterson's \u03C0", 
    title = "Togiak nucleotide diversity by chromosome")
# kotzebue  
kz.plot <- ggplot(kz,aes(x=CHR, y=avg_pi))+
  geom_point(alpha=0.9, size=2,color = "#D53E4F")+
  scale_y_continuous(limits = c(0, 0.3), expand = c(0, 0)) + # get rid of space underneath 0
  theme_linedraw()+
  labs(
    x = "Chromosome",  
    y = "Watterson's \u03C0", 
    title = "Kotzebue nucleotide diversity by chromosome")
# norton sound
ns.plot <- ggplot(ns,aes(x=CHR, y=avg_pi))+
  geom_point(alpha=0.9, size=2,color = "#FDAE61",)+
  scale_y_continuous(limits = c(0, 0.3), expand = c(0, 0)) + # get rid of space underneath 0
  theme_linedraw()+
  labs(
    x = "Chromosome",  
    y = "Watterson's \u03C0", 
    title = "Norton Sound nucleotide diversity by chromosome")
# nelson island
ni.plot <- ggplot(ni,aes(x=CHR, y=avg_pi))+
  geom_point(alpha=0.9, size=2,color = "#E6F598")+
  scale_y_continuous(limits = c(0, 0.3), expand = c(0, 0)) + # get rid of space underneath 0
  theme_linedraw()+
  labs(
    x = "Chromosome",  
    y = "Watterson's \u03C0", 
    title = "Nelson Island nucleotide diversity by chromosome")
# goodnews bay
gb.plot <- ggplot(gb,aes(x=CHR, y=avg_pi))+
  geom_point(alpha=0.9, size=2,color = "#ABDDA4")+
  scale_y_continuous(limits = c(0, 0.3), expand = c(0, 0)) + # get rid of space underneath 0
  theme_linedraw()+
  labs(
    x = "Chromosome",  
    y = "Watterson's \u03C0", 
    title = "Goodnews Bay nucleotide diversity by chromosome")
# port moller
pm.plot <- ggplot(pm,aes(x=CHR, y=avg_pi))+
  geom_point(alpha=0.9, size=2,color = "#3288BD")+
  scale_y_continuous(limits = c(0, 0.3), expand = c(0, 0)) + # get rid of space underneath 0
  theme_linedraw()+
  labs(
    x = "Chromosome",  
    y = "Watterson's \u03C0", 
    title = "Port Moller nucleotide diversity by chromosome")

  scale_fill_manual(values = c("#D53E4F","#FDAE61","#E6F598" ,"#ABDDA4", "#33a02c","#3288BD", "#8c86d2"))

  
# combine all pop plots
all_nucdiv_plots <- plot_grid(
    kz.plot, ns.plot, ni.plot, gb.plot, tg.plot, pm.plot, ua.plot,
    ncol = 2, # Number of columns in the grid
    align = "v" # Align plots vertically
  )
  
