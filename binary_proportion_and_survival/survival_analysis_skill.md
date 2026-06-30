# This is the survival analysis sub skill agent


---
name: survival-analysis
description: >
  Performs a survival analysis in R given a dataset with variables: time, event,
  categorical group 1, optional categorical group 2, and other vectors which might not be used.
  Automatically selects the log-rank test when the categorical variable has two levels,
  log-rank Bonferroni correction adjusted test for categorical variable with more than 2 levels 
  and when there are two categorical variables thus more interactions. Mention 
  the assumptions of the chosen test, and returns a complete interpretation and conclusion paragraph. 
  Use this skill whenever the data set or vectors, and ask for survival probabilities,
  quantile, Kaplan-Meier curve, censored-time-to-event or anything related to survival anlysis.
  This skill assumes Proportional Hazard Assumption (for log-rank test), Non-Informative Censoring,
  and Independent Observations.
---

**Highest order: Highest order: Display the Kaplan-Meier plot by rendering it via show_widget only after all text output (hypothesis test summary, tables) has been written. The show_widget call must be made strictly as the last action under Section 7 of the Output Specification, strictly after interaction table, or pairwise table when it is called. Never before. All other output must appear as plain markdown text in the chat response, not inside a widget. The plot should be the one rendered by R code `graph_lrt`, nothing else. **

- **note**: generate the graph inline using `svglite::svglite()`.


## Trigger

Use this skill when the user wants to perform survival analysis. Triggers include any mention of:
- "survival analysis", "Kaplan-Meier", "KM curve", "log-rank test"
- "time to event", "censored data", "event time"
- Requests to compare survival curves across groups
- Phrases like "how long until event", "survival probability", "median survival"

Do NOT use for general time-series analysis, regression without a censoring structure, or Cox proportional hazards unless explicitly requested alongside KM curves.

---

## Input Specification

The skill accepts input in one of two forms:

**Form A — Dataframe:** A single dataframe with at least 3 columns:
| Column | Type | Description |
|---|---|---|
| `event` | binary (0/1) | Whether the event occurred (1) or was censored (0) |
| `time` | numeric | Time to event or censoring |
| `group1` | categorical | Primary grouping variable |
| `group2` *(optional)* | categorical | Secondary grouping variable (triggers interaction analysis) |

**Form B — Separate vectors:** Three (or four) individual vectors with identical length passed as arguments, in order: `event`, `time`, `group1`, and optionally `group2`.

**Validation checks to perform before analysis:**
- `event` contains only 0 and 1 (no NAs unless user confirms listwise deletion)
- `time` is strictly positive numeric
- All vectors/columns have the same number of observations
- At least one event (1) exists in the data
- Each level of `group1` (and `group2` if present) has at least one event

If there are over 4 variables, let the user specify which two groups should be used as the two categorical variables.
---

## Analysis Steps

### Step 1 — Fit the Kaplan-Meier Estimator

When there is only one categorical group variable, refer to 'scripts/survival_single_groups.R'
From the skill's directory (the folder containing this `survival_analysis_skill.md`), run:

```bash
cd "<path-to-skill-directory>" && Rscript -e "
source('scripts/survival_single_groups.R')
lrt_test <- function(groups = <groups>, event = <event>, time = <time>, threshold)
"
```

When there are two categorical groups variable, refer to 'scripts/two_groups_combined.R'
From the skill's directory (the folder containing this `survival_analysis_skill.md`), run:

```bash
cd "<path-to-skill-directory>" && Rscript -e "
source('scripts/two_groups_combined.R')
lrt_test <- function(group_1 = <group1>, group_2 =<group2>, event = <event>, time =<time>, threshold)
"
```


