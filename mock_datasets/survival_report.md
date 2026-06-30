---
title: "Survival Analysis Report"
date: "2026-06-30"
output:
  html_document:
    toc: true
    toc_float: true
    html_encoding: "UTF-8"
encoding: UTF-8
---





## Hypothesis Test Summary

**Null Hypothesis:** Survival curves are identical across all groups of agecat and gender.

**Alternative Hypothesis:** At least one survival curve differs.

| Statistic | Value |
|---|---|
| &chi;&sup2; statistic | 18.27 |
| Degrees of freedom | 7 |
| p-value | 0.0108 (&#42;) |
| Decision | Reject Null Hypothesis at &alpha; = 0.05 |

## Background and Methods

This survival analysis examines whether age category (`agecat`) and gender jointly affect time-to-event (`lenfol`, days from hospital admission to death), with death (`fstat = 1`) as the event of interest and administrative censoring (`fstat = 0`) indicating patients alive at the end of follow-up. The analysis includes 8 strata formed by crossing age category (4 levels: [32,60), [60,70), [70,80), [80,92]) &times; gender (Female = 0, Male = 1) across 100 patients. A **log-rank test with Bonferroni correction** was selected because two categorical covariates are present, producing more than two comparison groups. The three key assumptions are: (1) **Proportional Hazards** &mdash; the hazard ratio between any two groups remains constant over time; (2) **Non-Informative Censoring** &mdash; whether an observation is censored is unrelated to the underlying risk of the event; and (3) **Independent Observations** &mdash; each subject's survival time is independent of all others.

The log-rank test yielded &chi;&sup2;(7) = 18.27, p = 0.0108 (&#42;). The decision is to **Reject Null Hypothesis** at significance level &alpha; = 0.05, indicating there is a statistically significant difference in survival across at least one of the 8 agecat &times; gender strata.

## Quantile Table

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>Survival Quantiles with 95% Confidence Intervals</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Group </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> Events </th>
   <th style="text-align:left;"> Median (95% CI) </th>
   <th style="text-align:left;"> Q25 (95% CI) </th>
   <th style="text-align:left;"> Q75 (95% CI) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> [32,60).0 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> NR (1401–NR) </td>
   <td style="text-align:left;"> 2060 (538–NR) </td>
   <td style="text-align:left;"> NR (NR–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [60,70).0 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> 2624 (2624–NR) </td>
   <td style="text-align:left;"> 2624 (6–NR) </td>
   <td style="text-align:left;"> NR (2624–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [70,80).0 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> 1624 (189–NR) </td>
   <td style="text-align:left;"> 274 (6–1557) </td>
   <td style="text-align:left;"> 2421 (1624–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [80,92].0 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> 936 (123–NR) </td>
   <td style="text-align:left;"> 274 (107–936) </td>
   <td style="text-align:left;"> NR (492–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [32,60).1 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> 1577 (1011–NR) </td>
   <td style="text-align:left;"> 1172 (1011–NR) </td>
   <td style="text-align:left;"> NR (1011–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [60,70).1 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> 1807.5 (14–NR) </td>
   <td style="text-align:left;"> 302 (14–NR) </td>
   <td style="text-align:left;"> NR (302–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [70,80).1 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> 2031 (128–NR) </td>
   <td style="text-align:left;"> 187 (128–2031) </td>
   <td style="text-align:left;"> NR (1806–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [80,92].1 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:left;"> 841 (104–2201) </td>
   <td style="text-align:left;"> 148 (62–461) </td>
   <td style="text-align:left;"> 2201 (841–NR) </td>
  </tr>
</tbody>
</table>

*NR = Not Reached. The survival estimate did not decline to the specified percentile during the follow-up period. NR in confidence interval bounds indicates the interval could not be estimated &mdash; too few events were observed for the survival curve to reach that quantile threshold within the follow-up period.*

---

## Mean Survival Table

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>Restricted Mean Survival Time with 95% Confidence Intervals</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Group </th>
   <th style="text-align:right;"> Mean Survival </th>
   <th style="text-align:right;"> SE </th>
   <th style="text-align:right;"> 95% CI Lower </th>
   <th style="text-align:right;"> 95% CI Upper </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> [32,60).0 </td>
   <td style="text-align:right;"> 2291.20 </td>
   <td style="text-align:right;"> 169.45 </td>
   <td style="text-align:right;"> 1959.08 </td>
   <td style="text-align:right;"> 2623.32 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [60,70).0 </td>
   <td style="text-align:right;"> 2309.29 </td>
   <td style="text-align:right;"> 206.29 </td>
   <td style="text-align:right;"> 1904.97 </td>
   <td style="text-align:right;"> 2713.62 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [70,80).0 </td>
   <td style="text-align:right;"> 1486.69 </td>
   <td style="text-align:right;"> 240.92 </td>
   <td style="text-align:right;"> 1014.48 </td>
   <td style="text-align:right;"> 1958.90 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [80,92].0 </td>
   <td style="text-align:right;"> 1262.36 </td>
   <td style="text-align:right;"> 295.14 </td>
   <td style="text-align:right;"> 683.88 </td>
   <td style="text-align:right;"> 1840.84 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [32,60).1 </td>
   <td style="text-align:right;"> 1839.60 </td>
   <td style="text-align:right;"> 331.54 </td>
   <td style="text-align:right;"> 1189.79 </td>
   <td style="text-align:right;"> 2489.41 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [60,70).1 </td>
   <td style="text-align:right;"> 1579.17 </td>
   <td style="text-align:right;"> 480.50 </td>
   <td style="text-align:right;"> 637.39 </td>
   <td style="text-align:right;"> 2520.95 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [70,80).1 </td>
   <td style="text-align:right;"> 1660.14 </td>
   <td style="text-align:right;"> 392.00 </td>
   <td style="text-align:right;"> 891.82 </td>
   <td style="text-align:right;"> 2428.47 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [80,92].1 </td>
   <td style="text-align:right;"> 1234.35 </td>
   <td style="text-align:right;"> 258.78 </td>
   <td style="text-align:right;"> 727.13 </td>
   <td style="text-align:right;"> 1741.56 </td>
  </tr>
</tbody>
</table>

*Mean survival is bounded by the largest observed event time in each group (restricted mean survival time).*

---

## Interaction Summary

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>Interaction Strata Summary (agecat × gender)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> strata </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> Events </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> [32,60).0 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [60,70).0 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [70,80).0 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [80,92].0 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [32,60).1 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [60,70).1 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [70,80).1 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [80,92].1 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 13 </td>
  </tr>
</tbody>
</table>

**Warning:** Stratum **[60,70).0** has fewer than 5 events &mdash; results for this stratum should be interpreted cautiously.

**Warning:** Stratum **[32,60).1** has fewer than 5 events &mdash; results for this stratum should be interpreted cautiously.

**Warning:** Stratum **[60,70).1** has fewer than 5 events &mdash; results for this stratum should be interpreted cautiously.

**Warning:** Stratum **[70,80).1** has fewer than 5 events &mdash; results for this stratum should be interpreted cautiously.

---

## Pairwise Table (Bonferroni-adjusted)

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>Pairwise Log-Rank p-values (Bonferroni-adjusted)</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;"> [32,60).0 </th>
   <th style="text-align:left;"> [60,70).0 </th>
   <th style="text-align:left;"> [70,80).0 </th>
   <th style="text-align:left;"> [80,92].0 </th>
   <th style="text-align:left;"> [32,60).1 </th>
   <th style="text-align:left;"> [60,70).1 </th>
   <th style="text-align:left;"> [70,80).1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> [60,70).0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [70,80).0 </td>
   <td style="text-align:left;"> 0.3454 </td>
   <td style="text-align:left;"> 0.2133 </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [80,92].0 </td>
   <td style="text-align:left;"> 0.131 </td>
   <td style="text-align:left;"> 0.128 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [32,60).1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [60,70).1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> — </td>
   <td style="text-align:left;"> — </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [70,80).1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> — </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [80,92].1 </td>
   <td style="text-align:left;"> 0.0481 </td>
   <td style="text-align:left;"> 0.2816 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
  </tr>
</tbody>
</table>

---

## Kaplan-Meier Plot

![plot of chunk km-plot](figure/km-plot-1.png)

---

## Plain-Language Interpretation

This analysis examined whether survival times differed across combinations of age group and gender among 100 patients in the WHAS100 dataset. The log-rank test with Bonferroni correction was statistically significant (&chi;&sup2;(7) = 18.27, p = 0.0108), meaning the probability of observing differences this large by chance alone &mdash; if survival were truly identical across all groups &mdash; is approximately 1.1%. We therefore conclude that at least one group's survival experience differs meaningfully from the others.

In practical terms, a clear age gradient is visible: younger patients (ages 32&ndash;70) survived substantially longer on average (restricted mean survival: ~1,579&ndash;2,309 days) compared to the oldest patients (ages 80&ndash;92, mean: ~1,234&ndash;1,262 days), regardless of gender. After Bonferroni correction, only the contrast between [80,92] Male and [32,60) Female reached statistical significance (adjusted p = 0.048). Statistical significance does not, however, imply clinical significance &mdash; the observed differences should be interpreted alongside clinical context.

We are 95% confident that the true median (or mean) survival time for each group lies within the intervals shown in the tables above. Important caveats include: three strata ([60,70) Female, [60,70) Male, [70,80) Male) had fewer than 5 events, which reduces the reliability of pairwise comparisons for those groups; the wide confidence intervals in male strata with small samples reflect considerable uncertainty in those estimates; and the proportional hazards assumption underlying the log-rank test should be formally verified for a definitive assessment.
