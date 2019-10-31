DOC CAR model
================
Eric Oh
8/26/2019

We noticed in [doc\_data\_overview.md](https://github.com/ericoh17/doc_project/blob/master/doc_data_overview.md) that there was evidence of spatial correlation in number of releases between neighboring zip codes through Philadelphia. Accounting for this spatial correlation is the focus of the current modeling work.

One of the standard statistics used to assess the strength of this spatial correlation is Moran's <img src="/tex/21fd4e8eecd6bdf1a4d3d6bd1fb8d733.svg?invert_in_darkmode&sanitize=true" align=middle width=8.515988249999989pt height=22.465723500000017pt/>, which is defined as

<p align="center"><img src="/tex/7f92a466144740eb598b2f2f9fca91b5.svg?invert_in_darkmode&sanitize=true" align=middle width=332.2617474pt height=45.5133228pt/></p>
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

where <img src="/tex/5e3abe0aa44a39a2ce3748f92fb4ff9f.svg?invert_in_darkmode&sanitize=true" align=middle width=17.67612329999999pt height=14.15524440000002pt/> is the number of releases in zip code <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/> at time <img src="/tex/4f4f4e395762a3af4575de74c019ebb5.svg?invert_in_darkmode&sanitize=true" align=middle width=5.936097749999991pt height=20.221802699999984pt/> and log(2) is subtracted to center the transformed values. The inverse hyperbolic sine transformation has the additional benefit that it can be interpreted the same way as a standard log transformation. Specifically, changes in the transformed number of releases can be interpreted as percent changes in the raw number of releases.

Zip code level predictors
=========================

We want our model to account for zip code level predictors that might be predictive of the number of releases. To do so, we merge the DOC data with the Census Bureau's American Community Survey, containing information about poverty and income levels for Census tract groups. We utilize [crosswalk files](https://www.huduser.gov/portal/datasets/usps_crosswalk.html) from the U.S. Department of Housing and Urban Development's Office of Policy Development and Research to relate Philadelphia zip codes to Census tract groups.

From the American Community Survey (ACS), we obtain information about the proportion of households in various states of poverty. Specifically, the ACS has data on the proportion of the population in seven different brackets of income-to-poverty line ratios: [0, 0.5), [0.5, 1), [1, 1.25), [1.25, 1.5), [1.5, 1.85), [1.85, 2), and [2+). For example, the [0.5, 1) bracket represents families with income between 50% of the poverty line and the poverty line, where the poverty line is determined by the Census Bureau according to the size and number of children of a household.

From this poverty data, we create a single measure of poverty for each zip code by calculating a weighted sum of the proportion of households in each of the seven poverty brackets:

<p align="center"><img src="/tex/fee10c4337bd5b154f384304ccc1f408.svg?invert_in_darkmode&sanitize=true" align=middle width=148.49425965pt height=49.59602339999999pt/></p>

<img src="/tex/90dff9909748b9a4f696eca310eb4dd5.svg?invert_in_darkmode&sanitize=true" align=middle width=18.09372014999999pt height=14.15524440000002pt/> is the proportion of households in zip code <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/> that are in poverty bracket <img src="/tex/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710416999999989pt height=21.68300969999999pt/> and <img src="/tex/40cca55dbe7b8452cf1ede03d21fe3ed.svg?invert_in_darkmode&sanitize=true" align=middle width=17.87301779999999pt height=14.15524440000002pt/> is the weight given to poverty bracket <img src="/tex/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710416999999989pt height=21.68300969999999pt/>. We use decreasing weights w = [1, 5/6, 4/6, 3/6, 2/6, 1/6, 0] to give higher poverty brackets more weight. Thus, the poverty measure ranges from 0 to 1, with higher values indicating a higher level of poverty.

For more detail on how all of the above was done, see [link\_doc\_census.R](https://github.com/ericoh17/doc_project/blob/master/link_doc_census.R).

CAR priors to account for spatial correlation
=============================================

Conditional autoregressive (CAR) models are commonly used as prior distributions for spatially correlated random effects with areal spatial data. Let <img src="/tex/a2444102b2e61cc97e649c8f1b46bad6.svg?invert_in_darkmode&sanitize=true" align=middle width=114.85016565pt height=24.65753399999998pt/> be a vector of random elements for n areal locations that are spatially correlated. The CAR model can then be represented using conditional distributions:

<p align="center"><img src="/tex/428f5690ed07e2b884cd19389d8cc88a.svg?invert_in_darkmode&sanitize=true" align=middle width=252.84369495pt height=59.1786591pt/></p>
 where <img src="/tex/64e70e84545b2941bed8aa7fe2211cde.svg?invert_in_darkmode&sanitize=true" align=middle width=22.523917349999987pt height=14.15524440000002pt/> are weights equal to 1 if zip codes <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/> and <img src="/tex/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710416999999989pt height=21.68300969999999pt/> share a border and 0 otherwise and <img src="/tex/e7cdf5013524d24e01bb7ecb5878d45f.svg?invert_in_darkmode&sanitize=true" align=middle width=11.83700594999999pt height=14.15524440000002pt/> is a spatially varying precision parameter.

It can be proved using Brook's Lemma that the joint distribution of <img src="/tex/b2af456716f3117a91da7afe70758041.svg?invert_in_darkmode&sanitize=true" align=middle width=10.274003849999989pt height=22.465723500000017pt/> is given by

<img src="/tex/1ee22dc176537c117bae788a8b63811d.svg?invert_in_darkmode&sanitize=true" align=middle width=184.62041895pt height=26.76175259999998pt/> where: 
* <img src="/tex/757e1fcbaeca746399568d2029e0d16a.svg?invert_in_darkmode&sanitize=true" align=middle width=66.85437824999998pt height=22.465723500000017pt/> 
* <img src="/tex/91fa5bca6173108672b5772799fe0dbf.svg?invert_in_darkmode&sanitize=true" align=middle width=100.01389364999999pt height=24.65753399999998pt/>: an <img src="/tex/3add1221abfa79cb14021bc2dacd5725.svg?invert_in_darkmode&sanitize=true" align=middle width=39.82494449999999pt height=19.1781018pt/> diagonal matrix with <img src="/tex/07ccf1b4cf5366428e3b9028a5ad13ee.svg?invert_in_darkmode&sanitize=true" align=middle width=37.25742899999999pt height=14.15524440000002pt/> the number of neighbors for zip code <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/> 
* <img src="/tex/21fd4e8eecd6bdf1a4d3d6bd1fb8d733.svg?invert_in_darkmode&sanitize=true" align=middle width=8.515988249999989pt height=22.465723500000017pt/>: an <img src="/tex/3add1221abfa79cb14021bc2dacd5725.svg?invert_in_darkmode&sanitize=true" align=middle width=39.82494449999999pt height=19.1781018pt/> identity matrix 
* <img src="/tex/6dec54c48a0438a5fcde6053bdb9d712.svg?invert_in_darkmode&sanitize=true" align=middle width=8.49888434999999pt height=14.15524440000002pt/>: parameter controlling spatial dependence (<img src="/tex/eb876e879b1b73f8b10694369588f87e.svg?invert_in_darkmode&sanitize=true" align=middle width=38.63572349999999pt height=21.18721440000001pt/> implies spatial independence and <img src="/tex/64827c82163bd369fa6ca0b567c6e19a.svg?invert_in_darkmode&sanitize=true" align=middle width=38.63572349999999pt height=21.18721440000001pt/> results in an intrinsic conditional autoregressive model) 
* <img src="/tex/dd9c18c46cc50b308593676a404646c2.svg?invert_in_darkmode&sanitize=true" align=middle width=84.73398449999998pt height=26.76175259999998pt/>, the scaled adajency matrix 
* <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/>: the adajency matrix (<img src="/tex/7265484ff4793140cbfe033f69f48680.svg?invert_in_darkmode&sanitize=true" align=middle width=52.02902429999998pt height=21.18721440000001pt/>, <img src="/tex/518f09173c4dfb57e55ab1fce9df76a2.svg?invert_in_darkmode&sanitize=true" align=middle width=53.482629749999994pt height=21.18721440000001pt/> if neighbor; 0 otherwise)

Full Bayesian model
===================

<p align="center"><img src="/tex/5a481403148877e73329d0c17f51e4a6.svg?invert_in_darkmode&sanitize=true" align=middle width=133.0790307pt height=17.24382pt/></p>

where <img src="/tex/ec5c3bebb42b5e03d3a7d9084d73796b.svg?invert_in_darkmode&sanitize=true" align=middle width=14.045887349999989pt height=24.7161288pt/> is a design vector of predictor variables for zip code <img src="/tex/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663225699999989pt height=21.68300969999999pt/> and <img src="/tex/8217ed3c32a785f0b5aad4055f432ad8.svg?invert_in_darkmode&sanitize=true" align=middle width=10.16555099999999pt height=22.831056599999986pt/> is the vector of coefficients for those predictor variables.

Implementation in Stan
======================
