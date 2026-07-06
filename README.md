# SIBDS-project
This SKILL.md statistical assistant was developed for the SIBDS 2026 research project, focusing on LLM, R code, and SKILL.md. The `binary_proportion_and_survival.zip` file aims to assist clinicians and researchers with conducting binary hypothesis tests and survival analyses between differing patient groups.

## Installation

Follow these steps to install our SKILL.md statistical assistant:

1. Download the `binary_proportion_and_survival.zip.`

2. Go to claude.com and open the sidebar.

3. Select 'Customize'.

4. Under the 'Skills' tab, select 'Add' and then 'Upload a skill.'

5. Upload the `binary_proportion_and_survival.zip`. Ensure to upload this exact file without unzipping.

## Usage

To use our SKILL.md statistical assistant:

1. Choose the 'Code' option.

2. Enter your clinical scenario, including the total number of patients and the number of patients who received an outcome in each arm, with the **triggering words**.

3. If prompted, allow Claude to run or install any packages.

4. Choose whether you would prefer a brief, moderate, or detailed response.

5. After the test runs, select if you would like the results exported as an R Markdown (.Rmd) and/or rendered HTML file.

### Triggering Words

To use this SKILL.md, users can explicitly ask Claude Code to 'use the binary_proportion_and_survival skill to conduct the analysis'. Otherwise, users can trigger tasks through task-specific phrases.

For **binary hypothesis testing** (via Chi-square or Fisher's Exact test), provide four numeric inputs representing patient group sizes and success/response counts. Then, enter any of the following phrases or similar phrases:

  - "Did the treatment work"
  - "Compare two groups"
  - "Conversion rate test"
  - "Statistical tests"
  - "Summary statistics"
  - "I have a study with X patients in the treatment arm, X patients in the control arm, X responders in the treatment group, and X responders in the control group"

For **survival analysis** that compares between and within covariates, provide a dataset that contains the event, timeframes, and covariates. Then, enter any of the following phrases or similar phrases:

  - "Survival analysis"
  - "Kaplan-Meier"
  - "KM curve"
  - "Log-rank test"
  - "Time to event"
  - "Censored data"
  - "Event time"
  - "Survival probability"

## Output option hierarchy

Our SKILL.md provides three output options of differing levels of detail to best meet varying statistical and clinical needs. The options are as follows:

- **Brief**: reports only the test statistic, p-value, hypothesis testing decision, and a one-line outcome summary. Best suited for professionals and practitioners who are already familiar with the relevant statistical methods and need results, not explanations.

- **Moderate**: includes everything in Brief, along with an explanation of the test assumptions and supporting tables where relevant. Best suited for users who have studied the relevant statistical concepts but are not deeply experienced with them in practice.

- **Detailed**: includes everything in Moderate, plus a comprehensive summary on the statistical method, definitions of all key terms, and step-by-step interpretations. Best suited for users without a formal statistical background who need conceptual grounding alongside the results.

Users can also ask questions regarding the output options in Claude, or try all options for themselves.

**Note to first time users** - this file will automatically install R in Claude and save results in a folder in the local desktop.




