# SIBDS-project
This is the project for SIBDS 2026 research project, focusing on LLM, R code and SKILL.md. The file `binary_proportion_and_survival.zip` focuses on conducting binary proportion hypothesis testing and survival analysis between groups.

## Installation

Follow these steps to install our SKILL.md statistical assistant:

1. Download the `binary_proportion_and_survival.zip.`

2. Go to claude.com and open the sidebar.

3. Select 'Customize'.

4. Under the 'Skills' tab, select 'Add' and then 'Upload a skill.'

5. Upload the `binary_proportion_and_survival.zip`. Make sure to upload this exact file only.

## Usage

To use our SKILL.md statistical assistant:

1. Choose the 'Code' option.

2. Enter your clinical scenario, including the total number of patients and the number of patients who received an outcome in each arm, with the **triggering words**.

3. If prompted, allow Claude to run or install any packages.

4. Choose whether you would prefer a brief, moderate, or detailed response.

5. After the test runs, select if you would like the results exported as an R Markdown (.Rmd) and/or rendered HTML file.

### Triggering Words

To use this Skill, users could explicitly ask Claude Code to 'use the binary_proportion_and_survival skill to conduct the analysis'. Otherwise, users could trigger tasks through task-specific phrases: 

- If you would like to trigger the binary proportions hypothesis testing (via Chi-sq test or Fisher's Exact test), provide four numeric inputs representing group sizes and success/response counts. Then use the words:

  - "Did the treatment work"
  - "Compare two groups"
  - "Conversion rate test"
  - "Statistical tests"
  - "Summary statistics"
  - "I have a study with X patients in the treatment arm, X patients in the control arm, X responders in the treatment group, and X responders in the control group."

- If you would like to trigger the survival analysis that compares between and within covariates, provide a dataset that contains event, time, covariates, and use the words:

  - "Survival analysis"
  - "Kaplan-Meier"
  - "KM curve"
  - "Log-rank test"
  - "Time to event"
  - "Censored data"
  - "Event time"
  - "Survival probability"

## Response Levels

There are three response levels for statistical analysis to help users with different statistical background.

- Brief: reports only the test statistic, p-value, hypothesis testing decision, and a one-line outcome summary. Best suited for professionals and practitioners who are already familiar with the relevant statistical methods and need results, not explanations.

- Moderate: includes everything in Brief, plus an explanation of the test assumptions and supporting tables where relevant. Best suited for users who have studied the relevant statistical concepts but are not deeply experienced with them in practice.

- Detailed: includes everything in Moderate, plus full background on the statistical method, definitions of all key terms, and step-by-step interpretation. Best suited for users without a formal statistical background who need conceptual grounding alongside the results.

Users could also ask questions regarding the response levels in Claude, or try all result levels.

**Note to first time users** - this file will automatically install R in Claude and save results in a folder in local desktop. Users should give permission for complete analysis result.




