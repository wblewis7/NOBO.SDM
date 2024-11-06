require(parallel)

load("NOBO.SDM.BBS.eBird.Data.gzip")

mod.data <- NOBO.SDM.BBS.eBird.Data$mod.data

mod.const <- NOBO.SDM.BBS.eBird.Data$mod.const

pars <- c("mean_intercept", "sd_intercept", "mean_intercept_lrr", "sd_intercept_lrr",
          "intercept", "mean_cov", "sd_cov", "cov", "mean_cov_year", "sd_cov_year",
          "cov_year", "det_bbs_0", "det_bbs_noise", "det_bbs_car", "det_ebd_0",
          "det_ebd_dur", "det_ebd_type", "det_ebd_type_eff", "cov_year_avg",
          "p_bbs", "p_ebd", "N_overall", "N_bbs", "N_bbs_pred",
          "val_ebd_residsq", "val_bbs_residsq")



# Running SDM in parallel
NOBO_SDM_MCMC_code <- function(seed, mod.data, mod.const, monitors){
  
  require(nimble)
  
  model_NOBO_SDM <- nimbleCode({
    
    # Priors
    
    ## Intercept term for abundance
    mean_intercept ~ dnorm(0, 0.001)
    sd_intercept ~ dunif(0, 10)
    prec_intercept <- 1/(sd_intercept^2)
    for(l in 1:n_lrr){
      mean_intercept_lrr[l] ~ dnorm(mean_intercept, prec_intercept) # Average intercept for lrr comes from global distribution
      sd_intercept_lrr[l] ~ dunif(0, 10) # Each lrr gets its own sd for the intercept term
      prec_intercept_lrr[l] <- 1/(sd_intercept_lrr[l]^2)
    }
    for(m in 1:n_mlra){
      intercept[m] ~ dnorm(mean_intercept_lrr[lrr[m]], prec_intercept_lrr[lrr[m]]) #MLRA intercepts come from distribution around lrr mean
    }
    
    ## Parameter effects on abundance
    for(i in 1:nCovs){
      mean_cov[i] ~ dnorm(0, 0.001)
      sd_cov[i] ~ dunif(0, 10)
      prec_cov[i] <- 1/(sd_cov[i]^2)
      for(l in 1:n_lrr){
        cov[l, i] ~ dnorm(mean_cov[i], prec_cov[i]) # Values for each lrr come from global distribution
      }
    }
    
    ## Year effects on abundance
    # Setting 1st year to baseline and others as offsets
    mean_cov_year[1] <- 0
    for(l in 1:n_lrr){
      cov_year[l, 1] <- 0
    }
    sd_cov_year ~ dunif(0, 10)
    prec_cov_year <- 1/(sd_cov_year^2)
    for(y in 2:nYear){
      mean_cov_year[y] ~ dnorm(0, 0.001)
      for(l in 1:n_lrr){
        cov_year[l, y] ~ dnorm(mean_cov_year[y], prec_cov_year) # Average values for each mlra come from distribution based on lrr
      }
    }
    
    ## Detection covariates
    det_bbs_0 ~ dnorm(0, 0.01)
    det_bbs_noise ~ dnorm(0, 0.01)
    det_bbs_car ~ dnorm(0, 0.01) 
    det_ebd_0 ~ dnorm(0, 0.01)
    det_ebd_dur ~ dnorm(0, 0.01)
    det_ebd_type ~ dnorm(0, 0.01)
    det_ebd_type_eff ~ dnorm(0, 0.01)	
    
    
    
    # Process model
    
    for(t in 1:nYear){
      
      ## State model for abundance
      for(i in 1:nTot){
        log(lambda_overall[i, t]) <- intercept[mlra[i]] +
          cov[lrr_grid[i], 1] * shrub[i] +
          cov[lrr_grid[i], 2] * bgr[i] +
          cov[lrr_grid[i], 3] * rowcrop[i] +
          cov[lrr_grid[i], 4] * energy[i] +
          cov[lrr_grid[i], 5] * transport[i] +
          cov[lrr_grid[i], 6] * urban[i] +
          cov[lrr_grid[i], 7] * fire[i] +
          cov[lrr_grid[i], 8] * tmax[i] +
          cov[lrr_grid[i], 9] * prcp[i] +
          cov[lrr_grid[i], 10] * snowdays[i] +
          cov[lrr_grid[i], 11] * pasture[i] +
          cov[lrr_grid[i], 12] * evergreen[i] +
          cov[lrr_grid[i], 13] * deciduous[i] +
          cov[lrr_grid[i], 14] * mixed[i] +
          cov[lrr_grid[i], 15] * water[i] +
          cov[lrr_grid[i], 16] * grass[i] +
          cov[lrr_grid[i], 17] * shrub[i] * shrub[i] +
          cov[lrr_grid[i], 18] * bgr[i] * bgr[i] +
          cov[lrr_grid[i], 19] * rowcrop[i] * rowcrop[i] +
          cov[lrr_grid[i], 20] * fire[i] * fire[i] +
          cov[lrr_grid[i], 21] * pasture[i] * pasture[i] +
          cov[lrr_grid[i], 22] * evergreen[i] * evergreen[i] +
          cov[lrr_grid[i], 23] * deciduous[i] * deciduous[i] +
          cov[lrr_grid[i], 24] * mixed[i] * mixed[i] +
          cov[lrr_grid[i], 25] * water[i] * water[i] +
          cov[lrr_grid[i], 26] * grass[i] * grass[i] +
          cov_year[lrr_grid[i], t]
        N_overall_1[i, t] ~ dpois(lambda_overall[i, t])
        N_overall[i, t] <- min(N_overall_1[i,t], Nmax)
      }
      
      ## Observation process for BBS
      for(b in 1:nCells_bbs){
        N_bbs[b, t] ~ dbinom(bbs_prop_area, N_overall[grid_bbs_id[b], t])
        for(s in 1:nStops_bbs[b, t]){
          logit(p_bbs[b, s, t]) <- det_bbs_0 + 
            det_bbs_noise * noise_bbs[b, s, t] +
            det_bbs_car * car_bbs[b, s, t]
          y_bbs[b, s, t] ~ dbinom(p_bbs[b, s, t], N_bbs[b, t])
        }
      }
      
      # Observation process for eBird
      for(e in 1:nCells_ebd){
        for(j in 1:nChecklists_ebd[e, t]){
          logit(p_ebd[e, j, t]) <- det_ebd_0 +
            det_ebd_dur * dur_ebd[e, j, t] +
            det_ebd_type * type_ebd[e, j, t] +
            det_ebd_type_eff * type_ebd[e, j, t] * eff_ebd[e, j, t]
          y_ebd[e, j, t] ~ dbinom(p_ebd[e, j, t], N_overall[grid_ebd_id[e], t])
        }
      }
    }
    
    
    # Derived parameter for average year effect
    for(m in 1:n_lrr){
      cov_year_avg[m] <- mean(cov_year[m,1:nYear])
    }
    
    
    # Out of sample validation
    for(m in 1:nYear){
      
      # BBS
      for(u in 1:Npred_bbs){
        N_bbs_pred[u, m] ~ dbinom(bbs_prop_area, N_overall[bbs_grid_ID_pred[u], m])
        for(a in 1:nStops_bbs_pred[u, m]){
          logit(p_bbs_pred[u, a, m]) <- det_bbs_0 + 
            det_bbs_noise * noise_bbs[grid_bbs_id_pred[u], a, m] +
            det_bbs_car * car_bbs[grid_bbs_id_pred[u], a, m]
          y_bbs_val[u, a, m] ~ dbinom(p_bbs_pred[u, a, m], N_bbs_pred[u, m])
          val_bbs_residsq[u, a, m] <- (y_bbs[grid_bbs_id_pred[u], a, m] - y_bbs_val[u, a, m])^2
        }
      }
      
      # eBird
      for(e in 1:Npred_ebd){
        for(z in 1:nChecklists_ebd_pred[e, m]){
          logit(p_ebd_pred[e, z, m]) <- det_ebd_0 +
            det_ebd_dur * dur_ebd[grid_ebd_id_pred[e], z, m] +
            det_ebd_type * type_ebd[grid_ebd_id_pred[e], z, m] +
            det_ebd_type_eff * type_ebd[grid_ebd_id_pred[e], z, m] * eff_ebd[grid_ebd_id_pred[e], z, m]
          y_ebd_val[e, z, m] ~ dbinom(p_ebd_pred[e, z, m], N_overall[ebd_grid_ID_pred[e], m])
          val_ebd_residsq[e, z, m] <- (y_ebd[grid_ebd_id_pred[e], z, m] - y_ebd_val[e, z, m])^2
        }
      }
    }
    
  })
  
  
  # Setting initial values
  N_bbs_init <- apply(mod.data$y_bbs, c(1,3), FUN=max, na.rm=T)
  N_bbs_init[N_bbs_init=="-Inf"] <- 0
  N_bbs_init <- N_bbs_init + 1
  N_overall.init <- matrix(NA, nrow=mod.const$nTot, ncol=mod.const$nYear)
  for(i in 1:nrow(N_overall.init)){
    for(t in 1:ncol(N_overall.init)){
      present_bbs <- sum(!is.na(mod.data$y_bbs[which(mod.const$grid_bbs_id == i),,t]))
      present_ebd <- sum(!is.na(mod.data$y_ebd[which(mod.const$grid_ebd_id == i),,t]))
      if(present_bbs == 0 & present_ebd > 0){
        N_overall.init[i,t] <- sum(mod.data$y_ebd[which(mod.const$grid_ebd_id == i),,t], na.rm=T) + 1 # Ensures higher than observations
      }
      if(present_bbs > 0){
        bbs_maxcount <- max(mod.data$y_bbs[which(mod.const$grid_bbs_id == i),,t], na.rm=T)
        bbs_maxcount2 <- ifelse(bbs_maxcount > 0, 50, 1)
        if(present_ebd > 0){
          bbs_maxcount2 <- max(bbs_maxcount2, sum(mod.data$y_ebd[which(mod.const$grid_ebd_id == i),,t], na.rm=T) + 1)
        }
        N_overall.init[i,t] <- bbs_maxcount2
      }
    }
  }
  cov_init <- matrix(rep(0, times=mod.const$nCovs * mod.const$n_lrr), nrow=mod.const$n_lrr)
  intercept_init <- rep(NA, mod.const$n_mlra)
  for(i in 1:length(intercept_init)){
    meanval <- log(mean(rowMeans(matrix(N_overall.init[which(mod.const$mlra == i),], ncol=mod.const$nYear), na.rm=T)))
    intercept_init[i] <- runif(1, meanval-0.2, meanval+0.2)
  }
  mean_intercept_lrr_init <- rep(NA, mod.const$n_lrr)
  for(l in 1:mod.const$n_lrr){
    mean_intercept_lrr_init[l] <- mean(intercept_init[which(mod.const$lrr == l)])
  }
  mean_cov_init <- colMeans(cov_init)
  mean_intercept_init <- mean(mean_intercept_lrr_init)
  
  inits.fun <- function() list(mean_cov = mean_cov_init,
                               sd_cov = runif(mod.const$nCovs, 0, 2),
                               cov = cov_init,
                               mean_intercept = mean_intercept_init,
                               sd_intercept = runif(1, 0, 2),
                               mean_intercept_lrr = mean_intercept_lrr_init,
                               sd_intercept_lrr = runif(mod.const$n_lrr, 0, 2),
                               intercept = intercept_init,
                               mean_cov_year = c(0,runif(mod.const$nYear-1, -2, 2)),
                               sd_cov_year = runif(1, 0, 2),
                               cov_year = matrix(c(rep(0,times=mod.const$n_lrr),runif((mod.const$nYear-1) * mod.const$n_lrr, -0.1, 0.1)), nrow=mod.const$n_lrr),
                               det_bbs_0 = runif(1, -2, 2),
                               det_bbs_noise = runif(1, -2, 2),
                               det_bbs_car = runif(1, -2, 2),
                               det_ebd_0 = runif(1, -2, 2),
                               det_ebd_dur = runif(1, -2, 2),
                               det_ebd_type = runif(1, -2, 2),
                               det_ebd_type_eff = runif(1, -2, 2),
                               N_overall_1 = N_overall.init,
                               N_bbs = N_bbs_init)
  
  NOBO.SDM.model <- nimbleModel(code = model_NOBO_SDM,
                                data = mod.data,
                                constants = mod.const,
                                inits = inits.fun())
  
  NOBO.SDM.mcmc.out <- nimbleMCMC(model = NOBO.SDM.model,
                                  niter = 120000, nchains = 1, nburnin = 20000, thin=25,
                                  samplesAsCodaMCMC=TRUE, monitor=monitors, setSeed = seed)
  
  return(NOBO.SDM.mcmc.out)
}

this_cluster <- makeCluster(3) # Creating cluster

NOBO_SDM <- parLapply(cl = this_cluster, X = 1:3, 
                      fun = NOBO_SDM_MCMC_code, 
                      mod.data = mod.data,
                      mod.const = mod.const,
                      monitors = pars)

stopCluster(this_cluster)