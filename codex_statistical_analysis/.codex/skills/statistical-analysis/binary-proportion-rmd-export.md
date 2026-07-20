---
name: "binary-proportion-rmd-export"
description: >-
  R Markdown / HTML export sub-skill for the two-sample proportion test.
  Load only after the client has confirmed, in response to
  binary-proportion-test.md Step 8, that they want a .Rmd and .html report.
---

# R Markdown Export Sub-Skill (Binary Proportion Test)

> **This file is invoked only when the client confirms they want `.Rmd` and
> `.html` output.** It is not part of the main conversation flow and should
> not be referenced until that confirmation is received.

## Sandbox Policy

Recommended mode: `workspace-write`

Rationale: writes `report.Rmd`/`report.md`/`report.html` to the working
directory and may install the `markdown` R package if missing.

---

## Rmd Generation Instructions

Build a self-contained `R Markdown (.Rmd)` file that reproduces **exactly**
the same content already shown to the client (same test choice, same
numbers, same detail level). No new analysis -- only formatting.

### YAML header

```yaml
---
title: "Two-Sample Proportion Test Report"
date: "`r Sys.Date()`"
output:
  html_document:
    html_encoding: "UTF-8"
encoding: UTF-8
---
```

The `encoding: UTF-8` line tells knitr to read the `.Rmd` source as UTF-8,
which prevents symbols from being mangled into `<U+2014>` or similar escape
sequences in the rendered HTML. Use `output: pdf_document` only if the
client explicitly requests PDF and a LaTeX engine is available.

### Setup chunk (`echo=FALSE, include=FALSE`)

Set global chunk options so no R code appears in the rendered document,
source the helper script, and force the R session to use UTF-8 so all
string output is encoded correctly before pandoc sees it:

```r
knitr::opts_chunk$set(echo = FALSE)
options(encoding = "UTF-8")
source("scripts/Two_sample_proportion_with_multiple_functions.R")
```

### Computation chunk (`echo=FALSE`)

Assign the four confirmed input values (and `threshold` if the client
specified one; default 0.05), then run the pipeline using the exact
function signatures from the script:

```r
n.tx      <- <n.tx>
n.ctrl    <- <n.ctrl>
resp.tx   <- <resp.tx>
resp.ctrl <- <resp.ctrl>
threshold <- 0.05   # replace if client specified a different level

validate_inputs(n.tx, n.ctrl, resp.tx, resp.ctrl)

contingency <- matrix(c(resp.tx, resp.ctrl, n.tx - resp.tx, n.ctrl - resp.ctrl),
                       nrow = 2, byrow = TRUE)
test_type   <- choose_test(contingency)                 # returns "chisq" or "fisher"
test_result <- run_selected_test(contingency, test_type) # reads resp.tx/n.tx/resp.ctrl/n.ctrl from this env for the fisher branch
confint     <- confidence_int(n.tx, n.ctrl, resp.tx, resp.ctrl, threshold)
interp      <- interpret_test(test_result$p_value, threshold)
```

Replace `<n.tx>`, `<n.ctrl>`, `<resp.tx>`, `<resp.ctrl>` with the actual
numbers before writing the file.

**Function reference (do not deviate from these signatures -- corrected
against `scripts/Two_sample_proportion_with_multiple_functions.R` during
migration; the source Claude doc listed extra arguments for
`run_selected_test` that the function does not actually take):**

| Function | Arguments | Returns |
|---|---|---|
| `validate_inputs` | `n.tx, n.ctrl, resp.tx, resp.ctrl` | stops with error if invalid |
| `choose_test` | `contingency` (matrix) | `"chisq"` or `"fisher"` |
| `run_selected_test` | `contingency, test_type` (the fisher branch also reads `resp.tx, n.tx, resp.ctrl, n.ctrl` from the calling environment) | list: `test_name`, `p_value`, `statistic`, `statistic_label` |
| `interpret_test` | `p_value, threshold` | list: `p_level`, `decision`, `evidence`, `conclusion` |
| `confidence_int` | `n.tx, n.ctrl, resp.tx, resp.ctrl, threshold = 0.05` | list: `ci_tx`, `ci_ctrl`, `ci_rd` |
| `two_sample_proportion_test` | `n.tx, n.ctrl, resp.tx, resp.ctrl, threshold=0.05` | prints the full conclusion paragraph |

