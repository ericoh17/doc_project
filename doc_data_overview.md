---
title: "DOC data overview"
author: "Eric Oh"
date: "8/13/2019" 
output: 
  html_document:
    keep_md: true
---

This document summarizes key variables from the Philadelphia Department of Corrections (DOC) data. The dataset represents incarcerated person releases from 2007-2016 throughout the Philadelphia area.  




# Zip codes

Let's take a look at from which zip codes the most releases occured.


```r
zip_code_freq <- data.frame(table(doc_dat$legal_zip_code))
colnames(zip_code_freq) <- c("Zip_code", "Frequency")
zip_code_freq <- zip_code_freq[order(zip_code_freq$Frequency,
                                     decreasing = TRUE),]
zip_code_freq$Percent <- (zip_code_freq$Frequency / sum(zip_code_freq$Frequency)) * 100

kable(zip_code_freq[1:10,], row.names = FALSE) %>% kable_styling(position = "center")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Zip_code </th>
   <th style="text-align:right;"> Frequency </th>
   <th style="text-align:right;"> Percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 19124 </td>
   <td style="text-align:right;"> 5590 </td>
   <td style="text-align:right;"> 11.654331 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19134 </td>
   <td style="text-align:right;"> 3851 </td>
   <td style="text-align:right;"> 8.028771 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19140 </td>
   <td style="text-align:right;"> 2974 </td>
   <td style="text-align:right;"> 6.200354 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19133 </td>
   <td style="text-align:right;"> 2875 </td>
   <td style="text-align:right;"> 5.993954 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19132 </td>
   <td style="text-align:right;"> 2539 </td>
   <td style="text-align:right;"> 5.293443 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19143 </td>
   <td style="text-align:right;"> 2273 </td>
   <td style="text-align:right;"> 4.738872 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19121 </td>
   <td style="text-align:right;"> 2194 </td>
   <td style="text-align:right;"> 4.574169 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19129 </td>
   <td style="text-align:right;"> 1740 </td>
   <td style="text-align:right;"> 3.627645 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19120 </td>
   <td style="text-align:right;"> 1573 </td>
   <td style="text-align:right;"> 3.279475 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 19139 </td>
   <td style="text-align:right;"> 1568 </td>
   <td style="text-align:right;"> 3.269050 </td>
  </tr>
</tbody>
</table>

## Zip code plot


```r
# plot all zip codes with more than 1000 releases
# and group all others in OTHER category

#zip_code_plot_dat <- zip_code_freq[zip_code_freq$Frequency >= 1000,]

#zip_code_others <- data.frame(Zip_code = "Other",
#                              Frequency = sum(zip_code_freq$Frequency[zip_code_freq$Frequency < 1000]),
#                              Percent = 0)

#zip_code_plot_dat <- data.frame(rbind(zip_code_plot_dat, zip_code_others))
```

Comparing the number of releases across zip codes visually. 


```r
zip_code_plot_dat <- zip_code_freq[1:10,]
zip_code_plot_dat$Zip_code <- factor(zip_code_plot_dat$Zip_code, 
                                     levels = zip_code_plot_dat$Zip_code[order(-zip_code_plot_dat$Percent)])

ggplot(zip_code_plot_dat, aes(x = Zip_code, y = Frequency)) + 
  geom_bar(stat = "identity", fill = "#599ad3") +
  xlab("Zip code") + ylab("Frequency") + 
  ggtitle("Most frequent zip codes with offenses (only shows those with > 1000)") + 
  theme_hc()
```

<img src="doc_data_overview_files/figure-html/unnamed-chunk-4-1.png" style="display: block; margin: auto;" />


## Zip code over time

The three zip codes that had the most number of releases is 19124, 19134, and 19140. Let's see if the number of releases has varied much over time. 


```r
# plot trend of releases from top three zip codes
top_three_zip <- c(19124, 19134, 19140)
zip_code_trend <- doc_dat[,c("ReleaseYear", "legal_zip_code")]
zip_code_trend <- zip_code_trend[zip_code_trend$legal_zip_code %in% top_three_zip,]

