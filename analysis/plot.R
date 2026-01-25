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

km_sum <- summary(km_raw)

km_df <- data.frame(
  strata   = km_sum$strata,
  time     = km_sum$time,
  n.risk   = km_sum$n.risk,
  n.event  = km_sum$n.event,
  n.censor = km_sum$n.censor,
  surv     = km_sum$surv
)


km_min10 <- km_df |>
  group_by(strata) |>
  mutate(
    N = max(n.risk),
    
    cml_event  = floor(cumsum(n.event)  / threshold) * threshold,
    cml_censor = floor(cumsum(n.censor) / threshold) * threshold,
    
    n.event  = c(cml_event[1],  diff(cml_event)),
    n.censor = c(cml_censor[1], diff(cml_censor)),
    
    n.risk = N - lag(cumsum(n.event + n.censor), default = 0),
    
    surv = cumprod(1 - n.event / n.risk)
  ) |>
  ungroup()

svg("./output/km_plot.svg", width = 8, height = 6)

dev.off()


