extract.coeffs.table <- function(coeff_table, featureName){
    ##-------------------------------------------------------------------
    ## extract coefficients from table and concatenate in CSV line
    ##-------------------------------------------------------------------
    

    mm <- 1
    mm_plus <- 3
    rn <- rownames(coeff_table)

    P_VALUE <- 0
    if ("Pr(>|t|)" %in% colnames(coeff_table)){
        P_VALUE <- 1
        mm_plus <- 4
    }

    str_fixed_effects <- c("(Intercept)", "time", "GA", "time:GA")
    coeffs_write <- vector(mode="character", 4*mm_plus)
    

    for(pp in 1:length(str_fixed_effects) ){

        imatch <- match(str_fixed_effects[pp], rn)
        if(!is.na(imatch)){
            coeffs_write[mm] <- coeff_table[imatch, "coefficient"]
            coeffs_write[mm+1] <- coeff_table[imatch, "2.5%"]
            coeffs_write[mm+2] <- coeff_table[imatch, "97.5%"]
            if(P_VALUE) coeffs_write[mm+3] <- coeff_table[imatch, "Pr(>|t|)"]
        }
        mm <- mm + mm_plus
    }        

    return(paste(c(featureName, coeffs_write), collapse=","))
}
