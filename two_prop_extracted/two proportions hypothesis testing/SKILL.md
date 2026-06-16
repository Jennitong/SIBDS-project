---
name: two-proportion-test
description: >
  Performs a two proportion test in R given four numbers: treatment total,
  control total, treatment responses, and control responses. Automatically selects
  between a chi-square test and Fisher's exact test based on expected cell count
  criteria (≥ 5 rule), explains the assumptions of the chosen test, and returns
  a complete interpretation and conclusion paragraph. Use this skill whenever the
  user provides counts from a two-group experiment and wants to compare proportions
  or test for a significant difference — even if they don't use the words "proportion
  test" or "A/B test". Trigger on phrases like "is this significant?", "did the
  treatment work?", "compare two groups", "conversion rate test", "statistical tests", 
  "summary statistics", "I have a study with X
  patients in the treatment arm", or whenever four numeric inputs represent group
  sizes and success/response counts. This skill assumes the two groups are independent. 
  Do not use for crossover or within-subject designs.
---

# Two-Sample Proportion Test Skill (R)

## Highest rule
 
**DO NOT** display anything until step 6. follow. exact instruction as in step 6 when showing outputs or texts.

## Inputs

Ask the user for exactly four numbers if they have not already provided them:

| Variable | Symbol | Meaning |
|---|---|---|
| Treatment total | n.tx | Number of subjects in the treatment group |
| Control total | n.ctrl | Number of subjects in the control group |
| Treatment responses | resp.tx | Number of successes/responses in the treatment group/arm |
| Control responses | resp.ctrl | Number of successes/responses in the control group/arm |

---

## Step 0 — Extract Inputs from Natural Language

If the user provides a sentence such as:

> "I have a study with X patients in the treatment arm, X patients in the control arm, X responders in the treatment group, and X responders in the control group."

Extract the four numbers:

| "X patients in the treatment arm" | `n.tx` |
| "X patients in the control arm" | `n.ctrl` |
| "X responders in the treatment group" | `resp.tx` |
| "X responders in the control group" | `resp.ctrl` |

Do not output anything,and assume that the values extracted are correct. Nothing to be reported yet, until step 6.

---

## Step 1 — Validate Inputs

Before running any test, check all of the following. If any check fails, report the issue clearly and stop.

- All four values are **positive integers**
- `resp.ctrl ≤ n.ctrl` and `resp.tx ≤ n.tx` (responses cannot exceed totals)
- `n.tx ≥ 1` and `n.ctrl ≥ 1`
- All four variables are not NA

---

## Step 2 — Create Contingency Table

Build a 2×2 contingency table from the four inputs. Show the table in the final report.

|           | Response   | No Response         |
|-----------|------------|---------------------|
| Treatment | resp.tx    | n.tx − resp.tx      |
| Control   | resp.ctrl  | n.ctrl − resp.ctrl  |

---

## Step 3 — Choose the Correct Test

Compute the **expected cell counts** under the null hypothesis using row sums, column sums, and total participants:

```
Expected counts:
  E(treatment, response)    = (resp.tx + resp.ctrl) * n.tx / (n.tx + n.ctrl)
  E(treatment, no response) = (n.tx - resp.tx + n.ctrl - resp.ctrl) * n.tx / (n.tx + n.ctrl)
  E(control, response)      = (resp.tx + resp.ctrl) * n.ctrl / (n.tx + n.ctrl)
  E(control, no response)   = (n.tx - resp.tx + n.ctrl - resp.ctrl) * n.ctrl / (n.tx + n.ctrl)
```

**Decision rule:**
- If **all four expected counts ≥ 5** → use **Chi-square test** (`chisq.test`)
- If **any expected count < 5** → use **Fisher's exact test** (`fisher.test`)

Compute these values internally only. Do **not** display the expected cell counts, the formulas, or any intermediate table, and do not display test decision at this step. The only number surfaced to the user is the single minimum expected cell count, shown in Step 6.

---

## Step 4 — Assumptions

Before showing results, briefly explain the assumptions of the chosen test.

