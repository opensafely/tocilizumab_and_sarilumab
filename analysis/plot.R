library(survival)
library(dplyr)
library(broom)
library(haven)
library(tidyverse)

df <- read_dta("./output/main.dta")



svg("./output/km_plot.svg", width = 8, height = 6)


dev.off()


