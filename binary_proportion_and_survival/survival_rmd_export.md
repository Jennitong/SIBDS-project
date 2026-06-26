# Survival Analysis R Markdown Export Sub-Skill

> **This file is invoked only after the survival analysis results have already been shown in chat and the user confirms they want `.Rmd` and `.html` output.**
> It reproduces the same numbers, tables, and plots — no new analysis.

---

## Overview

Generate a self-contained `.Rmd` file and render it to `.html`. The rendered document must show exactly what the survival analysis skill already displayed: the same test statistic, the same tables, the same KM plot, and the same narrative at the chosen detail level (brief / moderate / detailed).

---

## Step 1 — Determine Script and Input Mode

**Single categorical group (`group1` only):** source `scripts/survival_single_groups.R`, call `lrt_test(groups, event, time, threshold)`.

**Two categorical groups (`group1` + `group2`):** source `scripts/two_groups_combined.R`, call `lrt_test(group_1, group_2, event, time, threshold)`.

Identify which applies from the earlier analysis, then fill placeholders below accordingly.

---

## Step 2 — Build the `.Rmd` File

### YAML Header

```yaml
---
title: "Survival Analysis Report"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_float: true
    html_encoding: "UTF-8"
encoding: UTF-8
---
```

### Setup Chunk (`echo=FALSE, include=FALSE`)

```r
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)
options(encoding = "UTF-8")

# Source the correct script — uncomment ONE line:
# source("scripts/survival_single_groups.R")   # one group variable
# source("scripts/two_groups_combined.R")       # two group variables

if (!requireNamespace("knitr",    quietly = TRUE)) install.packages("knitr")
if (!requireNamespace("kableExtra", quietly = TRUE)) install.packages("kableExtra")
library(knitr)
library(kableExtra)
```

### Computation Chunk (`echo=FALSE`)

**Single-group version:**

```r
# Replace vectors below with the actual data used in chat
groups    <- <groups_vector>
event     <- <event_vector>
time      <- <time_vector>
threshold <- 0.05   # replace if user specified a different level

res               <- lrt_test(groups, event, time, threshold)
lr_chisq          <- res$logrank["chisq"]
lr_p              <- res$logrank["p.value"]
lr_df             <- length(unique(groups)) - 1
survival_mean_CI  <- res$survival_mean_CI
survival_quantile_CI <- res$survival_quantile_CI
fit_pairwise_mat  <- NULL  # populated below only when > 2 levels with p < threshold
```

**Two-group version (replace the single-group block above):**

```r
group_1   <- <group1_vector>
group_2   <- <group2_vector>
event     <- <event_vector>
time      <- <time_vector>
threshold <- 0.05

res               <- lrt_test(group_1, group_2, event, time, threshold)
lr_chisq          <- res$logrank["chisq"]
lr_p              <- res$logrank["p.value"]
lr_df             <- length(unique(interaction(group_1, group_2))) - 1
survival_mean_CI  <- res$survival_mean_CI
survival_quantile_CI <- res$survival_quantile_CI
fit_pairwise_mat  <- NULL
```

**p-value label helper (add after either block above):**

```r
p_label <- if (lr_p < 0.001) {
  "< 0.001 (&#42;&#42;&#42;)"
} else if (lr_p < 0.01) {
  "< 0.01 (&#42;&#42;)"
} else if (lr_p < 0.05) {
  "< 0.05 (&#42;)"
} else {
  as.character(round(lr_p, 4))
}

decision <- if (lr_p < threshold) {
  "Reject Null Hypothesis"
} else {
  "Fail to Reject Null Hypothesis"
}
```

> **Why escape asterisks?** In R Markdown, `*` and `**` are Markdown bold/italic markers. Inside inline R or `paste()` calls they are consumed by the parser, turning `(***)` into `()`. Always write `&#42;` in place of `*` anywhere a p-value significance star must appear in the rendered HTML.

---

## Step 3 — Narrative Sections

Write Markdown prose. Use inline R `` `r expr` `` for all numbers so the report stays reproducible. Mirror the detail level selected by the user. Never show R code in the output.

---

### Symbol and Notation Rules

**note: these notation is included for the agent only. Do not display for client**

Use HTML entities everywhere — in Markdown prose, in `paste()` / `sprintf()` strings, and inside `knitr::kable()` cell values. Never paste raw Unicode glyphs.

| Concept | Wrong (raw glyph) | Correct (HTML entity) | Meaning |
|---|---|---|---|
| Chi-square statistic | χ² | `&chi;&sup2;` | Test statistic for log-rank test |
| Significance stars | * | `&#42;` | p < 0.05; `&#42;&#42;` = p < 0.01; `&#42;&#42;&#42;` = p < 0.001 |
| Degrees of freedom | — | write as plain text "df" | Number of groups minus 1 |
| Alpha / significance level | α | `&alpha;` | Threshold for decision (default 0.05) |
| Greater-or-equal | ≥ | `&ge;` | Used in censoring descriptions |
| Less-or-equal | ≤ | `&le;` | Used in confidence interval bounds |
| En dash | – | `&ndash;` | Ranges, e.g. "95% CI: 4.2&ndash;8.1" |
| Em dash | — | `&mdash;` | Sentence breaks |
| Times / cross | × | `&times;` | Strata combinations, e.g. "group1 &times; group2" |
| Delta | Δ | `&Delta;` | Not used in survival but included for consistency |
| Bullet | • | `&#8226;` | List items inside `paste()` strings |


