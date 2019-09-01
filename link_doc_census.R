
# script to create covariates from the census data
# and merge with the DOC data

suppressMessages(suppressWarnings(library(readxl)))
suppressMessages(suppressWarnings(library(dplyr)))
suppressMessages(suppressWarnings(library(tidyr)))

options(scipen = 999)

## poverty data ##
poverty_dat <- read.csv("~/Dropbox/doc_project/data/ACS_17_5YR_C17002_with_ann.csv",
                        header = TRUE, skip = 1)

# remove margin of error cols
poverty_dat <- poverty_dat[,!grepl("Margin.of.Error", colnames(poverty_dat))]

poverty_dat$census_tract <- as.numeric(substr(poverty_dat$Id2, 1, 11))

## income data ##
income_dat <- read.csv("~/Dropbox/doc_project/data/ACS_17_5YR_B19001_with_ann.csv",
                       header = TRUE, skip = 1)

# remove margin of error cols
income_dat <- income_dat[,!grepl("Margin.of.Error", colnames(income_dat))]

income_dat$census_tract <- as.numeric(substr(income_dat$Id2, 1, 11))

# get the census tracts in both 
# covariate datasets
uniq_census_tract <- intersect(unique(poverty_dat$census_tract),
                               unique(income_dat$census_tract))

## table to convert census tracts to zip codes ##
tract_to_zip <- read_excel("~/Dropbox/doc_project/data/TRACT_ZIP_122017.xlsx")

get_zip_highest_total <- function(tract, tract_zip_map) {
  
  # return the tract_to_zip map with the highest total ratio 
  tract_df <- tract_to_zip[tract_to_zip$tract == tract,]
  tract_df <- tract_df[order(-tract_df$tot_ratio),]
  return(tract_df[1,])
  
}

# extract census tract to zip maps
# for tracts in covariate data
tract_zip_df <- do.call(rbind, 
                        lapply(uniq_census_tract,
                               get_zip_highest_total,
                               tract_zip_map = tract_to_zip))

# merge poverty covariate data with 
# tract to zip map
poverty_tract_dat <- merge(poverty_dat,
                           tract_zip_df[,c("tract", "zip")],
                           by.x = "census_tract", by.y = "tract",
                           all.x = TRUE)

# for each zip code, sum up totals of 
# people in each poverty category
poverty_tract_dat <- poverty_tract_dat %>%
  dplyr::select(-c(census_tract, Id, Id2, Geography)) %>%
  dplyr::group_by(zip) %>%
  summarise(total = sum(Estimate..Total.),
            total_under_050 = sum(Estimate..Total....Under..50),
            total_050_099 = sum(Estimate..Total.....50.to..99),
            total_100_124 = sum(Estimate..Total....1.00.to.1.24),
            total_125_149 = sum(Estimate..Total....1.25.to.1.49),
            total_150_184 = sum(Estimate..Total....1.50.to.1.84),
            total_185_199 = sum(Estimate..Total....1.85.to.1.99),
            total_over_200 = sum(Estimate..Total....2.00.and.over)) %>%
  as.data.frame()

# set blocks with total equal to 0 to NA
poverty_tract_dat[which(poverty_tract_dat[,"total"] == 0), "total"] <- NA

# create poverty measure
poverty_prop <- poverty_tract_dat[,3:9]/poverty_tract_dat[,2]
weights_poverty <- (6:0)/6
poverty_tract_dat$poverty_measure <- 
  as.matrix(poverty_prop, 
            nrow = dim(poverty_prop)[1]) %*% weights_poverty 


# merge income covariate data with 
# tract to zip map
income_tract_dat <- merge(income_dat,
                          tract_zip_df[,c("tract", "zip")],
                          by.x = "census_tract", by.y = "tract",
                          all.x = TRUE)

# for each zip code, sum up totals of
# people in each income category
income_tract_dat <- income_tract_dat %>%
  dplyr::select(-c(census_tract, Id, Id2, Geography)) %>%
  dplyr::group_by(zip) %>%
  summarise(total = sum(Estimate..Total.),
            total_under_10000 = sum(Estimate..Total....Less.than..10.000),
            total_10000_14999 = sum(Estimate..Total.....10.000.to..14.999),
            total_15000_19999 = sum(Estimate..Total.....15.000.to..19.999),
            total_20000_24999 = sum(Estimate..Total.....20.000.to..24.999),
            total_25000_29999 = sum(Estimate..Total.....25.000.to..29.999),
            total_30000_34999 = sum(Estimate..Total.....30.000.to..34.999),
            total_35000_39999 = sum(Estimate..Total.....35.000.to..39.999),
            total_40000_44999 = sum(Estimate..Total.....40.000.to..44.999),
            total_45000_49999 = sum(Estimate..Total.....45.000.to..49.999),
            total_50000_59999 = sum(Estimate..Total.....50.000.to..59.999),
            total_60000_74999 = sum(Estimate..Total.....60.000.to..74.999),
            total_75000_99999 = sum(Estimate..Total.....75.000.to..99.999),
            total_100000_124999 = sum(Estimate..Total.....100.000.to..124.999),
            total_125000_149999 = sum(Estimate..Total.....125.000.to..149.999),
            total_150000_199999 = sum(Estimate..Total.....150.000.to..199.999),
            total_over_200000 = sum(Estimate..Total.....200.000.or.more)) %>%
  as.data.frame()

# set blocks with total equal to 0 to NA
income_tract_dat[which(income_tract_dat[,"total"] == 0), "total"] <- NA

# create income measure
income_prop <- income_tract_dat[,3:18]/income_tract_dat[,2]
weights_income <- (15:0)/15
income_tract_dat$income_measure <- as.matrix(income_prop, 
                                             nrow = dim(income_prop)[1]) %*% weights_income 

doc_dat <- read.csv("~/Dropbox/doc_project/data/johnson_doc_data/PhilaLegalZip-Table 1.csv")

doc_dat$ReleaseYear <- as.factor(doc_dat$ReleaseYear)

# get number of releases by zip code and year
num_offense_zip_year  <- doc_dat %>%
  group_by(legal_zip_code, ReleaseYear) %>%
  summarise(count = n()) %>%
  tidyr::complete(ReleaseYear, fill = list(count = 0)) %>%
  as.data.frame()

# merge covariate data with outcome data
release_by_zip_year_cov <- merge(merge(num_offense_zip_year,
                                       poverty_tract_dat[,c("zip", "poverty_measure")],
                                       by.x = "legal_zip_code", 
                                       by.y = "zip"),
                                 income_tract_dat[,c("zip", "income_measure")],
                                 by.x = "legal_zip_code", 
                                 by.y = "zip")

save(release_by_zip_year_cov,
     file = "~/Dropbox/doc_project/cleaned_data/release_by_zip_year_cov.RData")




