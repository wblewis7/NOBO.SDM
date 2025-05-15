# NOBO.SDM
Data and R and NIMBLE code for a spatially-non-stationary species distribution model (SDM) integrating structured North American Breeding Bird Survey (BBS) data and semi-structured eBird data to estimate northern bobwhite (Colinus virginianus) abundance, and the environmental drivers of variation in abundance, across the United States.
---
Authors: William B. Lewis, Sprih Harsh, Patrick Freeman, Victoria Nolan, Justin Suraci, Bridgett E. Costanzo, and James A. Martin
<br />
Manuscript Title: Integrating multiple data sources with species distribution models to estimate the distribution and abundance of northern bobwhite (Colinus virginianus) in the United States

---

# Metadata

<br />

# Code_NOBO_SDM_BBS_eBird.R

Code for running the spatially-non-stationary integrated SDM in R and NIMBLE is contained in the 'Code_NOBO_SDM_BBS_eBird' R file. We use a generalized linear model (GLM) framework and incorporated data integration through a joint-likelihood method. Bobwhite abundance is jointly estimated from BBS and eBird data within 5-km x 5-km grid cells across the eastern United States in each of three years (2018, 2019, 2021). Abundance is modeled as a function of year effects and 16 environmental covariates (10 of which are also included as quadratic effects). To aid in prediction, grid-level abundance is constrained to be less than or equal to 8250 (corresponding to a maximum density of 6.6 birds/ha). We incorporate non-stationary responses through regional partitioning of coefficients. Specifically, we modeld intercept, covariate, and year effects as varying by USDA Land Resource Region (LRR), with LRR-level effects arising from Normal distributions around global means. Intercepts are further allowed to vary based on USDA Major Land Resource Areas (MLRA) to account for finer-scale variation in abundance. MLRAs are nested within LRRs, so MLRA-specific intercepts are modeled as arising from Normal distributions around LRR-specific intercepts.
To reduce the effects of spatial autocorrelation, up to 18 (BBS) or 50 (eBird) surveys were included in each grid cell in each year.
The detection radius for BBS surveys is 400m, meaning that expected abundance on BBS surveys is 2% of the abundance within the 5x5km grid cell. Detections on BBS surveys are modeled based on this survey-level abundance and BBS detection probability, which is modeled based on background noise and the number of passing cars.
Due its semi-structured nature, the exact survey radius of eBird is generally not known. Detections on eBird checklists are therefore modeled based on the grid-level abundance and eBird detection probability, which is modeled based on checklist type (stationary or travelling), duration, and travel distance (travelling checklists only).
Roughly 10% of grids with surveys from each dataset (BBS and eBird) are randomly removed from model fitting to assess out-of-sample prediction performance.

<br />

# NOBO.SDM.BBS.eBird.Data.gzip

The data for running the northern bobwhite SDM are stored in 'NOBO.SDM.BBS.eBird.Data' gzip file. NOBO.SDM.BBS.eBird.Data contains two objects which correspond to the data (mod.data) and constants (mod.const) used in the NIMBLE model.

<br />

## mod.data
### y_bbs
A three-dimensional array giving the number of bobwhite detected on BBS surveys. The x-dimension corresponds to grid cells with BBS surveys, the y-dimension corresponds to BBS surveys within each grid and year (up to 18), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 18 BBS surveys were performed in some grids/years (denoted with NA). Note that this array contains both grid cells used for training the model and for out-of-sample validation, though only the training data are used for model fitting.
### y_ebd
A three-dimensional array giving the number of bobwhite detected on eBird checklists. The x-dimension corresponds to grid cells with eBird checklists, the y-dimension corresponds to eBird checklists within each grid and year (up to 50), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 50 eBird checklists were recorded in some grids/years (denoted with NA). Note that this array contains both grid cells used for training the model and for out-of-sample validation, though only the training data are used for model fitting.

<br />

