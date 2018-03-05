##-------------------------------------------------------------------------------
## loglikelihood.ratio.test.MEM: log-likelihood ratio test compare 2 mixed-effects models
##
## Syntax: logtest_lst <- loglikelihood.ratio.test.MEM(model1,model2,DBverbose)
##
## Inputs: 
##     model1    - mixed effect model #1
##     model2    - mixed effect model #2
##     DBverbose - yes/no (1/0)
##
## Outputs: 
##     logtest_lst - list of:
##                   $logLikeTable = table of log-likelihoods plus p-values from chi-sq. test
##                   $whichModel   = which model is better fit
##


## John M. O' Toole, University College Cork
## Started: 27-02-2018
##
## last update: Time-stamp: <2018-03-05 11:40:24 (otoolej)>
##-------------------------------------------------------------------------------
loglikelihood.ratio.test.MEM <- function(model1, model2, DBverbose=1){


    ##-------------------------------------------------------------------
    ## 1. log-likelihood ratio test between models model1 and model2
    ##-------------------------------------------------------------------
    a <- logLik(model1, REML=FALSE)
    b <- logLik(model2, REML=FALSE)
    d1=attr(a, "df")        
    d2=attr(b, "df")    
    ll.diff <- -2*(a[1]-b[1])

    ## assemble table matrix to show results:
    res <- matrix(, nrow=2, ncol=4)
    colnames(res) <- c('df', 'logLik', 'logRatio (chisq)', 'pvalue')
    rownames(res) <- c('pm1', 'pm2')    
    res[, 'df'] <- c(d1, d2)
    res[, 'logLik'] <- c(a[1], b[1])

    ## re-arrange so better model last:
    if(ll.diff<0)
    {
        pm1 <- model2
        pm2 <- model1
        ll.diff=-ll.diff
        tt <- res
        tt[1, ] <- res[2, ]
        tt[2, ] <- res[1, ]
        res <- tt
        betterFitModel <- 1
    } else {
        pm1 <- model1
        pm2 <- model2
        betterFitModel <- 2
    }


    ##-------------------------------------------------------------------
    ## 2. is one likelihood significantly better than the other?
    ##    (using the chi-squared distribution to find p-value)
    ##-------------------------------------------------------------------
    pvalue2 <- pchisq(ll.diff, df=abs(d1-d2), lower.tail=FALSE)
    res[2, 'logRatio (chisq)'] <- ll.diff
    res[2, 'pvalue'] <- pvalue2

    
    if(DBverbose){
        cat('pm1: ')
        show(formula(pm1))
        cat('pm2: ')
        show(formula(pm2))
        show(res)
    }

    ## return a list:
    return(list('logLikeTable'=res, 'whichModel'=betterFitModel))
}
