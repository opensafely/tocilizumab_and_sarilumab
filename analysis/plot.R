library(survival)
library(dplyr)
library(broom)
library(haven)
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

km_min10 <- broom::tidy(km_raw) |>
  group_by(strata) |>
  mutate(
    N = max(n.risk),
    cml_event = cumsum(n.event),
    cml_event = floor(cml_event / threshold) * threshold,
    n.event   = c(cml_event[1], diff(cml_event)),
    n.event = pmax(n.event, 0)
  ) |>
  mutate(
    n.risk = N - lag(cumsum(n.event + n.censor), default = 0),
    n.risk = pmax(n.risk, 1),
    surv   = cumprod(1 - n.event / n.risk)
  ) |>
  ungroup()


svg("./output/km_plot.svg", width = 8, height = 6)



dev.off()