DOC CAR model
================
Eric Oh
8/26/2019

We noticed in [doc\_data\_overview.md](https://github.com/ericoh17/doc_project/blob/master/doc_data_overview.md) that there was evidence of spatial correlation in number of releases between neighboring zip codes through Philadelphia. Accounting for this spatial correlation is the focus of the current modeling work.

One of the standard statistics used to assess the strength of this spatial correlation is Moran's *I*, which is defined as

$$
I = \\frac{n}{\\sum\_i \\sum\_j w\_{ij}}\\frac{\\sum\_i \\sum\_j w\_{ij}(X\_i-\\bar{X})(X\_j-\\bar{X})}{\\sum\_i (X\_i-\\bar{X})^2}
$$
 where
*w*<sub>*i**j*</sub>
 is 1 if zip codes i and j share a border and 0 otherwise.

    OGR data source with driver: ESRI Shapefile 
    Source: "/Users/ericoh/Dropbox/doc_project/Zipcodes_Poly", layer: "Zipcodes_Poly"
    with 48 features
    It has 5 fields
    Integer64 fields read as strings:  OBJECTID COD 


        Moran I test under randomisation

    data:  num_offense_zip$count  
    weights: philly_nb_listw    

    Moran I statistic standard deviate = 4.716, p-value = 0.000001203
    alternative hypothesis: greater
    sample estimates:
    Moran I statistic       Expectation          Variance 
          0.387804709      -0.021276596       0.007524396 

We can use Moran's I to perform testing for spatial correlation under the null hypothesis that there is no spatial correlation. Calculating Moran's I on the total number of releases in each zip code from 2007 - 2016 yields a statistic of 0.3878, compared to a null mean of −0.0213 and standard error of 0.0075, suggesting a high amount of spatial correlation in the number of releases between zip codes.

Counts of incarcerated person releases
======================================

As seen in [doc\_data\_overview.md](https://github.com/ericoh17/doc_project/blob/master/doc_data_overview.md) the number of releases across Philadelphia zip codes seems to be quite skewed due to some zip codes having a higher number of releases relative to others. One classical method to handle such skewed data is to take a log transformation of the count of releases. However, there are a number of zip codes in some years with zero releases, meaning we must consider a different transformation that is defined at zero. Thus, we decided to use the inverse hyperbolic sine transformation

$$
\\tilde{y}\_{it} = \\log\\left(y\_{it} + \\sqrt{y\_{it}^2 + 1}\\right) - \\log(2)
$$

where *y*<sub>*i**t*</sub> is the number of releases in zip code *i* at time *t* and log(2) is subtracted to center the transformed values. The inverse hyperbolic sine transformation has the additional benefit that it can be interpreted the same way as a standard log transformation. Specifically, changes in the transformed number of releases can be interpreted as percent changes in the raw number of releases.

Zip code level predictors
=========================

We want our model to account for zip code level predictors that might be predictive of the number of releases. To do so, we merge the DOC data with the Census Bureau's American Community Survey, containing information about poverty and income levels for Census tract groups. We utilize [crosswalk files](https://www.huduser.gov/portal/datasets/usps_crosswalk.html) from the U.S. Department of Housing and Urban Development's Office of Policy Development and Research to relate Philadelphia zip codes to Census tract groups.

From the American Community Survey (ACS), we obtain information about the proportion of households in various states of poverty. Specifically, the ACS has data on the proportion of the population in seven different brackets of income-to-poverty line ratios: \[0, 0.5), \[0.5, 1), \[1, 1.25), \[1.25, 1.5), \[1.5, 1.85), \[1.85, 2), and \[2+). For example, the \[0.5, 1) bracket represents families with income between 50% of the poverty line and the poverty line, where the poverty line is determined by the Census Bureau according to the size and number of children of a household.

From this poverty data, we create a single measure of poverty for each zip code by calculating a weighted sum of the proportion of households in each of the seven poverty brackets:

$$
\\text{poverty}\_{i} = \\sum\_{j=1}^7 w\_j q\_{i,j}
$$
 *q*<sub>*i*, *j*</sub> is the proportion of households in zip code *i* that are in poverty bracket *j* and *w*<sub>*j*</sub> is the weight given to poverty bracket *j*. We use decreasing weights w = \[1, 5/6, 4/6, 3/6, 2/6, 1/6, 0\] to give higher poverty brackets more weight. Thus, the poverty measure ranges from 0 to 1, with higher values indicating a higher level of poverty.

For more detail on how all of the above was done, see [link\_doc\_census.R](https://github.com/ericoh17/doc_project/blob/master/link_doc_census.R).

CAR priors to account for spatial correlation
=============================================

Conditional autoregressive (CAR) models are commonly used as prior distributions for spatially correlated random effects with areal spatial data. Let *Γ* = (*γ*<sub>1</sub>, …, *γ*<sub>*n*</sub>)′ be a vector of random elements for n areal locations that are spatially correlated. The CAR model can then be represented using conditional distributions:

$$
\\gamma\_i | \\gamma\_j, j \\neq i  \\sim \\text{N}\\left(\\rho\\sum\_{j=1}^n w\_{ij}\\gamma\_j, \\tau\_i^{-1}\\right)
$$
 where *w*<sub>*i**j*</sub> are weights equal to 1 if zip codes *i* and *j* share a border and 0 otherwise and *τ*<sub>*i*</sub> is a spatially varying precision parameter.

It can be proved using Brook's Lemma that the joint distribution of *Γ* is given by

*Γ* ∼ N(0,\[*D*<sub>*τ*</sub>(*I*−*ρ**B*)\]<sup>−1</sup>)
 where: \* *D*<sub>*τ*</sub> = *τ**D* \* *D* = *d**i**a**g*(*m*<sub>*i*</sub>): an *n* × *n* diagonal matrix with *m*<sub>*i*</sub>= the number of neighbors for zip code *i* \* *I*: an *n* × *n* identity matrix \* *ρ*: parameter controlling spatial dependence (*ρ* = 0 implies spatial independence and *ρ* = 1 results in an intrinsic conditional autoregressive model) \* *B* = *D*<sup>−1</sup>*W*, the scaled adajency matrix \* *W*: the adajency matrix ($w\_{ii}=0, *W*<sub>*i**j*</sub> = 1 if neighbor; 0 otherwise)

We can then write the CAR prior as:

*Γ* ∼ N(0, \[*τ*(*D* − *ρ**W*)\]<sup>−1</sup>)

Full Bayesian model
===================

We model the transformed number of releases as follows:

$$
\#y\_i \\sim \\text{Poisson}(\\exp\\{X\_i \\gamma + \\beta \\cdot t + \\phi\_i + \\log(\\text{offset}\_i\\})
\#$$
============================================================================================================

$$
\\tilde{y}\_{it} = \\psi\_i + \\phi\_i t + x\_i'\\beta + \\epsilon\_{it}
$$

where *x*<sub>*i*</sub>′ is a design vector of predictor variables for zip code *i*, *β* is the vector of coefficients for those predictor variables, *t* represents time, *ψ*<sub>*i*</sub> and *ϕ*<sub>*i*</sub> are zip code specific intercepts and slopes, and *ϵ*<sub>*i**t*</sub> ∼ N(0, *σ*<sub>*ϵ*</sub><sup>2</sup>). Since we do not expect every zip code to have unique coefficients, we impose CAR priors for *ψ*<sub>*i*</sub> and *ϕ*<sub>*i*</sub>, resulting in

$$
\\begin{align\*}
\\mathbf{\\psi} &\\sim \\text{N}(\\psi\_0 \\cdot \\mathbf{1}, \\tau^2\_{\\psi} \\cdot \\mathbf{\\Sigma}^{-1}) \\\\
\\mathbf{\\phi} &\\sim \\text{N}(\\phi\_0 \\cdot \\mathbf{1}, \\tau^2\_{\\phi} \\cdot \\mathbf{\\Sigma}^{-1}) 
\\end{align\*}
$$
 where **Σ** = *τ*(*D* − *ρ**W*). The posterior distribution can then be written as follows:

$$
\\begin{align\*}
p(\\beta, \\psi, \\phi, \\psi\_0, \\phi\_0, \\rho, \\tau | y) &\\propto p(y|\\beta, \\psi, \\phi, \\psi\_0, \\phi\_0, \\rho, \\tau)p(\\psi|\\psi\_0,\\tau^2\_{\\psi},\\rho)p(\\phi|\\phi\_0,\\tau^2\_{\\phi},\\rho) \\\\
& \\times p(\\psi\_0)p(\\phi\_0)p(\\tau^2\_{\\psi})p(\\tau^2\_{\\phi})p(\\rho)p(\\beta)
\\end{align\*}
$$

We specify the following prior distributions:

$$
\\begin{align\*}
\\mathbf{\\psi} &\\sim \\text{N}(\\psi\_0 \\cdot \\mathbf{1}, \\tau^2\_{\\psi} \\cdot \\mathbf{\\Sigma}^{-1}) \\\\
\\mathbf{\\phi} &\\sim \\text{N}(\\phi\_0 \\cdot \\mathbf{1}, \\tau^2\_{\\phi} \\cdot \\mathbf{\\Sigma}^{-1}) \\\\
p(\\psi\_0) &\\propto 1 \\\\
p(\\phi\_0) &\\propto 1 \\\\
p(\\tau^2\_{\\psi}) &\\sim \\text{Inv-Gamma}(l\_{\\psi}, k\_{\\psi}) \\\\
p(\\tau^2\_{\\phi}) &\\sim \\text{Inv-Gamma}(l\_{\\phi}, k\_{\\phi}) \\\\
p(\\rho) &\\sim \\text{Uniform}(0,1) \\\\
p(\\mathbf{\\beta}) &\\sim \\text{N}(0, \\tau^2\_{\\beta} \\cdot \\mathbf{I}) \\\\
p(\\tau^2\_{\\beta}) &\\sim \\text{Inv-Gamma}(l\_{\\beta},k\_{\\beta}) \\\\
p(\\sigma^2\_{\\epsilon}) &\\sim \\text{Inv-Gamma}(l\_{\\epsilon}, k\_{\\epsilon})
\\end{align\*}
$$

Implementation in Stan
======================

First, we can load the necessary packages and set the MCMC options.

``` r
library(ggmcmc)
```

    ## Loading required package: tidyr

``` r
library(dplyr)
library(rstan)
```

    ## Loading required package: StanHeaders

    ## rstan (Version 2.19.2, GitRev: 2e1f913d3ca3)

    ## For execution on a local, multicore CPU with excess RAM we recommend calling
    ## options(mc.cores = parallel::detectCores()).
    ## To avoid recompilation of unchanged Stan programs, we recommend calling
    ## rstan_options(auto_write = TRUE)

    ## 
    ## Attaching package: 'rstan'

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

``` r
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
```

Next, we setup the necessary data.

``` r
# remove 19112 zip code because not in census data
tmp_philly_zip <- philly_zip_shape[!(philly_zip_shape$CODE %in% "19112"),]

tmp_philly_nb <- poly2nb(tmp_philly_zip,
                         queen = FALSE,
                         row.names = tmp_philly_zip$CODE)
philly_nb_mat <- nb2mat(tmp_philly_nb, style = "B",
                        zero.policy = TRUE)

# order dataframe by zip codes and years within zip codes
# also add in numeric time variable
release_by_zip_year_cov <- release_by_zip_year_cov %>%
  dplyr::group_by(legal_zip_code) %>%
  dplyr::arrange(ReleaseYear, .by_group = TRUE) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(time = rep(seq(1, 10), 48))

# remove 19112 from outcome and covariate mat
release_by_zip_year_cov <- release_by_zip_year_cov[!(release_by_zip_year_cov$legal_zip_code %in% 19112),]
design_mat <- as.matrix(release_by_zip_year_cov[,c("poverty_measure",
                                                   "income_measure")])
scaled_design_mat <- scale(design_mat)
X <- model.matrix(~scaled_design_mat)
  
full_dat <- list(n = nrow(X),         # number of observations
                 p = ncol(X),         # number of coefficients
                 l = nrow(philly_nb_mat),  # number of zip codes
                 X = X,               # design matrix
                 y = c(release_by_zip_year_cov$count_tf),  # observed number of cases
                 W = philly_nb_mat)               # adjacency matrix
```

Then, we can fit the model using `rstan`.

``` r
car_mod <- stan('stan/doc_car.stan', data = full_dat, 
                iter = niter, chains = nchains, verbose = FALSE)
```