zip_code_trend_count  <- zip_code_trend %>%
  group_by(ReleaseYear, legal_zip_code) %>%
  count(ReleaseYear) %>%
  as.data.frame()

ggplot(zip_code_trend_count,
       aes(x = as.factor(ReleaseYear), y = n, 
           colour = as.factor(legal_zip_code), 
           group = as.factor(legal_zip_code))) +
  geom_line() + 
  geom_point(size = 2.5) + 
  scale_colour_manual(values = c("#00AFBB", "#E7B800", "#FC4E07")) +
  labs(x = "Release year", y = "Number of releases", colour = "Zip codes") + 
  theme_minimal()
```

<img src="doc_data_overview_files/figure-html/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

# Race

Let's take a look at the distribution of different races amongst all offenses.


```r
race_freq <- data.frame(table(doc_dat$race))
colnames(race_freq) <- c("Race", "Frequency")
race_freq <- race_freq[order(race_freq$Frequency,
                             decreasing = TRUE),]
race_freq$Percent <- (race_freq$Frequency / sum(race_freq$Frequency)) * 100

kable(race_freq, row.names = FALSE) %>% kable_styling(position = "center")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Race </th>
   <th style="text-align:right;"> Frequency </th>
   <th style="text-align:right;"> Percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> BLACK </td>
   <td style="text-align:right;"> 34096 </td>
   <td style="text-align:right;"> 71.0851663 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> HISPANIC </td>
   <td style="text-align:right;"> 6991 </td>
   <td style="text-align:right;"> 14.5752111 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> WHITE </td>
   <td style="text-align:right;"> 6588 </td>
   <td style="text-align:right;"> 13.7350151 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> OTHER </td>
   <td style="text-align:right;"> 147 </td>
   <td style="text-align:right;"> 0.3064735 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ASIAN </td>
   <td style="text-align:right;"> 128 </td>
   <td style="text-align:right;"> 0.2668613 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AMERICAN INDIAN </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 0.0312728 </td>
  </tr>
</tbody>
</table>


# Sex

Let's take a look at the distribution of sex amongst all offenses.


```r
sex_freq <- data.frame(table(doc_dat$sex))
colnames(sex_freq) <- c("Sex", "Frequency")
sex_freq <- sex_freq[order(sex_freq$Frequency,
                             decreasing = TRUE),]
sex_freq$Percent <- (sex_freq$Frequency / sum(sex_freq$Frequency)) * 100

kable(sex_freq, row.names = FALSE) %>% kable_styling(position = "center")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Sex </th>
   <th style="text-align:right;"> Frequency </th>
   <th style="text-align:right;"> Percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> MALE </td>
   <td style="text-align:right;"> 45489 </td>
   <td style="text-align:right;"> 94.837903 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FEMALE </td>
   <td style="text-align:right;"> 2476 </td>
   <td style="text-align:right;"> 5.162097 </td>
  </tr>
</tbody>
</table>


# Offenses

More unique offense codes than offenses..what is going on?

What are the most frequent offenses?


```r
offense_freq <- data.frame(table(doc_dat$offense))
colnames(offense_freq) <- c("Offense", "Frequency")
offense_freq <- offense_freq[order(offense_freq$Frequency,
                             decreasing = TRUE),]
offense_freq$Percent <- (offense_freq$Frequency / sum(offense_freq$Frequency)) * 100

