# NSE-Security-Reference-Data-Quality-Reconciliation
Financial reference data quality and reconciliation project using PostgreSQL and Python. Profiles 2,384 NSE security records and reconciles 20 selected securities, achieving a 100% match rate with zero field-level mismatches.

## 1. Project Overview

This project evaluates the data quality of an NSE security master dataset using PostgreSQL and Python. It checks data completeness, uniqueness, identifier formats, listing dates, and security status. A separate dataset containing 20 selected securities is reconciled against the master dataset to identify missing securities and field-level discrepancies.

The project demonstrates how data-quality checks and reconciliation can support reliable financial reference data and downstream reporting.

## 2. Business Problem

Financial institutions rely on accurate security reference data to identify and maintain information about listed securities. Missing identifiers, duplicate records, inconsistent company details, or incorrect listing information can affect reporting and downstream analytical processes.

This project applies a structured validation process to assess data quality and compare selected security records across two datasets.

## 3. Objectives

- Assess completeness of required fields.
- Identify duplicate records and duplicate security identifiers.
- Validate NSE symbol and ISIN formats.
- Review company-name consistency and listing dates.
- Examine the distribution of active-status values.
- Reconcile selected securities against the master dataset.
- Produce a repeatable validation summary using Python.

## 4. Tools and Technologies

- **PostgreSQL:** Data profiling, validation queries, joins, and reconciliation.
- **Python:** Reconciliation automation and summary reporting.
- **Pandas:** CSV loading, dataset merging, field comparisons, and validation summaries.
- **VS Code / Jupyter Notebook:** Python development and documentation.

## 5. Project Files

| File | Purpose |
|---|---|
| `nse_security_master.csv` | Master security dataset containing 2,384 records |
| `nse_explorer_20symbols.csv` | Comparison dataset containing 20 selected securities |
| `nse_security_data_quality.ipynb` | Python notebook for loading data, reconciliation, and reporting |
| SQL file (`.sql`) | PostgreSQL table setup, data profiling, and reconciliation queries |
| `README.md` | Project documentation |

## 6. Methodology

### Step 1: Data Profiling in PostgreSQL

The security master dataset was assessed for:

- Total record count.
- NULL and blank values in required fields.
- Exact duplicate records.
- Duplicate NSE symbols and ISINs.
- ISIN format validity.
- NSE symbol format validity.
- Leading or trailing spaces in company names.
- Listing-date range and future dates.
- Active-status distribution.

### Step 2: Validation Rule Refinement

An initial NSE symbol validation rule allowed only uppercase letters and numbers. It flagged 17 symbols, including `M&M`, `BAJAJ-AUTO`, `J&KBANK`, and `NAM-INDIA`.

These exceptions showed that the initial rule was too restrictive. The rule was refined to allow uppercase letters, numbers, ampersands, and hyphens. The refined validation returned zero invalid symbols.

This illustrates the importance of understanding legitimate business values before classifying records as defective.

### Step 3: Reconciliation in PostgreSQL

The 20 selected securities were compared with the master dataset using NSE symbols as the matching key.

The comparison assessed whether each selected symbol existed in the master and whether the following fields agreed:

- ISIN
- Company name
- Listing date
- Active status

### Step 4: Reconciliation in Python

Pandas was used to merge the comparison dataset with the master dataset and identify matched and unmatched records.

A validation summary was generated to report the match rate and field-level mismatch counts. This provides a repeatable way to review reconciliation results.

## 7. Key Results

### Security Master Data Quality

| Check | Result |
|---|---:|
| Total security records | 2,384 |
| NULL values across checked fields | 0 |
| Blank or whitespace-only required text values | 0 |
| Exact duplicate rows | 0 |
| Duplicate NSE symbols | 0 |
| Duplicate ISINs | 0 |
| Invalid ISIN formats | 0 |
| Invalid NSE symbols under the refined rule | 0 |
| Company names with leading/trailing spaces | 0 |
| Future listing dates | 0 |

The listing dates ranged from 8 February 1995 to 16 July 2026. All 2,384 records had `active_flag = TRUE`; this is an observed property of the supplied dataset, not independent confirmation of each security's status.

Repeated normalized company-name groups were also observed for Future Enterprises Limited, GACM Technologies Limited, and Jain Irrigation Systems Limited. These were treated as review observations rather than automatic errors because different securities or share classes may have related company names.

### Reconciliation Results

| Metric | Result |
|---|---:|
| Selected securities | 20 |
| Matched securities | 20 |
| Unmatched securities | 0 |
| Symbol match rate | 100% |
| ISIN mismatches | 0 |
| Company-name mismatches | 0 |
| Listing-date mismatches | 0 |
| Active-status mismatches | 0 |

The 20 selected securities matched the master dataset, with no discrepancies in the four compared fields.

## 8. Business Value

The workflow demonstrates how structured data-quality controls can help:

- Detect missing or duplicate security records.
- Validate identifier formats before downstream use.
- Identify discrepancies between reference datasets.
- Improve the repeatability of data validation.
- Provide a concise reconciliation summary for review and reporting.

## 9. How to Run the Project

1. Keep both CSV files, the SQL file, and the notebook in the same project folder.
2. Create or select a PostgreSQL database and execute the SQL setup and validation queries as documented in the SQL file.
3. Open `nse_security_data_quality.ipynb` in VS Code.
4. Ensure Python and Pandas are available in the selected Python environment.
5. Run the notebook cells in order to load the CSV files, reconcile the datasets, and generate the validation summary.

The notebook expects the two CSV files to be available in its working directory.

## 10. Limitations

- The comparison dataset contains only 20 selected securities and does not represent an exhaustive reconciliation of the full master dataset.
- A successful match demonstrates consistency between the two supplied datasets; it does not independently verify the values against an authoritative NSE source.
- The presence of active status for every master record does not establish that every status value is correct.
- The project validates the supplied snapshot and does not implement continuous monitoring or scheduled production checks.

## 11. Resume Bullet

Built a PostgreSQL and Python data-quality and reconciliation workflow for a 2,384-record NSE security master, validating completeness, uniqueness, identifier formats, listing dates, and status fields; reconciled 20 selected securities with a 100% match rate and zero discrepancies across four compared fields.

## 12. Interview Explanation

“I built a financial reference-data quality project using PostgreSQL and Python. I first profiled a security master containing 2,384 records to check for missing values, duplicates, invalid identifiers, and listing-date issues. I then reconciled 20 selected securities against a comparison dataset using NSE symbols as the matching key. All 20 securities matched, and I found no mismatches across ISIN, company name, listing date, or active status. One important learning was that validation rules must accommodate legitimate symbol formats, so I refined an overly restrictive NSE symbol rule rather than incorrectly treating valid symbols as data defects.”

