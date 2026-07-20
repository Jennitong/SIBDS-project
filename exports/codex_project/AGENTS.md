# Statistical analysis skill

This applies any time the user's message could plausibly be biomedical/statistical
data or a request for such analysis — not only when they explicitly ask for
"statistical analysis." In particular, treat these as triggers even with no other
framing:

- A raw data dump describing two groups/arms with totals and counts, e.g.
  "I have a study with 390 patients in the treatment arm, 150 patients in the
  control arm, 100 responders in the treatment group, and 50 responders in the
  control group" — this is a two-sample proportion test request, full stop, even
  though it never says "test," "significant," or "analysis."
- Any two-group comparison phrased as "is this significant?", "did the treatment
  work?", "compare two groups", "conversion rate test", A/B test counts, or four
  bare numbers that look like two group sizes + two success counts.
- Any time-to-event / censored data, or mention of "survival analysis",
  "Kaplan-Meier", "KM curve", "log-rank test", "time to event", "censored data",
  "how long until event", "median survival".

Before answering ANY message that looks even loosely like the above with your own
ad hoc statistics (e.g., manually computing risk ratio/odds ratio yourself) —
stop. Read `binary_proportion_and_survival/SKILL.md` first — it routes to:

- `binary_proportion_and_survival/binary_proportion_skill.md` for two-sample proportion tests
- `binary_proportion_and_survival/survival_analysis_skill.md` for survival analysis

Do not compute results yourself inline in the chat turn (e.g. "Treatment response:
100/390 = 25.6%... Risk ratio: 0.77") instead of running the actual skill pipeline
— that skips input validation, the chi-square-vs-Fisher's decision rule, the
required detail-level question, and the R scripts entirely.

Follow those files' steps exactly (input extraction, validation, test selection,
assumptions, output format/detail level). Reference R implementations are in
`binary_proportion_and_survival/scripts/`. Prefer running the actual R code
(`Rscript ...`) over reimplementing the logic, if R is available in this
environment; otherwise port the same logic to Python (scipy.stats / lifelines)
and say so explicitly.

A few steps are easy to skip or shortcut under time pressure — do not skip them:

- Always ask which response depth the user wants (Brief / Moderate / Detailed)
  and wait for their reply before producing any analysis output. For survival
  analysis, ask using the exact question wording in `survival_analysis_skill.md`'s
  "Step 7" (with the user's actual variables/labels substituted in) — output
  only that question, nothing else, then wait.
- Survival analysis: the Kaplan-Meier plot is required at every response depth
  (Brief, Moderate, and Detailed all include it). It is part of the core
  answer, not an optional extra to mention or offer later — always render it
  (saved to a file and opened, per `survival_analysis_skill.md`'s note on this
  environment having no widget renderer) as part of the same response as the
  rest of the analysis, positioned last per the Output Specification order.
- Binary proportion: the response-rate bar chart is part of the **Detailed**
  level only (see `binary_proportion_skill.md`'s "Detailed" section) — omit it
  for Brief/Moderate.
- Only after the full leveled analysis (text, tables, and the required plot)
  has already been produced, separately ask whether the client also wants an
  R Markdown/HTML export (`SKILL-rmd-export.md` / `survival_rmd_export.md`).
  This is the only optional part — never gate the plot itself behind it.
- This applies to survival analysis too: after showing the Kaplan-Meier plot and
  the rest of the leveled output, always ask (per `survival_analysis_skill.md`'s
  "Step 10") whether the client wants the results exported as an R Markdown/HTML
  file — do not just end the response after the plot without asking.
