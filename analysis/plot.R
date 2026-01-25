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

km_sum <- summary(km_raw)

strata_vec <- if (length(km_sum$strata) == length(km_sum$time)) {
  as.character(km_sum$strata)
} else {
  as.character(rep(names(km_sum$strata), km_sum$strata))
}

km_df <- data.frame(
  strata   = strata_vec,
  time     = km_sum$time,
  n.risk   = km_sum$n.risk,
  n.event  = km_sum$n.event,
  n.censor = km_sum$n.censor,
  surv     = km_sum$surv,
  stringsAsFactors = FALSE
)

unique_strata <- unique(km_df$strata)
result_list <- list()

for(stratum in unique_strata) {
  sub_df <- km_df[km_df$strata == stratum, ]
  
  sub_df <- sub_df[order(sub_df$time), ]
  
  N <- max(sub_df$n.risk)
  
  cml_event <- cumsum(sub_df$n.event)
  
  cml_event_floor <- floor(cml_event / threshold) * threshold
  
  n_event_new <- numeric(length(cml_event_floor))
  n_event_new[1] <- cml_event_floor[1]
  if(length(cml_event_floor) > 1) {
    n_event_new[2:length(cml_event_floor)] <- 
      cml_event_floor[2:length(cml_event_floor)] - 
      cml_event_floor[1:(length(cml_event_floor)-1)]
  }
  
  n_event_new <- pmax(n_event_new, 0)
  
  cum_loss <- cumsum(n_event_new + sub_df$n.censor)
  
  n_risk_new <- numeric(length(cum_loss))
  n_risk_new[1] <- N
  if(length(cum_loss) > 1) {
    n_risk_new[2:length(cum_loss)] <- N - cum_loss[1:(length(cum_loss)-1)]
  }
  n_risk_new <- pmax(n_risk_new, 1)
  
  surv_new <- cumprod(1 - n_event_new / n_risk_new)
  
  result_df <- data.frame(
    strata = stratum,
    time = sub_df$time,
    n.risk = n_risk_new,
    n.event = n_event_new,
    n.censor = sub_df$n.censor,
    surv = surv_new,
    stringsAsFactors = FALSE
  )
  
  result_list[[stratum]] <- result_df
}

km_min10 <- do.call(rbind, result_list)
rownames(km_min10) <- NULL


svg("./output/km_plot.svg", width = 8, height = 6)



dev.off()