kable(offense_freq[1:10,], row.names = FALSE) %>% kable_styling(position = "center")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Offense </th>
   <th style="text-align:right;"> Frequency </th>
   <th style="text-align:right;"> Percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> DRUG - MANUFACTURE/SALE/DELIVER OR POSSESS W/INTENT TO </td>
   <td style="text-align:right;"> 16483 </td>
   <td style="text-align:right;"> 34.364641 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ROBBERY (GENERAL) </td>
   <td style="text-align:right;"> 4490 </td>
   <td style="text-align:right;"> 9.360992 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AGGRAVATED ASSAULT (GENERAL) </td>
   <td style="text-align:right;"> 3014 </td>
   <td style="text-align:right;"> 6.283749 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ROBBERY </td>
   <td style="text-align:right;"> 2825 </td>
   <td style="text-align:right;"> 5.889711 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AGGRAVATED ASSAULT </td>
   <td style="text-align:right;"> 1676 </td>
   <td style="text-align:right;"> 3.494215 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PERSONS NOT TO POSSESS, USE, ETC. FIREARMS </td>
   <td style="text-align:right;"> 1639 </td>
   <td style="text-align:right;"> 3.417075 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BURGLARY </td>
   <td style="text-align:right;"> 1392 </td>
   <td style="text-align:right;"> 2.902116 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BURGLARY (GENERAL) </td>
   <td style="text-align:right;"> 1391 </td>
   <td style="text-align:right;"> 2.900031 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FIREARM NOT TO BE CARRIED W/O LICENSE </td>
   <td style="text-align:right;"> 1339 </td>
   <td style="text-align:right;"> 2.791619 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MURDER (3RD DEGREE) </td>
   <td style="text-align:right;"> 1089 </td>
   <td style="text-align:right;"> 2.270405 </td>
  </tr>
</tbody>
</table>

There seem to be different versions of some offenses (ie. robbery vs. robbery (general)). Not sure what this is. But let's combine them and then recalculate. 


```r
offense_agg <- doc_dat %>%
  mutate(offense = trimws(offense),
         offense = str_replace(offense, " \\(GENERAL\\)", ""))

offense_agg_freq <- data.frame(table(offense_agg$offense))
colnames(offense_agg_freq) <- c("Offense", "Frequency")
offense_agg_freq <- offense_agg_freq[order(offense_agg_freq$Frequency,
                             decreasing = TRUE),]
offense_agg_freq$Percent <- (offense_agg_freq$Frequency / sum(offense_agg_freq$Frequency)) * 100

kable(offense_agg_freq[1:10,], row.names = FALSE) %>% kable_styling(position = "center")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Offense </th>
   <th style="text-align:right;"> Frequency </th>
   <th style="text-align:right;"> Percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> DRUG - MANUFACTURE/SALE/DELIVER OR POSSESS W/INTENT TO </td>
   <td style="text-align:right;"> 16483 </td>
   <td style="text-align:right;"> 34.364641 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ROBBERY </td>
   <td style="text-align:right;"> 7315 </td>
   <td style="text-align:right;"> 15.250704 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AGGRAVATED ASSAULT </td>
   <td style="text-align:right;"> 4690 </td>
   <td style="text-align:right;"> 9.777963 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BURGLARY </td>
   <td style="text-align:right;"> 2783 </td>
   <td style="text-align:right;"> 5.802147 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PERSONS NOT TO POSSESS, USE, ETC. FIREARMS </td>
   <td style="text-align:right;"> 1639 </td>
   <td style="text-align:right;"> 3.417075 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FIREARM NOT TO BE CARRIED W/O LICENSE </td>
   <td style="text-align:right;"> 1339 </td>
   <td style="text-align:right;"> 2.791619 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MURDER (3RD DEGREE) </td>
   <td style="text-align:right;"> 1089 </td>
   <td style="text-align:right;"> 2.270405 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> RETAIL THEFT - TAKE MERCHANDISE </td>
   <td style="text-align:right;"> 826 </td>
   <td style="text-align:right;"> 1.722089 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> RECEIVING STOLEN PROPERTY </td>
   <td style="text-align:right;"> 603 </td>
   <td style="text-align:right;"> 1.257167 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> THEFT MOVABLE PROPERTY </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 1.240488 </td>
  </tr>
</tbody>
</table>

## Offenses plot

Now let's look at which offenses were most common amongst released persons.


```r
offense_plot_dat <- offense_freq[offense_freq$Frequency >= 1000,]

