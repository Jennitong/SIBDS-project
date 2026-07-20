---
name: "statistical-analysis"
description: >-
  Performs binary proportion hypothesis testing or survival analysis in R upon
  request. Explains the functionality available (which analyses, which output
  detail levels, R Markdown/HTML export) at brief, moderate, or detailed
  length for the client. Trigger on any mention of statistical analysis,
  binary proportion / two-sample proportion tests, survival analysis,
  Kaplan-Meier, log-rank tests, or a general question about what this skill
  can do.
---

# Statistical Analysis

## Quick Start

- Client mentions comparing two groups' response/success counts, an A/B test,
  or "is this significant?" -> load `binary-proportion-test.md`.
- Client mentions time-to-event data, censoring, Kaplan-Meier, or a log-rank
  test -> load `survival-analysis.md`.
- Client asks what this skill does, in general -> answer from this file only
  (see Output below); do not load either sub-skill.

## Sandbox Policy

Recommended mode: `workspace-write`

Rationale: both sub-skills execute local R scripts under `scripts/` via the
terminal command tool and, on request, write `.Rmd`/`.html`/image files into
the working directory.

## Runtime Contract

1. This file only dispatches to the two sub-skill files below and answers
   generic "what can you do" questions. All analysis logic lives in
   `binary-proportion-test.md` and `survival-analysis.md` — load the relevant
   one before doing any analysis work, and follow it verbatim.
2. Preserve the source workflow's control shape: this is a direct-execution
   skill (terminal command tool running R), not a delegated/sub-agent
   workflow. Do not spawn a sub-agent to do the statistics.
3. R computation is authoritative. Never compute p-values, test statistics,
   confidence intervals, or survival estimates yourself — always read them
   from the R script's output.

## Workflow

### 1. Identify the request

**Context**: The client asks for an analysis or asks about the skill itself.
**Action**: Classify the request per Quick Start above.
**Result**: Either a routing decision to a sub-skill, or a direct answer from
this file.

### 2. Route

**Binary proportion hypothesis testing** -> `binary-proportion-test.md`
(covers inputs, test selection between chi-square and Fisher's exact,
assumptions, execution, and the brief/moderate/detailed report format). Its
export step routes to `binary-proportion-rmd-export.md`.

**Survival analysis** -> `survival-analysis.md` (covers inputs, log-rank test
with optional Bonferroni correction, quantiles, mean survival, pairwise
comparisons, and the Kaplan-Meier plot). Its export step routes to
`survival-rmd-export.md`.

### 3. Generic "what can this skill do" answer

**Context**: The client asks about the skill's functionality rather than
requesting an analysis.
**Action**: In a paragraph, using a professional tone, explain:
- The two supported analyses (binary proportion hypothesis testing, survival
  analysis).
- That the skill can provide relevant graphs and tables, and can help
  determine and choose the most appropriate statistical test.
- That it can explain background and test assumptions.
- The three response detail levels and what distinguishes them (see below).
- That an R Markdown file and rendered HTML report can be produced on
  request.
**Result**: A single explanatory paragraph; no analysis is run.

## Progressive Disclosure

To keep responses appropriately scoped, ask the client for their preferred
detail level if it isn't already specified in the sub-skill's own prompt.
If none is specified there either, infer one from context.

### Brief
Only the test statistic, p-value, hypothesis testing decision, and a one-line
outcome summary. Best suited for clients already familiar with the relevant
statistical methods who need results, not explanations.

### Moderate
Everything in Brief, plus an explanation of the test assumptions and
supporting tables where relevant. Best suited for clients who have studied
the relevant statistical concepts but lack deep practical experience.

### Detailed
Everything in Moderate, plus full background on the statistical method,
definitions of all key terms, and step-by-step interpretation. Best suited
for clients without a formal statistical background who need conceptual
grounding alongside the results.

## Output Formats

By default, results are returned as formatted text in the response.

If requested, the skill can also produce an **R Markdown (.Rmd) file** and a
rendered **HTML report**, saved to the working directory and opened with
`view_image`/linked as a file. Generating and rendering these takes
additional time — say so when the client asks for it.

## Reference Map

| Reference | Load when |
| --- | --- |
| `binary-proportion-test.md` | Client wants a two-sample proportion / A/B-style hypothesis test |
| `binary-proportion-rmd-export.md` | Client confirmed they want the proportion-test results exported to `.Rmd`/`.html` |
| `survival-analysis.md` | Client wants a survival / Kaplan-Meier / log-rank analysis |
| `survival-rmd-export.md` | Client confirmed they want the survival results exported to `.Rmd`/`.html` |

## Scripts

| Script | Purpose |
| --- | --- |
| `scripts/Two_sample_proportion_with_multiple_functions.R` | Validates inputs, selects and runs chi-square or Fisher's exact test, computes confidence intervals |
| `scripts/survival_single_groups.R` | Fits Kaplan-Meier + log-rank test for a single categorical group variable |
| `scripts/two_groups_combined.R` | Fits Kaplan-Meier + Bonferroni-adjusted log-rank test for two categorical group variables |
| `scripts/response_rate_barplot.R` | Renders the two-group response-rate bar chart to a PNG (added during migration; replaces the source's inline HTML/SVG widget — see `binary-proportion-test.md` Step 2) |

## Migration Notes

- Source: Claude skill package at the repo root (`SKILL.md`,
  `binary_proportion_skill.md`, `survival_analysis_skill.md`,
  `SKILL-rmd-export.md`, `survival_rmd_export.md`). That source tree is left
  untouched by this migration.
- Tier 3 (hand-authored): both sub-skills mandate direct R execution via the
  terminal as the authoritative computation step and use filesystem-relative
  script paths as execution contract — mechanical conversion would have
  broken that contract.
- Behavior change (confirmed with the user): the source's inline
  `show_widget` bar chart and Kaplan-Meier plot have no Codex equivalent.
  Both are now rendered to image files by R and shown via `view_image`
  instead of an interactive in-chat widget.
- Status: `CODEX_COMPATIBLE_BUT_NOT_NATIVE` pending a nativeness review pass.
