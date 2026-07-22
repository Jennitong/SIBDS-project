---
name: "survival-analysis"
description: >-
  Performs a survival analysis in R given a dataset with variables: time,
  event, categorical group 1, optional categorical group 2, and other
  vectors which might not be used. Automatically selects the log-rank test
  when the categorical variable has two levels, a Bonferroni-corrected
  log-rank test for a categorical variable with more than two levels or when
  there are two categorical variables (more interactions). States the
  assumptions of the chosen test and returns a complete interpretation and
  conclusion paragraph. Use whenever the client provides a dataset or
  vectors and asks for survival probabilities, quantiles, a Kaplan-Meier
  curve, censored time-to-event analysis, or anything related to survival
  analysis. Assumes the Proportional Hazard assumption (for the log-rank
  test), Non-Informative Censoring, and Independent Observations.
---

# Survival Analysis Skill (R)

## Highest Order Rule

Display the Kaplan-Meier plot by rendering it via `view_image` only after
all text output (hypothesis test summary, tables) has been written. The
`view_image` call must be made strictly as the last action under the
"Kaplan-Meier Plot" section of the Output Specification, strictly after the
pairwise table when it is called. Never before. All other output must
appear as plain markdown text in the response, not as an image.

The plot is the one rendered by `graph_lrt` in the R code, saved to a PNG
file and nothing else.

## Sandbox Policy

Recommended mode: `workspace-write`

Rationale: runs `scripts/survival_single_groups.R` or
`scripts/two_groups_combined.R` via the terminal command tool and writes a
plot image (and, on request, `.Rmd`/`.html` files) to the working directory.

## Trigger

Use this skill when the client wants to perform survival analysis. Triggers
include any mention of:
- "survival analysis", "Kaplan-Meier", "KM curve", "log-rank test"
- "time to event", "censored data", "event time"
- Requests to compare survival curves across groups
- Phrases like "how long until event", "survival probability", "median
  survival"

Do NOT use for general time-series analysis, regression without a censoring
structure, or Cox proportional hazards unless explicitly requested alongside
KM curves.

---

## Input Specification

The skill accepts input in one of two forms:

**Form A -- Dataframe:** A single dataframe with at least 3 columns:
| Column | Type | Description |
|---|---|---|
| `event` | binary (0/1) | Whether the event occurred (1) or was censored (0) |
| `time` | numeric | Time to event or censoring |
| `group1` | categorical | Primary grouping variable |
| `group2` *(optional)* | categorical | Secondary grouping variable |

**Form B -- Separate vectors:** Three (or four) individual vectors with
identical length passed as arguments, in order: `event`, `time`, `group1`,
and optionally `group2`.

**Validation checks to perform before analysis:**
- `event` contains only 0 and 1 (no NAs unless client confirms listwise
  deletion)
- `time` is strictly positive numeric
- All vectors/columns have the same number of observations
- At least one event (1) exists in the data
- Each level of `group1` (and `group2` if present) has at least one event

If there are more than 4 variables, let the client specify which two groups
should be used as the two categorical variables.

**Note for labelling**: If `group1` (or `group2`) has exactly two unique
values that are not already self-descriptive (e.g., numeric codes like 0/1,
1/2, TRUE/FALSE), ask the client which value corresponds to which label
before proceeding. Skip this if the values are already descriptive strings
(e.g., 'Male'/'Female'). Use exact question wording, e.g. "I see [group1] is
coded as 0/1 -- which value corresponds to which group (e.g., 0 = female,
1 = male)?"

---

## Analysis Steps

### Step 1 -- Fit the Kaplan-Meier Estimator

When there is only one categorical group variable, refer to
`scripts/survival_single_groups.R`. From the skill's directory (the folder
containing this `survival-analysis.md`), run:

```bash
cd "<path-to-skill-directory>" && Rscript -e "
source('scripts/survival_single_groups.R')
res <- lrt_test(groups = <groups>, event = <event>, time = <time>, threshold = <threshold>)
ggplot2::ggsave('km_plot.png', plot = res\$graph, width = 8, height = 6, dpi = 120)
"
```

For `lrt_test`, build a factor (e.g. `factor(<groups>, levels = c(0,1),
labels = c("Female","Male"))`, using whatever mapping the client gave) and
substitute that in place of `<groups>` in the Rscript call, so the tables,
plot, and any description use the labelling the client provided, not the
raw numbers.

When there are two categorical group variables, refer to
`scripts/two_groups_combined.R`. From the skill's directory, run:

```bash
cd "<path-to-skill-directory>" && Rscript -e "
source('scripts/two_groups_combined.R')
res <- lrt_test(group_1 = <group1>, group_2 = <group2>, event = <event>, time = <time>, threshold = <threshold>)
ggplot2::ggsave('km_plot.png', plot = res\$graph, width = 8, height = 6, dpi = 120)
"
```

Replace `<groups>`, `<group1>`, `<group2>`, `<time>`, `<event>`, `<threshold>`
with the actual vectors/value. Replace `<path-to-skill-directory>` with the
actual absolute path to the folder containing this file. `threshold`
defaults to 0.05; if the client specifies a different significance level,
pass it explicitly (e.g., `threshold = 0.01`).