offense_plot_dat_agg <- do.call(rbind, lapply(c('ROBBERY', 'ASSAULT', 'BURGLARY'),
                                function(x) {
         temp_df <- offense_plot_dat[grep(x, offense_plot_dat$Offense, ignore.case=TRUE),]
         data.frame(Offense = x, 
                    Frequency = sum(temp_df$Frequency), 
                    Percent = sum(temp_df$Percent))}))

offense_plot_dat_agg <- rbind(offense_plot_dat_agg, 
                              offense_plot_dat[c(1, 6, 9, 10),])

offense_plot_dat_agg$Offense <- factor(offense_plot_dat_agg$Offense,
                                       levels = offense_plot_dat_agg$Offense[order(-offense_plot_dat_agg$Percent)])

ggplot(offense_plot_dat_agg, aes(x = Offense, y = Frequency)) + 
  geom_bar(stat = "identity", fill = "#599ad3") +
  scale_x_discrete(labels = c("Drugs", "Robbery", "Assault",
                              "Burglary", "Use\nof Firearm", 
                              "Firearm\nw/o license", "Murder\n(3rd degree)")) + 
  xlab("Offense") + ylab("Frequency") + 
  ggtitle("Most frequent offenses") + 
  theme_hc()
```

<img src="doc_data_overview_files/figure-html/unnamed-chunk-10-1.png" style="display: block; margin: auto;" />

## Offenses by zip code

The most common offenses and their frequencies in the five zip codes with most releases.


```r
most_common_zip <- c(19124, 19134, 19140,
                     19133, 19132)

# remove white space at the end of the factor 
# level label and remove (GENERAL) 
# to aggregate with non-general ones
offense_by_zip_dat <- doc_dat[doc_dat$legal_zip_code %in% most_common_zip, 
                              c("legal_zip_code", "offense")] %>%
  mutate(offense = trimws(offense),
         offense = str_replace(offense, " \\(GENERAL\\)", ""))

offense_by_zip_dat <- offense_by_zip_dat %>%
  group_by(legal_zip_code, offense) %>%
  summarise(count = n()) %>%
  filter(row_number(desc(count)) < 4) %>%
  as.data.frame()

ggplot(offense_by_zip_dat,
       aes(x = as.factor(legal_zip_code), y = count, 
           fill = offense)) + 
  geom_bar(position = "dodge", stat = "identity") + 
  labs(x = "Zip code", y = "Count of offenses",
       fill = "Offense") + 
  scale_fill_manual(values = c("#00AFBB", "#E7B800", "#FC4E07"),
                    labels = c("Aggravated assault",
                                 "Drug sale",
                                 "Robbery")) + 
  ggtitle("Count of most frequent offenses in the top 5 zip codes") + 
  theme_minimal()
```

<img src="doc_data_overview_files/figure-html/unnamed-chunk-11-1.png" style="display: block; margin: auto;" />


## Classify offenses

We can also classify the offenses into violent or non-violent. We consider violent crimes to be robbery, assault, murder, rape, manslaughter, homicide, kidnapping, or any other crimes resulting in bodily injury or death.


```r
violent_keywords <- c("ROBBERY", "ASSAULT", "MURDER",
                      "RAPE", "SEXUAL", "MANSLAUGHTER",
                      "BODILY", "KIDNAPPING", "HOMICIDE",
                      "DEATH")
not_violent_keyword <- c("VEHICLES")

doc_dat$violent_crime <- as.numeric(str_detect(doc_dat$offense, 
                                               paste(violent_keywords, collapse="|")))

violent_crime_trend <- doc_dat[,c("ReleaseYear", "violent_crime")]

