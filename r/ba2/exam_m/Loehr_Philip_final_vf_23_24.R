###########################################
##    BA II -- FINAL EXAM // 17.01.24    ##
###########################################

## TOTAL  /40


##EX1     /13

#1.   /2

#2.   /2

#3.   /1

#4.   /4

#5.   /4


##EX2     /10


##EX3     /11

#1.   /1
#2.   /3
#3.   /3
#4.   /2
#5.   /2

##EX4     /6
#1.   /3
#2.   /3

# ------------------------------------------------------------------------------------------------------------

## Libraries
library(zoo)
library(xts)
library(lubridate)
library(colorspace)
library(moments)
library(ggplot2)

## Load the data
load("final_data.RData")


###########################################
##              Exercise 1               ##
###########################################



#------------------------------------------------------------------------------------------------------------
## 1)
data1_xts <- xts(data1[,-1], order.by = as.Date(data1$date), format = "%Y-%m-%d")



#------------------------------------------------------------------------------------------------------------
## 2)
data1_xts <- na.approx(data1_xts)





#------------------------------------------------------------------------------------------------------------
## 3)
dailyreturns <- data1_xts / lag(data1_xts ) - 1






#------------------------------------------------------------------------------------------------------------
## 4)
quantiles <- apply(dailyreturns, 2, function(x) quantile(x, probs = c(0.1, 0.9), na.rm = TRUE))

# replacing the quantile values
data1_capped <- apply(dailyreturns, 2, function(x, quants) {
  x[x < quants[1]] <-NA # sets values of x smaller than it to the lower extreme value
  x[x > quants[2]] <- NA # sets values of x bigger than it to the lower extreme value
  return(x)
}, quants = quantiles)

# converting it back to xts
data1_capped <- xts(data1_capped, order.by = as.Date(data1$date), format = "%Y-%m-%d")




#------------------------------------------------------------------------------------------------------------
## 5)
annual_returns <- apply.yearly(dailyreturns, function(x) prod(1 + na.omit(x)) - 1)







###########################################
##              Exercise 2               ##
###########################################

# P = FV/(1+YTM/100)^n
maturities <- data2$maturity
yields <- data2$yield_pa

price <- c()

for(i in 1: length(maturities)){
  price[i] <- 1/(1+yields[i]/100)^maturities[i]
}

#------------------------------------------------------------------------------------------------------------
# Data frame:

data.frame(maturities, price)

bond_data <- data.frame(Maturity = maturities, Price = price)

#------------------------------------------------------------------------------------------------------------
# Verbal answer:

# To answer if the bond trades at premium, par or discount it is essential to know that:
# Price > Face Value -> premium
# Price = Face Value -> par
# Price < Face Value -> discount

# Determine the trading status of the bonds
bond_data$Status <- ifelse(bond_data$Price < 100, "Discount", 
                           ifelse(bond_data$Price > 100, "Premium", "Par"))

# Print the resulting data frame
print(bond_data)






###########################################
##              Exercise 3               ##
###########################################

# converting to xts
data3 <- xts(data3[,-1], order.by = as.Date(data3$date), format = "%Y-%m-%d")
dr_stocks <- data3 # for easier of the code understanding later


#------------------------------------------------------------------------------------------------------------
## 1)
# this constructs the equally weighted portfolio 
dr_pf <- xts(rowMeans(dr_stocks), order.by=time(dr_stocks))




#------------------------------------------------------------------------------------------------------------
## 2)

#a) Volatility
volatility_pf <- sd(dr_pf) # Portfolio volatility
volatility_stocks <- apply(dr_stocks, 2, sd) # individual stock volatilities

#b) VaR
VaR_pf <- quantile(dr_pf, probs = 0.01, na.rm=TRUE)
print(VaR_pf) # Portfolio VaR

VaR_stocks <- apply(dr_stocks, 2, function(x) quantile(x, probs = 0.01, na.rm = TRUE))
print(VaR_stocks) # Individual stocks VaR

#c) ES (expected shortfall)
ES_pf <- mean(dr_pf[dr_pf < VaR_pf ]) # Portfolio
print(ES_pf)

