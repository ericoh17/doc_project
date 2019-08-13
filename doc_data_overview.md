Doc data overview
================
Eric Oh
8/13/2019

``` r
library(ggplot2)
library(ggthemes)

doc_dat <- read.csv("~/Dropbox/doc_project/data/johnson_doc_data/PhilaLegalZip-Table 1.csv")
#doc_dat2 <- read.csv("~/Dropbox/doc_project/johnson_doc_data/PhilaCommittingCounty-Table 1.csv")
```

Zip codes
=========

``` r
zip_code_freq <- data.frame(table(doc_dat$legal_zip_code))
colnames(zip_code_freq) <- c("Zip_code", "Frequency")
zip_code_freq <- zip_code_freq[order(zip_code_freq$Frequency,
                                     decreasing = TRUE),]
zip_code_freq$Percent <- (zip_code_freq$Frequency / sum(zip_code_freq$Frequency)) * 100
```

Zip code plot
-------------

``` r
zip_code_plot_dat <- zip_code_freq[zip_code_freq$Frequency >= 1000,]

zip_code_others <- data.frame(Zip_code = "Other",
                              Frequency = sum(zip_code_freq$Frequency[zip_code_freq$Frequency < 1000]),
                              Percent = 0)

zip_code_plot_dat <- data.frame(rbind(zip_code_plot_dat, zip_code_others))
zip_code_plot_dat$Zip_code <- factor(zip_code_plot_dat$Zip_code, 
                                     levels = zip_code_plot_dat$Zip_code[order(-zip_code_plot_dat$Percent)])

ggplot(zip_code_plot_dat, aes(x = Zip_code, y = Frequency)) + 
  geom_bar(stat = "identity", fill = "#599ad3") +
  xlab("Zip code") + ylab("Frequency") + 
  ggtitle("Most frequent zip codes with offenses (only shows those with > 1000)") + 
  theme_hc()
```

![](doc_data_overview_files/figure-markdown_github/unnamed-chunk-3-1.png)

Race
====

``` r
race_freq <- data.frame(table(doc_dat$race))
colnames(race_freq) <- c("Race", "Frequency")
race_freq <- race_freq[order(race_freq$Frequency,
                             decreasing = TRUE),]
race_freq$Percent <- (race_freq$Frequency / sum(race_freq$Frequency)) * 100
```

Sex
===

``` r
sex_freq <- data.frame(table(doc_dat$sex))
colnames(sex_freq) <- c("Sex", "Frequency")
sex_freq <- sex_freq[order(sex_freq$Frequency,
                             decreasing = TRUE),]
sex_freq$Percent <- (sex_freq$Frequency / sum(sex_freq$Frequency)) * 100
```

Offenses
========

More unique offense codes than offenses..what is going on?

Separate into violent and non-violent crime? Add other category? What is difference between general and non-general (ie. robbery (general) vs robbery)?

``` r
offense_freq <- data.frame(table(doc_dat$offense))
colnames(offense_freq) <- c("Offense", "Frequency")
offense_freq <- offense_freq[order(offense_freq$Frequency,
                             decreasing = TRUE),]
offense_freq$Percent <- (offense_freq$Frequency / sum(offense_freq$Frequency)) * 100
```

Offenses plot
-------------

``` r
offense_plot_dat <- offense_freq[offense_freq$Frequency >= 1000,]

#offense_others <- data.frame(Offense = "Other",
#                             Frequency = sum(offense_freq$Frequency[offense_freq$Frequency < 1000]),
#                             Percent = 0)

#offense_plot_dat <- data.frame(rbind(offense_plot_dat, offense_others))
offense_plot_dat$Offense <- factor(offense_plot_dat$Offense, 
                                     levels = offense_plot_dat$Offense[order(-offense_plot_dat$Percent)])

addline_format <- function(x,...){
    gsub('\\s','\n',x)
}

ggplot(offense_plot_dat, aes(x = Offense, y = Frequency)) + 
  geom_bar(stat = "identity", fill = "#599ad3") +
  scale_x_discrete(breaks = offense_plot_dat$Offense,
                   labels = addline_format(offense_plot_dat$Offense)) + 
  xlab("Offense") + ylab("Frequency") + 
  ggtitle("Most frequent offenses (only shows those with > 1000)") + 
  theme_hc()
```

![](doc_data_overview_files/figure-markdown_github/unnamed-chunk-7-1.png)

Priors
======

``` r
prior_freq <- data.frame(table(doc_dat$Prior.Incs))
colnames(prior_freq) <- c("Prior_incarcerations", "Frequency")
prior_freq <- prior_freq[order(prior_freq$Frequency,
                             decreasing = TRUE),]
prior_freq$Percent <- (prior_freq$Frequency / sum(prior_freq$Frequency)) * 100
```

Priors plot
-----------

``` r
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

![](doc_data_overview_files/figure-markdown_github/unnamed-chunk-9-1.png)