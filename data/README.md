# Data

The raw dataset is intentionally not included in this repository.

Official source:
https://open.data.gov.sa/ar/datasets/view/4e458e64-1f3d-4464-bd22-812a9006bc3e/resources

Download the relevant dataset from the Saudi Open Data Portal and review the current licensing/usage terms before redistributing it.

The analysis script expects the relevant sheet to be imported into R as an object named `airport`.

Example:

```r
library(readxl)

airport <- read_excel(
  "your_file.xlsx",
  sheet = "Services_V7"
)
```