violent_crime_trend_count  <- violent_crime_trend %>%
  group_by(ReleaseYear, violent_crime) %>%
  #filter(violent_crime == 1) %>%
  count(ReleaseYear) %>%
  as.data.frame()

ggplot(violent_crime_trend_count,
       aes(x = as.factor(ReleaseYear), y = n, 
           colour = as.factor(violent_crime), 
           group = as.factor(violent_crime))) +
  geom_line() + 
  geom_point(size = 2.5) + 
  scale_colour_manual(values = c("#00AFBB", "#E7B800"),
                      labels = c("Non-violent", "Violent")) +
  labs(x = "Release year", y = "Number of releases", 
       colour = "Type of crime") + 
  theme_minimal()
```

<img src="doc_data_overview_files/figure-html/unnamed-chunk-12-1.png" style="display: block; margin: auto;" />

# Priors

Now let's take a look at the distribution of prior incarcerations for persons released in the data.


```r
prior_freq <- data.frame(table(doc_dat$Prior.Incs))
colnames(prior_freq) <- c("Prior_incarcerations", "Frequency")
prior_freq <- prior_freq[order(prior_freq$Frequency,
                             decreasing = TRUE),]
prior_freq$Percent <- (prior_freq$Frequency / sum(prior_freq$Frequency)) * 100

kable(prior_freq, row.names = FALSE) %>% kable_styling(position = "center")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Prior_incarcerations </th>
   <th style="text-align:right;"> Frequency </th>
   <th style="text-align:right;"> Percent </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 22142 </td>
   <td style="text-align:right;"> 46.2747393 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 10564 </td>
   <td style="text-align:right;"> 22.0777864 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:right;"> 6527 </td>
   <td style="text-align:right;"> 13.6408284 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 3913 </td>
   <td style="text-align:right;"> 8.1778094 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:right;"> 2259 </td>
   <td style="text-align:right;"> 4.7211018 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:right;"> 1261 </td>
   <td style="text-align:right;"> 2.6353738 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:right;"> 647 </td>
   <td style="text-align:right;"> 1.3521704 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:right;"> 297 </td>
   <td style="text-align:right;"> 0.6207026 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:right;"> 146 </td>
   <td style="text-align:right;"> 0.3051265 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 9 </td>
   <td style="text-align:right;"> 66 </td>
   <td style="text-align:right;"> 0.1379339 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 0.0438881 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0.0083596 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0020899 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0020899 </td>
  </tr>
</tbody>
</table>

## Priors plot

We can view the distribution of priors visually as well. 


```r
prior_plot_dat <- prior_freq[prior_freq$Frequency >= 297,]

prior_others <- data.frame(Prior_incarcerations = ">7",
                           Frequency = sum(prior_freq$Frequency[prior_freq$Frequency < 297]),
                           Percent = 0)

prior_plot_dat <- data.frame(rbind(prior_plot_dat, prior_others))
prior_plot_dat$Prior_incarcerations <- factor(prior_plot_dat$Prior_incarcerations, 
                                     levels = prior_plot_dat$Prior_incarcerations[order(-prior_plot_dat$Percent)])

ggplot(prior_plot_dat, aes(x = Prior_incarcerations, y = Frequency)) + 
  geom_bar(stat = "identity", fill = "#599ad3") +
  xlab("Prior incarcerations") + ylab("Frequency") + 
  ggtitle("Most frequent number of prior incarcerations") + 
  theme_hc()
```

<img src="doc_data_overview_files/figure-html/unnamed-chunk-14-1.png" style="display: block; margin: auto;" />


# Sentencing lengths

Let's investigate the lengths of sentenences for all releases and what proportion of the maximum sentence they served. Summaries of the sentence lengths and proportion of maximum sentence served are given below. 

Are offenses in 19124 older min sentencing dates? Maybe more people in 19124 were incaracerated back in 80s?
Calculate sentence lengths. Tabulate by zip code?
Calculate proportion of max sentence length they served.


