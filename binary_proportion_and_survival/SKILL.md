---
name: statistical-analysis
description: >
  Performs binary proportion hypothesis testing or survival analysis upon request.
  Explain the contents of brief, moderate or detailed response for the client.
  List the functionality that can be provided.
---

## Trigger

Triggered when the client ask for statistical analysis, binary proportion, survival analysis, the use of this skill, functionality and so on.

This skill supports two types of statistical analyses:

- **Binary proportion hypothesis testing** → handled by [`binary_proportion_skill.md`](binary_proportion_skill.md)
- **Survival analysis** → handled by [`survival_analysis_skill.md`](survival_analysis_skill.md)

---
# Output 

In a paragraph, use **professional tone** to explain the function and use of this skill.
- Explain the analysis that can be provided (binary proportion hypothesis testing, survival analysis). 
- Explain this skill file could provide relevant graphs, tables, could help determine and choose most appropriate statistical test.
- Could explain background and test assumptions.
- Explain the levels of responses (brief/moderate/detailed).
- Mention that R Markdown file and html could be provided by request.

Read the detailed below.
---

## Progressive Disclosure

To keep responses appropriately scoped, please indicate your preferred detail level. If none is specified, the skill will infer one based on context.

### Brief
Reports only the test statistic, p-value, hypothesis testing decision, and a one-line outcome summary. Best suited for professionals and practitioners who are already familiar with the relevant statistical methods and need results, not explanations.

### Moderate
Includes everything in Brief, plus an explanation of the test assumptions and supporting tables where relevant. Best suited for users who have studied the relevant statistical concepts but are not deeply experienced with them in practice.

### Detailed
Includes everything in Moderate, plus full background on the statistical method, definitions of all key terms, and step-by-step interpretation. Best suited for users without a formal statistical background who need conceptual grounding alongside the results.

---

## Output Formats

By default, results are returned as formatted text in the chat window.

If you request it, the skill can also produce an **R Markdown (.Rmd) file** and a rendered **HTML report** displayed in a preview window. Note that generating and rendering these files takes additional time.
