
library(dplyr)
library(ggplot2)
library(margins)

load("r/eda/data/loans.Rdata")
head(loans)

# RQ1: discrimnation against black people when apllying for loans
# hypothesis: black people are more likely to have their loans denied

# Transform Data
loans = loans %>% mutate(
    deny = (s7 == 3), # 1 if denied, 0 if granted
    pi_ration = (s46 / 100), # payment_to_income; is already in a percent, not a ratio
    black = (s13 == 3), # 1 if black person, 0 if different
    .keep = "none" # remove all other variables from dataframe, free up some memory, not necessary for smaller datasets but can be important if dealing with larger datasets
)
head(loans)

# pie chart of applications
loans %>%
    group_by(black) %>%
    summarise(count = n(), denied = sum(deny)) %>%
    ggplot(aes(x="", y=count, fill = black)) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y", start = 0) +
    theme_void()

# bar plot of percentage of denied loans
loans %>%
    group_by(black) %>%
    summarise(count = n(), denied = sum(deny)) %>%
    mutate(percent = denied/count * 100) %>%
    ggplot(aes(x=black, y=percent)) +
    geom_bar(stat = "identity")

# logistic regression
logit1 = glm(deny ~ black, data=loans, family="binomial")
summary(logit1)

margins(logit1) # black people are 19% more likely to have their loan denied

loans %>% 
    group_by(black) %>%
    summarise(mean_pi = mean(pi_ration)) %>%
    ggplot(aes(x=black, y=mean_pi)) + 
    geom_bar(stat = "identity")

logit2 = glm(deny ~ black + pi_ration, data=loans, family="binomial")
summary(logit2)
margins(logit2) 
# if the loan sum increases by 1 yearly income the denial chance increases by 50% (or the chance of acceptance is halved)
# if the person applying is black they have a 16% higher chance of getting denied
