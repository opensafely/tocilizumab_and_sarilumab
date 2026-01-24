library(survival)
library(dplyr)
library(broom)
library(haven)
library(tidyverse)

df <- read_dta("./output/main.dta")

if(is.numeric(df$drug)) {
  df$drug <- as.factor(df$drug)
}

df <- df %>%
  mutate(
    end_date = as.Date(end_date),
    start_date = as.Date(start_date),
    time  = as.numeric(end_date - start_date),
    event = failure == 1,
    drug = factor(drug, 
                  levels = c(0, 1), 
                  labels = c("tocilizumab", "sarilumab"))
  )



#by drug #
km_raw <- survfit(
  Surv(time, event ) ~ drug,
  data = df
)
threshold <- 10

svg("./output/km_plot.svg", width = 8, height = 6)



dev.off()