> **Important:** This skill assumes the two groups are **independent** random samples (e.g., a parallel-arm trial). It is not appropriate for paired, matched, or crossover designs.

### Chi-square test assumptions
1. The two groups are **independent** random samples.
2. Each observation is **binary** (success or failure).
3. **Expected cell counts ≥ 5** in all cells of the 2×2 contingency table (the condition verified in Step 3).
4. Sample size is large enough for the chi-square approximation to be reliable.

### Fisher's exact test assumptions
1. The two groups are **independent** random samples.
2. Each observation is **binary** (success or failure).
3. The marginal totals (row and column sums) are treated as **fixed** — Fisher's exact test makes no large-sample approximation, which is why it is preferred when expected counts are small.

---

## Step 5 — Execute R Code and Extract Results

Run the R script using the Bash tool. This is the authoritative computation step — do not calculate p-values, test statistics, or odds ratios yourself. All numerical results in Step 7 must come directly from the output of this command.

From the skill's directory (the folder containing this `SKILL.md`), run:

```bash
cd "<path-to-skill-directory>" && Rscript -e "
source('scripts/Two_sample_proportion_with_multiple_functions.R')
two_sample_proportion_test(n.tx=<n.tx>, n.ctrl=<n.ctrl>, resp.tx=<resp.tx>, resp.ctrl=<resp.ctrl>)
"
```

Replace `<n.tx>`, `<n.ctrl>`, `<resp.tx>`, `<resp.ctrl>` with the actual numbers. Replace `<path-to-skill-directory>` with the actual absolute path to the folder containing this SKILL.md. The `threshold` argument defaults to 0.05; if the user specifies a different significance level, pass it explicitly (e.g., `threshold = 0.01`).

