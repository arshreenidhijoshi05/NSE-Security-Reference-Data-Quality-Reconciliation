-----------------------------------------NSE SECURITY REFERENCE DATA QUALITY & RECONCILIATION---------------------------------------------

---** 1. PROJECT OVERVIEW

This project focuses on assessing the quality and consistency of NSE (National Stock Exchange of India) security reference data using PostgreSQL and Python.

Security reference data contains information used to identify and distinguish financial instruments. Maintaining accurate reference data is important for reliable financial reporting, security identification, and downstream analytical processes.

The project begins by examining a security master dataset and a smaller dataset containing selected securities. It aims to establish whether the records are complete, valid, unique, and consistent across the two datasets.

---** 2. BUSINESS PROBLEM

Financial datasets can contain missing information, duplicate records, invalid identifiers, or inconsistencies between data sources. If these issues are not identified, they may affect downstream reporting and analysis.

The business problem addressed in this project is:

How can we systematically validate the quality of financial security reference data and determine whether selected security records are consistent with a master dataset?

The project applies a structured data quality and reconciliation approach to investigate this question.

---** 3. PROJECT OBJECTIVES

Understand the structure and contents of the available security reference datasets.

Assess data completeness, uniqueness, consistency, and validity.

Identify potential data quality issues that require further investigation.

Reconcile selected security records against the master dataset.

Use SQL and Python to support systematic validation and reproducible analysis.

---** 4. DATASET OVERVIEW

SELECT *
FROM dataset_overview;

Both datasets contain five columns. Their exact column names, meanings, and data types will be documented as part of the profiling process.
The initial record-count and comparison checks have been completed. Detailed data quality checks will be performed in the next stage.

---** 5. TOOLS & TECHNOLOGIES

-- (PostgreSQL: Database queries, data profiling, validation, and reconciliation).
-- (Python: Supporting data inspection, comparison, and analysis where appropriate).
-- (This project focuses exclusively on SQL and Python).

---** 6. DATABASE SETUP & INITIAL VALIDATION

CREATE TABLE security_master (
    nse_symbol   VARCHAR(30),
    isin         VARCHAR(20),
    company_name VARCHAR(150),
    listing_date DATE,
    active_flag  BOOLEAN
);

SELECT COUNT(*) AS total_records
FROM security_master

SELECT *
FROM security_master
LIMIT 10

SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns
WHERE table_name = 'security_master'
ORDER BY ordinal_position

===================================================DATA_PROFILING===================================================

---** 7. DATASET SCHEMA INSPECTION

The structure of the security_master table was reviewed using PostgreSQL’s information_schema.columns view.
The table comprises five attributes capturing key security reference details: NSE symbol, ISIN, company name, listing date, and active status.

| Column        | Data Type | Max Length | Nullable |
|---------------|-----------|------------|----------|
| nse_symbol    | VARCHAR   | 30         | Yes      |
| isin          | VARCHAR   | 20         | Yes      |
| company_name  | VARCHAR   | 150        | Yes      |
| listing_date  | DATE      | —          | Yes      |
| active_flag   | BOOLEAN   | —          | Yes      |

Observations:
1. All five fields currently allow NULL values.
2. No primary key or mandatory constraints are defined.
3. The schema does not enforce uniqueness on identifiers such as nse_symbol or isin.

Implications:
1. Without constraints, data integrity risks exist (e.g., duplicate or incomplete records).
2. Nullable identifiers may complicate downstream joins and reporting.

---** 8. INVESTIGATE MISSING & BLANK VALUES
SELECT 
COUNT(*) AS total_records,
COUNT(*) FILTER (WHERE nse_symbol IS NULL) AS missing_nse_symbol,
COUNT(*) FILTER (WHERE isin IS NULL) AS missing_isin,
COUNT(*) FILTER (WHERE company_name IS NULL) AS missing_company_name,
COUNT(*) FILTER (WHERE listing_date IS NULL) AS missing_listing_date,
COUNT(*) FILTER (WHERE active_flag IS NULL) AS missing_active_flag
FROM security_master

