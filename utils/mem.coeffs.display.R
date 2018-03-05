##-------------------------------------------------------------------------------
## mem.coeffs.display: return coefficients with 95% CIs and p-value in table
##
## Syntax: ntable <- mem.coeffs.display(pd.final, scaleFactor = 1, bootCI = 0)
##
## Inputs: 
##     pd.final     - mixed-effect model (object)
##     scaleFactor  - re-scale coefficients (integer; default=1)
##     bootCI       - yes/no boostrap confidence intervals (default=0)
##
## Outputs: 
##     ntable - coefficients with 95% CIs and p-value (table)
##


## John M. O' Toole, University College Cork
## Started: 23-02-2018
##
## last update: Time-stamp: <2018-03-05 11:41:36 (otoolej)>
##-------------------------------------------------------------------------------
mem.coeffs.display <- function(pd.final, scaleFactor = 1, bootCI = 0){

    
    b <- summary(pd.final)
    if(bootCI){
        cintr <- data.frame(confint(pd.final, method="boot", nsim=1000, 
                                    parallel="multicore", ncpus=4))
    } else {
        cintr <- data.frame(confint(pd.final, method="Wald"))
    }

    i_cintr <- which(grepl( ".sig", rownames(cintr)) ==FALSE)

    bcoef <- cbind(b$coef[, 1])
    rownames(bcoef) <- rownames(b$coef)
    cis <- cintr[i_cintr, ]
    rownames(cis) <- rownames(b$coef)

    if("Pr(>|t|)" %in% colnames(b$coeff)){
        ## if p-value then include
        bpvalue <- cbind(b$coef[, 5])
        rownames(bpvalue) <- rownames(b$coef)
        oldtable <- cbind(bcoef, cintr[i_cintr, ], bpvalue)
        newtable <- oldtable
        colnames(newtable) <- c('coefficient', '2.5%', '97.5%', 'Pr(>|t|)')
    } else {
        ## other just coefficients with 95% CIs
        oldtable <- cbind(bcoef, cintr[i_cintr, ])
        newtable <- oldtable
        colnames(newtable) <- c('coefficient', '2.5%', '97.5%')
    }


    ## if want to scale the variables to days:
    if(scaleFactor!=1){
        ## not sure that is correct ?????
        coeffnames <- c('coefficient', '2.5%', '97.5%')

        for(i in 1:length(coeffnames))
        {
            newtable['time', coeffnames[i]] <- newtable['time', coeffnames[i]]*scaleFactor
            if('I(time^2)' %in% rownames(newtable))
            {
                newtable['I(time^2)', coeffnames[i]] <- newtable['I(time^2)', coeffnames[i]]*(scaleFactor^2)
            }
            ## if('time:group1' %in% rownames(newtable))
            ## {
            ##     newtable['time:group1', coeffnames[i]] <- newtable['time:group1', coeffnames[i]]*scaleFactor
            ## }
            time.interactions <- grep('time:', rownames(newtable))
            for(p in 1:length(time.interactions))
            {
                newtable[time.interactions[p], coeffnames[i]] <- newtable[time.interactions[p], coeffnames[i]]*scaleFactor
            }
                
        }
    }
    ntable <- format(newtable, digits=3)

    
    return(ntable)
}
