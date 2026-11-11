
# Multinational Business Intelligence Analysis

## Project Overview

This project analyzes multinational enterprise activity using data from the **Multinational Revenue, Employment, and Investment Database (MREID)** provided by the U.S. International Trade Commission (USITC).

The objective is to transform raw economic data into meaningful business insights through data extraction, transformation, storage, SQL analysis, and interactive visualization.

This project follows an end-to-end **Data Analytics workflow**, combining data engineering and business intelligence tools.

---

## Tools & Technologies

- **MySQL:** Database creation, data storage, and SQL queries.
- **n8n:** ETL workflow automation and data processing.
- **Power BI:** Interactive dashboards and data visualization.
- **SQL:** Data exploration, aggregation, and business analysis.
- **CSV / API:** Data source and extraction.

---

## Project Workflow

1. **Data Extraction:** Obtain multinational enterprise data from the MREID database.
2. **ETL Process:** Use n8n to automate data processing and transformation.
3. **Data Storage:** Load structured data into MySQL.
4. **SQL Analysis:** Perform queries to analyze subsidiaries, revenue, employment, and total assets.
5. **Data Visualization:** Build interactive Power BI dashboards to communicate the findings.

---

## Key Business Questions

The analysis explores the following business questions:

- How has multinational enterprise activity evolved over time?
- Which countries have the highest number of foreign affiliates?
- Which sectors generate the highest operating revenue?
- How are employment and total assets distributed across industries?
- How does domestic activity compare with international activity?
- Which sectors and countries show the most significant changes over time?

---

## Key Findings

The main findings of this project include:

- Analysis of multinational enterprise activity across countries and industries.
- Identification of sectors with significant operating revenue.
- Evaluation of employment and total assets across industries.
- Comparison between domestic and international activity.
- Analysis of trends and changes over time.

*Specific numerical findings and conclusions are documented based on the SQL analysis and Power BI dashboards.*

---

## Repository Structure

```text
multinational-business-intelligence-analysis/
│
├── README.md
│
├── data/
│   └── README.md
│
├── sql/
│   ├── structure.sql
│   └── queries.sql
│
├── etl/
│   └── workflow_n8n.json
│
└── powerbi/
    ├── report.pbix
    └── screenshots/

```

---

## Data Source

**MREID – Multinational Revenue, Employment, and Investment Database**

- **Provider:** U.S. International Trade Commission (USITC).
- **Data type:** Multinational enterprise activity.
- **Dimensions:** Countries, industries, and years.
- **Indicators:** Subsidiaries, operating revenue, employees, and total assets.

---

## Important Data Note

Total assets and annual investment are different financial concepts.

In this project, `TotalassetsthUSD` represents total assets in thousands of US dollars. It should not be interpreted as an annual investment flow.

---

## Project Objective

This project demonstrates practical skills in:

- Data extraction and transformation (ETL).
- Workflow automation with n8n.
- Relational database management with MySQL.
- SQL querying and data analysis.
- Business intelligence and visualization with Power BI.
- Data interpretation and communication of business insights.
