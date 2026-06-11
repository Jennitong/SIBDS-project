---
name: two-proportion-test
description: >
  Performs a two proportion hypothesis test in R given four numbers: treatment total,
  control total, treatment responses, and control responses. Automatically selects
  between a chi-square test and Fisher's exact test based on expected cell count
  criteria (≥ 5 rule), explains the assumptions of the chosen test, and returns
  a complete interpretation and conclusion paragraph. Use this skill whenever the
  user provides counts from a two-group experiment and wants to compare proportions
  or test for a significant difference — even if they don't use the words "proportion
  test" or "A/B test". Trigger on phrases like "is this significant?", "did the
  treatment work?", "compare two groups", "conversion rate test", "summary","decision",
  "statistical tests", "summary statistics" or whenever four numeric inputs represent group 
  sizes and success counts. 
---

# Two-Sample Proportion Test Skill (R)

## Inputs

Ask the user for exactly four numbers if they have not already provided them:

| Variable | Symbol | Meaning |
|---|---|---|
| Treatment total | n.tr | Number of subjects in the treatment group |
| Control total | n.ctrl | Number of subjects in the control group |
| Treatment responses | resp.tr | Number of successes/responses in the treatment group/arm |
| Control responses | resp.ctrl | Number of successes/responses in the control group/arm |

## Step 1 — Validate Inputs

Before running any test, check all of the following. If any check fails, report the issue clearly and stop.

- All four values are **positive integers**
- resp.ctrl ≤ n.ctrl and resp.tr ≤ n.tr (responses cannot exceed totals)
- n.tr ≥ 1 and n.ctrl ≥ 1
- All four variables are not NA

## Step 2 - Creating Contingency tables using the four input values and arithmatic operations

|---------|Response|No response|
|Treatment| resp.tr|n.tr-resp.tr|
|Control  |resp.ctrl|n.ctrl-resp.ctrl|

## Step 3 — Choose the Correct Test

Compute the **expected cell counts** under the null hypothesis using row sums, column sums and total participants:

```
Expected counts:
  E(treatment responses) = (resp.tr+resp.ctrl)*(n.tr-resp.tr+resp.tr)/(n.tr+n.ctrl)
  E(treatment no response)    = (n.tr-resp.tr+n.ctrl-resp.ctrl)*(n.tr-resp.tr+resp.tr)/(n.tr+n.ctrl)
  E(control responses)     = (resp.tr+resp.ctrl)*(resp.ctrl+n.ctrl-resp.ctrl)/(n.tr+n.ctrl)
  E(control no responses)      = (n.ctrl-resp.ctrl+resp.ctrl)*(n.tr-resp.tr+n.ctrl-resp.ctrl)/(n.tr+n.ctrl)
```

**Decision rule:**
- If **all four expected counts ≥ 5** → use **Chi-square test** (`prop.test`)
- If **any expected count < 5** → use **Fisher's exact test** (`fisher.test`)

State which test was chosen and why (mention the smallest expected count).

## Step 3 — Assumptions

Before showing results, briefly explain the assumptions of the chosen test:

### Chi-square test assumptions
1. The two groups are **independent** random samples.
2. Each observation is **binary** (success or failure).
3. **Expected cell counts ≥ 5** in all cells of the 2×2 contingency table (the condition we just verified).
4. Sample size is large enough for the chi-square approximation to be reliable.

### Fisher's exact test assumptions
1. The two groups are **independent** random samples.
2. Each observation is **binary** (success or failure).
3. The marginal totals (row and column sums) are treated as **fixed** — Fisher's exact makes no large-sample approximation, which is why it is preferred when expected counts are small.

## Step 4 — R Code

Present the complete function below to the user, then call it with the actual input values to produce the output. Do **not** substitute values into the function body — call it at the bottom as shown.

