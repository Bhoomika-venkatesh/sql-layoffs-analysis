# sql-layoffs-analysis
SQL data cleaning and exploratory data analysis on tech layoffs dataset (2022-2023)
# Tech Layoffs SQL Analysis (2022–2023)

## Project Overview
This project performs end-to-end SQL analysis on a real-world dataset of 
tech industry layoffs from 2022–2023. It covers data cleaning, 
standardization, and exploratory data analysis to uncover trends in 
workforce reductions across companies, industries, and countries.

## Dataset
- Source:[Kaggle - Layoffs 2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- Records:2,000+ layoff events across global tech companies

## Tools Used
- MySQL
- SQL (CTEs, Window Functions, Aggregations, String Functions)

## Project Structure
| File | Description |
|------|-------------|
| `data_cleaning.sql` | Removes duplicates, standardizes data, handles nulls |
| `EDA.sql` | Exploratory analysis + original extended queries |

## Key Analysis Performed
- Companies and industries with highest total layoffs
- Rolling monthly layoff totals using window functions
- Top 3 companies with most layoffs per year using DENSE_RANK
- Industry recovery analysis (2022 vs 2023 comparison)
- Layoff rates by company funding stage
- Countries with highest average workforce reduction
- Companies with multiple rounds of layoffs
- Month-over-month percentage change in layoffs

## Key Findings
- The Consumer and Retail industries saw the highest total layoffs
- 2023 had significantly higher layoffs than 2022 despite fewer events
- Companies in Post-IPO stage laid off the most workers overall
- Several companies conducted 3+ rounds** of layoffs within the dataset period

## How to Run
1. Download the dataset from Kaggle (link above)
2. Import into MySQL as `world_layoffs.layoffs`
3. Run `data_cleaning.sql` first
4. Run `EDA.sql` for analysis
