##-------------------------------------------------------------------------------
## mixedmodel_each_feature: backward elimination process to select mixed-effects model
##
## Syntax:  model_list <- mixedmodel_each_feature(dfData, featName, DBverbose, DBplot)
##
## Inputs: 
##     dfData    - variables for mixed-effects model as data-frame
##     featName  - name of feature (string)
##     DBverbose - yes/no (1/0) verbose 
##
## Outputs: 
##     model_list - list including the formula for the mixed-effect model,
##                  $feature = feature name (string)
##                  $form    = formula for mixed model
##                  $coeffs  = coefficients for mixed-effect model
##
## REQUIRES:
##     lme4 (version 1.1.15)
##
##     and local functions:
##          utils/loglikelihood.ratio.test.MEM.R
##          utils/mem.coeffs.display.R
##

## John M. O' Toole, University College Cork
## Started: 23-02-2018
##
## last update: Time-stamp: <2018-03-06 17:30:23 (otoolej)>
##-------------------------------------------------------------------------------
mixedmodel_each_feature <- function(dfData, featName = 'generic_feature',
                                    DBverbose = 0){

    ## define the formula:
    form.predicators <- c("1", "time", "GA", "time:GA", "(1 + time | c_code)")
    form.full <- reformulate(form.predicators, "feat")
    if(DBverbose) cat(sprintf('FULL formula: %s\n', format(form.full)))
    

    ##-------------------------------------------------------------------
    ## 0. FULL model (i.e. with everything)
    ##-------------------------------------------------------------------
    pd.full <- lme4::lmer(form.full, dfData, REML=FALSE)


    ##-------------------------------------------------------------------
    ## 1. REMOVE random-effect time?
    ##-------------------------------------------------------------------
    form.p.exclude.rt <- form.predicators
    form.p.exclude.rt[form.p.exclude.rt=="(1 + time | c_code)"]="(1 | c_code)"    

    pd.t.ga.gat <- lme4::lmer(reformulate(form.p.exclude.rt, "feat"), 
                              dfData, REML=FALSE)
    
    if(DBverbose){
        cat('\n*** COMPARING MODELS with random effects, intercept vs. intercept+linear\n')
    }
    keep_lst <- logRatioTest_coefficient(pd.t.ga.gat, pd.full, 
                                         form.p.exclude.rt, form.predicators, 
                                         DBverbose)


    ##-------------------------------------------------------------------
    ## 2. REMOVE fixed-effects time-GA interaction?
    ##-------------------------------------------------------------------
    ## a) remove GA*time:
    form.p.exclude.gat <- keep_lst$form[ !keep_lst$form %in% "time:GA" ]
    pd.t.ga <- lme4::lmer(reformulate(form.p.exclude.gat, "feat"), 
                          dfData, REML=FALSE)

    if(DBverbose) cat('\n*** COMPARING MODELS when removing GA * time fixed effect\n')
    keep_lst <- logRatioTest_coefficient(pd.t.ga, keep_lst$pd, 
                                         form.p.exclude.gat, keep_lst$form, 
                                         DBverbose)    


    ## only if removing time:GA (otherwise must keep time and GA)
    if(!("time:GA" %in% keep_lst$form)){
        ##-------------------------------------------------------------------
        ## 3. REMOVE fixed-effects GA?
        ##-------------------------------------------------------------------        
        form.p.exclude.ga <- keep_lst$form[ !keep_lst$form %in% "GA"]
        pd.t <- lme4::lmer(reformulate(form.p.exclude.ga, "feat"), 
                           dfData, REML=FALSE)

        if(DBverbose) cat('\n*** COMPARING MODELS when removing GA fixed effect\n')
        keep_lst <- logRatioTest_coefficient(pd.t, keep_lst$pd, 
                                             form.p.exclude.ga, keep_lst$form, 
                                             DBverbose)

        
        ##-------------------------------------------------------------------
        ## 4. REMOVE fixed-effects time?
        ##-------------------------------------------------------------------        
        form.p.exclude.t <- keep_lst$form[ !keep_lst$form %in% "time"]
        pd <- lme4::lmer(reformulate(form.p.exclude.t, "feat"), 
                         dfData, REML=FALSE)

        if(DBverbose) cat('\n*** COMPARING MODELS when removing time fixed effect\n')
        keep_lst <- logRatioTest_coefficient(pd, keep_lst$pd, 
                                             form.p.exclude.t, keep_lst$form, 
                                             DBverbose)
    }

    
    form.final <- reformulate(keep_lst$form, "feat")
    if(DBverbose) cat(sprintf('\n*** FINAL formula: %s\n', format(form.final)))

    
    ##-------------------------------------------------------------------
    ## 5. FINAL model: 
    ##-------------------------------------------------------------------
    ## final, with no group x time interactions
    pd.final <- lme4::lmer(form.final, dfData, REML=TRUE)

    if(DBverbose){
        cat('\n\n*** summary of FINAL model\n')
        print(summary(pd.final))
    }

    ## 95% confidence intervals for fixed-effects (estimated using a bootstrap)
    use.bootstrap <- 1
    h <- mem.coeffs.display(pd.final, 1, use.bootstrap)
    if(DBverbose){
        cat('\n**** 95% CI for coefficients\n')
        print(h)
        cat('\n   -- END COEFFs --\n')
    }



    ##-------------------------------------------------------------------
    ## 6. plot
    ##-------------------------------------------------------------------
    DBplot <- 0
    if(DBplot){
        library(gridExtra)
        library(ggplot2)
        

        ## remove NAs:
        drPlot <- dfData[!is.na(dfData$feat), ]
        ## re-order based on GA (for plotting only):
        ## drPlot$c_code <- factor(drPlot$c_code, levels = drPlot$c_code[order(drPlot$GA)])
        drPlot$ID <- drPlot$c_code
        

        p1 <- ggplot(drPlot, aes(x=time, y=feat, colour=ID, order=GA)) +
            geom_point(size=3) +
            geom_line(aes(x=time, y=predict(pd.final)), size=0.5) +
            geom_line(aes(y=predict(pd.final, re.form=NA, newdata=drPlot)), size=4) +         
            ylab(featName) + xlab("time (days)") + 
            theme_bw(base_size=22)        

        p2 <- ggplot(drPlot, aes(x=GA, y=feat, colour=ID)) +
            geom_point(size=3) +
            geom_line(aes(x=GA, y=predict(pd.final)), size=0.5) +
            geom_line(aes(x=GA, y=predict(pd.final, re.form=NA)), size=4) +         
            ylab(featName) + xlab("GA (weeks)") + 
            theme_bw(base_size=22)
        
        grid.arrange(p1, p2, ncol=1, nrow=2)
    }

    
    return(list('feature'=featName, 'form'=form.final, 'coeffs'=h))
}





logRatioTest_coefficient <- function(pd.test, pd.full, form.test, form.full, DBverbose){
    ##-------------------------------------------------------------------
    ## log-ratio test to test contribution of fixed-effect (coefficient)
    ##
    ## compares the simplier model pd.test with more complex pd.full
    ## only keep the fixed effect if pd.full is significant improvement
    ## over pd.test
    ##-------------------------------------------------------------------
    
    logTest <- loglikelihood.ratio.test.MEM(pd.test, pd.full)
    if(logTest$logLikeTable[2, 'pvalue']>=0.05) {
        form.p.keep <- form.test
        pd.keep <- pd.test
    } else {
        if(logTest$whichModel==1){
            form.p.keep <- form.test
            pd.keep <- pd.test
        } else {
            form.p.keep <- form.full
            pd.keep <- pd.full
        }
    }
    
    ## form.keep <- convert_formula(form.p.keep, DBverbose)
    if(DBverbose){
        cat(sprintf('¬¬ NEW MODEL: %s\n', 
                    format(reformulate(form.p.keep, "feat"))))
    }
    
    ## return(form.p.keep)
    return(list("form" = form.p.keep, "pd" = pd.keep))
}