---

### Brief Level

A single paragraph of 2–3 sentences covering:

1. Test used (log-rank test; state whether Bonferroni correction was applied and why).
2. Key result: &chi;&sup2; statistic (rounded to 2 decimal places), df, and p-value label from `p_label`.
3. Decision (reject / fail to reject the null hypothesis that survival curves are identical across groups).
4. Median survival (Q50) and 95% CI for each group, drawn from `survival_quantile_CI`.
5. Mean survival and 95% CI for each group, drawn from `survival_mean_CI`.
6. The KM plot rendered inline (see Step 4).

No tables displayed in brief mode.

---

### Moderate Level

A single cohesive paragraph in four parts:

**Note: show things in the order specifiedf below*

1. **Background** — what the event is, what time-to-event means in this context, how many groups or interactions exist.
2. **Test and assumptions** — log-rank test selected because survival curves are compared across independent groups; Bonferroni correction applied when more than two levels or two covariates exist. Key assumptions: Proportional Hazards (hazard ratio between groups is constant over time), Non-Informative Censoring (censoring is unrelated to the event), and Independent Observations.
3. **Results** — &chi;&sup2;(`r lr_df`) = `r round(lr_chisq, 2)`, p `r p_label`, followed by the **Quantile Table**, **Mean Survival Table**, and **KM Plot** (see Step 4 for table formats).
4. **Decision** — state `r decision` at significance level &alpha; = `r threshold`, and explain what this means in plain language (e.g., "there is/is not sufficient evidence that survival differs between the groups").

**note: Must obey the order of display**
When the conditions in Steps 5–6 are met, show:
5.  **Interaction Summary**
6. **Pairwise Table**
If conditions are not met, do not display 5 and 6.
---

### Detailed Level

The full Moderate paragraph and plot, then a **Plain-Language Interpretation** section (3–5 sentences) for a non-statistical audience:

- What does the result mean practically for the groups being compared?
- What can and cannot be concluded (statistical significance does not imply clinical or practical significance).
- Definition of p-value: "the probability of observing a difference this large or larger by chance alone, assuming no true difference exists."
- Correct interpretation of confidence interval: "We are `r (1 - threshold) * 100`% confident that the true median (or mean) survival time for this group lies within the interval shown."
- Any relevant caveats (small sample sizes, sparse strata, tied event times).

---

## Step 4 — Table and Plot Chunks

All chunks must have `echo=FALSE`. All `knitr::kable()` calls must use `format = "html"` and `escape = FALSE` so HTML entities render correctly.

### Table Formatting 
**rules that should be followed when showing tables**

When creating tables:

- Use bold headers
- Use alignment markers
- Add section breaks between tables


### Hypothesis Test Summary Block

```r
cat(paste0(
  "**Null Hypothesis:** Survival curves are identical across all groups.\n\n",
  "**Alternative Hypothesis:** At least one survival curve differs.\n\n",
  "| Statistic | Value |\n",
  "|---|---|\n",
  "| &chi;&sup2; statistic | ", round(lr_chisq, 2), " |\n",
  "| Degrees of freedom | ", lr_df, " |\n",
  "| p-value | ", p_label, " |\n",
  "| Decision | ", decision, " at &alpha; = ", threshold, " |\n\n"
))
```

Use `results='asis'` on this chunk so the Markdown table renders.

### Quantile Table

Show in moderate and detailed levels.

```r
qtbl <- data.frame(
  Group   = survival_quantile_CI$group,
  n       = "<fill from fit summary>",
  Events  = "<fill from fit summary>",
  `Median (95% CI)` = paste0(
    round(survival_quantile_CI$q50, 2),
    " (", round(survival_quantile_CI$q50_lower, 2),
    "&ndash;", round(survival_quantile_CI$q50_upper, 2), ")"),
  `Q25 (95% CI)` = paste0(
    round(survival_quantile_CI$q25, 2),
    " (", round(survival_quantile_CI$q25_lower, 2),
    "&ndash;", round(survival_quantile_CI$q25_upper, 2), ")"),
  `Q75 (95% CI)` = paste0(
    round(survival_quantile_CI$q75, 2),
    " (", round(survival_quantile_CI$q75_lower, 2),
    "&ndash;", round(survival_quantile_CI$q75_upper, 2), ")"),
  check.names = FALSE
)

knitr::kable(qtbl, format = "html", escape = FALSE,
             caption = "Survival Quantiles with 95% Confidence Intervals") %>%
  kableExtra::kable_styling(full_width = FALSE)
```

NA values in quantile columns mean the event was not reached by the end of follow-up; render as `"NR"` (Not Reached):

```r
qtbl[is.na(qtbl)] <- "NR"
```

### Mean Survival Table

Show in moderate and detailed levels.

