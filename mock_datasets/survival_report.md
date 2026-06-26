---
title: "Survival Analysis Report"
date: "2026-06-25"
output:
  html_document:
    toc: true
    toc_float: true
    html_encoding: "UTF-8"
encoding: UTF-8
---





## Overview

This report presents a survival analysis examining whether time-to-event outcomes differ across subgroups defined by gender (Female, Male) and age category (Adult, Child, Senior, Youth), yielding 8 strata in total. The analysis applies the log-rank test with Bonferroni correction, fits Kaplan-Meier survival curves per stratum, and reports median and mean survival estimates with 95% confidence intervals.

---

## 1. Hypothesis Test Summary

**Null Hypothesis:** Survival curves are identical across all strata of genders &times; age.

**Alternative Hypothesis:** At least one survival curve differs.

| Statistic | Value |
|:---|:---|
| Test | Log-rank test with Bonferroni correction |
| &chi;&sup2; statistic | 2.4701 |
| Degrees of freedom | 7 |
| p-value | 0.9293 |
| Decision | Fail to Reject Null Hypothesis at &alpha; = 0.05 |

---

## 2. Background and Test

This analysis examines time-to-event data from 30 observations across 8 strata formed by crossing gender (Female, Male) with age category (Adult, Child, Senior, Youth). An event (outcome = 1) indicates the occurrence of the outcome of interest; censoring (outcome = 0) indicates the outcome had not yet occurred by the end of follow-up. Because two categorical covariates are present and more than two strata are compared simultaneously, a **log-rank test with Bonferroni correction** was selected. The Bonferroni adjustment controls the family-wise Type I error rate when making multiple simultaneous comparisons. The test rests on three key assumptions: (1) **Proportional Hazards** &mdash; the hazard ratio between any two groups remains constant over time; (2) **Non-Informative Censoring** &mdash; the reason for censoring is unrelated to the probability of experiencing the event; and (3) **Independent Observations** &mdash; each participant's outcome is independent of all others.

The log-rank test yielded &chi;&sup2;(7) = 2.47, p = 0.9293. Based on this result, we **Fail to Reject Null Hypothesis** at significance level &alpha; = 0.05. There is no statistically significant evidence that survival curves differ across any of the eight gender &times; age subgroups.

---

## 3. Quantile Table