# Individual Stocks
ES <- c()
for(i in 1: ncol(dr_stocks)){
  r <- dr_stocks[,i] # for easier handeling
  ES[i] <- mean(r[r<VaR_stocks[i]]) # compute ES for each
}
names(ES) <- colnames(dr_stocks) # assign the names back
ES

#------------------------------------------------------------------------------------------------------------
## 3)

# Converting the data into a suitable format for ggplot
data_for_plot <- data.frame(
  Stock = c(names(VaR_stocks), "Portfolio"),
  VaR = c(VaR_stocks, VaR_pf),
  ES = c(ES, ES_pf)
)

# Adding volatility to the data_for_plot dataframe
data_for_plot$Volatility <- c(volatility_stocks, volatility_pf)

# Volatility Plot
ggplot(data_for_plot, aes(x = Stock, y = Volatility, fill = Stock == "Portfolio")) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Volatility Comparison", x = "Stock", y = "Volatility") +
  coord_flip()

# VaR Plot
ggplot(data_for_plot, aes(x = Stock, y = VaR, fill = Stock == "Portfolio")) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Value at Risk (VaR) Comparison", x = "Stock", y = "VaR") +
  coord_flip()

# ES Plot
ggplot(data_for_plot, aes(x = Stock, y = ES, fill = Stock == "Portfolio")) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Expected Shortfall (ES) Comparison", x = "Stock", y = "ES") +
  coord_flip()



#------------------------------------------------------------------------------------------------------------
## 4)
# The concept of diversification is based on the principle that a portfolio of
# different kinds of investments will, on average, yield higher returns and pose
# a lower risk than any individual investment found within the portfolio. 
# The main idea is that the various assets in a portfolio will not perform the 
# same way at the same time. When some investments are down, others may be up, 
# thus a diversified portfolio tends to have less volatile returns over time.

# From the plots we can easily observe that the volatility, expected shortfall and VaR
# of the equally weighted portfolio (marked in blue) is lower than the values of the same measures
# all of the individual stocks, expect one.

# This suggests a huge diversification effect. This happens because while individual
# stock prices can be quite risky, when combined, the ups and downs can cancel
# each other out to some extent, leading to a smoother overall performance for 
# the portfolio.




#------------------------------------------------------------------------------------------------------------
## 5)
# My primary concern would be Predictive Accuracy.
# As these metrics assume that past patterns and volatility will continue, which
# may not always be the case. Especially for VaR and ES, which are highly sensitive
# to extreme events that might not be well-represented in the historical data.







###########################################
##              Exercise 4               ##
###########################################



#------------------------------------------------------------------------------------------------------------
## 1)
# Calculate excess returns
excess_return_market <- data4$r_mkt - data4$RF
excess_return_health <- data4$r_health - data4$RF

# Perform linear regression to estimate CAPM beta and alpha
capm_model <- lm(excess_return_health ~ excess_return_market)

# Extract beta (slope) and alpha (intercept) from the model
beta_health <- coef(capm_model)["excess_return_market"]
alpha_health <- coef(capm_model)["(Intercept)"]

# Print beta and alpha
print(paste("CAPM Beta for the health care portfolio:", beta_health))
print(paste("CAPM Alpha for the health care portfolio:", alpha_health))



#------------------------------------------------------------------------------------------------------------
## 2)

# Beta measures the portfolio's sensitivity to market movements, and alpha 
# represents the portfolio's performance relative to the expected return given 
# by the CAPM. In our case we have:

# CAPM Beta of 0.836
# This indicates that the healthcare portfolio is less volatile than the market.
# A beta less than 1 suggests that the portfolio is less sensitive to market movements.
# If the market goes up or down, this portfolio is expected to go up or down to 
# a lesser extent.

# CAPM Alpha of 0.251
# This represents the portfolio's performance relative to the return predicted by
# the CAPM. A positive alpha of 0.251 suggests that the portfolio is performing 
# better than what the CAPM would predict, given its level of market risk. 
# This could be interpreted as the portfolio generating a significant positive 
# return above what would be expected based on its beta.