```r
two_sample_proportion_test <- function(n.tx, n.ctrl, resp.tx, resp.ctrl, threshold = 0.05) {

  # --- Input validation ---
  if (n.tx < resp.tx |
      n.ctrl < resp.ctrl |
      any(is.na(c(n.tx, n.ctrl, resp.tx, resp.ctrl))) |
      any(c(n.tx, n.ctrl) <= 0) | any(c(resp.tx, resp.ctrl) < 0) |
      any(c(n.tx, n.ctrl, resp.tx, resp.ctrl) %% 1 != 0)) {
    return("Error: Input invalid. Please check for the correct numerical values.")
  }

  # --- Build 2×2 contingency table ---
  contigency <- matrix(
    c(resp.tx, resp.ctrl,
      n.tx - resp.tx, n.ctrl - resp.ctrl),
    nrow = 2, byrow = TRUE)

  # --- Run both tests; select based on expected counts ---
  chisqtest  <- suppressWarnings(chisq.test(contigency, correct = FALSE))
  fishertest <- suppressWarnings(fisher.test(contigency))

  if (all(chisqtest$expected >= 5)) {
    # Chi-square path
    p_value        <- chisqtest$p.value
    statistic      <- chisqtest$statistic
    statistic_label <- "test statistic"
    hypothesis.test <- "Chi squared test"
  } else {
    # Fisher's exact path
    p_value        <- fishertest$p.value
    statistic      <- fishertest$estimate
    statistic_label <- "odds ratio"
    hypothesis.test <- "Fisher's exact test"
  }

  # --- Significance stars ---
  if (p_value < 0.001) {
    p_level <- "less than 0.001 (***)"
  } else if (p_value < 0.01) {
    p_level <- "less than 0.01 (**)"
  } else if (p_value < 0.05) {
    p_level <- "less than 0.05 (*)"
  } else {
    p_level <- as.character(round(p_value, 4))
  }

  # --- Decision ---
  if (p_value <= threshold) {
    result <- "reject"
    diff   <- "sufficient"
    end    <- "Thus receiving treatment or not is associated with the response."
  } else {
    result <- "fail to reject"
    diff   <- "no"
    end    <- "Thus receiving treatment or not is not associated with the response."
  }

  return(cat(
    "We are conducting a hypothesis testing question. We assume that the data represent a random sample from the population, ",
    "and the individual values in the sample are independent of each other. ",
    "We are interested in the two-sided hypothesis test of whether receiving treatments or not is associated with the response rate. ",
    "Our null hypothesis is that treatment groups and response rate are independent, ",
    "meaning that when the two are not associated, then regardless of the types of groups, ",
    "there should be the same rate of response within each group, ",
    "and the alternative hypothesis is that they are associated, so the response rates differ between the two groups. ",
    "In this study, each variable is a binary outcome, treatment/control, and response/no-response. There is a total of ",
    n.tx + n.ctrl, " individuals in the group. ",
    "We perform the hypothesis test using ", hypothesis.test,
    ". The response rate in the treatment arm is ", round(resp.tx / n.tx, 3),
    ", and is ", round(resp.ctrl / n.ctrl, 3), " in control group. ",
    "At the two sided significance level of ", threshold, ", and the sample size of ",
    n.tx, " in the treatment group and ", n.ctrl, " in the control group, we would get a ", statistic_label, " of ",
    round(statistic, 4), " and the associated p-value of the test is ", p_level, ". We conclude that we ", result,
    " the null hypothesis, and there is ", diff,
    " statistically significant evidence that the response rate differs between treatment and control groups. ", end))
}

# --- Call with user's values ---
two_sample_proportion_test(n.tx = <n1>, n.ctrl = <n0>, resp.tx = <x1>, resp.ctrl = <x0>)
```

Replace `<n1>`, `<n0>`, `<x1>`, `<x0>` with the actual numbers before presenting to the user. The `threshold` argument defaults to 0.05; if the user specifies a different significance level, pass it explicitly (e.g., `threshold = 0.01`).

**Reproducing the output mentally:** trace through the function logic with the given numbers so you can report the exact paragraph the function would print, rather than a paraphrase.

## Step 5 — Output

Write a single cohesive paragraph followed by a summary table. The paragraph must address all four elements in this order:

1. **Background** — state the group sizes, observed responses, and conversion rates for each group.
2. **Test chosen and assumptions** — name the test selected, briefly state why (expected counts), and confirm the key assumptions are met.
3. **Testing conclusion** — report the test statistic, degrees of freedom (if chi-square), p-value (to 4 decimal places), and whether p < 0.05.
4. **Decision and interpretation** — state whether we reject or fail to reject H₀ (that the two proportions are equal), and explain what this means in plain language for the user's context.

**Tone:** Professional but accessible. Write for a stakeholder who understands "statistically significant" but does not need to verify the math. Define p-value briefly inline on first use as "the probability of observing a difference this large (or larger) by chance alone if there were truly no effect."

**Summary table** (after the paragraph):

| Metric | Treatment | Control |
|---|---|---|
| Total (n) | n₁ | n₀ |
| Responses (x) | x₁ | x₀ |
| Rate (p̂) | p̂₁ % | p̂₀ % |
| Absolute difference | Δ = p̂₁ − p̂₀ | — |

Then one line: `Test: [Chi-square / Fisher's exact] | Statistic: X² = … (df=1) or OR = … | p-value = … | α = 0.05`

## Examples

### Example A — Chi-square (large samples)

Input: n₁=2000, n₀=2000, x₁=340, x₀=280

> In this experiment, 2,000 subjects were assigned to the treatment group and 2,000 to the control group. The treatment group showed 340 successes (17.0% rate) versus 280 successes (14.0%) in the control group, an absolute difference of 3.0 percentage points. All four expected cell counts exceeded 5 (minimum ≈ 293), so the chi-square test of equal proportions was applied; the independence and binary-outcome assumptions are met. The test yielded X² = 6.87 (df = 1) and a p-value of 0.0088 — the probability of observing a 3-point gap or larger by chance alone if there were truly no effect. Because p < 0.05, we reject the null hypothesis that the two proportions are equal. The treatment is associated with a statistically significant increase in the success rate; the evidence supports a real difference rather than sampling variation.

### Example B — Fisher's exact (small samples)

Input: n₁=30, n₀=25, x₁=3, x₀=1

> With only 30 subjects in the treatment group and 25 in the control group, the treatment recorded 3 successes (10.0%) against 1 success (4.0%) in the control group. Because two of the four expected cell counts fell below 5 (minimum ≈ 1.27), Fisher's exact test was used instead of the chi-square approximation; this test makes no large-sample assumption and remains valid for small or sparse tables. Fisher's exact test returned a p-value of 0.6154. Because p > 0.05, we fail to reject the null hypothesis that the two proportions are equal. While the treatment group's rate is numerically higher, the samples are too small to distinguish this gap from chance variation — there is insufficient statistical evidence to conclude the treatment had a real effect.
