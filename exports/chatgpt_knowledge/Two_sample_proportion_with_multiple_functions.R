## Two sample proportion test code for two binary inputs

# four inputs will be provided directly in context:
# the treatment arm total is denoted as n.tx
# the control arm total is denoted as n.ctrl
# the treatment arm response number is denoted as resp.tx
# the control arm response number is denoted as resp.ctrl

# threshold: this is the significance level, users can change it. By default it is 0.05

# In this code, we are using multiple helper functions, to get to the eventual hypothesis testing task
# Helper functions: validate_inputs, create_contingency_table, choose_test, run_selected_test, interpret_test, build conclusion
# the final code two_sample_proportion_test uses all the inputs and helper fuctions to get to the correct conclusion

# confirming valid inputs
library(Hmisc)
library(PropCIs)

validate_inputs <- function(n.tx, n.ctrl, resp.tx, resp.ctrl){
  
  if(n.tx < resp.tx |
     n.ctrl < resp.ctrl |
     any(is.na(c(n.tx,n.ctrl,resp.tx,resp.ctrl))) |
     any(c(n.tx,n.ctrl) <= 0) |
     any(c(resp.tx,resp.ctrl) < 0) |
     any(c(n.tx,n.ctrl,resp.tx,resp.ctrl) %% 1 != 0)){
    stop("Error: Input invalid. Please check numerical values.")
  }
  
}


# test decision: chisq test or fisher's exact test
choose_test <- function(contingency){
  
  chisq_result <- suppressWarnings(chisq.test(contingency, correct = FALSE))
  
  if(all(chisq_result$expected >= 5)){
    return("chisq")
  } else {
    return("fisher")
  }
  
}


#test computation
run_selected_test <- function(contingency, test_type){
  
  if(test_type == "chisq"){
    result <- suppressWarnings(chisq.test(contingency, correct = FALSE))
    return(
      list(
        test_name = "Chi squared test",
        p_value = result$p.value,
        statistic = unname(result$statistic),
        statistic_label = "test statistic"))}
  
  if(test_type == "fisher"){
    result <- suppressWarnings(fisher.test(contingency))
    return(
      list(
        test_name = "Fisher's exact test",
        p_value = result$p.value,
        statistic = round((resp.tx/(n.tx-resp.tx))/(resp.ctrl/(n.ctrl-resp.ctrl)),4),
        statistic_label = "sample odds ratio"))
  }
}

# labeling p-values
interpret_test <- function(p_value, threshold){
  if(p_value < 0.001){
    p_level <- "less than 0.001 (***)"
  } else if(p_value < 0.01){
    p_level <- "less than 0.01 (**)"
  } else if(p_value < 0.05){
    p_level <- "less than 0.05 (*)"
  } else {
    p_level <- as.character(round(p_value,4))
  }

  if(p_value <= threshold){
    
    return(
      list(
        p_level = p_level,
        decision = "reject",
        evidence = "sufficient",
        conclusion =
          "Thus receiving treatment or not is associated with the response."
      )
    )
  } else {
  
    return(
      list(
        p_level = p_level,
        decision = "fail to reject",
        evidence = "no",
        conclusion = "Thus receiving treatment or not is not associated with the response."
    ))
  }
  
}

confidence_int <- function(n.tx, n.ctrl, resp.tx, resp.ctrl, threshold = 0.05){
  # Clopper-Pearson (exact) CIs for each arm
  ci_tx   = round(binconf(x = resp.tx,  n = n.tx, method = "exact"),4)
  ci_ctrl = round(binconf(x = resp.ctrl,  n = n.ctrl,  method = "exact"),4)
  # Newcombe method
  ci_rd = diffscoreci(x1 = resp.tx, n1 = n.tx, x2 = resp.ctrl, n2 = n.ctrl, conf.level = 1-threshold)
  return(list(ci_tx = ci_tx,
              ci_ctrl = ci_ctrl,
              ci_rd = ci_rd))
}


# the major code
two_sample_proportion_test <- function(n.tx, n.ctrl, resp.tx, resp.ctrl, threshold = 0.05){
  
  validate_inputs(n.tx,n.ctrl,resp.tx,resp.ctrl)
  
  contingency <- matrix(c(resp.tx,resp.ctrl,n.tx - resp.tx,n.ctrl - resp.ctrl),
                        nrow = 2,byrow = TRUE)
  test_type <- choose_test(contingency)
  test_result <- run_selected_test(contingency, test_type)
  interpretation <- interpret_test(test_result$p_value,threshold)
  confint <- confidence_int(n.tx, n.ctrl, resp.tx, resp.ctrl, threshold)
  return(c(round(resp.tx/n.tx,3), round(resp.ctrl/n.ctrl,3),  test_result$test_name, test_result$statistic_label,
    round(test_result$statistic,4), interpretation$p_level, interpretation$decision,
    interpretation$evidence, interpretation$conclusion, confint
  ))
}

