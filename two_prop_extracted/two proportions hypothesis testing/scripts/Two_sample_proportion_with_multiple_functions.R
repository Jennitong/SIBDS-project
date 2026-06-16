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
# the major code
two_sample_proportion_test <- function(n.tx, n.ctrl, resp.tx, resp.ctrl, threshold = 0.05){
  
  validate_inputs(n.tx,n.ctrl,resp.tx,resp.ctrl)
  
  contingency <- matrix(c(resp.tx,resp.ctrl,n.tx - resp.tx,n.ctrl - resp.ctrl),
                        nrow = 2,byrow = TRUE)
  test_type <- choose_test(contingency)
  test_result <- run_selected_test(contingency,test_type)
  interpretation <- interpret_test(test_result$p_value,threshold)
  return(cat(
    "We are conducting a hypothesis testing question.",
    "We assume that the data represent a random sample from the population,",
    "and the individual values in the sample are independent of each other.",
    "We are interested in the two-sided hypothesis test of whether receiving treatments or not is associated with the response rate.",
    "Our null hypothesis is that treatment groups and response rate are independent.",
    "The response rate in the treatment arm is",
    round(resp.tx/n.tx,3), "and", round(resp.ctrl/n.ctrl,3), "in the control arm.",
    "We perform",  test_result$test_name, ". The", test_result$statistic_label,
    "is", round(test_result$statistic,4), "with p-value", interpretation$p_level,
    ". At significance level", threshold,  ", we", interpretation$decision,
    "the null hypothesis. There is", interpretation$evidence,
    "statistically significant evidence that response rates differ.", interpretation$conclusion
  ))
}

