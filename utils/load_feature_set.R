##-------------------------------------------------------------------------------
## load_feature_set: parameters for the algorithm to estimate brain maturation
##
## Syntax:  dfFeats <- load_feature_set()
##
## Inputs: 
##     file_name - name of .csv file (full path)
##
## Outputs: 
##     dfFeats - data frame of the 27 features, c_code (unique baby identifier),
##               gestational age (in weeks), and time of EEG recording (postnatal
##               age in hours)
##
## REQUIRES:
##     none
##

## John M. O' Toole, University College Cork
## Started: 23-02-2018
##
## last update: Time-stamp: <2018-10-19 14:05:37 (otoolej)>
##-------------------------------------------------------------------------------
load_feature_set <- function(file_name){
    
    ## a. read in feature set from .csv file:
    dfFeats <- read.csv(file=file_name, sep=',')

    ## b. remove features which are not significantly correlated with GA:
    FEATS_NOT_SIGNIF_GA=c(
        'spectral_power..3.',
        'spectral_power..4.', 
        'spectral_relative_power..1.',
        'spectral_relative_power..2.', 
        'spectral_flatness..1.', 
        'spectral_flatness..4.', 
        'rEEG_median' )
    
    dfFeats <- droplevels(dfFeats[, !(names(dfFeats) %in% FEATS_NOT_SIGNIF_GA)])

    ## c. remove other fields not needed here:
    dfFeats <- droplevels(dfFeats[, !(names(dfFeats) %in% c("baby_ID", "time"))])


    return(dfFeats)
}