- Always build the matrix inline as shown above.

### Narrative section

Write in Markdown. Use inline R (`` `r expr` ``) or an `echo=FALSE,
results='asis'` chunk for numeric values so the report is reproducible.
Mirror the detail level the client selected:

- **Brief** -> 2-3 sentences + no table
- **Moderate** -> single cohesive paragraph + summary table + one-line
  result
- **Detailed** -> Moderate paragraph + bar chart + contingency table +
  summary table + one-line result + plain-language interpretation

Reproduce the exact wording already shown to the client in the response; do
not rephrase or add new content.

**Symbol encoding rule (applies everywhere in the `.Rmd`):** Never paste raw
Unicode glyphs into the document source. Use HTML entities instead -- this
is the only form pandoc reliably converts to visible characters in HTML
output regardless of OS locale or R build:

| Symbol | Wrong (raw glyph) | Correct (HTML entity) |
|--------|-------------------|-----------------------|
| em dash | -- | `&mdash;` |
| en dash | - | `&ndash;` |
| Delta / Δ | Δ | `&Delta;` |
| chi / χ | χ | `&chi;` |
| superscript 2 | ² | `&sup2;` |
| greater-or-equal | >= | `&ge;` |
| less-or-equal | <= | `&le;` |
| alpha / α | α | `alpha` |
| times / x | x | `&times;` |
| bullet / • | • | `&#8226;` |
| asterisk / * | * | `&#42;` |

Apply UTF-8 characters directly in Markdown prose. Use HTML entities only
inside raw HTML tags or `paste()`/`sprintf()` chunks with `results='asis'`.

**Code span exception:** Never place HTML entities inside single-backtick
inline code (`` `...` ``) or fenced code blocks -- these render their
contents as literal text, so `&sup2;` and `&#42;` display verbatim instead
of decoding to ² and *. Any backtick-quoted line (e.g., the one-line
`Test: ...` summary) must use raw Unicode characters (X², *, α) directly
instead of entities.

**Asterisk / p-value stars rule:** The `interp$p_level` string returned by
`interpret_test()` may contain `*`, `**`, or `***` inside parentheses (e.g.
`"less than 0.001 (***)"`). When rendered inside a bold Markdown span
(`**...**`), these asterisks are consumed by the Markdown parser, collapsing
`(***)` to `()`. Always escape them with `gsub()` before inline use:

This `gsub()` substitution applies only when `interp$p_level` is placed
inside a bold span (`**...**`) or plain prose. Do not apply it -- and do not
use entities at all -- when the value is placed inside single backticks;
leave the raw asterisks there since code spans are never Markdown- or
entity-processed.

```r
`r gsub("\\*", "&#42;", interp$p_level)`
```

Use this form everywhere `interp$p_level` appears inline in the `.Rmd`.

### Bar Chart

The text for the percentages should be **black**; scale each bar's length
proportionally to its response rate so bar length visually encodes the
rate. Source the same helper used for the in-chat image and embed it
directly in the report (do not re-derive the HTML/CSS bar manually):

```{r, echo=FALSE, results='asis'}
source("scripts/response_rate_barplot.R")
plot_response_rates(resp.tx, n.tx, resp.ctrl, n.ctrl, file = "response_rates.png")
cat(sprintf('<img src="response_rates.png" alt="Response rates" style="max-width:600px;">'))
```

### Summary table

Only show when moderate or detailed is chosen.

Render with `knitr::kable()`:

Use HTML entities for all special characters -- `&Delta;` for Δ, `&mdash;`
for --, `&ge;` for >=, `&le;` for <=, `&chi;` for χ, `&sup2;` for ², `alpha`
for α. Never paste the raw Unicode glyph into a string literal; always use
the entity form so pandoc outputs the correct character regardless of the
system locale.

