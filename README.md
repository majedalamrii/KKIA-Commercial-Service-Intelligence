# KKIA Commercial Service Intelligence

Independent statistical analysis of commercial-service distribution at **King Khalid International Airport (KKIA)** using public Saudi open data.

**Author:** Majed ALAMRI  
**Field:** Statistics  
**Tools:** R / RStudio  
**Data source:** Saudi Open Data Portal

## Project idea

The project asks a simple question:

> Are commercial services distributed in the same way across airport terminals and passenger areas?

Instead of using raw counts only, the analysis compares service composition, concentration, restaurant share, and diversity across terminals. It also tests whether the observed differences are statistically meaningful.

## Why this matters

A terminal can have many services while still being heavily concentrated in one category. Another terminal may have fewer total services but a more diverse mix.

This project provides a statistical baseline that could later be extended with passenger traffic, footfall, terminal capacity, and peak-hour data to support commercial-service planning.

## Dataset

The analysis uses a public dataset from the Saudi Open Data Portal related to commercial services at King Khalid International Airport.

Source:
https://open.data.gov.sa/ar/datasets/view/4e458e64-1f3d-4464-bd22-812a9006bc3e/resources

The original dataset contained **427 records** and the following variables:

- `TRADE_CATEGORY`
- `TRADE_SUBCATEGORY`
- `BRAND_NAME`
- `LOCATION`
- `TERMINAL`

After cleaning, the analytical dataset contained **426 records** with no missing values.

> The raw dataset is not included in this repository. Please obtain it from the official Saudi Open Data Portal and review its current licensing/usage terms before redistribution.

## Main findings

### Arrival vs Departure
The commercial-service mix differs significantly between Arrival and Departure areas.

- Transportation was strongly overrepresented in **Arrival**.
- Food & Beverage was more represented in **Departure**.
- Fisher's Exact Test with Monte Carlo simulation produced a simulated p-value of approximately **0.00001**.

### Terminal differences
The service mix also differs significantly across Terminals 1–5.

- Fisher's Exact Test with Monte Carlo simulation: **p = 0.00626**.
- Terminal 4 showed higher-than-expected **Food & Beverage** representation.
- Terminal 5 showed higher-than-expected **Retail** representation.

### Terminal 5
Terminal 5 had the largest number of recorded services:

- **122** total recorded services
- **84** Retail services
- Retail represented approximately **68.9%** of its service mix

### Restaurants
Terminal 4 and Terminal 5 both had **9 recorded restaurants**, but their relative shares differed:

- Terminal 4: **17.6%**
- Terminal 5: **7.4%**

This demonstrates why proportions can be more informative than raw counts alone.

### Service diversity
Using the Shannon Diversity Index:

| Terminal | Total Services | Categories | Shannon Index |
|---|---:|---:|---:|
| Terminal 1 | 93 | 6 | 1.180 |
| Terminal 2 | 79 | 5 | 1.010 |
| Terminal 3 | 48 | 4 | 0.984 |
| Terminal 4 | 51 | 4 | 0.958 |
| Terminal 5 | 122 | 5 | 0.862 |

Terminal 1 had the highest recorded service diversity, while Terminal 5 had the lowest despite having the largest total service count.

## Statistical methods

The project uses:

- Exploratory Data Analysis
- Counts and percentages
- Contingency tables
- Pearson Chi-Square diagnostics
- Fisher's Exact Test with Monte Carlo simulation
- Standardized residual analysis
- Service concentration percentages
- Shannon Diversity Index

Sparse contingency-table cells were checked before interpreting Pearson Chi-Square results. When expected frequencies were too small, Fisher's Exact Test with simulation was used as the main inferential test.

## Repository structure

```text
KKIA-Commercial-Service-Intelligence/
├── README.md
├── LICENSE
├── .gitignore
├── data/
│   └── README.md
├── scripts/
│   └── airport_service_analysis.R
├── figures/
│   ├── terminal_services.png
│   ├── restaurant_share.png
│   └── service_diversity.png
└── report/
    ├── KKIA_Commercial_Service_Intelligence_Executive_Brief.pdf
    └── KKIA_Commercial_Service_Intelligence_Full_Statistical_Report.docx
```

## How to run

1. Download the dataset from the Saudi Open Data Portal.
2. Import the relevant sheet into R as an object named `airport`.
3. Install/load:
   - `dplyr`
   - `ggplot2`
4. Run `scripts/airport_service_analysis.R`.

Example:

```r
library(readxl)

airport <- read_excel(
  "your_file.xlsx",
  sheet = "Services_V7"
)

source("scripts/airport_service_analysis.R")
```

## Important limitation

This project analyzes **recorded service distribution**, not service adequacy or congestion.

The dataset does not include:

- passenger count by terminal
- footfall
- peak-hour demand
- terminal area
- queue or waiting-time data
- revenue or transaction data

Because of this, the project does **not** claim that a terminal has too many or too few services.

## Future development

With operational data, the framework could be extended to calculate:

- Services per 100,000 passengers
- Restaurants per 100,000 passengers
- Commercial services per unit of terminal area
- Peak-hour service pressure
- Passenger-demand-adjusted service availability
- A management dashboard for terminal comparison

## Reports

The `report/` folder contains:

- an executive brief designed for non-technical stakeholders
- the full statistical report with methodology, results, limitations, and R workflow

## Disclaimer

This is an **independent student statistical analysis** based on publicly available open data. It is not an official report issued by King Khalid International Airport, Riyadh Airports Company, or any Saudi government entity.

## Contact

**Majed ALAMRI**  
Email: majedalamr2@gmail.com  
