#recreate the data in R to get better graphs 
rm(list = ls())

#install.packages("WDI")
library(WDI)
library("dplyr")
library("ggplot2")
library("stargazer")


data <- WDI(country = "all", indicator = c("NY.GDP.PCAP.KD.ZG","NY.GDP.MKTP.KD.ZG"), start = 1960, end = NULL, extra = TRUE)

data <- data %>% rename(GDPpCapGro = NY.GDP.PCAP.KD.ZG)
#i think this is another way to do this
data <- data %>% rename(GDPpGro = NY.GDP.MKTP.KD.ZG)


stargazer(data, type="text", out = "summary.txt")


data %>% select(GDPpGro) %>% stargazer(type = "text")


data %>% select(GDPpCapGro) %>% stargazer(type = "text")
