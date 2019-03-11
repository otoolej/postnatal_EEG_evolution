Code for manuscript:


O'Toole JM, Pavlidis E, Korotchikova I, Boylan GB, Stevenson NJ, Temporal evolution of
quantitative EEG within 3 days of birth in early preterm infants, Scientific Reports,
41227, [DOI: 10.1038/s41598-019-41227-9](https://doi.org/10.1038/s41598-019-41227-9)
(2019)



Please cite the above reference if using this code or data to generate new results. 


Includes _R_ code for mixed-effects models of the EEG features and an algorithm to
estimate brain maturation from the EEG.

All code developed in _R_ (version 3.4.2, [The R Foundation of Statistical
Computing](http://www.r-project.org)).


EEG features calculated using NEURAL (version 0.4.0 
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2536888.svg)](https://doi.org/10.5281/zenodo.2536888),
also available [on github](https://github.com/otoolej/qEEG_feature_set)) with burst
detector (version 0.1.2 
[![DOI](https://zenodo.org/badge/42042482.svg)](https://zenodo.org/badge/latestdoi/42042482),
also available [on github](https://github.com/otoolej/burst_detector)). See
[references](#references) [1,2] for more details on these.




## Require packages
Mixed-effects models use the `lme4` package (v1.1.15), gradient boosting uses `gbm`
(v2.1.3), and for parallel processing `foreach` (v1.4.4) and `doParallel` (v1.0.11)
packages are required. Also, `ggplot2` (v2.0.0) is needed for plotting and `plyr` (v1.8.3)
is required somewhere.

If not installed, then 

``` R
install.packages('lme4')
install.packages('gbm')
install.packages('foreach')
install.packages('doParallel')
install.packages('ggplot2')
install.packages('plyr')
```

## Load the functions

``` R
# load the functions:
source('all_features_MEM.R')	
source('xv_EMA_regression.R')	
source('var_importance_Niter.R')
```

## Mixed-effects models

Generate mixed-effects models for all EEG features
``` R
all_features_MEM()
```

## Estimating maturation

To train and test the model to estimate EEG maturational age (EMA) using cross-validation, 
``` R
xv_EMA_regression()
```
(see [references](#references) [3,4] for more details on these types of algorithms.)


To assess the importance of the postnatal age as a feature in the EMA model,
``` R
var_importance_Niter()
```

## Parameters for the NEURAL toolbox
Parameter values of the [NEURAL](https://github.com/otoolej/qEEG_feature_set) toolbox used
to the generate the qEEG features are listed in the file
[neural_parameters_PNA_qEEG.m](neural_parameters_PNA_qEEG.m).

# Licence

```
Copyright (c) 2018, John M. O' Toole, University College Cork
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

  Neither the name of the University College Cork nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

# References

1. JM O' Toole, GB Boylan, RO Lloyd, RM Goulding, S Vanhatalo, and NJ Stevenson,
   Detecting Bursts in the EEG of Very and Extremely Premature Infants Using a
   Multi-Feature Approach, Medical Engineering & Physics, vol. 45, pp. 42-50, 2017.
   [doi:10.1016/j.medengphy.2017.04.003](https://doi.org/10.1016/j.medengphy.2017.04.003)

2. JM O’Toole and GB Boylan (2017). NEURAL: quantitative features for newborn EEG using
   Matlab. ArXiv e-prints, arXiv:[1704.05694](https://arxiv.org/abs/1704.05694).

3. JM O’ Toole, GB Boylan, S Vanhatalo, NJ Stevenson (2016). Estimating functional brain
   maturity in very and extremely preterm neonates using automated analysis of the
   electroencephalogram. Clinical Neurophysiology,
   127(8):2910–2918. [doi:10.1016/j.clinph.2016.02.024](https://doi.org/10.1016/j.clinph.2016.02.024)

4. NJ Stevenson, L Oberdorfer, N Koolen, JM O’Toole, T Werther, K Klebermass-Schrehof, S
   Vanhatalo. (2017). Functional maturation in preterm infants measured by serial
   recording of cortical activity. Scientific Reports,
   7(1), 12969. [doi:10.1038/s41598-017-13537-3](http://doi.org/10.1038/s41598-017-13537-3)

# Contact

John M. O' Toole

Neonatal Brain Research Group,  
INFANT: Irish Centre for Fetal and Neonatal Translational Research,  
Department of Paediatrics and Child Health,  
Room 2.19 UCC Academic Paediatric Unit, Cork University Hospital,  
University College Cork,  
Ireland

- email: j.otoole AT ieee.org