-- Missing Value Analysis
-- A missing value check was performed on all five columns in the security_master table using PostgreSQL's COUNT(*) FILTER (WHERE column IS NULL) expression.

| Metric                     | Result |
|----------------------------|--------|
| Total records examined     | 2,384  |
| Missing NSE symbols        | 0      |
| Missing ISINs              | 0      |
| Missing company names      | 0      |
| Missing listing dates      | 0      |
| Missing active-status values | 0    |

Finding: No SQL NULL values were detected in any of the five columns across the 2,384 records examined.

--** 9. CHECK BLANK AND WHITESPACE-ONLY TEXT

SELECT 
COUNT(*) AS total_records,
COUNT(*) FILTER (WHERE TRIM(nse_symbol) = '') AS blank_nse_symbol,
COUNT(*) FILTER (WHERE TRIM(isin) = '') AS blank_isin,
COUNT(*) FILTER (WHERE TRIM(company_name) = '') AS blank_company_name
FROM security_master

-- Blank Value Analysis
-- After checking for SQL NULL values, the three text columns were examined for empty strings and whitespace-only values using PostgreSQL's TRIM() function.
| Metric                   | Result |
|---------------------------|--------|
| Total records examined    | 2,384  |
| Blank NSE symbols         | 0      |
| Blank ISINs               | 0      |
| Blank company names       | 0      |

Finding: No empty or whitespace-only values were detected in nse_symbol, isin, or company_name.

--** 10. CHECK DUPLICATE RECORDS

SELECT nse_symbol, isin, company_name, listing_date, active_flag, COUNT(*) AS occurance_count
FROM security_master
GROUP BY nse_symbol, isin, company_name, listing_date, active_flag
HAVING COUNT(*) > 1
ORDER BY occurance_count DESC

--The dataset was checked for exact duplicate records by grouping rows across all five columns and identifying combinations occurring more than once.
--Result: The query returned zero rows.
--Finding: No exact duplicate records were detected across the five columns in the 2,384-row dataset.

--** 11. CHECK DUPLICATE NSE SYMBOLS

SELECT nse_symbol, COUNT(*) AS occurrence_count
FROM security_master
GROUP BY nse_symbol
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC, nse_symbol; 

-- The nse_symbol column was examined to determine whether any symbol appeared in multiple records.
-- Result: The query returned zero rows.
-- Finding: No duplicate NSE symbols were detected among the 2,384 records. Each symbol appears only once in the dataset.

--** 12. CHECK DUPLICATE isin

SELECT isin, COUNT(*) AS occurrence_count
FROM security_master
GROUP BY isin
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC, isin; 

-- The isin column was examined to identify any International Securities Identification Numbers (ISINs) appearing in multiple records.
-- Result: The query returned zero rows.
-- Finding: No duplicate ISIN values were detected among the 2,384 records.

--** 13. VALIDATE isin FORMAT

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE isin !~ '^[A-Z]{2}[A-Z0-9]{9}[0-9]$'
    ) AS invalid_isin_format
FROM security_master;

Finding: All 2,384 ISIN values passed the applied structural format check. No format violations were detected.

--** 14. VALIDATE NSE symbol FORMAT

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE nse_symbol !~ '^[A-Z0-9]+$'
    ) AS invalid_symbol_format
FROM security_master;

Finding: Seventeen symbols did not conform to the applied uppercase-alphanumeric pattern.

--** 15. INSPECT THE FLAGGED SYMBOLS

SELECT nse_symbol, isin, company_name
FROM security_master
WHERE nse_symbol !~ '^[A-Z0-9]+$'
ORDER BY nse_symbol

The initial NSE symbol-format validation flagged 17 records because their symbols did not match the uppercase-alphanumeric pattern ^[A-Z0-9]+$.
The flagged records were retrieved and inspected. The symbols included special characters such as ampersands (&) and hyphens (-).
Examples included M&M, BAJAJ-AUTO, J&KBANK, and NAM-INDIA.
Finding: The investigation indicated that the initial validation rule was too restrictive for the observed symbol conventions. The 17 records were therefore treated as exceptions requiring investigation rather than confirmed data errors.

