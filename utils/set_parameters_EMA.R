##-------------------------------------------------------------------------------
## set_parameters_EMA: parameters for the algorithm to estimate EEG maturational
##                     age
##
## Syntax:  params <- set_parameters_EMA()
##
## Inputs: 
##     none
##
## Outputs: 
##     params - list of the parameters (see details in code)
##
## REQUIRES:
##     none
##

## John M. O' Toole, University College Cork
## Started: 23-02-2018
##
## last update: Time-stamp: <2018-03-04 19:34:25 (otoolej)>
##-------------------------------------------------------------------------------
set_parameters_EMA <- function(){

    
    ##-------------------------------------------------------------------
    ## parameters for gradient boosting algorithm
    ##-------------------------------------------------------------------
    params = list( loss_fn = 'laplace', ## loss function (l1 loss function)
                  N_trees = 5000,       ## number of trees
                  shrinkage = 0.01,     ## shrinkage
                  int_depth = 6,        ## tree size
                  bag_fraction = 0.5    ## fraction of data to randomly select
                  )

    return(params)
}
