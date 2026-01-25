library(survival)
library(dplyr)
library(broom)
library(haven)
library(tidyverse)
library(tidyr)

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
    N = max(n.risk, na.rm=TRUE),
    cml.event = plyr::round_any(cumsum(replace_na(n.event, 0)), threshold),
    cml.censor = plyr::round_any(cumsum(replace_na(n.censor, 0)), threshold),
    n.event = diff(c(0,cml.event)),
    n.censor = diff(c(0,cml.censor)),
    n.risk = plyr::round_any(N, threshold) - lag(cml.event + cml.censor,1,0),
    summand = n.event / ((n.risk - n.event) * n.risk),
    
    ## calculate surv based on rounded event counts
    surv = cumprod(1 - n.event / n.risk)
  ) |>
  ungroup()

svg("./output/km_plot.svg", width = 8, height = 6)

dev.off()


