library(tidyverse)
library(survival)
library(ggsurvfit)
library(survminer)

# We will be using this code when there are only one group vector
# event should be a binary variable, 0 or 1. Thus, the event wither happens, or is censored
# time should be a numerical variable.

# To extract the correct variables from the dataset, ask the client which variable contains the group, event and time.
# Once extracted, put the variables into the function once called under the correct name and order.

validation_input <- function(groups, event, time) {
  
  if (length(groups) != length(event) |
      length(event) != length(time)) {
    stop(
      "Inputs not compatible: groups, event, and time must have the same length.")}
  
  if (any(is.na(groups)) | any(is.na(event)) | any(is.na(time))) {
    stop("Missing values detected in groups, event, or time.")}
  
  if (!is.numeric(time)) {
    stop("Data type not compatible: time must be numeric.")}

  if (any(is.infinite(time))) {stop("Time contains infinite values.")}
  
  if (any(time < 0)) {stop("Time to event cannot be negative.")}

  if (!all(event %in% c(0, 1))) {stop(
      "Event variable must contain only 0 (censored) and 1 (event).")}
  
  if (sum(event) == 0) {stop("No events observed in the dataset.")}
  
  if (length(unique(groups)) < 2) {stop("At least two groups are required for comparison.")}
  
  events_by_group <- tapply(event, groups, sum)
  
  if (any(events_by_group == 0)) {
    warning("One or more groups contain no observed events.")}

}

graph_lrt <- function(groups,event,time){
  survfit2(Surv(time, event)~groups) %>%
    ggsurvfit() +
    add_censor_mark() +
    add_pvalue(location="annotation",
               caption="Log-rank {p.value}") +
    labs(title="Kaplan-Meier Estimates of Overall Survival Between Groups")
}

lrt_test <- function(groups, event, time, threshold = 0.05){
  
  validation_input(groups, event, time)
  
  dat <- data.frame(groups, event, time)
  
  # log-rank
  if (length(unique(groups)) == 2){
    fit_lr <- survdiff(Surv(time, event) ~ groups, data = dat)
    lr_chisq <- unname(fit_lr$chisq)
    lr_df <- length(fit_lr$n) - 1
    lr_p <- pchisq(lr_chisq, lr_df, lower.tail = FALSE)
    fit_pairwise <- pairwise_survdiff(Surv(time, event) ~ groups, data = dat,
                                      p.adjust.method = "none")$p.value
    test <- "log-rank test"}
  else if (length(unique(groups)) > 2){
    fit_lr  <- survdiff(Surv(time, event) ~ groups, data = dat)
    lr_chisq     <- fit_lr$chisq
    lr_df        <- length(fit_lr$n) - 1
    lr_p         <- pchisq(lr_chisq, lr_df, lower.tail = FALSE)
    fit_pairwise <- pairwise_survdiff(Surv(time, event) ~ groups, data = dat,
                                      p.adjust.method = "bonferroni")$p.value
    
    test <- "log-rank test and Bonferroni Test"
  }
    
  p_value_groups <-
    if(lr_p < 0.001){
        p_level  = "less than 0.001 (***)"
      } else if(lr_p < 0.01){
        p_level  = "less than 0.01 (**)"
      } else if (lr_p < 0.05){
        p_level  = "less than 0.05 (*)"
      } else {
        p_level = as.character(round(lr_p,4))
      }
  
  # fit the curve
  fit = survfit(Surv(time,event) ~ groups, data = dat, conf.type = "log-log")
  s = summary(fit)$table
  
  mean_df = data.frame(
    group    = rownames(s),
    rmean    = s[, "rmean"],
    se       = s[, "se(rmean)"],
    lower_ci = s[, "rmean"] - 1.96 * s[, "se(rmean)"],
    upper_ci = s[, "rmean"] + 1.96 * s[, "se(rmean)"])
  
  q = quantile(fit, probs = c(0.25, 0.5, 0.75), conf.int = TRUE)
  
  quantile_df = data.frame(
    group = rownames(q$quantile),
    q25   = q$quantile[, "25"], q25_lower = q$lower[, "25"], q25_upper = q$upper[, "25"],
    q50   = q$quantile[, "50"], q50_lower = q$lower[, "50"], q50_upper = q$upper[, "50"],
    q75   = q$quantile[, "75"], q75_lower = q$lower[, "75"], q75_upper = q$upper[, "75"]
  )
  

  # interpretation
result = if(lr_p < threshold){
    int <- paste0("We reject the null hypothesis and conclude that there is a statistically significant difference in survival between groups (consistent across tests)",
        " under the significance level of ",as.character(threshold), ". The test being used is ", 
        as.character(test),
        ". The p.value is ", as.character(p_level))
    if (test == "log-rank test"){
      int
    } else if (test == "log-rank test and Bonferroni Correction"){
      list(int, print(fit_pairwise))
    }
  } else {
    paste0("We do not reject the null hypothesis and conclude that there is no statistically significant survival difference under the significance level of ",
          as.character(threshold),". The p.value is ", as.character(p_level))
  }

  
  return(list(
    logrank = c(chisq = lr_chisq, p.value = lr_p),
    result = result,
    degrees_of_freedom = lr_df,
    survival_mean_CI = mean_df,
    survival_quantile_CI = quantile_df,
    graph = graph_lrt(groups,event,time)
  ))
}