--** 16. REFINE THE FLAGGED SYMBOLS

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE nse_symbol !~ '^[A-Z0-9&-]+$'
    ) AS invalid_symbol_format
FROM security_master;

Finding: All 2,384 symbols passed the refined preliminary format check.
Conclusion: The 17 exceptions identified by the original rule were attributable to characters excluded by that rule. No additional exceptions were identified under the refined rule.

--** 17. VALIDATE company name FORMAT

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE company_name <> TRIM(company_name)
    ) AS names_with_outer_spaces
FROM security_master;

Finding: No company names contained leading or trailing spaces. All 2,384 records passed this whitespace validation check.

--** 18. CHECK REPEATED COMPANY NAMES

SELECT UPPER(TRIM(company_name)) AS normalized_company_name,
       COUNT(DISTINCT nse_symbol) AS symbol_count,
	   STRING_AGG(DISTINCT nse_symbol, ', ' ORDER BY nse_symbol) AS symbols
FROM security_master
GROUP BY UPPER(TRIM(company_name))
HAVING  COUNT(DISTINCT nse_symbol) > 1
ORDER BY symbol_count DESC, normalized_company_name 

Findings:
Future Enterprises Limited: FEL, FELDVR
GACM Technologies Limited: GATECH, GATECHDVR
Jain Irrigation Systems Limited: JISLDVREQS, JISLJALEQS

Interpretation: 
These cases indicate that a company name may be associated with multiple NSE symbols. 
This can occur when a company has different listed securities or share classes. 
The results require further investigation and are not automatically classified as errors.

--** 19. INTERNAL SPACES COMPANY NAMES

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE company_name ~ '[[:space:]]{2,}'
    ) AS names_with_multiple_spaces
FROM security_master;

Finding: No company names contained multiple consecutive whitespace characters. All 2,384 records passed this validation check.

--** 20. LISTING DATE VALIDATION

SELECT
    COUNT(*) AS total_records,
    MIN(listing_date) AS earliest_listing_date,
    MAX(listing_date) AS latest_listing_date,
    COUNT(*) FILTER (
        WHERE listing_date > CURRENT_DATE
    ) AS future_listing_dates
FROM security_master;

Finding: No records had listing dates later than the current database date. All 2,384 records passed this future-date check.

--** 21. ACTIVE vs INACTIVE SECURITIES

SELECT active_flag, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),2) AS percentage
FROM security_master
GROUP BY active_flag
ORDER BY active_flag

SELECT
    active_flag,
    COUNT(*) AS record_count
FROM security_master
GROUP BY active_flag
ORDER BY active_flag;

Finding: All 2,384 records are marked active. No inactive or missing status values were identified.

--** 22. DISTINCT RECORD COUNTS

SELECT 
COUNT(*) AS total_records,
COUNT(DISTINCT nse_symbol) AS distinct_symbols,
COUNT(DISTINCT isin) AS distinct_isins,
COUNT(*) - COUNT(DISTINCT nse_symbol) AS symbol_count_difference,
COUNT(*) - COUNT(DISTINCT isin) AS isin_count_difference
FROM security_master 

Finding: The number of distinct NSE symbols and ISINs matches the total record count. Both identifiers are unique across all 2,384 records.

--** 23. COMPANY NAME NORMALIZATION CHECK

SELECT UPPER(TRIM(company_name)) AS normalized_company_name,
COUNT(DISTINCT company_name) AS raw_name_variants,
STRING_AGG(DISTINCT company_name, '|' ORDER BY company_name) AS raw_name
FROM security_master
GROUP BY UPPER(TRIM(company_name))
HAVING COUNT(DISTINCT company_name) > 1
ORDER BY raw_name_variants DESC,  normalized_company_name

Finding: No company-name variations were identified that differed only by capitalization or leading/trailing whitespace.

===================================================DATA_RECONCILATION===================================================

--** 1. DATASET INSPECTION

CREATE TABLE explorer_20symbols (
    nse_symbol   VARCHAR(30),
    isin         VARCHAR(20),
    company_name VARCHAR(150),
    listing_date DATE,
    active_flag  BOOLEAN
);

