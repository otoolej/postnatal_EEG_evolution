##-------------------------------------------------------------------------------
## all_features_MEM: generate mixed-effects models for all EEG features.
##                   writes fixed-effects coefficients and formulats to .csv files
##
## Syntax: all_features_MEM()
##
## Inputs: 
##     none
##
## Outputs:
##     none
##
## REQUIRES:
##     lme4 (version 1.1.15)
##
##     and local functions:
##             mixedmodel_each_feature.R
##             utils/loglikelihood.ratio.test.MEM.R
##             utils/mem.coeffs.display.R
##             utils/extract.coeffs.table.R
##
##

## John M. O' Toole, University College Cork
## Started: 23-02-2018
##
## last update: Time-stamp: <2019-01-10 16:19:57 (otoolej)>
##-------------------------------------------------------------------------------
all_features_MEM <- function(){
    
    ##-------------------------------------------------------------------
    ## 1. set directories
    ##-------------------------------------------------------------------
    data_dir <- './data/'
    utils_dir <- './utils/'
    fin_feat_set <- paste(data_dir, 'subset_features_v3.csv', sep='')
    fout_fixed_effects <- paste(data_dir, 'coeffs_fixedEffects_MM_v1.csv', sep='')
    fout_mm_formulas <- paste(data_dir, 'formulas_MM_v1.csv', sep='')
    ## set verbose level (0 or 1):
    DBverbose <- 1


    ##-------------------------------------------------------------------
    ## 2. load libraries and local functions
    ##-------------------------------------------------------------------
    source(paste(utils_dir, 'loglikelihood.ratio.test.MEM.R', sep=""))
    source(paste(utils_dir, 'mem.coeffs.display.R', sep=""))
    source(paste(utils_dir, 'extract.coeffs.table.R', sep=""))
    source('mixedmodel_each_feature.R')
    library(lme4)


    ##-------------------------------------------------------------------
    ## 3. load feature set
    ##-------------------------------------------------------------------
    dfFeats <- read.csv(file = fin_feat_set, sep = ",")

    ## use precise timing of EEG epochs and convert to days:
    dfFeats$time <- dfFeats$EEG_PNA / 24

    featNames <- colnames(dfFeats)
    featNames <- featNames[! featNames %in% c("c_code", "GA", "baby_ID", "time", "EEG_PNA")]
    N_feats <- length(featNames)



    ##-------------------------------------------------------------------
    ## 4. mixed-effect model for all features
    ##-------------------------------------------------------------------
    all_coeffs_forms <- vector("list", N_feats)
    all_forms <- vector("list", N_feats)

    ## write fixed-effects coefficients to .csv file:
    cat(paste("# feature, intercept, Ici1, Ici2, time, Tci1, Tci2, ",
              "GA, Gci1, Gci2, time:GA, TGci1, TGci2 ",
              sep=""), file=fout_fixed_effects, append=FALSE, sep = "\n")



    ## iterate over all features:
    for(nn in 1:N_feats){
        
        ## a) make subset data frame:
        aa <- names(dfFeats) %in% featNames
        dfFeats.sub <- dfFeats[!aa]
        featureName <- featNames[nn];
        dfFeats.sub$feat <- dfFeats[[featNames[nn]]]
        dfFeats.sub <- droplevels(dfFeats.sub)

        
        ## b) fit the mixed-effect model:
        cat(sprintf('\n\n** FEAT: %s  -----\n', featureName))
        coeff_form_lt <- mixedmodel_each_feature(dfFeats.sub, featureName, DBverbose)

        

        ## c) write the fixed-effect coefficients (and formulas) to .csv file:
        csv_line <- extract.coeffs.table(coeff_form_lt$coeffs, coeff_form_lt$feature)
        cat(csv_line, file=fout_fixed_effects, append=TRUE, sep = "\n")

        all_coeffs_forms[[nn]] <- coeff_form_lt
        coeff_form_lt[['coeffs']] <- NULL    
        all_forms[[nn]] <- coeff_form_lt
    }



    ##-------------------------------------------------------------------
    ## 5. write formulas to output file and in terminal
    ##-------------------------------------------------------------------
    fcon <- file(fout_mm_formulas)
    writeLines(unlist(lapply(all_forms, paste, collapse=" , ")), con=fcon)
    close(fcon)
    writeLines(unlist(lapply(all_forms, paste, collapse=" || ")), con=stdout())

}


