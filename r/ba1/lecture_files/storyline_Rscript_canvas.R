###################################
# Storyline                       #
#           Regression Analysis   #
###################################

options(scipen=999)
### Create a new R project for easy read-in and storage of respective files

# this helps a lot in organizing your work and e.g. share it with others 
# fixed alternative would be to set a working directory (setwd(...))


### Read in data

story_line <- read.csv("Storyline_Data.csv")

## Getting to know your data by checking descriptives
str(story_line)


library(psych)
describe(story_line) # psych::describe offers a short overview of descriptive statistics


# visual inspection, e.g histograms (for uni-variate distributions of metric variables)

hist(story_line$Sales)


#plotting sales across time
plot((1:nrow(story_line)),story_line$Sales)


# for more advanced (and nice) graphs, see: https://r4ds.had.co.nz/

# combined uni-, and bi-variate distributions in a matrix graph (helper functions, see end of script)
library(ggplot2)
pairs(story_line,
  upper.panel = panel.cor,
  diag.panel  = panel.hist,
  lower.panel = panel.smooth,
  pch = ".",cex=2)


# code can be found on alternative websites, on e.g.  
# https://r-coder.com/correlation-plot-r/ 
# https://www.r-bloggers.com/2011/03/five-ways-to-visualize-your-pairwise-comparisons/



#####################################################################################################
##	a) First analyze how strong sales correlate with each variable using a correlation analysis. 
### Correlation matrix

cor(story_line) #base R

library(Hmisc)
rcorr(as.matrix(story_line)) # includes respective p-values

#library(apaTables)
#apa.cor.table(story_line) # nicely formatted tables, with CIs

library(corrplot) # correlation plots 
M <- cor(story_line)
corrplot(M, method="circle",diag=FALSE,tl.srt=35)

##################################################################################################################
###	b) Using simple linear regression, determine which of the variables have had the strongest effect on sales. 
###It is sufficient to perform a simple linear regression analysis for only three variables 
###(advertisement spending, quality score of flour, and R&D spending). Should the bakery better invest in 
###advertisement spending, R&D spending or in improving the quality of the flour? 
### Impact of sales, one-by-one


mod0 = lm(Sales ~ Adv_Spending, data = story_line); summary(mod0)

mod1 = lm(Sales ~ RD_spending, data = story_line); summary(mod1)

mod2 = lm(Sales ~ Quality_flour, data = story_line); summary(mod2)


plot(story_line$Sales ~ story_line$Adv_Spending, 
     xlab = "Advertising spending", 
     ylab = "Sales", pch = 20, col = "blue")
abline(mod0, col = "red", lwd = 3)

plot(story_line$Sales ~ story_line$RD_spending, 
     xlab = "R&D spending", 
     ylab = "Sales", pch = 20, col = "blue")
abline(mod1, col = "red", lwd = 3)

plot(story_line$Sales ~ story_line$Quality_flour, 
     xlab = "Quality flour", 
     ylab = "Sales", pch = 20, col = "blue")
abline(mod2, col = "red", lwd = 3)


### Risk by using solely regression analysis for decision making?

# How do you judge the quality of data? Is it a good base for decision making (e.g., reliable, valid)?
# Is the model correctly specified (i.e., its functional form, cf. mixed model slides/ lecturecast)?
# Does the model fit well  (R², visual inspection) and satisfy regression assumptions (use plot())?
# What is your goal: Explanation vs. prediction? 
# What does the quantitative data not cover (missing data, or yet unobserved but accessible variables?)? 
# How much effort would it take (consider attached cost)? 


###Please perform a multiple regression analysis and define a sales equation in the following format: 
### Multiple linear regressions

mreg <- lm(Sales ~ Adv_Spending+RD_spending+Quality_flour, data =story_line)
summary(mreg)


###extra: how would you see in a multiple regression which variables is the most important/leads to largest increases 
#or decreases of DV?

#make z-transformation of variables (ie, adjust their scales)

threevars <- cbind(story_line$Adv_Spending,story_line$RD_spending,story_line$Quality_flour)
summary(threevars)
threevars_Scaled <- scale(threevars)
summary(threevars_Scaled)
mreg_a <- lm(Sales ~ threevars_Scaled, data =story_line)
summary(mreg_a)


#now use all variables

mreg2 <- lm(Sales ~ Adv_Spending+RD_spending+Quality_flour+Num_Employees+Num_Presented_products+Num_Visitors+Num_Transactions+Lead_time,data=story_line )
summary(mreg2)


plot(mreg2) #checking model assumptions graphically 

#reduce to significant variables only

mreg4 <- lm(Sales ~ Adv_Spending+Quality_flour+Num_Visitors+Num_Transactions+Lead_time,data=story_line )
summary(mreg4)

plot(mreg4) #checking model assumptions graphically (cf. model assumptions slides/ lecturecast 8)

## small prediction task

# you need to specify new data for the prediction, which covers all variables in your model used for prediction
# with a large dataset you can also split your data, use one half for developing the model and the second half for validation/ testing

# this code below basically solves our equation with specified values set in (controls set at their mean to represent "a usual week")
new <- data.frame(cbind(Adv_Spending = 1000000000,Quality_flour=0,Num_Visitors=772.45,Num_Transactions=584.41,Lead_time=3.92))
predict(mreg4,newdata = new)

### What about other drivers of potential store success? Trade-off effects?


# with this data, you could also check alternative DVs (and thus answering different questions)
# for example you could see, what drives shop visits, transactions, or sales
# different goals might need different investment strategies
# these differences might create trade-offs, for example increase visits, but reduce sales

mreg5 <- lm(Num_Visitors ~ Adv_Spending+RD_spending+Quality_flour+Num_Employees+Num_Presented_products+Lead_time,data=story_line )

mreg6 <- lm(Num_Transactions ~ Adv_Spending+RD_spending+Quality_flour+Num_Employees+Num_Presented_products+Num_Visitors+Lead_time,data=story_line )

mreg7 <- lm(Sales ~ Adv_Spending+RD_spending+Quality_flour+Num_Employees+Num_Presented_products+Num_Visitors+Num_Transactions+Lead_time,data=story_line )

# let's compare:
summary(mreg5);summary(mreg6);summary(mreg7)

# does this more holistic view change you recommendation made in class?



########################################
########################################

### Helper functions for matrix plot

panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y, use = "complete.obs"))
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt <- paste(prefix, txt, sep = "")
  if (missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex =  cex.cor * (1 + r) / 2)
}

panel.hist <- function(x, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks
  nB <- length(breaks)
  y <- h$counts
  y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col = "white", ...)
}

panel.lm <- function (x, y, col = par("col"), bg = NA, pch = par("pch"),
                      cex = 1, col.smooth = "black", ...) {
  points(x, y, pch = pch, col = col, bg = bg, cex = cex)
  abline(stats::lm(y ~ x),  col = col.smooth, ...)
}
