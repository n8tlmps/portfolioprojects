# Data Analysis

### Goal
The goal of this project is to conduct a comprehensive data analysis on the Stack Overflow Developer Survey 2023 dataset and extract valuable insights from the data.

### Questions of Interest
   - At what companies do developers get paid the most?
   - How much does remote working matter to employees?
   - How does coding experience affect the level of pay?
   - What’s the most popular method of learning to code?
   - What database systems and cloud services are the most popular?

### Methodology
To determine salary patterns for different companies, I clustered 

```python
# analysis will be conducted on selected columns:
selected_columns = ['Age',
                    'Employment', 
                    'RemoteWork', 
                    'LearnCode', 
                    'EdLevel', 
                    'YearsCode', 
                    'YearsCodePro', 
                    'DevType', 
                    'OrgSize', 
                    'DatabaseHaveWorkedWith',
                    'DatabaseWantToWorkWith',
                    'PlatformHaveWorkedWith',
                    'PlatformWantToWorkWith',
                    'Industry', 
                    'ConvertedCompYearly']
df = survey_raw_df[selected_columns]
```
