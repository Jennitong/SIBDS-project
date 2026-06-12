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

Extract the four numbers using this mapping:

| Phrase in prompt | Maps to |
|---|---|
| "X patients in the treatment arm" | `n.tx` |
| "X patients in the control arm" | `n.ctrl` |
| "X responders in the treatment group" | `resp.tx` |
| "X responders in the control group" | `resp.ctrl` |

Before proceeding, confirm the extraction by echoing:

> "I understand: n.tx = X, n.ctrl = X, resp.tx = X, resp.ctrl = X — is that correct?"

Only continue to Step 1 after the user confirms (or corrects) the values.

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

State which test was chosen and why (mention the smallest expected count).

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

## Step 5 — R Code : This code is not to be shown in final report. It should be executed but hidden

Source the R script from the `scripts/` folder (relative to this skill file), then call `two_sample_proportion_test` with the actual input values.

```r
# --- Load all helper functions and the main function ---
source("scripts/Two_sample_proportion_with_multiple_functions.R")

# --- Call with user's values ---
two_sample_proportion_test(n.tx = <n.tx>, n.ctrl = <n.ctrl>, resp.tx = <resp.tx>, resp.ctrl = <resp.ctrl>)
```

Replace `<n.tx>`, `<n.ctrl>`, `<resp.tx>`, `<resp.ctrl>` with the actual numbers before executing. The `threshold` argument defaults to 0.05; if the user specifies a different significance level, pass it explicitly (e.g., `threshold = 0.01`).

**Reproducing the output mentally:** trace through the function logic in `scripts/Two_sample_proportion_with_multiple_functions.R` with the given numbers so you can report the exact paragraph the function would print, rather than a paraphrase.

---

## Step 6 — Output

Write a single cohesive paragraph followed by a summary table. The paragraph must address all four elements in this order:

1. **Background** — state the group sizes, observed responses, and response rates for each group, and the null and alternative hypothesis.
2. **Test chosen and assumptions** — name the test selected, briefly state why (expected counts), and confirm the key assumptions are met.
3. **Test result** — report the test statistic for chi-square (or odds ratio for Fisher's exact), degrees of freedom (if chi-square), and the p-value (to 4 decimal places if ≥ 0.05, or as `< 0.05`, `< 0.01`, or `< 0.001` with stars otherwise).
4. **Decision and interpretation** — state whether we reject or fail to reject H₀ (that treatment group and response rate are independent), and explain what this means in plain language for the user's context.

**Tone:** Professional but accessible. Write for a stakeholder who understands "statistically significant" but does not need to verify the math. Define p-value briefly inline on first use as "the probability of observing a difference this large (or larger) by chance alone if there were truly no effect."

**Note:** Do not show the R code in output. Clients should not see the code.

**Summary table** (after the paragraph):

| Metric | Treatment | Control |
|---|---|---|
| Total | n.tx | n.ctrl |
| Responses | resp.tx | resp.ctrl |
| Response rate | resp.tx / n.tx % | resp.ctrl / n.ctrl %|
| Absolute difference | Δ = \|resp.tx/n.tx − resp.ctrl/n.ctrl\| | — |

Then one line:

`Test: [Chi-square / Fisher's exact] | Statistic: X² = … (df = 1) or Odds Ratio = … | p-value = … | α = 0.05`

---

## Examples

### Example A — Chi-square (large samples)

Input: n.tx = 2000, n.ctrl = 2000, resp.tx = 340, resp.ctrl = 280

> In this experiment, 2,000 subjects were assigned to the treatment group and 2,000 to the control group. The treatment group showed 340 successes (17.0% rate) versus 280 successes (14.0%) in the control group, an absolute difference of 3.0 percentage points. All four expected cell counts exceeded 5 (minimum ≈ 293), so the chi-square test of equal proportions was applied; the independence and binary-outcome assumptions are met. The test yielded X² = 6.87 (df = 1) and a p-value of 0.0088 — the probability of observing a 3-point gap or larger by chance alone if there were truly no effect. Because p < 0.05, we reject the null hypothesis that the two proportions are equal. The treatment is associated with a statistically significant increase in the success rate; the evidence supports a real difference rather than sampling variation.

### Example B — Fisher's exact (small samples)

Input: n.tx = 30, n.ctrl = 25, resp.tx = 3, resp.ctrl = 1

> With only 30 subjects in the treatment group and 25 in the control group, the treatment recorded 3 successes (10.0%) against 1 success (4.0%) in the control group. Because two of the four expected cell counts fell below 5 (minimum ≈ 1.27), Fisher's exact test was used instead of the chi-square approximation; this test makes no large-sample assumption and remains valid for small or sparse tables. Fisher's exact test returned a p-value of 0.6154. Because p > 0.05, we fail to reject the null hypothesis that the two proportions are equal. While the treatment group's rate is numerically higher, the samples are too small to distinguish this gap from chance variation — there is insufficient statistical evidence to conclude the treatment had a real effect.
