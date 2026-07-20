library(tidyverse)
library(survival)
library(ggsurvfit)
library(survminer)

# We will be using this code when there are two covariates as groups to be fixed on
# event should be a binary variable, 0 or 1. Thus, the event wither happens, or is censored
# time should be a numerical variable.

# To extract the correct variables from the dataset, ask the client which variable contains the group, event and time.
# Once extracted, put the variables into the function once called under the correct name and order.

validate_inputs <- function(group_1, group_2, event, time) {

  if (!(length(group_1) == length(group_2) &
        length(group_2) == length(event) &
        length(event) == length(time))) {
    stop(
      "Inputs not compatible: Incomplete data for certain participants.")}
  
  if (any(is.na(group_1)) | any(is.na(group_2)) |any(is.na(event)) | any(is.na(time))) {
    stop("Missing values detected in one or more variables.")}
  
  if (!is.numeric(time)) {
    stop("Data type not compatible: time to event must be numeric.")}

  if (any(is.infinite(time))) {stop("Time contains infinite values.")}
  
  if (any(time < 0)) {
    stop( "Time to event cannot be negative.")}
  
  if (!all(event %in% c(0, 1))) {
    stop("Event variable must contain only 0 (censored) and 1 (event).")}

  if (sum(event) == 0) {
    stop("No events observed in the dataset.")}
  
  if (length(unique(group_1)) < 2 | length(unique(group_2)) < 2){
    stop( "group_1 must contain at least two levels.")}
  
  interaction_groups <- interaction(group_1, group_2, drop = TRUE)
  
  if (length(unique(interaction_groups)) < 2) {
    stop(
      "The interaction of two covariates must contain at least two groups.")}
  
  events_by_interaction <- tapply(
    event,
    interaction_groups,
    sum
  )
  
  if (any(events_by_interaction == 0)) {
    warning(
      "One or more interaction groups contain no observed events.")}

}

graph_lrt <- function(group_1, group_2, event, time) {
  
  df <- data.frame(
    group_1 = as.factor(group_1),
    group_2 = as.factor(group_2),
    event   = event,
    time    = time)
  
  fit <- survfit2(
    Surv(time, event) ~ interaction(group_1, group_2, sep = "."),
    data = df)
  
  g1_levels <- levels(df$group_1)
  g2_levels <- levels(df$group_2)
  strata_labels <- as.vector(outer(g1_levels, g2_levels, paste, sep = "."))
  
  group_2_colors <- setNames(
    scales::hue_pal()(length(g2_levels)), g2_levels)
  lty_choices <- c("solid", "dashed", "dotted", "dotdash", "longdash", "twodash")
  group_1_ltys <- setNames(
    lty_choices[((seq_along(g1_levels) - 1) %% length(lty_choices)) + 1], g1_levels)
  
  strata_grid <- expand.grid(g1 = g1_levels, g2 = g2_levels, stringsAsFactors = FALSE)
  strata_cols <- setNames(group_2_colors[strata_grid$g2], strata_labels)
  strata_ltys <- setNames(group_1_ltys[strata_grid$g1], strata_labels)
  
  ggsurvfit(fit, linetype_aes = TRUE) +
    add_censor_mark() +
    add_pvalue(
      location = "annotation",
      caption  = "log-rank {p.value}"
    ) +
    scale_color_manual(values = strata_cols) +
    scale_linetype_manual(values = strata_ltys) +
    labs(title = "Kaplan-Meier Estimates of Overall Survival Between Groups") +  
    theme(
      legend.position  = "bottom",
      legend.title     = element_text(size = 9),
      legend.text      = element_text(size = 8),
      legend.key.width = unit(1, "cm")
    )
}

## When confidence interval or quantile has missing values, just write "NA" in the correct place
lrt_test <- function(group_1, group_2, event, time, threshold = 0.05){
  
  validate_inputs(group_1, group_2, event, time)
  
  dat <- data.frame(group_1, group_2, event, time,
                    group = interaction(group_1, group_2))
  
  dat$group <- droplevels(interaction(group_1, group_2))

  
  fit_lr  <- survdiff(Surv(time, event) ~ group, data=dat)
  lr_chisq <- as.numeric(fit_lr$chisq)
  lr_df        <- length(fit_lr$n) - 1
  lr_p      <- as.numeric(pchisq(lr_chisq, lr_df, lower.tail = FALSE))
  fit_pairwise <- pairwise_survdiff(Surv(time, event) ~ group, data=dat,
                                      p.adjust.method = "bonferroni")$p.value
  test <- "log-rank test and Bonferroni Test"
  
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
  
  fit <- survfit(Surv(time, event) ~ group, data = dat, conf.type = "log-log")
  
  s <- summary(fit)$table
  
  mean_df <- data.frame(
    group    = rownames(s),
    rmean    = s[, "rmean"],
    se       = s[, "se(rmean)"],
    lower_ci = s[, "rmean"] - 1.96 * s[, "se(rmean)"],
    upper_ci = s[, "rmean"] + 1.96 * s[, "se(rmean)"]
  )
  
  q <- quantile(fit, probs = c(0.25, 0.5, 0.75), conf.int = TRUE)
  
  quantile_df <- data.frame(
    group     = rownames(q$quantile),
    q25       = q$quantile[, "25"], q25_lower = q$lower[, "25"], q25_upper = q$upper[, "25"],
    q50       = q$quantile[, "50"], q50_lower = q$lower[, "50"], q50_upper = q$upper[, "50"],
    q75       = q$quantile[, "75"], q75_lower = q$lower[, "75"], q75_upper = q$upper[, "75"]
  )
  
  
  # interpretation
  result <- if(lr_p < threshold){
    int <- paste0("We reject the null hypothesis and conclude that there is a statistically significant difference in survival between groups (consistent across tests)",
                  " under the significance level of ",as.character(threshold), ". The test being used is ", 
                  as.character(test),
                  ". The p.value is ", as.character(p_level))
    list(int, fit_pairwise)
    }else {
    paste0("We do not reject the null hypothesis and conclude that there is no statistically significant survival difference under the significan level of ",
           as.character(threshold),". The p.value is ", as.character(p_level))
    }
  
  group_summary = dat %>%
      group_by(group_1,group_2) %>%
      summarize(n = n(),
                event_happened = sum(event))
  
  return(list(
    logrank = c(chisq = lr_chisq, p.value = lr_p),
    result = result,
    degrees_of_freedom = lr_df,
    survival_mean_CI = mean_df,
    survival_quantile_CI = quantile_df,
    group_summary,
    graph = graph_lrt(group_1, group_2, event, time)
  ))
}