`km_plot.png` is written to the skill's working directory; display it with
`view_image` at the point specified in the Output Specification's
Kaplan-Meier Plot section — never earlier, per the Highest Order Rule.

### Step 2 -- Log-Rank Test (Chi-Square Test of Equality)

Run the appropriate R script depending on how many variables there are. When
there are two categorical variables, or one categorical variable with more
than two levels, apply the Bonferroni correction (the scripts do this
automatically). Otherwise it is not needed.

Extract and report:
- **Chi-square test statistic**
- **Degrees of freedom** (number of groups minus 1; with two covariates,
  report df for the overall test)
- **p-value** (with significance stars: `***` p < 0.001, `**` p < 0.01, `*`
  p < 0.05, ` ` p >= 0.05)
- **Decision:** "Reject Null Hypothesis" if p < 0.05, otherwise "Fail to
  reject Null Hypothesis"
- **Null Hypothesis statement:** Survival curves are identical across all
  groups

### Step 3 -- Quantiles (Median and Percentiles)

From the R result's `survival_quantile_CI`, extract for each group:
- **Median survival** (50th percentile) with **95% CI**
- **25th percentile** survival time with **95% CI**
- **75th percentile** survival time with **95% CI**

Present as a formatted table (one row per group/strata).

When extracting quantile values from `survival_quantile_CI`, replace any NA
value with NR (Not Reached) before displaying. This applies to all quantile
columns (q25, q50, q75) and their confidence interval bounds.

### Step 4 -- Mean Survival with Confidence Interval

Use the R result's `survival_mean_CI` to find the mean survival and
confidence interval.

Report per group:
- **Mean survival time** (restricted mean up to the largest observed time)
- **Standard error** and **95% CI** for the mean, when the client did not
  change the significance level, `threshold`.

Present as a formatted, separate table.

### Step 5 -- Pairwise Table / Pairwise Plot (if more than two levels of the single categorical variable OR two covariates, AND p-value is less than the threshold)

Confirm the p-value indicates a significant result, then refer to
`fit_pairwise` from the R result.

Present as a formatted table (pairwise p-value table for levels or
interactions).

### Step 6 -- Kaplan-Meier Plot (generation only; do not display yet)

Produce a KM survival curve plot using `graph_lrt(groups, event, time)` or
`graph_lrt(group_1, group_2, event, time)` — already generated and saved to
`km_plot.png` in Step 1. Do not call `view_image` here; the Highest Order
Rule fixes exactly where this image is shown.

Required plot elements, as specified in the R code:
- Separate curves per group/strata, with distinct colors and a legend
- 95% confidence bands (shaded or dashed)
- Risk table below the plot (number at risk at each time point)
- Axis labels: x = "Time", y = "Survival Probability"
- Title indicating the grouping variable(s)
- Ticks for censored marks
- Annotate with the p-value from the log-rank test on the plot

## Step 7 -- Ask for Detail Level and Export Preference

Output **exactly** the following block -- nothing before it, nothing after
except waiting for the client's reply. Do not show formulas, intermediate
tables, or any other text.

> Assuming these vector inputs are correct (time = `<time>`, event =
> `<event>`, categorical group = `<group1>`, and (*optional*) categorical
> group 2 = `<group2>`), we will proceed with the analysis. Would you like a
> **brief** (test statistic, p-value, graph, and one-line conclusion),
> **moderate** (adds assumption checks and supporting tables), or
> **detailed** (full background, definitions, and step-by-step
> interpretation) response?

**Note: Assuming these vector inputs are correct, do not ask for
confirmation.**

Show the client-given labels instead of raw codes once they've been
provided, rather than echoing raw values like "categorical group =
`<group1>`".

---

## Step 8 -- Output

**Tone for all levels:** Professional but accessible. Write for a
stakeholder who understands "statistically significant" but does not need
to verify the math. Define p-value briefly inline for clients who chose
"detailed response" as "the probability of observing a difference this
large (or larger) by chance alone if there were truly no effect." Also
explicitly state what the null hypothesis refers to for "moderate" and
"detailed" response choosers. Never show the R code in output.

---
### Brief

2-3 sentences covering: test used (log-rank test and whether Bonferroni
correction is used), key result (chi-sq statistic + p-value, 4 decimal
places if >= 0.05, otherwise `< 0.05`, `< 0.01`, or `< 0.001` with stars),
and decision (reject / fail to reject null hypothesis), 50th quantile and
its confidence interval, mean survival and confidence interval, and the
Kaplan-Meier curve.

No table displayed.
---

### Moderate

A single cohesive paragraph covering all four elements in order:

1. **Background** -- censoring event, time to event, levels in the group or
   interactions.
2. **Test chosen and assumptions** -- test name, why it was selected
   (proportional hazard assumption), other key assumptions met.
