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

Conditional autoregressive (CAR) priors

Implementation in Stan
======================