The function prints a full conclusion paragraph to stdout. From that output, extract:
- The test name (Chi-square or Fisher's exact)
- The test statistic value and its label (test statistic or sample odds ratio)
- The p-value (exact formatted string as printed, e.g. "less than 0.001 (***)" or "0.0312")
- The decision ("reject" or "fail to reject")
- The full conclusion sentence

Use these extracted values verbatim when writing the Step 7 report. Do not recompute or reword numerical results.

---

## Step 6 — Ask for Detail Level and Export Preference

Output **exactly** the following block — nothing before it, nothing after except waiting for the user's reply. Do not show formulas, intermediate tables, or any other text. Do not returhn any output or text until step 6.

If the minimum expected cell count is ≥ 5 (Chi-square):

> Assuming these numerical inputs are correct (treatment group = `<n.tx>`, control group = `<n.ctrl>`, treatment response = `<resp.tx>`, and control response = `<resp.ctrl>`), we will proceed with the analysis. The minimum expected cell count is `<min_expected>` (> 5), so the Chi-square test will be used. Would you like a **brief**, **moderate**, or **detailed** response?


If the minimum expected cell count is < 5 (Fisher's exact):

> Assuming these numerical inputs are correct (treatment group = `<n.tx>`, control group = `<n.ctrl>`, treatment response = `<resp.tx>`, and control response = `<resp.ctrl>`), we will proceed with the analysis. The minimum expected cell count is `<min_expected>` (< 5), so Fisher's exact test will be used. Would you like a **brief**, **moderate**, or **detailed** response?

Replace each placeholder with its computed value. `<min_expected>` is a single rounded number (no formula, no table). The user can answer both questions at once (e.g., "detailed, and yes please export to HTML"). Wait for the user's answer before generating any output.

---

## Step 7 — Output

**Tone for all levels:** Professional but accessible. Write for a stakeholder who understands "statistically significant" but does not need to verify the math. Define p-value briefly inline for people who chose "detailed response" as "the probability of observing a difference this large (or larger) by chance alone if there were truly no effect." Also explicitly state what the null hypothesis refers to in "moderate" and "detailed" response chosers. Never show the R code in output.

---



### Brief

2–3 sentences covering: test used(chi-square or Fisher's exact test), key result (statistic + p-value (4 decimal places if ≥ 0.05, otherwise `< 0.05`, `< 0.01`, or `< 0.001` with stars)), and decision (reject / fail to reject null hypothesis).

Then the **summary table** below.
---

### Moderate

A single cohesive paragraph covering all four elements in order:

1. **Background** — group sizes, observed responses, response rates, null and alternative hypothesis.
2. **Test chosen and assumptions** — test name, why it was selected (expected counts), key assumptions met.
3. **Test result** — test statistic (X² or odds ratio), degrees of freedom if chi-square, and p-value (4 decimal places if ≥ 0.05, otherwise `< 0.05`, `< 0.01`, or `< 0.001` with stars).
4. **Decision** — reject or fail to reject H₀, and what that means in plain language.

Then the **summary table** and **one-line result** below.

---

### Detailed

The full **Moderate** paragraph, then:

**Contingency table:**

|           | Response   | No Response         |
|-----------|------------|---------------------|
| Treatment | resp.tx    | n.tx − resp.tx      |
| Control   | resp.ctrl  | n.ctrl − resp.ctrl  |

Then the **summary table** and **one-line result** below.

Then a short **Plain-language interpretation** section (3–5 sentences) written for a non-statistical audience: what does this result mean practically, what can and cannot be concluded, and any relevant caveats (e.g., statistical significance ≠ clinical or practical significance), and the definition of p-value.

---
Note: All R code chunks must use echo = FALSE (set globally in the setup chunk) so no R code is visible in the rendered report. Clients should not see the code.

### Summary table (for all levels, after the paragraph, rendered via knitr::kable()):

| Metric | Treatment | Control |
|---|---|---|
| Total | n.tx | n.ctrl |
| Response rate | resp.tx / n.tx % | resp.ctrl / n.ctrl % |
| Risk difference | Δ = \|resp.tx/n.tx − resp.ctrl/n.ctrl\| | — |

**Note**: For the summary table, do not include the row "Response". Only include "Total", "Response rate", and "Risk difference".
One line:

`Test: [Chi-square / Fisher's exact] | Statistic: X² = … (df = 1) or Odds Ratio = … | p-value = … | α = 0.05`

---

## Examples

---

## Step 8 — R Markdown / HTML Export (if requested)

After output has been printed out in the Claude window, lastly ask 

> Would you also like the results exported as an **R Markdown (.Rmd) and rendered HTML file**?

**If the user said yes to export:** follow the instructions in `SKILL-rmd-export.md` (located in the same folder as this skill file) to generate the `.Rmd` and render the `.html`. The exported files must contain **exactly the same content** already shown in Step 7 — same detail level, no new analysis, no rephrasing. All three detail levels (brief, moderate, detailed) are supported for export.

**If the user said no (or did not request export):** close the session with a brief sign-off, e.g.:

> "The analysis is complete. Feel free to start a new session if you have additional questions."

Do not prompt again or offer alternative formats.

---

## Examples

### Example A — Chi-square (large samples)

Input: n.tx = 2000, n.ctrl = 2000, resp.tx = 340, resp.ctrl = 280

Chose : Moderate

> In this experiment, 2,000 subjects were assigned to the treatment group and 2,000 to the control group. The treatment group showed 340 successes (17.0% rate) versus 280 successes (14.0%) in the control group, an absolute difference of 3.0 percentage points. All four expected cell counts exceeded 5 (minimum ≈ 293), so the chi-square test of equal proportions was applied; the independence and binary-outcome assumptions are met. The test yielded X² = 6.87 (df = 1) and a p-value of 0.0088 — the probability of observing a 3-point gap or larger by chance alone if there were truly no effect. Because p < 0.05, we reject the null hypothesis that the two proportions are equal. The treatment is associated with a statistically significant increase in the success rate; the evidence supports a real difference rather than sampling variation.

### Example B — Fisher's exact (small samples)

Input: n.tx = 30, n.ctrl = 25, resp.tx = 3, resp.ctrl = 1

Chose : Brief

> We use Fisher's exact test (Expected < 5 ) . Fisher's exact test returned a p-value of 0.6154. Because p > 0.05, we fail to reject the null hypothesis that the two proportions are equal. There is insufficient statistical evidence to conclude the treatment had a real effect.
