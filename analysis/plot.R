library(survival)
library(haven)


df <- read_dta("./output/main.dta")

if(is.numeric(df$drug)) {
  df$drug <- factor(df$drug, levels = c(0, 1), 
                    labels = c("tocilizumab", "sarilumab"))
} else {
  df$drug <- factor(df$drug)
}

df$end_date <- as.Date(df$end_date)
df$start_date <- as.Date(df$start_date)

df$time <- as.numeric(df$end_date - df$start_date)
df$event <- df$failure == 1  

#by drug #
km_raw <- survfit(Surv(time, event) ~ drug, data = df)
threshold <- 10

km_summary <- summary(km_raw)

km_df <- data.frame(
  strata = km_summary$strata,
  time = km_summary$time,
  n.risk = km_summary$n.risk,
  n.event = km_summary$n.event,
  n.censor = km_summary$n.censor,
  surv = km_summary$surv,
  stringsAsFactors = FALSE
)

unique_strata <- unique(km_df$strata)
result_list <- list()



svg("./output/km_plot.svg", width = 8, height = 6)



dev.off()