```r
result <- two_sample_proportion_test(n.tx, n.ctrl, resp.tx, resp.ctrl)

knitr::kable(
  data.frame(
    Metric    = c("Total", "Response rate", "Risk difference"),
    Treatment = c(
      n.tx,
      paste0(round(resp.tx / n.tx * 100, 2), "% (",
             round(result$ci_tx[, "Lower"] * 100, 2), "%, ",
             round(result$ci_tx[, "Upper"] * 100, 2), "%)"),
      paste0("&Delta; = ", round(abs(resp.tx/n.tx - resp.ctrl/n.ctrl) * 100, 2), "%")
    ),
    Control   = c(
      n.ctrl,
      paste0(round(resp.ctrl / n.ctrl * 100, 2), "% (",
             round(result$ci_ctrl[, "Lower"] * 100, 2), "%, ",
             round(result$ci_ctrl[, "Upper"] * 100, 2), "%)"),
      paste0("95% CI: (", round(result$ci_rd$conf.int[1] * 100, 2), "%, ",
                           round(result$ci_rd$conf.int[2] * 100, 2), "%)")
    )
  ),
  format = "html", escape = FALSE
)
```

Show this sentence underneath the table: **The confidence intervals for
response rates are computed using Clopper-Pearson, and the confidence
interval for the response rate difference is computed using the Newcombe
method.**

### Notation rule

In the HTML output, refer to hypotheses and significance level **in words
only** -- do not use LaTeX notation such as `H_a`, `H_0`, or `\alpha`. Write
"the null hypothesis", "the alternative hypothesis", and "a significance
level of 0.05" instead.

### Hyperlink rule

All hyperlinks in the `.Rmd` narrative **must** use standard Markdown syntax
`[link text](url)` -- never paste raw plain-text URLs. The `markdown`
package converts `[text](url)` to `<a href="url">text</a>` automatically,
making links clickable in the browser. Do **not** escape or HTML-encode
URLs; write them as-is inside the parentheses.

If you need an inline HTML hyperlink (e.g., inside a `paste()` string),
write the full `<a href="url">text</a>` tag and make sure the surrounding
chunk or `kable()` call uses `escape = FALSE` so the tag is rendered rather
than printed literally.

### Rendering

Use the following rendering strategy in order. Try each step; move to the
next only if the previous fails.

**Step 1 -- Pandoc-free render (preferred, no installation required)**

```r
if (!requireNamespace("markdown", quietly = TRUE)) install.packages("markdown")
knitr::knit("report.Rmd", output = "report.md")   # knit .Rmd -> .md
markdown::markdownToHTML("report.md", output = "report.html",
                         options = c("use_xhtml", "smartypants", "toc"),
                         fragment.only = FALSE)
```

This path requires only the `markdown` R package, which installs from CRAN
without any system-level dependency. No Pandoc needed. The `markdown`
package renders standard Markdown links `[text](url)` as clickable
`<a href="url">` tags by default -- no extra options are required for link
support. Do **not** pass `"skip_html"` in the options list, as that would
suppress raw HTML tags (including any `<a>` tags you write inline, and the
`<img>` tag used for the bar chart).

**Step 2 -- rmarkdown render (if Pandoc is available)**

```r
rmarkdown::render("report.Rmd", output_file = "report.html")
```

Use this only if Step 1 fails and `rmarkdown::find_pandoc()$version` is
non-empty.

**Step 3 -- Fallback**

If both steps fail, deliver the `.Rmd` file alone and include this message:

> "The `.Rmd` file is ready. To render it yourself, run
> `knitr::knit2html('report.Rmd')` in R (requires the `markdown` package),
> or open it in RStudio and click Knit."

Deliver both the `.Rmd` source and the rendered `.html` whenever rendering
succeeds.

### Completion message

After rendering succeeds, output **exactly** the following block, replacing
`<absolute-path>` with the actual absolute path to the output directory:

> Both files are ready in your working directory:
>
> - [report.Rmd](file://<absolute-path>/report.Rmd) -- the reproducible R
>   Markdown source
> - [report.html](file://<absolute-path>/report.html) -- the rendered HTML
>   report

Use `file://` URLs (e.g. `file:///Users/alice/project/report.html`) so the
links are clickable.

### Fallback (cannot execute R)

Trace through `scripts/Two_sample_proportion_with_multiple_functions.R`
mentally with the given inputs. Hard-code the computed values into the
`.Rmd` narrative so it reflects the exact numbers rather than a paraphrase.