<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>Survival Quantiles with 95% Confidence Intervals</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Group </th>
   <th style="text-align:left;"> Median (95% CI) </th>
   <th style="text-align:left;"> Q25 (95% CI) </th>
   <th style="text-align:left;"> Q75 (95% CI) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Female.Adult </td>
   <td style="text-align:left;"> 19.38 (3.08–NR) </td>
   <td style="text-align:left;"> 6.69 (3.08–19.38) </td>
   <td style="text-align:left;"> 42.06 (6.69–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Adult </td>
   <td style="text-align:left;"> 21.52 (6.7–NR) </td>
   <td style="text-align:left;"> 10.48 (6.7–21.52) </td>
   <td style="text-align:left;"> 21.84 (6.7–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Child </td>
   <td style="text-align:left;"> 21.12 (12.15–NR) </td>
   <td style="text-align:left;"> 12.15 (12.15–NR) </td>
   <td style="text-align:left;"> NR (12.15–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Child </td>
   <td style="text-align:left;"> 12.28 (4.73–NR) </td>
   <td style="text-align:left;"> 4.73 (4.73–NR) </td>
   <td style="text-align:left;"> NR (4.73–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Senior </td>
   <td style="text-align:left;"> 11.3 (10.42–NR) </td>
   <td style="text-align:left;"> 10.42 (10.42–NR) </td>
   <td style="text-align:left;"> 12.18 (10.42–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Senior </td>
   <td style="text-align:left;"> 13.16 (4.5–NR) </td>
   <td style="text-align:left;"> 4.5 (4.5–NR) </td>
   <td style="text-align:left;"> NR (4.5–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Youth </td>
   <td style="text-align:left;"> 8.75 (3.75–NR) </td>
   <td style="text-align:left;"> 3.75 (3.75–NR) </td>
   <td style="text-align:left;"> NR (3.75–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Youth </td>
   <td style="text-align:left;"> 5.76 (3.2–NR) </td>
   <td style="text-align:left;"> 3.2 (3.2–NR) </td>
   <td style="text-align:left;"> NR (3.2–NR) </td>
  </tr>
</tbody>
</table>

---

## 4. Mean Survival Table

<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
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
   <td style="text-align:left;"> Female.Adult </td>
   <td style="text-align:right;"> 18.68 </td>
   <td style="text-align:right;"> 6.52 </td>
   <td style="text-align:right;"> 5.90 </td>
   <td style="text-align:right;"> 31.45 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Adult </td>
   <td style="text-align:right;"> 16.45 </td>
   <td style="text-align:right;"> 2.92 </td>
   <td style="text-align:right;"> 10.73 </td>
   <td style="text-align:right;"> 22.16 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Child </td>
   <td style="text-align:right;"> 25.11 </td>
   <td style="text-align:right;"> 7.24 </td>
   <td style="text-align:right;"> 10.93 </td>
   <td style="text-align:right;"> 39.29 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Child </td>
   <td style="text-align:right;"> 23.39 </td>
   <td style="text-align:right;"> 13.20 </td>
   <td style="text-align:right;"> -2.48 </td>
   <td style="text-align:right;"> 49.27 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Senior </td>
   <td style="text-align:right;"> 11.30 </td>
   <td style="text-align:right;"> 0.62 </td>
   <td style="text-align:right;"> 10.08 </td>
   <td style="text-align:right;"> 12.52 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Senior </td>
   <td style="text-align:right;"> 23.28 </td>
   <td style="text-align:right;"> 13.28 </td>
   <td style="text-align:right;"> -2.75 </td>
   <td style="text-align:right;"> 49.31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Youth </td>
   <td style="text-align:right;"> 18.19 </td>
   <td style="text-align:right;"> 9.82 </td>
   <td style="text-align:right;"> -1.06 </td>
   <td style="text-align:right;"> 37.43 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Youth </td>
   <td style="text-align:right;"> 22.63 </td>
   <td style="text-align:right;"> 13.74 </td>
   <td style="text-align:right;"> -4.30 </td>
   <td style="text-align:right;"> 49.56 </td>
  </tr>
</tbody>
</table>

*Mean survival is bounded by the largest observed event time in each stratum (restricted mean survival time).*

---

## 5. Interaction Summary

<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>Interaction Strata Summary (genders × age)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Stratum (Gender × Age) </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> Events </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Female.Adult </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Adult </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Child </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Child </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Senior </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Senior </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Female.Youth </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Male.Youth </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

**Warning:** Most strata contain fewer than 5 events. Results for sparse strata (Male.Child, Male.Senior, Male.Youth, Female.Senior) should be interpreted with caution.

---

## 6. Kaplan-Meier Plot

![plot of chunk km-plot](figure/km-plot-1.png)

---

## 7. Plain-Language Interpretation

In plain terms, this analysis found no meaningful difference in how long it took for the event to occur between any of the gender and age groups examined. A p-value of 0.9293 means that if the groups truly had identical survival experiences, there is a 92.9% chance of observing differences at least as large as those seen here purely by chance &mdash; a very high probability indicating the observed variation is entirely consistent with random fluctuation.

It is critical to note that **statistical non-significance is not the same as proof of no difference.** With only 30 total observations spread across 8 strata, this analysis is substantially underpowered. A true survival difference between subgroups could easily go undetected at this sample size. The wide confidence intervals (and in some cases undefined bounds) visible in the quantile and mean survival tables confirm this uncertainty.

The p-value represents the probability of observing a difference this large or larger by chance alone, assuming no true difference exists. We are 95% confident that the true median (or mean) survival time for each group lies within the interval shown; however, for several strata these intervals are very wide or include negative values, reflecting insufficient data to draw reliable conclusions.

Any conclusions drawn from this dataset should be treated as preliminary. A larger sample with more events per stratum would be required before meaningful group comparisons can be made.
