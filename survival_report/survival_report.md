---
title: "Survival Analysis Report"
date: "2026-06-29"
output:
  html_document:
    toc: true
    toc_float: true
    html_encoding: "UTF-8"
encoding: UTF-8
---





## Hypothesis Test Summary

**Null Hypothesis:** Survival curves are identical across all groups of gender.

**Alternative Hypothesis:** At least one survival curve differs.

| Statistic | Value |
|---|---|
| &chi;&sup2; statistic | 3.971 |
| Degrees of freedom | 1 |
| p-value | < 0.05 (&#42;) |
| Decision | Reject Null Hypothesis at &alpha; = 0.05 |

## Background and Method

This analysis employs the Kaplan-Meier (KM) estimator to compare time-to-event survival distributions between two gender groups (0 = female, n = 65; 1 = male, n = 35) using the WHAS100 dataset. The event of interest (`fstat = 1`) was observed in 28 females and 23 males; remaining participants were right-censored, meaning their follow-up ended before the event occurred (e.g., administrative study end on 31 December 2002). The time variable (`lenfol`) records the number of days from hospital admission to the event or censoring.

The log-rank test was selected as the appropriate comparison method. This test assumes: (1) **Proportional Hazards** &mdash; the ratio of hazard rates between groups remains constant over time; (2) **Non-Informative Censoring** &mdash; the reason a participant is censored is unrelated to their risk of the event; and (3) **Independent Observations** &mdash; survival times across individuals are mutually independent.

## Test Results

The log-rank test yielded &chi;&sup2;(1) = 3.971, p < 0.05 (&#42;). We therefore **Reject Null Hypothesis** at significance level &alpha; = 0.05, concluding that there is statistically significant evidence that the survival curves differ between female and male patients.

## Quantile Table

<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
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
   <td style="text-align:left;"> gender = 0 (female) </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:left;"> 2624 (1907–NR) </td>
   <td style="text-align:left;"> 1054 (274–1624) </td>
   <td style="text-align:left;"> NR (2624–NR) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> gender = 1 (male) </td>
   <td style="text-align:right;"> 35 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 1806 (461–2201) </td>
   <td style="text-align:left;"> 302 (98–1002) </td>
   <td style="text-align:left;"> 2710 (2031–NR) </td>
  </tr>
</tbody>
</table>

## Mean Survival Table

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
   <td style="text-align:left;"> gender = 0 (female) </td>
   <td style="text-align:right;"> 1907.42 </td>
   <td style="text-align:right;"> 126.01 </td>
   <td style="text-align:right;"> 1660.44 </td>
   <td style="text-align:right;"> 2154.40 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> gender = 1 (male) </td>
   <td style="text-align:right;"> 1475.21 </td>
   <td style="text-align:right;"> 181.71 </td>
   <td style="text-align:right;"> 1119.07 </td>
   <td style="text-align:right;"> 1831.36 </td>
  </tr>
</tbody>
</table>

*Mean survival is bounded by the largest observed event time in each group (restricted mean survival time).*

## Kaplan-Meier Plot

![plot of chunk km-plot](figure/km-plot-1.png)

## Plain-Language Interpretation

Females in this dataset had notably longer survival times than males. The median survival time for females was 2624 days (95% CI: 1907&ndash;NR), compared to 1806 days for males (95% CI: 461&ndash;2201 days) &mdash; a difference of over two and a half years at the median. The mean restricted survival time also favoured females at 1907.4 days (95% CI: 1660.4&ndash;2154.4) versus 1475.2 days for males (95% CI: 1119.1&ndash;1831.4).

The p-value of 0.0463 is the probability of observing a difference in survival curves this large or larger purely by chance, assuming no true effect of gender on survival. A value below 0.05 indicates this difference is unlikely to be due to random variation alone. We are 95% confident that the true median survival time for females lies above 1,907 days, and for males between 461 and 2,201 days.

While this result is statistically significant, statistical significance does not automatically imply clinical or practical importance &mdash; the observed difference may be confounded by other variables such as age, BMI, or comorbidities that were not accounted for in this analysis. Additionally, with only 35 male participants, the confidence intervals for the male group are notably wider, reflecting greater uncertainty in those estimates. These findings should be considered exploratory and interpreted alongside other clinical and demographic factors.