3. **Test result** -- test statistic (X²), degrees of freedom, p-value (4
   decimal places if >= 0.05, otherwise `< 0.05`, `< 0.01`, or `< 0.001`
   with stars), confidence interval and quantiles as **Quantile Table**,
   mean survival and confidence interval as **Mean Survival Table**, and the
   Kaplan-Meier curve as **Kaplan-Meier Plot**.
4. **Decision** -- reject or fail to reject the null hypothesis, and what
   that means in plain language.

Return the **Pairwise Table** only when needed and conditions are met.
---

### Detailed

The full **Moderate** paragraph and plot, then:

A short **Plain-language interpretation** section (3-5 sentences) written
for a non-statistical audience: what does this result mean practically,
what can and cannot be concluded, and any relevant caveats (e.g.,
statistical significance != clinical or practical significance), the
definition of p-value, and the correct interpretation of confidence
interval ("We are (1-`<threshold>`)% confident that the true median (or
mean) survival time for this group lies within the interval shown.").

---
Note: All R code chunks must use `echo = FALSE` (set globally in the setup
chunk) so no R code is visible in the rendered report. Clients should not
see the code.

---

## Output Specification

Return the following based on the response brief/moderate/detailed level,
in order:

**If any of the following is required, follow the order in which they are
listed below.**

### Hypothesis Test Summary
Null Hypothesis: Survival curves are identical across all groups of
[group1] [and group2].
Alternative Hypothesis: At least one survival curve differs.

Chi-square statistic: X.XX
Degrees of freedom:   X
p-value:              X.XXXX [* / ** / *** / (none)]
Decision:             Reject Null Hypothesis  /  Fail to reject Null
Hypothesis  at significance level = 0.05

### Quantile Table
One row per group/strata. Columns: Group | Median (95% CI) | Q25 (95% CI) |
Q75 (95% CI)

For a **two-categorical dataset** only, refer to `group_summary` (from
`two_groups_combined.R`) to find the relevant `n` and `Events` for this
table.

Any NA in the Median, Q25, or Q75 columns (including CI bounds) must be
displayed as NR in the table. Do not display raw NA.

If there are NR values in the table, output the exact sentence beneath the
quantile table: **NR = Not Reached. The survival estimate did not decline to
the specified percentile during the follow-up period.**

The "Group" column and plot legend must show the client-provided labels;
strip any `groups=` prefix R's `rownames()`/`summary()` output adds (e.g.,
"groups=Female" -> "Female").

### Mean Survival Table
One row per group/strata. Columns: Group | Mean Survival | SE | 95% CI Lower
| 95% CI Upper

The "Group" column and plot legend must show the client-provided labels;
strip any `groups=` prefix as above.

### Pairwise Table *(only if more than two levels of the single categorical variable OR two covariates, AND p-value is less than the threshold)*
Pairwise table for p-values among groups or interactions.

The "Group" column and plot legend must show the client-provided labels;
strip any `groups=` prefix as above.

### Kaplan-Meier Plot
**Must be rendered under the Kaplan-Meier Plot heading, in the order
specified — strictly the last thing shown at this detail level.** Render
inline with `view_image` on `km_plot.png` so the client can see it without
downloading anything.

Do NOT shade confidence intervals in the plot beyond what `graph_lrt`
already draws. The legend should only contain the groups and color/linetype
used, as rendered by the R code. Nothing else.

The "Group" column and plot legend must show the client-provided labels;
strip any `groups=` prefix as above.

**Note: do not add an additional notation section.**

---

## Edge Cases & Warnings

| Situation | Behavior |
|---|---|
| All observations censored (event = 0) | Abort with error: "No events observed -- survival analysis not possible." |
| A group has 0 events | Warn: "Group [X] has no events; quantiles/median will be undefined." |
| Tied event times | Handled automatically by `survfit` (Efron method by default) |
| Single group (no covariate levels > 1) | Skip log-rank test; report KM curve and summary only |
| NAs in any column | Warn and apply listwise deletion; report number of rows removed |

---

## Step 10 -- R Markdown / HTML Export (if requested)

After output has been shown, lastly ask:

> Would you also like this analysis exported as an **R Markdown (.Rmd) and
> rendered HTML report**?

**If the client said yes to export:** load and follow
`survival-rmd-export.md` (located in the same directory as this file). That
sub-skill handles all file generation and rendering -- do not duplicate its
instructions here.

**If the client said no (or did not request export):** close the session
with a brief sign-off, e.g.:

> "The analysis is complete. Feel free to start a new session if you have
> additional questions."

Do not prompt again or offer alternative formats.

---

## Table Formatting

**Rules that should be followed when showing tables:**

- Use bold headers
- Use alignment markers
- Add section breaks between tables

---

## Notes

- All confidence intervals are 95% by default; the client may specify a
  different level.
- The mean survival time is bounded by the largest observed time in each
  stratum; report this bound explicitly.
- If the client requests Cox regression in addition to KM curves, treat that
  as a separate, out-of-scope request and suggest a Cox PH skill.
- There is no need to add a notation section. Use the appropriate symbols
  directly; no additional explanation of symbols/notation is needed.
