# NOBO.SDM
Data and R and NIMBLE code for a species distribution model (SDM) integrating structured North American Breeding Bird Survey (BBS) data and semi-structured eBird data to estimate northern bobwhite (Colinus virginianus)  abundance, and the environmental drivers of variation in abundance, across the eastern United States.
---
Authors: William B. Lewis, Sprih Harsh, Patrick Freeman, Victoria Nolan, Justin Suraci, Bridgett Costanza, and James A. Martin
<br />
Manuscript Title: Integrating multiple data sources with species distribution models to predict the distribution and abundance of northern bobwhites (Colinus virginianus) in the United States

---

# Metadata

<br />
<br />

# Code_NOBO_SDM_BBS_eBird.R

Code for running the integrated SDM in R and NIMBLE is contained in the 'Code_NOBO_SDM_BBS_eBird' R file. Bobwhite abundance is jointly estimated from BBS and eBird data in each of 25066 5x5km grid cell across the eastern United States in each of three years (2018, 2019, 2021). Abundance is modeled as a function of year effects and 16 environmental covariates (10 of which are also included as quadratic effects). To aid in prediction, grid-level abundance is constrained to be less than or equal to 8250 (corresponding to a maximum density of 6.6 birds/ha). Intercept, covariate, and year effects are allowed to vary by USDA Land Resource Region (LRR), with LRR-level effects arising from Normal distributions around global means. Intercepts are further allowed to vary based on USDA Major Land Resource Areas (MLRA) to account finer-scale variation in abundance. MLRAs are nested within LRRs, so MLRA-specific intercepts are modeled as arising from Normal distributions around LRR-specific intercepts.
BBS surveys were completed in 3178 grid cells, with up to 18 surveys from each grid cell and year incorporated into analysis. The detection radius for BBS surveys is 400m, meaning that expected abundance on BBS surveys is 2% of the abundance within the 5x5km grid cell. Detections on BBS surveys are modeled based on this survey-level abundance and BBS detection probability, which is modeled based on background noise and the number of passing cars.
eBird surveys were completed in 22,885 grid cells, with up to 50 checklists from each grid cell and year incorporated into analysis. Due its semi-structured nature, the exact survey radius of eBird is generally not known. Detections on eBird checklists are therefore modeled based on the grid-level abundance and eBird detection probability, which is modeled based on checklist type (stationary or travelling), duration, and travel distance (travelling checklists only).
Roughly 10% of grids with surveys from each dataset (BBS and eBird) were randomly removed from model fitting to assess out-of-sample prediction performance. 

# NOBO.SDM.BBS.eBird.Data.gzip

The data for running the northern bobwhite SDM are stored in 'NOBO.SDM.BBS.eBird.Data' gzip file. NOBO.SDM.BBS.eBird.Data contains two objects which correspond to the data (mod.data) and constants (mod.const) used in the NIMBLE model.
## mod.data
### y_bbs
A three-dimensional array giving the number of bobwhites detected on BBS surveys. The x-dimension corresponds to 5-km grid cells within 