SELECT e.nse_symbol
FROM explorer_20symbols AS e
LEFT JOIN security_master AS s
ON e.nse_symbol = s.nse_symbol
WHERE s.nse_symbol IS NULL

Interpretation: All 20 comparison symbols were found in security_master. No missing symbols were identified.

--** 2. DATASET COMPARISON

SELECT e.nse_symbol, e.isin AS explorer_isin, s.isin AS master_isin
FROM explorer_20symbols AS e
JOIN security_master AS s
ON e.nse_symbol = s.nse_symbol
WHERE e.isin <> s.isin

Interpretation: No ISIN mismatches were identified for symbols matched between the two datasets

--** 3. COMPANY NAME COMPARISON

SELECT e.nse_symbol, e.company_name AS explorer_company_name, s.company_name AS master_company_name
FROM explorer_20symbols AS e
JOIN security_master AS s
ON e.nse_symbol = s.nse_symbol
WHERE e.company_name <> s.company_name

Interpretation: No exact company name mismatches were identified for matched symbols.

--** 4. LISTING DATE COMPARISON

SELECT e.nse_symbol, e.listing_date AS explorer_listing_date, s.listing_date AS master_listing_date
FROM explorer_20symbols AS e
JOIN security_master AS s
ON e.nse_symbol = s.nse_symbol
WHERE e.listing_date <> s.listing_date

Interpretation: No listing-date mismatches were identified for matched symbols.

--** 5. ACTIVE STATUS COMPARISON

SELECT e.nse_symbol, e.active_flag AS explorer_active_flag, s.active_flag AS master_active_flag
FROM explorer_20symbols AS e
JOIN security_master AS s
ON e.nse_symbol = s.nse_symbol
WHERE e.active_flag <> s.active_flag

Interpretation: No active-status mismatches were identified for matched symbols.

--** 6. MATCHING STATUS COMPARISON

SELECT COUNT(*) AS matched_records
FROM explorer_20symbols AS e
INNER JOIN security_master AS s
ON e.nse_symbol = s.nse_symbol

Interpretation: All 20 records in the comparison dataset matched records in the primary security master by nse_symbol.

--** 7. OVERALL RECONCILIATION RATE

SELECT 
COUNT(*) AS total_comparison_records,
COUNT(s.nse_symbol) AS matched_records,
ROUND(COUNT(s.nse_symbol) * 100.0 / NULLIF(COUNT(*),0),2) AS match_percentage
FROM explorer_20symbols AS e
LEFT JOIN security_master AS s
ON e.nse_symbol = s.nse_symbol

Interpretation: All 20 comparison records matched the primary security master by nse_symbol.

--** 8. SUMMARY

SELECT 
COUNT(*) AS matched_records,
COUNT(*) FILTER(WHERE e.isin IS DISTINCT FROM s.isin) AS isin_mismatches,
COUNT(*) FILTER(WHERE e.company_name IS DISTINCT FROM s.company_name) AS company_name_mismatches,
COUNT(*) FILTER(WHERE e.listing_date IS DISTINCT FROM s.listing_date) AS listing_date_mismatches,
COUNT(*) FILTER(WHERE e.active_flag IS DISTINCT FROM s.active_flag) AS active_flag_mismatches
FROM explorer_20symbols AS e
JOIN security_master AS s
ON e.nse_symbol = s.nse_symbol;

Interpretation: No mismatches were detected across the four compared fields for the 20 matched records. 
The IS DISTINCT FROM operator also ensures that comparisons involving NULL values are handled safely.

===================================================DATASET_VALIDATION===================================================

SELECT 
COUNT(*) AS matched_records,
COUNT(*) FILTER(WHERE nse_symbol IS NULL) AS null_symbols,
COUNT(*) FILTER(WHERE isin IS NULL) AS null_isin,
COUNT(*) FILTER(WHERE company_name IS NULL) AS null_company_name,
COUNT(*) FILTER(WHERE listing_date IS NULL) AS null_listing_date,
COUNT(*) FILTER(WHERE active_flag IS NULL) AS null_active_flag
FROM explorer_20symbols AS e