Replace `<groups>`,`<group1>`, `<group2>`, `<time>`, `<event>` with the actual vectors. Replace `<path-to-skill-directory>` with the actual absolute path to the folder containing this binary_proportion_skill.md`. The `threshold` argument defaults to 0.05; if the user specifies a different significance level, pass it explicitly (e.g., `threshold = 0.01`).

### Step 2 — Log-Rank Test (Chi-Square Test of Equality)

Run the appropriate R scirpt depending on how many variables there are. When there are two categorical variables or one categorical variable with more than two levels, be sure to apply Bonferroni Correction. Otherwise this is not needed.

Extract and report:
- **Chi-square test statistic**
- **Degrees of freedom** (number of groups minus 1; with two covariates, report df for the overall test)
- **p-value** (with significance stars: `***` p < 0.001, `**` p < 0.01, `*` p < 0.05, ` ` p ≥ 0.05)
- **Decision:** "Reject Null Hypothesis" if p < 0.05, otherwise "Fail to reject Null Hypothesis"
- **Null Hypothesis statement:** Survival curves are identical across all groups

### Step 3 — Quantiles (Median and Percentiles)

From the R code summary, refer to `survival_quantile_CI`, extract for each group:
- **Median survival** (50th percentile) with **95% CI**
- **25th percentile** survival time with **95% CI**
- **75th percentile** survival time with **95% CI**

Present as a formatted table (one row per group/strata).

"When extracting quantile values from survival_quantile_CI, replace any NA value with NR (Not Reached) before displaying. This applies to all quantile columns (q25, q50, q75) and their confidence interval bounds."


### Step 4 — Mean Survival with Confidence Interval

Use appropriate R code and refer to `survival_mean_CI` to find the mean survival and confidence interval

Report per group:
- **Mean survival time** (restricted mean up to the largest observed time)
- **Standard error** and **95% CI** for the mean, when the user did not change the significance level, `threshold`.

Present as a formatted separate table.

### Step 5 — Number of Interactions (Two-Covariate Case Only)

If `group2` is provided:
- Report the **total number of strata** = levels(group1) × levels(group2)
- List all strata combinations with their event counts and sample sizes
- Note any empty or sparse cells (< 5 events) as a warning

Present as a list (For each interaction, show counts).

### Step 6 - Pairwise Table  Pairwise plot (if more than two levels of the single categorical variable OR two covariates, AND p value is less than the threshold)
Make sure that the p value indicates significant result, then refer to the appropriate R code and `fit_pairwise`

Present as a formatted table (pairwise p value table for levels or interactions)

### Step 7 — Kaplan-Meier Plot

**Note: show the plot directly inline following the correct order**

Produce a KM survival curve plot using `graph_lrt(groups,event,time)`, or `graph_lrt(group_1, group_2, event, time)` in the R codes.

Required plot elements, as specified in the code:
- Separate curves per group/strata, with distinct colors and a legend
- 95% confidence bands (shaded or dashed)
- Risk table below the plot (number at risk at each time point)
- Axis labels: x = "Time", y = "Survival Probability"
- Title indicating the grouping variable(s)
- Ticks for censored marks
- Annotate with p-value from log-rank test on the plot

## Step 8 — Ask for Detail Level and Export Preference

Ask for the response level using the exact wording as below:

> Assuming these vector inputs are correct (time = `<time>`, event = `<event>`, categorical group = `<group1>`, and (*optional*) categorical group 2 = `<group2>`), we will proceed with the analysis. Would you like a **brief** (test statistic, p-value, graph, and one-line conclusion), **moderate** (adds assumption checks and supporting tables), or **detailed** (full background, definitions, and step-by-step interpretation) response?

Output **exactly** the above sentence — nothing before it, nothing after except waiting for the user's reply. Do not show formulas, intermediate tables, or any other text.

**note: Assuming these vector inputs are correct, do not ask for confirmation.**
---

## Step 9 — Output

**Tone for all levels:** Professional but accessible. Write for a stakeholder who understands "statistically significant" but does not need to verify the math. Define p-value briefly inline for people who chose "detailed response" as "the probability of observing a difference this large (or larger) by chance alone if there were truly no effect." Also explicitly state what the null hypothesis refers to in "moderate" and "detailed" response chosers. Never show the R code in output.

---
### Brief

2–3 sentences covering: test used(log-rank test and whether Bonferroni correction is used), key result (chi-sq statistic + p-value (4 decimal places if ≥ 0.05, otherwise `< 0.05`, `< 0.01`, or `< 0.001` with stars)), and decision (reject / fail to reject null hypothesis), 50th quantile and its confidence interval, mean survival probability and confidence interval, Kaplan Meier curve.

No table displayed.
---

### Moderate

A single cohesive paragraph covering all four elements in order:

1. **Background** — censoring event, time to event, levels in the group or interactions
2. **Test chosen and assumptions** — test name, why it was selected (proportional hazard assumption), other key assumptions met.
3. **Test result** — test statistic (X²), degrees of freedom, p-value (4 decimal places if ≥ 0.05, otherwise `< 0.05`, `< 0.01`, or `< 0.001` with stars), and confidence interval and quantiles as **Quantile Table**, mean survival and confidence interval as **Mean Survival Table**, Kaplan-Meier curve as **Kaplan-Meier Plot**.
4. **Decision** — reject or fail to reject null hypothesis, and what that means in plain language.

Return **Interaction Summary** and **Pairwise Table** only when needed and conditions met.
---

### Detailed

The full **Moderate** paragraph and plot, then:

A short **Plain-language interpretation** section (3–5 sentences) written for a non-statistical audience: what does this result mean practically, what can and cannot be concluded, and any relevant caveats (e.g., statistical significance ≠ clinical or practical significance), the definition of p-value, the correct interpretation of confidence interval (We are (1-`<threshold>`)% confident that the true difference of probability of response between the two groups falls within `<confint>`. )

- extract the `<confint>` from the output of `Two_sample_proportion_with_multiple_functions.R`, and `<threshold>` is the significance level, which is 5% by default, unless specified.

---
Note: All R code chunks must use echo = FALSE (set globally in the setup chunk) so no R code is visible in the rendered report. Clients should not see the code.

---

## Output Specification

Return the following based on the response brief/moderate/detailed level, in order:

**if any of the following is required, be sure to follow the order that things are mentioned (of those required) as below when displayed.**

### Hypothesis Test Summary
Null Hypothesis: Survival curves are identical across all groups of [group1] [and group2].
Alternative Hypothesis: At least one survival curve differs.

Chi-square statistic: X.XX
Degrees of freedom:   X
p-value:              X.XXXX [* / ** / *** / (none)]
Decision:             Reject Null Hypothesis  /  Fail to reject Null Hypothesis  at significance level = 0.05


### Quantile Table
One row per group/strata. Columns: Group | Median (95% CI) | Q25 (95% CI) | Q75 (95% CI)


For **two categorical dataset** only, refer to the `two_groups_combined.R` file in the same path, and refer to `group_summary` to find relevant `n` and `Events` for this table.

"Any NA in the Median, Q25, or Q75 columns (including CI bounds) must be displayed as NR in the table. Do not display raw NA."

If there are NR in the table, output the exact sentence beneath the quantile table: **NR = Not Reached. The survival estimate did not decline to the specified percentile during the follow-up period.**

###  Mean Survival Table
One row per group/strata. Columns: Group | Mean Survival | SE | 95% CI Lower | 95% CI Upper


###  Interaction Summary *(only if two covariates)*
List of all strata (group1 × group2 combinations) with n, events, and any sparsity warnings.

### Pairwise Table *(only if more than two levels of the single categorical variablee OR two covariates, AND p value is less than the threshold)*
Pairwise table for p values among groups or interactions.

### Kaplan-Meier Plot
**The plot must be rendered under the Kaplan-Meier Plot in the order as specified. Must be in line in correct order, not else where.**
Rendered inline in the window directly, so the user could see without the need of downloading anything.
Must be displayed explicitly. show the exact plot rendered using R code.

DO NOT shade confidence intervals in the plot. The margin should only contain the groups and color/linetype used, as rendered using R code. Nothing else.

**note: do not add additional notation section**

---

## Edge Cases & Warnings

| Situation | Behavior |
|---|---|
| All observations censored (event = 0) | Abort with error: "No events observed — survival analysis not possible." |
| A group has 0 events | Warn: "Group [X] has no events; quantiles/median will be undefined." |
| Tied event times | Handled automatically by `survfit` (Efron method by default) |
| Empty interaction cell | Warn: "Strata [X × Y] has no observations." |
| Single group (no covariate levels > 1) | Skip log-rank test; report KM curve and summary only |
| NAs in any column | Warn and apply listwise deletion; report number of rows removed |

---


## Step 10 — R Markdown / HTML Export (if requested)

After output has been printed out in the Claude window, lastly ask 

> Would you also like the results exported as an **R Markdown (.Rmd) and rendered HTML file**?

**If the user said yes to export:** sub-skill defined in `survival_rmd_export.md` (located in the same directory as this file). That sub-skill handles all file generation and rendering — do not duplicate its instructions here.

**If the user said no (or did not request export):** close the session with a brief sign-off, e.g.:

> "The analysis is complete. Feel free to start a new session if you have additional questions."

Do not prompt again or offer alternative formats.

---

## Table Formatting 
**rules that should be followed when showing tables**

When creating tables:

- Use bold headers
- Use alignment markers
- Add section breaks between tables

---

## Notes

- All confidence intervals are 95% by default; the user may specify a different level.
- The mean survival time is bounded by the largest observed time in each stratum; report this bound explicitly.
- If the user requests Cox regression in addition to KM curves, treat that as a separate, out-of-scope request and suggest a Cox PH skill.
- There is no need to add anything notation. Use the appropriate symbols directly, and you do not need to add additional details to explain any symbol and notation used.
