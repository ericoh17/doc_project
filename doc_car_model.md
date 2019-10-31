DOC CAR model
================
Eric Oh
8/26/2019

We noticed in [doc\_data\_overview.md](https://github.com/ericoh17/doc_project/blob/master/doc_data_overview.md) that there was evidence of spatial correlation in number of releases between neighboring zip codes through Philadelphia. Accounting for this spatial correlation is the focus of the current modeling work.

One of the standard statistics used to assess the strength of this spatial correlation is Moran's *I*, which is defined as

<p align="center"><img src="/tex/c631486053f01c5351e68c38a63fddb5.svg?invert_in_darkmode&sanitize=true" align=middle width=323.4138402pt height=45.5133228pt/></p>
 where <img src="/tex/64e70e84545b2941bed8aa7fe2211cde.svg?invert_in_darkmode&sanitize=true" align=middle width=22.523917349999987pt height=14.15524440000002pt/> is 1 if zip codes i and j share a border and 0 otherwise.

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

<p align="center"><img src="/tex/94ee7715cb22ea34145e0576e05bd6a9.svg?invert_in_darkmode&sanitize=true" align=middle width=252.75389864999997pt height=39.452455349999994pt/></p>

where <img src="/tex/5e3abe0aa44a39a2ce3748f92fb4ff9f.svg?invert_in_darkmode&sanitize=true" align=middle width=17.67612329999999pt height=14.15524440000002pt/> is the number of releases in zip code <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/> at time <img src="/tex/4f4f4e395762a3af4575de74c019ebb5.svg?invert_in_darkmode&sanitize=true" align=middle width=5.936097749999991pt height=20.221802699999984pt/> and <img src="/tex/47e45884f446bad6d63ae7c0db2088f0.svg?invert_in_darkmode&sanitize=true" align=middle width=42.63139649999999pt height=24.65753399999998pt/> is subtracted to center the transformed values. The inverse hyperbolic sine transformation has the additional benefit that it can be interpreted the same way as a standard log transformation. Specifically, changes in the transformed number of releases can be interpreted as percent changes in the raw number of releases.

Zip code level predictors
=========================

We want our model to account for zip code level predictors that might be predictive of the number of releases. To do so, we merge the DOC data with the Census Bureau's American Community Survey, containing information about poverty and income levels for Census tract groups. We utilize [crosswalk files](https://www.huduser.gov/portal/datasets/usps_crosswalk.html) from the U.S. Department of Housing and Urban Development's Office of Policy Development and Research to relate Philadelphia zip codes to Census tract groups.

From the American Community Survey (ACS), we obtain information about the proportion of households in various states of poverty. Specifically, the ACS has data on the proportion of the population in seven different brackets of income-to-poverty line ratios: [0, 0.5), [0.5, 1), [1, 1.25), [1.25, 1.5), [1.5, 1.85), [1.85, 2), and [2+). For example, the [0.5, 1) bracket represents families with income between <img src="/tex/34cae016d8e4805f60faa6d65887e976.svg?invert_in_darkmode&sanitize=true" align=middle width=30.137091599999987pt height=24.65753399999998pt/> of the poverty line and the poverty line, where the poverty line is determined by the Census Bureau according to the size and number of children of a household.

From this poverty data, we create a single measure of poverty for each zip code by calculating a weighted sum of the proportion of households in each of the seven poverty brackets:

<p align="center"><img src="/tex/fee10c4337bd5b154f384304ccc1f408.svg?invert_in_darkmode&sanitize=true" align=middle width=148.49425965pt height=49.59602339999999pt/></p>

where <img src="/tex/b13b4016eb577e91a0fb6a2fe443b093.svg?invert_in_darkmode&sanitize=true" align=middle width=21.99785444999999pt height=14.15524440000002pt/> is the proportion of households in zip code <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/> that are in poverty bracket <img src="/tex/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710416999999989pt height=21.68300969999999pt/> and <img src="/tex/40cca55dbe7b8452cf1ede03d21fe3ed.svg?invert_in_darkmode&sanitize=true" align=middle width=17.87301779999999pt height=14.15524440000002pt/> is the weight given to poverty bracket <img src="/tex/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710416999999989pt height=21.68300969999999pt/>. We use decreasing weights w = [1, 5/6, 4/6, 3/6, 2/6, 1/6, 0] to give higher poverty brackets more weight. Thus, the poverty measure ranges from 0 to 1, with higher values indicating a higher level of poverty.

For more detail on how all of the above was done, see [link\_doc\_census.R](https://github.com/ericoh17/doc_project/blob/master/link_doc_census.R).

CAR priors to account for spatial correlation
=============================================

Conditional autoregressive (CAR) models are commonly used as prior distributions for spatially correlated random effects with areal spatial data. Let <img src="/tex/702c57473dd1dfd633f77d3e12c4f34d.svg?invert_in_darkmode&sanitize=true" align=middle width=114.85016565pt height=24.65753399999998pt/> be a vector of random elements for n areal locations that are spatially correlated. The CAR model can then be represented using conditional distributions:

<p align="center"><img src="/tex/428f5690ed07e2b884cd19389d8cc88a.svg?invert_in_darkmode&sanitize=true" align=middle width=252.84369495pt height=59.1786591pt/></p>
 where <img src="/tex/64e70e84545b2941bed8aa7fe2211cde.svg?invert_in_darkmode&sanitize=true" align=middle width=22.523917349999987pt height=14.15524440000002pt/> are weights equal to 1 if zip codes <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/> and <img src="/tex/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710416999999989pt height=21.68300969999999pt/> share a border and 0 otherwise and <img src="/tex/e7cdf5013524d24e01bb7ecb5878d45f.svg?invert_in_darkmode&sanitize=true" align=middle width=11.83700594999999pt height=14.15524440000002pt/> is a spatially varying precision parameter.

It can be proved using Brook's Lemma that the joint distribution of <img src="/tex/b2af456716f3117a91da7afe70758041.svg?invert_in_darkmode&sanitize=true" align=middle width=10.274003849999989pt height=22.465723500000017pt/> is given by

<img src="/tex/383a8fdb2529acab0b84e953778bb8a5.svg?invert_in_darkmode&sanitize=true" align=middle width=189.6432219pt height=27.94539330000001pt/>
 where 
 <p align="center"><img src="/tex/7bb8ff74d0db0ee79f2e89fd76f4e07b.svg?invert_in_darkmode&sanitize=true" align=middle width=675.6169563pt height=200.04562545pt/></p>

We can then write the CAR prior as:

<p align="center"><img src="/tex/94d8f7280317392942847607985fd975.svg?invert_in_darkmode&sanitize=true" align=middle width=181.90869014999998pt height=18.312383099999998pt/></p>

Full Bayesian model
===================

We model the transformed number of releases as follows:

<p align="center"><img src="/tex/f6a20c597a7801efa657781e53f5697e.svg?invert_in_darkmode&sanitize=true" align=middle width=179.39564445pt height=17.24382pt/></p>

where <img src="/tex/ec5c3bebb42b5e03d3a7d9084d73796b.svg?invert_in_darkmode&sanitize=true" align=middle width=14.045887349999989pt height=24.7161288pt/> is a design vector of predictor variables for zip code <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/>, <img src="/tex/8217ed3c32a785f0b5aad4055f432ad8.svg?invert_in_darkmode&sanitize=true" align=middle width=10.16555099999999pt height=22.831056599999986pt/> is the vector of coefficients for those predictor variables, <img src="/tex/4f4f4e395762a3af4575de74c019ebb5.svg?invert_in_darkmode&sanitize=true" align=middle width=5.936097749999991pt height=20.221802699999984pt/> represents time, <img src="/tex/e79c36bea376d2763ba9ecf055fc6331.svg?invert_in_darkmode&sanitize=true" align=middle width=15.35871314999999pt height=22.831056599999986pt/> and <img src="/tex/c83e439282bef5aadf55a91521506c1a.svg?invert_in_darkmode&sanitize=true" align=middle width=14.44544309999999pt height=22.831056599999986pt/> are zip code specific intercepts and slopes, and <img src="/tex/22c75a74394a18fd957345b7bb03b9de.svg?invert_in_darkmode&sanitize=true" align=middle width=97.02524864999998pt height=26.76175259999998pt/>. Since we do not expect every zip code to have unique coefficients, we impose CAR priors for <img src="/tex/e79c36bea376d2763ba9ecf055fc6331.svg?invert_in_darkmode&sanitize=true" align=middle width=15.35871314999999pt height=22.831056599999986pt/> and <img src="/tex/c83e439282bef5aadf55a91521506c1a.svg?invert_in_darkmode&sanitize=true" align=middle width=14.44544309999999pt height=22.831056599999986pt/>, resulting in

<p align="center"><img src="/tex/00d4c10e5a8c916464e75da3a323064d.svg?invert_in_darkmode&sanitize=true" align=middle width=165.33449295pt height=47.5834689pt/></p>

where <img src="/tex/664999def175c7521cdb4706c71ef7b3.svg?invert_in_darkmode&sanitize=true" align=middle width=117.86735729999998pt height=24.65753399999998pt/>. The posterior distribution can then be written as follows:

<p align="center"><img src="/tex/46f766c2407afd9f196ac2bad1ad97aa.svg?invert_in_darkmode&sanitize=true" align=middle width=533.5903369499999pt height=47.5834689pt/></p>

We specify the following prior distributions:

<p align="center"><img src="/tex/8b1d32c08ade4f49da6c4ccf58a596f2.svg?invert_in_darkmode&sanitize=true" align=middle width=193.17515415pt height=228.54776174999998pt/></p>

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
tmp_philly_zip <- philly_zip_shape[!(philly_zip_shape<img src="/tex/210cb1db9bc708fbbf6bc7c34bff941d.svg?invert_in_darkmode&sanitize=true" align=middle width=601.63573965pt height=48.85840409999997pt/>CODE)
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
release_by_zip_year_cov <- release_by_zip_year_cov[!(release_by_zip_year_cov<img src="/tex/46dc5e349253638f33c1416152f6df1a.svg?invert_in_darkmode&sanitize=true" align=middle width=901.9853551499999pt height=127.76251290000002pt/>count_tf),  # observed number of cases
                 W = philly_nb_mat)               # adjacency matrix
```

Then, we can fit the model using `rstan`.

``` r
car_mod <- stan('stan/doc_car.stan', data = full_dat, 
                iter = niter, chains = nchains, verbose = FALSE)
```