```r
doc_dat$release_date_format <- parse_date_time(doc_dat$ReleaseDate,
                                               orders = c('d-m-y'))

doc_dat$min_sent_date_format <- parse_date_time(doc_dat$MinDate,
                                                orders = c('d-m-y'))

doc_dat$min_sent_year <- year(doc_dat$min_sent_date_format)

doc_dat$max_sent_date_format <- parse_date_time(doc_dat$MaxDt,
                                                orders = c('d-m-y'))

doc_dat$sentence_length <- time_length(interval(doc_dat$min_sent_date_format,
                                                doc_dat$release_date_format),
                                       "year") + 
  (doc_dat$MinSentYrs + doc_dat$MinSentMos/12)

doc_dat$prop_max_sent_served <- doc_dat$sentence_length / (doc_dat$MaxSentYrs + doc_dat$MaxSentMos/12)

sentence_summary_dat <- do.call(rbind, 
                                lapply(doc_dat[, c("min_sent_year",
                                                   "sentence_length",
                                                   "prop_max_sent_served")],
                                       summary))

kable(sentence_summary_dat, row.names = FALSE) %>% kable_styling(position = "center")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> Min. </th>
   <th style="text-align:right;"> 1st Qu. </th>
   <th style="text-align:right;"> Median </th>
   <th style="text-align:right;"> Mean </th>
   <th style="text-align:right;"> 3rd Qu. </th>
   <th style="text-align:right;"> Max. </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1973.000000 </td>
   <td style="text-align:right;"> 2007.0000000 </td>
   <td style="text-align:right;"> 2010.0000000 </td>
   <td style="text-align:right;"> 2009.6751798 </td>
   <td style="text-align:right;"> 2013.0000000 </td>
   <td style="text-align:right;"> 2066.00000 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -8.951370 </td>
   <td style="text-align:right;"> 2.0970320 </td>
   <td style="text-align:right;"> 3.9071038 </td>
   <td style="text-align:right;"> 5.5504113 </td>
   <td style="text-align:right;"> 6.9260274 </td>
   <td style="text-align:right;"> 42.24658 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -2.775685 </td>
   <td style="text-align:right;"> 0.5004566 </td>
   <td style="text-align:right;"> 0.6211293 </td>
   <td style="text-align:right;"> 0.6968793 </td>
   <td style="text-align:right;"> 0.9637978 </td>
   <td style="text-align:right;"> 10.41393 </td>
  </tr>
</tbody>
</table>


## Plot sentence lengths in top 5 zip codes

Distributions of sentence lengths in the top 5 zip codes. 


```r
sentence_length_dat <- doc_dat[doc_dat$legal_zip_code %in% most_common_zip,]
sentence_length_by_zip <- sentence_length_dat[,c("legal_zip_code", "sentence_length",
                                                 "prop_max_sent_served")]

sentence_length_by_zip$legal_zip_code <- factor(sentence_length_by_zip$legal_zip_code,
                                                levels = most_common_zip)

ggplot(sentence_length_by_zip,
       aes(x = as.factor(legal_zip_code), y = sentence_length)) +
  geom_boxplot() + 
  labs(x = "Zip code", y = "Sentence length") + 
  ggtitle("Boxplots of sentence length for the top zip codes") + 
  theme_minimal()
```

<img src="doc_data_overview_files/figure-html/unnamed-chunk-16-1.png" style="display: block; margin: auto;" />


Distributions of proportion of maximum sentence served in the top 5 zip codes. 


```r
ggplot(sentence_length_by_zip,
       aes(x = as.factor(legal_zip_code), y = prop_max_sent_served)) +
  geom_boxplot() + 
  labs(x = "Zip code", y = "Proportion of maximum sentence served") + 
  ggtitle("Boxplots of proportion of max sentence for the top zip codes") + 
  theme_minimal()
```

<img src="doc_data_overview_files/figure-html/unnamed-chunk-17-1.png" style="display: block; margin: auto;" />