```r
mtbl <- data.frame(
  Group             = survival_mean_CI$group,
  `Mean Survival`   = round(survival_mean_CI$rmean, 2),
  SE                = round(survival_mean_CI$se, 2),
  `95% CI Lower`    = round(survival_mean_CI$lower_ci, 2),
  `95% CI Upper`    = round(survival_mean_CI$upper_ci, 2),
  check.names = FALSE
)

knitr::kable(mtbl, format = "html", escape = FALSE,
             caption = "Restricted Mean Survival Time with 95% Confidence Intervals") %>%
  kableExtra::kable_styling(full_width = FALSE)
```

Add a note below the table: "Mean survival is bounded by the largest observed event time in each group (restricted mean survival time)."

### Interaction Summary (Two-Covariate Case Only)

When `group2` is present, list all strata with sample size and event count:

```r
# dat was created inside lrt_test(); re-create it here for the summary
dat_summary <- data.frame(group_1, group_2, event, time,
                          strata = interaction(group_1, group_2))
int_tbl <- dat_summary %>%
  dplyr::group_by(strata) %>%
  dplyr::summarise(n = dplyr::n(), Events = sum(event), .groups = "drop")

knitr::kable(int_tbl, format = "html", escape = FALSE,
             caption = "Interaction Strata Summary (group1 &times; group2)") %>%
  kableExtra::kable_styling(full_width = FALSE)
```

Flag any stratum with fewer than 5 events with a note: "Warning: stratum [X] has fewer than 5 events — results for this stratum should be interpreted cautiously."

### Pairwise Table (Conditional)

Show only when: (a) p < threshold AND (b) more than two levels of the single group OR two covariates are present.

```r
# fit_pairwise is the $p.value matrix from pairwise_survdiff (already computed in lrt_test)
# Re-run here to capture it:
# Single group, >2 levels:
fit_pairwise_obj <- pairwise_survdiff(Surv(time, event) ~ groups,
                                      data = data.frame(groups, event, time),
                                      p.adjust.method = "bonferroni")
# Two groups:
# fit_pairwise_obj <- pairwise_survdiff(Surv(time, event) ~ group,
#                                       data = dat,
#                                       p.adjust.method = "bonferroni")

pw_mat <- round(fit_pairwise_obj$p.value, 4)
pw_mat[is.na(pw_mat)] <- "—"

knitr::kable(pw_mat, format = "html", escape = FALSE,
             caption = "Pairwise Log-Rank p-values (Bonferroni-adjusted)") %>%
  kableExtra::kable_styling(full_width = FALSE)
```
### Kaplan-Meier Plot

Always include at all detail levels.

```r
# Single group:
graph_lrt(groups, event, time)

# Two groups:
# graph_lrt(group_1, group_2, event, time)
```

The `graph_lrt()` function already adds confidence bands, censoring marks, risk table (via `ggsurvfit` defaults), and the log-rank p-value annotation. No further modification is needed.

---

## Step 5 — Rendering Strategy

Try each step in order; move to the next only if the previous fails.

**Step 1 — Pandoc-free render (preferred)**

```r
if (!requireNamespace("markdown", quietly = TRUE)) install.packages("markdown")
knitr::knit("survival_report.Rmd", output = "survival_report.md")
markdown::markdownToHTML("survival_report.md", output = "survival_report.html",
                         options = c("use_xhtml", "smartypants", "toc"),
                         fragment.only = FALSE)
```

Do **not** pass `"skip_html"` — it would suppress `<a>` tags and inline HTML entities.

**Step 2 — rmarkdown render (if Pandoc is available)**

```r
rmarkdown::render("survival_report.Rmd", output_file = "survival_report.html")
```

Use only if Step 1 fails and `rmarkdown::find_pandoc()$version` is non-empty.

**Step 3 — Fallback**

If both steps fail, deliver the `.Rmd` file alone with this message:

> "The `survival_report.Rmd` file is ready. To render it yourself, run `knitr::knit2html('survival_report.Rmd')` in R (requires the `markdown` package), or open it in RStudio and click Knit."

---

## Step 6 — Completion Message

After rendering succeeds, output **exactly** the following block, replacing `<absolute-path>` with the actual absolute path to the output directory:

> Both files are ready:
>
> - [survival_report.Rmd](file://<absolute-path>/survival_report.Rmd) — the reproducible R Markdown source
> - [survival_report.html](file://<absolute-path>/survival_report.html) — the rendered HTML report

Use `file://` URLs (e.g. `file:///Users/alice/project/survival_report.html`) so the links are clickable in the chat window.

---

## Edge Cases

| Situation | Behavior in the `.Rmd` |
|---|---|
| Quantile not reached (NA) | Replace NA with `"NR"` (Not Reached) in the table |
| No events in a group | Show warning inline: "Group [X] has no events; quantile undefined." |
| p-value stars inside bold Markdown | Always use `&#42;` — never raw `*` |
| All observations censored | Abort with error chunk: `stop("No events observed — survival analysis not possible.")` |
| NAs in input vectors | Add note: "Rows with missing values were removed (listwise deletion). N removed: X." |

---