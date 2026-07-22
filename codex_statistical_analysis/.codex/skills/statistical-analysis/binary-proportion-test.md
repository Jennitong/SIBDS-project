---
name: "binary-proportion-test"
description: >-
  Performs a two proportion test in R given four numbers: treatment total,
  control total, treatment responses, and control responses. Automatically
  selects between a chi-square test and Fisher's exact test based on expected
  cell count criteria (>= 5 rule), explains the assumptions of the chosen
  test, and returns a complete interpretation and conclusion paragraph. Use
  whenever the client provides counts from a two-group experiment and wants
  to compare proportions or test for a significant difference -- even if they
  don't use the words "proportion test" or "A/B test". Trigger on phrases
  like "is this significant?", "did the treatment work?", "compare two
  groups", "conversion rate test", "statistical tests", "summary statistics",
  "I have a study with X patients in the treatment arm", or whenever four
  numeric inputs represent group sizes and success/response counts. Assumes
  the two groups are independent; do not use for crossover or within-subject
  designs.
---

# Two-Sample Proportion Test Skill (R)

## Highest Rule

**DO NOT** display anything until Step 6. Follow the exact instructions in
Step 6 when showing outputs or text.

## Sandbox Policy

Recommended mode: `workspace-write`

Rationale: this skill runs `scripts/Two_sample_proportion_with_multiple_functions.R`
and `scripts/response_rate_barplot.R` via the terminal command tool, and may
write image/`.Rmd`/`.html` files to the working directory.

## Inputs

Ask the client for exactly four numbers if they have not already provided
them:

| Variable | Symbol | Meaning |
|---|---|---|
| Treatment total | n.tx | Number of subjects in the treatment group |
| Control total | n.ctrl | Number of subjects in the control group |
| Treatment responses | resp.tx | Number of successes/responses in the treatment group/arm |
| Control responses | resp.ctrl | Number of successes/responses in the control group/arm |

---

## Step 0 -- Extract Inputs from Natural Language

If the client provides a sentence such as:

> "I have a study with X patients in the treatment arm, X patients in the
> control arm, X responders in the treatment group, and X responders in the
> control group."

Extract the four numbers:

| Phrase | Variable |
|---|---|
| "X patients in the treatment arm" | `n.tx` |
| "X patients in the control arm" | `n.ctrl` |
| "X responders in the treatment group" | `resp.tx` |
| "X responders in the control group" | `resp.ctrl` |

Do not output anything; assume the extracted values are correct. Nothing is
reported until Step 6.

---

## Step 1 -- Validate Inputs

Before running any test, check all of the following. If any check fails,
report the issue clearly and stop.

- All four values are **positive integers**
- `resp.ctrl <= n.ctrl` and `resp.tx <= n.tx` (responses cannot exceed totals)
- `n.tx >= 1` and `n.ctrl >= 1`
- All four variables are not NA

---

## Step 2 -- Create Contingency Table and Bar Chart

Build a 2x2 contingency table from the four inputs. Show the table in the
final report.

**Contingency Table**
|           | Response   | No Response         |
|-----------|------------|---------------------|
| Treatment | resp.tx    | n.tx - resp.tx      |
| Control   | resp.ctrl  | n.ctrl - resp.ctrl  |

**Bar plot** (migration note: the source Claude skill rendered this as an
inline HTML/SVG widget; Codex has no in-chat widget primitive, so it is
rendered to an image file and displayed with `view_image` instead — see Step
5 for how it's generated together with the statistical computation):

Round `resp.tx/n.tx` and `resp.ctrl/n.ctrl` to two decimal places for
display. The rendered chart title is "RESPONSE RATES", with a blue bar for
Treatment and a gray bar for Control, each bar's length proportional to its
response rate and labeled with its percentage and raw count.

---

## Step 3 -- Choose the Correct Test

Compute the **expected cell counts** under the null hypothesis using row
sums, column sums, and total participants:

```
Expected counts:
  E(treatment, response)    = (resp.tx + resp.ctrl) * n.tx / (n.tx + n.ctrl)
  E(treatment, no response) = (n.tx - resp.tx + n.ctrl - resp.ctrl) * n.tx / (n.tx + n.ctrl)
  E(control, response)      = (resp.tx + resp.ctrl) * n.ctrl / (n.tx + n.ctrl)
  E(control, no response)   = (n.tx - resp.tx + n.ctrl - resp.ctrl) * n.ctrl / (n.tx + n.ctrl)
```

**Decision rule:**
- If **all four expected counts >= 5** -> use **Chi-square test** (`chisq.test`)
- If **any expected count < 5** -> use **Fisher's exact test** (`fisher.test`)

Compute these values internally only. Do **not** display the expected cell
counts, the formulas, or any intermediate table, and do not display the test
decision at this step. The only number surfaced to the client is the single
minimum expected cell count, used in a sentence, shown in Step 7.

---

## Step 4 -- Assumptions

Before showing results, briefly explain the assumptions of the chosen test.

> **Important:** This skill assumes the two groups are **independent**
> random samples (e.g., a parallel-arm trial). It is not appropriate for
> paired, matched, or crossover designs.

### Chi-square test assumptions
1. The two groups are **independent** random samples.
2. Each observation is **binary** (success or failure).
3. **Expected cell counts >= 5** in all cells of the 2x2 contingency table
   (the condition verified in Step 3).
4. Sample size is large enough for the chi-square approximation to be
   reliable.

### Fisher's exact test assumptions
1. The two groups are **independent** random samples.
2. Each observation is **binary** (success or failure).
3. The marginal totals (row and column sums) are treated as **fixed** --
   Fisher's exact test makes no large-sample approximation, which is why it
   is preferred when expected counts are small.

---

## Step 5 -- Execute R Code and Extract Results

Run the R script with the terminal command tool. This is the authoritative
computation step -- do not calculate p-values, test statistics, or odds
ratios yourself. All numerical results in Step 7 must come directly from the
output of this command.

From the skill's directory (the folder containing this
`binary-proportion-test.md`), run:

