##-------------------------------------------------------------------------------
## xv_regression: parameters for the algorithm to estimate brain maturation
##
## Syntax:  xv_regression()
##
## Inputs: 
##     none
##
## Outputs: 
##     none
##
## REQUIRES:
##     gbm (version 2.1.3)
##     ggplot2 (version 2.0.0)
##     plyr (version 1.8.3)
##     
##

## John M. O' Toole, University College Cork
## Started: 23-02-2018
##
## last update: Time-stamp: <2018-03-05 13:18:25 (otoolej)>
##-------------------------------------------------------------------------------
xv_regression <- function(){
    ##-------------------------------------------------------------------
    ## set directories; load packages and local functions
    ##-------------------------------------------------------------------
    data_dir <- './data/'
    utils_dir <- './utils/'
    fin_feat_set <- paste(data_dir, 'subset_features_v2.csv', sep='')    
    
    library('ggplot2')
    library('gbm')
    library('plyr')
    source(paste(utils_dir, 'load_feature_set.R', sep=""))
    source(paste(utils_dir, 'set_parameters_EMA.R', sep=""))



    ##-------------------------------------------------------------------
    ## 1. load the parameters
    ##    (set in set_parameters.R for details)
    ##-------------------------------------------------------------------
    params <- set_parameters_EMA()


    ##-------------------------------------------------------------------
    ## 2. load the feature set
    ##-------------------------------------------------------------------
    dfFeats <- load_feature_set(fin_feat_set)

    all_ccodes <- unique(dfFeats$c_code)


    LOG_TRANSFORM <- 1
    if(LOG_TRANSFORM){
        dfFeats$GA <- log( dfFeats$GA )
    }



    ##-------------------------------------------------------------------
    ## leave-one-out cross validation:
    ##-------------------------------------------------------------------
    n <- 1
    for(ccode in all_ccodes){
        itest <- which(dfFeats$c_code %in% ccode)
        itrain <- which(!(dfFeats$c_code %in% ccode))

        dfSub <- droplevels(dfFeats[,  !(names(dfFeats) %in% "c_code")])

        
        if(n==1){
            GA_all <- t(dfSub[itest, 'GA'])
        } else {
            GA_all <- rbind.fill.matrix(GA_all, t(dfSub[itest, 'GA']))
        }
        rowMeans(GA_all, na.rm=TRUE)

        ##-------------------------------------------------------------------
        ## a) train 
        ##-------------------------------------------------------------------
        gboost=gbm(GA ~ .,  data=dfSub[itrain,  ],
                   distribution=params$loss_fn,
                   n.trees=params$N_trees,
                   shrinkage=params$shrinkage,
                   interaction.depth=params$int_depth,
                   bag.fraction=params$bag_fraction)
        

        ##-------------------------------------------------------------------
        ## b) then test
        ##-------------------------------------------------------------------
        GA_est <- predict(gboost, newdata=dfSub[itest, ],
                          n.trees=params$N_trees)
        
        if(n==1){
            GA_est_all <- t(as.vector(GA_est))
        } else {
            GA_est_all <- rbind.fill.matrix(GA_est_all, t(as.vector(GA_est)))
        }
        
        cat(sprintf('%d,', n))
        n <- n + 1
    }
    cat(' -+|\n')


    if(LOG_TRANSFORM){
        GA_all <- exp(GA_all)
        GA_est_all <- exp(GA_est_all)
    }



    ##-------------------------------------------------------------------
    ## error measures
    ##-------------------------------------------------------------------
    cat("\n* TEST results; mean data points\n")
    error_measures(c(rowMeans(GA_all, na.rm=TRUE)),
                   c(rowMeans(GA_est_all, na.rm=TRUE)))
    cat("\n\n")



    ##-------------------------------------------------------------------
    ## plot
    ##-------------------------------------------------------------------
    DBplot <- 1
    if(DBplot) plotGA_GAhat(GA_all, GA_est_all)
}



error_measures <- function(GA, GA_hat){
    ##-------------------------------------------------------------------
    ## calculate metrics to measure the distance between the actual
    ## and estimated gestational ages (GA)
    ##-------------------------------------------------------------------
    ee <- (GA_hat - GA)
    err_fn <- sd(ee, na.rm=TRUE)*7
    ee_prc <- 100*length(which(abs(ee)<2)) / length(ee)
    ee_prc1 <- 100*length(which(abs(ee)<1)) / length(ee)

    cat(sprintf('** SD of error (total): %.2f (%.2f)\n',
                err_fn, sd(GA, na.rm=TRUE)*7))
    cat(sprintf('estimate within +/- 2 (1) week: %.2f (%.2f) %% \n',
                ee_prc, ee_prc1))

    ## percentage of the variance explained by function:
    var_data <- 1- (sum(ee^2, na.rm=TRUE)/sum((GA-mean(GA, na.rm=TRUE))^2, na.rm=TRUE))
    cat(sprintf('   %% of variance explained by model: %.2f\n', 100*var_data))

    ## correlation between variables:
    r2=cor(GA_hat, GA, use='complete.obs');
    cat(sprintf('R (Pearson): %.2f\n', r2))
}



plotGA_GAhat <- function(GA, GA_hat){
    ##-------------------------------------------------------------------
    ## plot estimated GA (GA_hat) versus actual GA (GA)
    ## requires ggplot2 package
    ##-------------------------------------------------------------------

    pData <- data.frame(GA=c(GA), estimate=c(GA_hat))
    pData <- pData[!is.na(pData$GA), ]
    pDataMean <- data.frame(GA=c(rowMeans(GA, na.rm=TRUE)),
                            estimate=c(rowMeans(GA_hat, na.rm=TRUE)))


    points_colour <- '#094074'

    (pl <- ggplot(data=pDataMean,  aes(GA, estimate)) +
         geom_point(colour=points_colour, size=3) +      
         geom_segment(aes(x=24, y=24, xend=32, yend=32)) +
         geom_segment(aes(x=25, y=24, xend=32, yend=31), colour='gray56', linetype=5) +
         geom_segment(aes(x=24, y=25, xend=31, yend=32), colour='gray56', linetype=5) +
         geom_segment(aes(x=26, y=24, xend=32, yend=30), colour='gray56', linetype=5) +
         geom_segment(aes(x=24, y=26, xend=30, yend=32), colour='gray56', linetype=5) +
         geom_point(data=pDataMean, aes(GA, estimate), colour=points_colour, size=3) +      
         xlim(24, 32) + ylim(24, 32) +
         xlab('gestational age (weeks)') + ylab('EEG maturational age (weeks)') + 
         theme_minimal() +
         theme(text=element_text(size=16))
    )

    print(pl)
}

