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
  ylim = c(0, 1.05),
  xlab = "Time (days)",
  ylab = "Survival Probability"
)

linetypes <- 1:2
strata_list <- unique(km_min10$strata)

for (i in seq_along(strata_list)) {
  s <- strata_list[i]
  d <- km_min10[km_min10$strata == s, ]
  d <- d[order(d$time), ]
  lines(d$time, d$surv, type = "s",lty = linetypes[i])
}

legend_labels <- gsub("drug=", "", unique(km_min10$strata))
legend("topright", legend = legend_labels,
       lty = linetypes, lwd = 2,
       title = "Drug", bty = "n")

dev.off()