## mod.const
### nCovs
Number of environmental covariate parameters for estimating grid-level abundance (including linear and quadratic effects for some variables).
### n_lrr
Number of LRRs across the eastern U.S. in which bobwhite abundance is estimated.
### n_mlra
Number of MLRAs across the eastern U.S. in which bobwhite abundance is estimated. MLRAs are nested within LRR.
### lrr
Vector giving the LRR for each MLRA used in analysis. 1 = D (Western Range and Irrigated Region), 2 = E (Rocky Mountain Range and Forest Region), 3 = F (Northern Great Plains Spring Wheat Region), 4 = G (Western Great Plains Range and Irrigated Region), 5 = H (Central Great Plains Winter Wheat and Range Region), 6 = I (Southwest Plateaus and Plains Range and Cotton Region), 7 = J (Southwestern Prairies Cotton and Forage Region), 8 = K (Northern Lake States Forest and Forage Region), 9 = L (Lake States Fruit, Truck Crop, and Dairy Region), 10 = M (Central Feed Grains and Livestock Region), 11 = N (East and Central Farming and Forest Region), 12 = O (Mississippi Delta Cotton and Feed Grains Region), 13 = P (South Atlantic and Gulf Slope Cash Crops, Forest, and Livestock Region), 14 = R (Northeastern Forage and Forest Region), 15 = S (Northern Atlantic Slope Diversified Farming Region), 16 = T (Atlantic and Gulf Coast Lowland Forest and Crop Region), and 17 = U (Florida Subtropical Fruit, Truck Crop, and Range Region).
### nYear
Number of years of study (2018, 2019, 2021).
### nTot
Total number of grid cells in the eastern U.S. with BBS and/or eBird surveys at which to estimate bobwhite abundance.
### mlra
Vector giving the MLRA for each grid cell in nTot.
### shrub
Vector giving the standardized values of proportional cover of shrubs in each grid cell in nTot. Values generated from the Rangeland Analysis Platform land cover datasets.
### bgr
Vector giving the standardized values of proportional cover of bare ground in each grid cell in nTot. Values generated from the Rangeland Analysis Platform land cover datasets.
### rowcrop
Vector giving the standardized values of percentage cover of row crops in each grid cell in nTot. Values generated from the National Land Cover Dataset.
### energy
Vector giving the standardized values of energy development intensity in each grid cell in nTot. Values generated from data in Suraci et al. 2023.
### transport
Vector giving the standardized values of transportation intensity in each grid cell in nTot. Values generated from data in Suraci et al. 2023.
### urban
Vector giving the standardized values of urbanization intensity in each grid cell in nTot. Values generated from data in Suraci et al. 2023.
### fire
Vector giving the standardized values of fire frequency in each grid cell in nTot. Values generated from the Monitoring Trends in Burn Severity Burned Areas Boundaries Dataset.
### tmax
Vector giving the standardized values of mean daily maximum temperature in each grid cell in nTot. Values generated from NASA's Daymet v4 dataset.
### prcp
Vector giving the standardized values of mean daily precipitation in each grid cell in nTot. Values generated from NASA's Daymet v4 dataset.
### snowdays
Vector giving the standardized values of mean number of days with snow depth greater than 2.5cm in each grid cell in nTot. Values generated from NASA's Daymet v4 dataset.
### pasture
Vector giving the standardized values of percentage cover of pasture in each grid cell in nTot. Values generated from the National Land Cover Dataset.
### evergreen
Vector giving the standardized values of percentage cover of evergreen forest in each grid cell in nTot. Values generated from the National Land Cover Dataset.
### deciduous
Vector giving the standardized values of percentage cover of deciduous forest in each grid cell in nTot. Values generated from the National Land Cover Dataset.
### mixed
Vector giving the standardized values of percentage cover of mixed forest in each grid cell in nTot. Values generated from the National Land Cover Dataset.
### water
Vector giving the standardized values of percentage cover of water/wetland in each grid cell in nTot. Values generated from the National Land Cover Dataset.
### grass
Vector giving the standardized values of percentage cover of grassland in each grid cell in nTot. Values generated from the National Land Cover Dataset.
### nCells_bbs
Number of grids with BBS surveys in at least one year.
### nStops_bbs
Matrix giving the number of BBS surveys in each grid cell in y_bbs (x-dimension) and each year (y-dimension). Values from grid cells used for assessing BBS out-of-sample predictive power (grid_bbs_id_pred) are all set to 0, so will be skipped in model fitting.
### bbs_prop_area
Proportion of 5x5km grid cell surveyed by each BBS survey (400m radius circle)
### grid_bbs_id
Vector giving the grid cell ID for each grid cell with BBS surveys, i.e., which grid cell in 1:nTot correspond to each grid cell in y_bbs.
### noise_bbs
A three-dimensional array giving the recorded noise level on BBS surveys. Values of noise were recorded as either 0 (no background noise) or 1 (background noise). The x-dimension corresponds to grid cells with BBS surveys, the y-dimension corresponds to BBS surveys within each grid and year (up to 18), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 18 BBS surveys were performed in some grids/years (denoted with NA).
### car_bbs
A three-dimensional array giving the recorded number of passing cars on BBS surveys (standardized). The x-dimension corresponds to grid cells with BBS surveys, the y-dimension corresponds to BBS surveys within each grid and year (up to 18), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 18 BBS surveys were performed in some grids/years (denoted with NA).
### nCells_ebd
Number of grids with eBird checklists in at least one year.
### nChecklists_ebd
Matrix giving the number of eBird checklists in each grid cell in y_ebd (x-dimension) and each year (y-dimension). Values from grid cells used for assessing eBird out-of-sample predictive power (grid_ebd_id_pred) are all set to 0, so will be skipped in model fitting.
### dur_ebd
A three-dimensional array giving the recorded survey duration on eBird checklists (standardized). The x-dimension corresponds to grid cells with eBird checklists, the y-dimension corresponds to eBird checklists within each grid and year (up to 50), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 50 eBird checklists were performed in some grids/years (denoted with NA).
### type_ebd
A three-dimensional array giving the recorded survey type of eBird checklists (0 = stationary, 1 = travelling). The x-dimension corresponds to grid cells with eBird checklists, the y-dimension corresponds to eBird checklists within each grid and year (up to 50), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 50 eBird checklists were performed in some grids/years (denoted with NA).
### eff_ebd
A three-dimensional array giving the recorded survey effort (distance travelled) of eBird checklists. This parameter is only informative for travelling checklists. Values for travelling checklists (type_ebd = 1) are standardized while values of stationary checklists (type_ebd = 0) are set to -6.898632645. eff_ebd is multiplied by type_ebd when calculating the eBird detection probability, so will only affect the likelihood for travelling checklists. The x-dimension corresponds to grid cells with eBird checklists, the y-dimension corresponds to eBird checklists within each grid and year (up to 50), and the z-dimension corresponds to year (1=2018, 2=2019, 3=2021). Less than 50 eBird checklists were performed in some grids/years (denoted with NA).
### grid_ebd_id
Vector giving the grid cell ID for each grid cell with eBird checklists, i.e., which grid cell in 1:nTot correspond to each grid cell in y_ebd.
### lrr_grid
Vector giving the LRR of each grid cell in nTot.
### Npred_bbs
Number of grids with BBS surveys in at least one year used for assessing BBS out-of-sample predictive performance.
### grid_bbs_id_pred
Vector representing which grid cell in 1:nCells_bbs corresponds to each grid cell in 1:Npred_bbs, i.e., which grids in y_bbs are used for assessing BBS out-of-sample predictive power.
### nStops_bbs_pred
Matrix giving the number of BBS surveys in each grid cell used for assessing BBS out-of-sample predictive power (x-dimension) and each year (y-dimension). These values represent the true number of checklists/grid/year for grids used for BBS out-of-sample prediction power, while these values are set to 0 in nStops_bbs.
### bbs_grid_ID_pred
Vector giving the grid cell ID for each grid cell with BBS surveys to be used for assessing BBS out-of-sample predictive performance, i.e., which grid in 1:nTot corresponds to grids in 1:Npred_bbs.
### Npred_ebd
Number of grids with eBird checklists in at least one year used for assessing eBird out-of-sample predictive performance.
### grid_ebd_id_pred
Vector representing which grid cell in 1:nChecklists_ebd corresponds to each grid cell in 1:Npred_ebd, i.e., which grids in y_ebd are used for assessing eBird out-of-sample predictive power.
### nChecklists_ebd_pred
Matrix giving the number of eBird checklists in each grid cell used for assessing eBird out-of-sample predictive power (x-dimension) and each year (y-dimension). These values represent the true number of checklists/grid/year for grids used for eBird out-of-sample prediction power, while these values are set to 0 in nChecklists_ebd.
### ebd_grid_ID_pred
Vector giving the grid cell ID for each grid cell with eBird checklists to be used for assessing eBird out-of-sample predictive performance, i.e., which grid in 1:nTot corresponds to grids in 1:Npred_ebd.
### Nmax
Maximum possible abundance at grid cells. This value is set to 8250, which is based on the maximum density (6.6 birds/ha) from Brennan et al. (2020 Northern Bobwhite (Colinus virginianus) Birds of the World) and a 50/50 sex ratio.
