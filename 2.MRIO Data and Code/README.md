# MRIO Data and Code

## Data Source
- MRIO Tables: CEADs MRIO Tables (https://www.ceads.net.cn/)
- Employment Data: National Bureau of Statistics of China (https://www.stats.gov.cn/sj/ndsj/); China Labor Statistical Yearbook (https://data.cnki.net/yearBook?type=type&code=A)

## MRIO Table Aggregation
This study provides preprocessed MRIO data in .mat format. The original MRIO tables contain 31 provinces and 42 sectors. The aggregation process combines the 42 sectors into 3 broad categories, resulting in a 93 x 93 intermediate use matrix (31 provinces x 3 sectors).

Note: "Preprocessed" in the filename indicates the data has been aggregated from 42 sectors to 3 sectors.

## File Description

1. Code.m: Main analysis script for embodied employment and value-added calculation
2. 2012_MRIO_preprocessed.mat: Preprocessed MRIO data for year 2012
3. 2015_MRIO_preprocessed.mat: Preprocessed MRIO data for year 2015
4. 2017_MRIO_preprocessed.mat: Preprocessed MRIO data for year 2017
5. 1.Employment by Sector.xlsx: Employment data by sector and province