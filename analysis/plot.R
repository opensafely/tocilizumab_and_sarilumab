library(survival)
library(dplyr)
library(broom)
library(haven)
library(tidyverse)

df <- read_dta("./output/main.dta")

df <- df %>%
  mutate(
    end_date = as.Date(end_date),
    start_date = as.Date(start_date),
  )

#by drug #
km_raw <- survfit(
  Surv(time = df$start_date, 
       time2 = df$end_date, 
       event = df$failure == 1) ~ drug,
  data = df
)
threshold <- 10

km_min10 <- broom::tidy(km_raw) |>
  group_by(strata) |>
  mutate(
    cml_event = cumsum(n.event),
    cml_event = floor(cml_event / threshold) * threshold,
    n.event   = c(cml_event[1], diff(cml_event))
  ) |>
  mutate(
    n.risk = max(n.risk) - lag(cumsum(n.event + n.censor), default = 0),
    surv   = cumprod(1 - n.event / n.risk)
  ) |>
  ungroup()

svg("./output/km_plot.svg", width = 8, height = 6)

plot(
  0, 0,
  type = "n",
  xlim = range(km_min10$time),
  ylim = c(0, 1),
  xlab = "Time",
  ylab = "Survival"
)

for (s in unique(km_min10$strata)) {
  d <- km_min10[km_min10$strata == s, ]
  lines(d$time, d$surv, type = "s")
}

legend(
  "topright",
  legend = unique(km_min10$strata),
  lty = 1
)

dev.off()


