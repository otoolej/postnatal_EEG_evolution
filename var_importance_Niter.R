##-------------------------------------------------------------------------------
## var_importance_Niter: test contribution of postnatal age (PNA) feature in
##                       gradient boosting algorithm assessing both relative 
##                       influence and loss in performance from a permutation test
##
## Syntax:  var_importance_Niter()
##
## Inputs: 
##     none
##
## Outputs: 
##     none
##
## REQUIRES:
##     gbm (version 2.1.3)
##     foreach (version 1.4.4)
##     doParallel (version 1.0.11)
##

## John M. O' Toole, University College Cork
## Started: 23-02-2018
##
## last update: Time-stamp: <2018-03-05 11:45:19 (otoolej)>
##-------------------------------------------------------------------------------
var_importance_Niter <- function(){

    ##-------------------------------------------------------------------
    ## load packages and local functions
    ##-------------------------------------------------------------------
    library('gbm')
    library('foreach')
    library('doParallel')

    source('load_feature_set.R')
    source('set_parameters.R')


    ##-------------------------------------------------------------------
    ## 1. load the parameters
    ##    (set in set_parameters.R for details)
    ##-------------------------------------------------------------------
    params <- set_parameters_EMA()


    ##-------------------------------------------------------------------
    ## 2. load the feature set
    ##-------------------------------------------------------------------
    data_dir <- './data/'
    fin_feat_set <- paste(data_dir, 'subset_features_v2.csv', sep='')
    dfFeats <- load_feature_set(fin_feat_set)
    dfFeats <- droplevels(dfFeats[, !(names(dfFeats) %in% "c_code")])


    ## speed up processing by using multiple CPU cores (use max. cores - 1)
    cores = detectCores()
    cl <- makeCluster(cores[1]-1) 
    registerDoParallel(cl)


    LOG_TRANSFORM <- 1
    if(LOG_TRANSFORM){
        dfFeats$GA <- log( dfFeats$GA )
    }

    ## set number of iterations:
    Niter <- 1000


    ##-------------------------------------------------------------------
    ## 3. monte-Carlo type simulation, train and assess variable importance:
    ##-------------------------------------------------------------------
    r.all <- foreach(p=1:Niter,
                     .combine=rbind,
                     .export='train_var_importance',
                     .packages=c('gbm')) %dopar% {
                         rank.all <- train_var_importance(dfFeats, params, 1)
                         rank.all        
                     }

    ##-------------------------------------------------------------------
    ## 4. show results:
    ##-------------------------------------------------------------------
    cat('\n __ RESULTS __\n')
    cat(sprintf(' + rank: mean (SD), (range) = %.2f (%.2f) (%.2f, %.2f)\n',
                mean(r.all[, 1]), sd(r.all[, 1]), range(r.all[, 1])[1], 
                range(r.all[, 1])[2])
        );
    cat(sprintf(' + reduction in performance: mean (SD), (range) = %.2f%% (%.2f)%% (%.2f, %.2f)%%\n',
                mean(r.all[, 3]), sd(r.all[, 3]), range(r.all[, 3])[1], 
                range(r.all[, 3])[2])
        );
    cat('\n')

    ## remove the CPU cluster
    stopCluster(cl)
}




train_var_importance <- function(dfData, params, DBverbose=0){
##-------------------------------------------------------------------------------
## train_var_importance: assess importance of PNA (postnatal age) feature when
##                       building gradient boosting model
##
## Syntax:  performance_PNA <- train_var_importance(dfData, params, DBverbose)
##
## Inputs: 
##     dfData    - data frame of features and gestational age (GA)
##     params    - parameter set for gradient boosting algorithm (see set_parameters.R)
##     DBverbose - yes/no (1/0) verbose (default=0)
##
## Outputs: 
##     performance_PNA - array:
##                       [1] = rank PNA of relative influence 
##                       [2] = total number of features
##                       [3] = % drop in performance when applying permutation
##                             test on PNA 
##-------------------------------------------------------------------------------    

    ## a) train with gradient boosting algorithm
    gboost=gbm(GA ~ ., data=dfData,
               distribution=params$loss_fn,
               n.trees=params$N_trees,
               shrinkage=params$shrinkage,
               interaction.depth=params$int_depth,
               bag.fraction=params$bag_fraction)

    
    ## b) find relative influence and permutation loss for PNA feature:
    rel_inf <- summary(gboost, method=relative.influence, plotit=FALSE)
    perm_inf <- summary(gboost, method=permutation.test.gbm, plotit=FALSE)

    pna_rel_ranking <- which( rel_inf[, 1]=="EEG_PNA" )
    pna_perm_loss <- perm_inf[perm_inf$var=="EEG_PNA", 2]

    performance_PNA <- numeric(3)
    performance_PNA[1] <- pna_rel_ranking
    performance_PNA[2] <- length(rel_inf[, 1])
    performance_PNA[3] <- pna_perm_loss

    if(DBverbose){
        cat(sprintf('\n ** EEG_PNA ranking = %d/%d\n',  
                    performance_PNA[1], performance_PNA[2]))
        cat(sprintf('     EEG_PNA permutation loss in performance = %.2f%%\n', 
                    performance_PNA[3]))
    }


    return(performance_PNA)
}