```bash
cd "<path-to-skill-directory>" && Rscript -e "
source('scripts/Two_sample_proportion_with_multiple_functions.R')
source('scripts/response_rate_barplot.R')
two_sample_proportion_test(n.tx=<n.tx>, n.ctrl=<n.ctrl>, resp.tx=<resp.tx>, resp.ctrl=<resp.ctrl>)
plot_response_rates(resp.tx=<resp.tx>, n.tx=<n.tx>, resp.ctrl=<resp.ctrl>, n.ctrl=<n.ctrl>, file='response_rates.png')
"
```

Replace `<n.tx>`, `<n.ctrl>`, `<resp.tx>`, `<resp.ctrl>` with the actual
numbers, and `<path-to-skill-directory>` with the actual absolute path to the
folder containing this file. The `threshold` argument of
`two_sample_proportion_test` defaults to 0.05; if the client specifies a
different significance level, pass it explicitly (e.g., `threshold = 0.01`).

The function prints a full conclusion paragraph to stdout. From that output,
extract:
- The test name (Chi-square or Fisher's exact)
- The test statistic value and its label (test statistic or sample odds
  ratio)
- The p-value (exact formatted string as printed, e.g. "less than 0.001
  (***)" or "0.0312")
- The decision ("reject" or "fail to reject")
- The full conclusion sentence

Use these extracted values verbatim when writing the Step 7 report. Do not
recompute or reword numerical results.

`response_rates.png` is written to the skill's working directory; display it
with `view_image` at the point specified in Step 7 (Detailed level) — never
before Step 6, per the Highest Rule.

---

## Step 6 -- Ask for Detail Level and Export Preference

Output **exactly** the following block -- nothing before it, nothing after
except waiting for the client's reply. Do not show formulas, intermediate
tables, or any other text. Do not return any output or text until Step 6.

> Assuming these numerical inputs are correct (treatment group = `<n.tx>`,
> control group = `<n.ctrl>`, treatment response = `<resp.tx>`, and control
> response = `<resp.ctrl>`), we will proceed with the analysis. Would you
> like a **brief** (test statistic, p-value, and one-line conclusion),
> **moderate** (adds assumption checks and supporting tables), or
> **detailed** (full background, definitions, and step-by-step
> interpretation) response?

Replace each placeholder with its computed value. The client can answer both
questions at once (e.g., "detailed, and yes please export to HTML"). Wait
for the client's answer before generating any output.

**Note**: Ignore any detail-level preference (brief/moderate/detailed) that
arrives together with the initial data -- always output the Step 6 question
and wait for a reply in the next turn, even if one was mentioned upfront.

---

## Step 7 -- Output

**Tone for all levels:** Professional but accessible. Write for a
stakeholder who understands "statistically significant" but does not need to
verify the math. Define p-value briefly inline for clients who chose
"detailed response" as "the probability of observing a difference this large
(or larger) by chance alone if there were truly no effect." Also explicitly
state what the null hypothesis refers to for "moderate" and "detailed"
response choosers. Never show the R code in output.

**Note: do not show anything with `tx` or `ctrl` directly. State the
hypothesis using words, not notation. Anything with `tx` and `ctrl` is for
code only, not for the report.**

---

### Brief

2-3 sentences covering: test used (chi-square or Fisher's exact test with
minimum expected cell value), key result (statistic + p-value, 4 decimal
places if >= 0.05, otherwise `< 0.05`, `< 0.01`, or `< 0.001` with stars),
and decision (reject / fail to reject null hypothesis), and the confidence
interval of the binary proportion (stored as `confint` in the
`two_sample_proportion_test` output).

No table displayed.

---

### Moderate

A single cohesive paragraph covering all four elements in order:

1. **Background** -- group sizes, observed responses, response rates, null
   and alternative hypothesis.
2. **Test chosen and assumptions** -- test name, why it was selected
   (minimum expected counts), key assumptions met.
3. **Test result** -- test statistic (X² or odds ratio), degrees of freedom
   if chi-square, p-value (4 decimal places if >= 0.05, otherwise `< 0.05`,
   `< 0.01`, or `< 0.001` with stars), and confidence interval.
4. **Decision** -- reject or fail to reject H0, and what that means in plain
   language.

Then the **summary table** and **one-line result** below.

---

### Detailed

The full **Moderate** paragraph, then:

**Contingency table:**

|           | Response   | No Response         |
|-----------|------------|---------------------|
| Treatment | resp.tx    | n.tx - resp.tx      |
| Control   | resp.ctrl  | n.ctrl - resp.ctrl  |

**Response rate bar chart:** display `response_rates.png` (generated in Step
5) with `view_image` at this point in the report.

Then the **summary table** and **one-line result** below.

Then a short **Plain-language interpretation** section (3-5 sentences)
written for a non-statistical audience: what does this result mean
practically, what can and cannot be concluded, and any relevant caveats
(e.g., statistical significance != clinical or practical significance), the
definition of p-value, and the correct interpretation of the confidence
interval ("We are (1-`<threshold>`)% confident that the true difference of
probability of response between the two groups falls within `<confint>`.").

- Extract `<confint>` from the output of
  `Two_sample_proportion_with_multiple_functions.R`; `<threshold>` is the
  significance level, 5% by default unless specified.

---

Note: All R code chunks must use `echo = FALSE` (set globally in the setup
chunk) so no R code is visible in the rendered report. Clients should not see
the code.

### Summary table (for moderate and detailed levels only, rendered via `knitr::kable()`)

| Metric | Treatment | Control |
|---|---|---|
| Total | n.tx | n.ctrl |
| Response rate | resp.tx / n.tx % (`two_sample_proportion_test(n.tx, n.ctrl, resp.tx, resp.ctrl)$ci_tx[, c("Lower","Upper")]*100`) % | resp.ctrl / n.ctrl % (`two_sample_proportion_test(n.tx, n.ctrl, resp.tx, resp.ctrl)$ci_ctrl[, c("Lower","Upper")]*100`) % |
| Risk difference | Delta = \|resp.tx/n.tx - resp.ctrl/n.ctrl\| | CI = (`two_sample_proportion_test(n.tx, n.ctrl, resp.tx, resp.ctrl)$ci_rd[, c("Lower","Upper")]*100`) % |

Show this sentence underneath the table: **The confidence intervals for
response rates are computed using Clopper-Pearson, and the confidence
interval for the response rate difference is computed using the Newcombe
method.**

**Note**: For the summary table, do not include a "Response" row. Only
include "Total", "Response rate", and "Risk difference". Refer to the R code
when calculating confidence intervals.

One line:

`Test: [Chi-square / Fisher's exact] | Statistic: X² = ... (df = 1) or Odds Ratio = ... | p-value = ... | alpha = 0.05`

### Notation

Throughout the analysis, use `*` only for p-values. Do not use any other
symbol.
- p-value < 0.001 (***)
- p-value < 0.01 (**)
- p-value < 0.05 (*)
- p-value *(rounded to 4 decimal places when p-value >= 0.05)*

## Step 8 -- R Markdown / HTML Export (if requested)

After output has been shown, lastly ask:

> Would you also like this analysis exported as an **R Markdown (.Rmd) and
> rendered HTML report**?

**If the client said yes to export:** load and follow
`binary-proportion-rmd-export.md` (located in the same folder as this file)
to generate the `.Rmd` and render the `.html`. The exported files must
contain **exactly the same content** already shown in Step 7 -- same detail
level, no new analysis, no rephrasing. All three detail levels (brief,
moderate, detailed) are supported for export.

**If the client said no (or did not request export):** close the session
with a brief sign-off, e.g.:

> "The analysis is complete. Feel free to start a new session if you have
> additional questions."

Do not prompt again or offer alternative formats.

---

## Examples

### Example A -- Chi-square (large samples)

Input: n.tx = 2000, n.ctrl = 2000, resp.tx = 340, resp.ctrl = 280

Chose: Moderate

> In this experiment, 2,000 subjects were assigned to the treatment group
> and 2,000 to the control group. The treatment group showed 340 successes
> (17.0% rate) versus 280 successes (14.0%) in the control group, an
> absolute difference of 3.0 percentage points. All four expected cell
> counts exceeded 5 (minimum ~= 293), so the chi-square test of equal
> proportions was applied; the independence and binary-outcome assumptions
> are met. The test yielded X² = 6.87 (df = 1) and a p-value of 0.0088 --
> the probability of observing a 3-point gap or larger by chance alone if
> there were truly no effect. Because p < 0.05, we reject the null
> hypothesis that the two proportions are equal. The treatment is
> associated with a statistically significant increase in the success rate;
> the evidence supports a real difference rather than sampling variation.

### Example B -- Fisher's exact (small samples)

Input: n.tx = 30, n.ctrl = 25, resp.tx = 3, resp.ctrl = 1

Chose: Brief

> We use Fisher's exact test (Expected < 5). Fisher's exact test returned a
> p-value of 0.6154. Because p > 0.05, we fail to reject the null hypothesis
> that the two proportions are equal. There is insufficient statistical
> evidence to conclude the treatment had a real effect.
