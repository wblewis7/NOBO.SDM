# NOBO.SDM
Data and R and NIMBLE code for a species distribution model (SDM) integrating structured North American Breeding Bird Survey (BBS) data and semi-structured eBird data to estimate northern bobwhite (Colinus virginianus)  abundance, and the environmental drivers of variation in abundance, across the eastern United States.
---
Authors: William B. Lewis, Sprih Harsh, Patrick Freeman, Victoria Nolan, Justin Suraci, Bridgett Costanza, and James A. Martin
<br />
Manuscript Title: Integrating multiple data sources with species distribution models to predict the distribution and abundance of northern bobwhites (Colinus virginianus) in the United States

---

# Metadata

<br />

# Code_NOBO_SDM_BBS_eBird.R

Code for running the integrated SDM in R and NIMBLE is contained in the 'Code_NOBO_SDM_BBS_eBird' R file. Bobwhite abundance is jointly estimated from BBS and eBird data in each of 25066 5x5km grid cell across the eastern United States in each of three years (2018, 2019, 2021). Abundance is modeled as a function of year effects and 16 environmental covariates (10 of which are also included as quadratic effects). To aid in prediction, grid-level abundance is constrained to be less than or equal to 8250 (corresponding to a maximum density of 6.6 birds/ha). Intercept, covariate, and year effects are allowed to vary by USDA Land Resource Region (LRR), with LRR-level effects arising from Normal distributions around global means. Intercepts are further allowed to vary based on USDA Major Land Resource Areas (MLRA) to account finer-scale variation in abundance. MLRAs are nested within LRRs, so MLRA-specific intercepts are modeled as arising from Normal distributions around LRR-specific intercepts.
BBS surveys were completed in 3178 grid cells, with up to 18 surveys from each grid cell and year incorporated into analysis. The detection radius for BBS surveys is 400m, meaning that expected abundance on BBS surveys is 2% of the abundance within the 5x5km grid cell. Detections on BBS surveys are modeled based on this survey-level abundance and BBS detection probability, which is modeled based on background noise and the number of passing cars.
eBird surveys were completed in 22,885 grid cells, with up to 50 checklists from each grid cell and year incorporated into analysis. Due its semi-structured nature, the exact survey radius of eBird is generally not known. Detections on eBird checklists are therefore modeled based on the grid-level abundance and eBird detection probability, which is modeled based on checklist type (stationary or travelling), duration, and travel distance (travelling checklists only).
Roughly 10% of grids with surveys from each dataset (BBS and eBird) were randomly removed from model fitting to assess out-of-sample prediction performance.

<br />

# NOBO.SDM.BBS.eBird.Data.gzip

The data for running the northern bobwhite SDM are stored in 'NOBO.SDM.BBS.eBird.Data' gzip file. NOBO.SDM.BBS.eBird.Data contains two objects which correspond to the data (mod.data) and constants (mod.const) used in the NIMBLE model.

<br />

## mod.data
### y_bbs
A three-dimensional array giving the number of bobwhites detected on BBS surveys. The x-dimension corresponds to grid cells with BBS surveys (3178), the y-dimension corresponds to BBS surveys within each grid and year (up to 18), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 18 BBS surveys were performed in some grids/years (denoted with NA).
### y_ebd
A three-dimensional array giving the number of bobwhites detected on eBird checklists. The x-dimension corresponds to grid cells with eBird checklists (22,885), the y-dimension corresponds to eBird checklists within each grid and year (up to 50), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 50 eBird checklists were recorded in some grids/years (denoted with NA).

<br />

## mod.const
### nCovs
Number of environmental covariates for estimating grid-level abundance.
### n_lrr
Number of LRRs across the eastern US in which bobwhite abundance is estimated.
### n_mlra
Number of MLRAs across the eastern US in which bobwhite abundance is estimated. MLRAs are nested within LRR.
### lrr
Vector giving the LRR for each MLRA used in analysis. 1 = D (Western Range and Irrigated Region), 2 = E (Rocky Mountain Range and Forest Region), 3 = F (Northern Great Plains Spring Wheat Region), 4 = G (Western Great Plains Range and Irrigated Region), 5 = H (Central Great Plains Winter Wheat and Range Region), 6 = I (Southwest Plateaus and Plains Range and Cotton Region), 7 = J (Southwestern Prairies Cotton and Forage Region), 8 = K (Northern Lake States Forest and Forage Region), 9 = L (Lake States Fruit, Truck Crop, and Dairy Region), 10 = M (Central Feed Grains and Livestock Region), 11 = N (East and Central Farming and Forest Region), 12 = O (Mississippi Delta Cotton and Feed Grains Region), 13 = P (South Atlantic and Gulf Slope Cash Crops, Forest, and Livestock Region), 14 = R (Northeastern Forage and Forest Region), 15 = S (Northern Atlantic Slope Diversified Farming Region), 16 = T (Atlantic and Gulf Coast Lowland Forest and Crop Region), and 17 = U (Florida Subtropical Fruit, Truck Crop, and Range Region).
### nYear
Number of years of study (2018, 2019, 2021).
### nTot
Total number of grid cells in the eastern US with BBS and/or eBird surveys at which to estimate bobwhite abundance.
### mlra
Vector giving the MLRA for each grid cell in the eastern US.
### shrub
Vector giving the standardized values of proportional cover of shrubs in each grid cell. Values generated from the Rangeland Analysis Platform land cover datasets.
### bgr
Vector giving the standardized values of proportional cover of bare ground in each grid cell. Values generated from the Rangeland Analysis Platform land cover datasets.
### rowcrop
Vector giving the standardized values of percentage cover of row crops in each grid cell. Values generated from the National Land Cover Dataset.
### energy
Vector giving the standardized values of energy development intensity in each grid cell. Values generated from data in Suraci et al. 2023.
### transport
Vector giving the standardized values of transportation intensity in each grid cell. Values generated from data in Suraci et al. 2023.
### urban
Vector giving the standardized values of urbanization intensity in each grid cell. Values generated from data in Suraci et al. 2023.
### tmax
Vector giving the standardized values of mean daily maximum temperature in each grid cell. Values generated from NASA's Daymet v4 dataset.
### prcp
Vector giving the standardized values of mean daily precipitation in each grid cell. Values generated from NASA's Daymet v4 dataset.
### snowdays
Vector giving the standardized values of mean number of days with snow depth greater than 2.5cm in each grid cell. Values generated from NASA's Daymet v4 dataset.
### pasture
Vector giving the standardized values of percentage cover of pasture in each grid cell. Values generated from the National Land Cover Dataset.
### evergreen
Vector giving the standardized values of percentage cover of evergreen forest in each grid cell. Values generated from the National Land Cover Dataset.
### deciduous
Vector giving the standardized values of percentage cover of deciduous forest in each grid cell. Values generated from the National Land Cover Dataset.
### mixed
Vector giving the standardized values of percentage cover of mixed forest in each grid cell. Values generated from the National Land Cover Dataset.
### water
Vector giving the standardized values of percentage cover of water/wetland in each grid cell. Values generated from the National Land Cover Dataset.
### grass
Vector giving the standardized values of percentage cover of grassland in each grid cell. Values generated from the National Land Cover Dataset.
