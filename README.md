# Dubai Real Estate Analytics

End-to-end analytics project working with **1M+ raw real estate transactions** from the Dubai Land Department. After profiling and cleaning, filtered to **286K recent transactions (2020–2023)** for in-depth analysis.

## 📊 Power BI Dashboard

![Market Overview](PowerBI/screenshots/page1_market_overview.png)

A 4-page interactive dashboard built on 286K cleaned transactions.

**Pages:**
- **Market Overview** — KPIs, quarterly trends, property type distribution
- **Area Analysis** — Treemap + top areas by price per sqm
- **Property Analysis** — Type, sub-type, room distribution, parking impact
- **Executive Summary** — Key findings + recommendations + AI workflow

📂 [View all dashboard screenshots →](PowerBI/screenshots/)

---

## 📋 Business Problem

Dubai's real estate market generates billions in transactions annually. Investors, developers, and analysts need to understand:
- **Where** the highest-value transactions happen
- **What** property types dominate the market
- **How** features (parking, location, size) impact pricing
- **When** the market peaks and slows

This project delivers data-driven answers to these questions.

## 🎯 Objectives

- Clean and prepare 1M+ raw transaction records
- Analyze pricing patterns across areas, property types, and time
- Build a 4-page executive dashboard with actionable insights
- Document an AI-assisted analysis workflow

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Python (Pandas)** | Data profiling, cleaning, feature engineering |
| **MySQL** | Data storage, 20+ business analysis queries |
| **Power BI** | Interactive 4-page executive dashboard |
| **DAX** | Calculated measures (formatted KPIs, time intelligence) |
| **AI Tools (ChatGPT, Claude)** | Query debugging, insight generation, DAX review |

## 🗄️ Dataset

**Source:** Dubai Land Department (via Kaggle)

| Metric | Value |
|--------|-------|
| Raw records | 1,047,965 |
| Raw columns | 46 |
| Cleaned records | 286,303 |
| Cleaned columns | 34 |
| Date range | 2020–2023 |

## 🔍 Methodology

### Phase 1: Data Profiling
- Loaded 1M+ rows into Python
- Identified 46 columns with mixed Arabic/English duplicates
- Documented missing values, data types, and anomalies

### Phase 2: Data Cleaning
- Dropped 12 duplicate Arabic columns
- Removed 2 near-empty columns (96%+ NULL)
- Converted date strings to datetime
- Filtered to 2020–2023 (kept 286K recent records)
- Created derived columns: `year`, `month`, `quarter`, `price_per_sqm`

### Phase 3: SQL Analysis (20 queries)
Covered: market overview, area analysis, property segmentation, time trends, window functions, median calculations.

### Phase 4: Power BI Dashboard
4 pages with KPIs, trend charts, treemaps, tables, and executive summary.

### Phase 5: AI-Assisted Workflow
Documented use of AI tools at each phase (see section below).

## 📊 Key Insights

- **AED 517.87 billion** in total sales across 217K transactions (2020–2023)
- **Units dominate**: 72% of transactions are apartments
- **Parking premium**: Properties with parking command **52% higher** price/sqm (AED 16.36K vs 10.72K)
- **Mid-tier is largest segment**: 53% of transactions fall in AED 500K–2M
- **Premium areas lead revenue**: Marsa Dubai, Palm Jumeirah, Burj Khalifa
- **Al Buteen** has the highest average price/sqm at AED 85K
- **1 BHK** is the most in-demand room type

## 💡 Recommendations

1. **Target mid-tier buyers** — 53% of transactions are AED 500K–2M
2. **Highlight parking** — +52% price premium
3. **Expand in high-yield areas** — Marsa Dubai, Palm Jumeirah
4. **Prioritize apartment inventory** — 72% of demand
5. **Build more 1 BHK supply** — highest transaction volume

## 🤖 AI-Assisted Workflow

This project used AI tools (ChatGPT, Claude) as productivity accelerators:

- **SQL Development** — Used AI to debug complex window functions and validate query logic
- **Insight Generation** — Used AI to brainstorm business implications from SQL findings
- **Data Validation** — Cross-checked AI suggestions against raw data (caught 8+ logic errors)
- **DAX Review** — AI reviewed Power BI measures for edge cases and formatting

**Key Principle: AI accelerates; I validate.** Every AI suggestion was tested against business logic and corrected where needed.

## 📁 Repository Structure
dubai-real-estate-analytics/
├── SQL/
│ └── analysis_queries.sql # 20 business analysis queries
├── PowerBI/
│ └── screenshots/ # Dashboard screenshots (4 pages)
├── 01_data_profiling.ipynb # Python data profiling
├── 02_data_cleaning.ipynb # Python data cleaning
└── README.md


## 👤 Author

**Yusuf Baig** — Data Analyst | SQL · Power BI · Excel · Python | Open to roles in Dubai, UAE

- LinkedIn: [linkedin.com/in/yusuf-baig-783906210](https://www.linkedin.com/in/yusuf-baig-783906210/)
- GitHub: [@Yusufbaig2001](https://github.com/Yusufbaig2001)
- Email: yusufbaig2001@gmail.com
