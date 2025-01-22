###########################################
##    BA II -- FINAL EXAM // 22.01.25    ##
###########################################

## TOTAL  /40

##EX1     /13
#1.   /2
#2.   /2
#3.   /1
#4.   /4
#5.   /4

##EX2     /10

##EX3     /8
#1.   /1
#2.   /3
#3.   /3
#4.   /1

##EX4     /9
#1.   /3
#2.   /3
#3.   /2
#4.   /1




###########################################
##              Exercise 1               ##
###########################################

load("final_data_1296.RData")

file_path <- "D:/tmp/data5.csv"
if (!dir.exists("D:/tmp")) { dir.create("D:/tmp", recursive = TRUE) }
write.csv(data5, file = file_path, row.names = FALSE)

## Libraries
library(zoo)
library(xts)
library(lubridate)
library(colorspace)
library(moments)
library(ggplot2)

#------------------------------------------------------------------------------------------------------------
## 1)

data1_xts <- xts(data1[,-1], order.by = as.Date(data1$date), format = "%Y-%m-%d")
head(data1_xts)

#------------------------------------------------------------------------------------------------------------
## 2)

# Use na.locf() from the 'xts' package to forward-fill any NA values.
data1_ff <- na.locf(data1_xts)
head(data1_ff)


#------------------------------------------------------------------------------------------------------------
## 3)

# Simple returns: (P_t / P_{t-1}) - 1
daily_returns <- data1_ff / lag(data1_ff) - 1
head(daily_returns)


#------------------------------------------------------------------------------------------------------------
## 4)

# Compute the 2.5% and 97.5% quantiles for each column
quantiles <- apply(daily_returns, 2, function(col_data) {
  quantile(col_data, probs = c(0.025, 0.975), na.rm = TRUE)
})

# Make a copy of the daily_returns so we don’t overwrite the original
daily_returns_capped <- daily_returns

# For each column, set values outside the [2.5%, 97.5%] range to NA
for (j in seq_len(ncol(daily_returns_capped))) {
  low  <- quantiles[1, j]
  high <- quantiles[2, j]
  
  # replace values below 'low' or above 'high' with NA
  daily_returns_capped[ daily_returns_capped[, j] < low,  j ] <- NA
  daily_returns_capped[ daily_returns_capped[, j] > high, j ] <- NA
}

head(daily_returns_capped)

#------------------------------------------------------------------------------------------------------------
## 5)

# We typically calculate monthly simple returns by compounding the daily returns
# within each month, i.e., Prod(1 + daily) - 1

monthly_returns <- apply.monthly(daily_returns_capped, function(x) {
  # for each column, we compute product(1 + daily) - 1
  # 'x' here is a matrix (or vector) of daily returns in the given month
  # We do it column by column
  apply(x, 2, function(col_data) {
    prod(1 + na.omit(col_data)) - 1
  })
})

# monthly_returns is now a matrix where each row corresponds to one month
# and each column corresponds to one of your time series.

head(monthly_returns)


###########################################
##              Exercise 2               ##
###########################################

## (1) Compute the implied prices for each maturity in data2

maturities <- data2$maturity
yields     <- data2$yield_pa

bond_price <- 100 / (1 + yields/100)^maturities

## Create a data frame with maturities and prices (8P)
df_bonds <- data.frame(
  Maturity = maturities,
  Price    = bond_price
)


#------------------------------------------------------------------------------------------------------------
# Data frame:


df_bonds


#------------------------------------------------------------------------------------------------------------
# Verbal answer:

## (2) Check whether each bond is at a discount, par, or premium (2P)
## Compare to face value = 100

# To answer if the bond trades at premium, par or discount we need to compare:
# Price > Face Value -> premium
# Price = Face Value -> par
# Price < Face Value -> discount

df_bonds$Status <- ifelse(df_bonds$Price < 100, "Discount",
                          ifelse(abs(df_bonds$Price - 100) < .Machine$double.eps^0.5, "Par", 
                                 "Premium"))

## Print the resulting data frame
df_bonds

## All bonds trade at a discount, the discount gets more significant with longer maturities.




###########################################
##              Exercise 3               ##
###########################################



#------------------------------------------------------------------------------------------------------------
## 1)
class(data3$date)

data3_xts <- xts(data3[,-1], order.by = as.Date(data3$date, format = "%Y-%m-%d"))
class(data3_xts)
head(data3_xts)

# --- 1) Construct the equally weighted portfolio ---
# Simply average across the 20 columns for each row (date)
pf_returns <- xts(rowMeans(data3_xts), order.by = index(data3_xts))

# The resulting 'pf_returns' is your equally weighted portfolio return series (in percent).

head(pf_returns)

#------------------------------------------------------------------------------------------------------------
## 2)

#a) Volatility
vol_stocks <- apply(data3_xts, 2, sd, na.rm = TRUE)  # each of the 20 columns
vol_pf     <- sd(pf_returns, na.rm = TRUE)           # portfolio

head(vol_stocks)
head(vol_pf)

#b) VaR

# By convention, the 90% VaR is the 10th percentile of returns (the "lower tail"). 
var_stocks <- apply(data3_xts, 2, function(x) quantile(x, probs = 0.10, na.rm=TRUE))
var_pf     <- quantile(pf_returns, probs = 0.10, na.rm = TRUE)

head(var_stocks)
head(var_pf)

#c) ES

# The 90% ES is the average return of all observations falling below the 10th percentile.
es_stocks <- numeric(ncol(data3_xts))
for(i in seq_len(ncol(data3_xts))){
  stock_i <- na.omit(data3_xts[,i])
  cutoff  <- var_stocks[i]  # 10th percentile for that stock
  es_stocks[i] <- mean(stock_i[stock_i < cutoff])
}

pf_cutoff <- var_pf
es_pf <- mean(na.omit(pf_returns)[na.omit(pf_returns) < pf_cutoff])

head(es_stocks)
head(es_pf)

#------------------------------------------------------------------------------------------------------------
## 3)

# Combine stock measures + portfolio into single vectors
all_vol <- c(vol_stocks, vol_pf)
all_var <- c(var_stocks, var_pf)
all_es  <- c(es_stocks, es_pf)

# Give names to the combined vectors
stock_names <- colnames(data3_xts)
names(all_vol) <- c(stock_names, "Portfolio")
names(all_var) <- c(stock_names, "Portfolio")
names(all_es)  <- c(stock_names, "Portfolio")

# We'll color the portfolio bar differently
colors_vol <- c(rep("steelblue", length(stock_names)), "red")
colors_var <- c(rep("steelblue", length(stock_names)), "red")
colors_es  <- c(rep("steelblue", length(stock_names)), "red")

#Volatility plot #

barplot(all_vol, 
        main="Volatility (Daily, in %)", 
        ylab="Std. Dev. of Returns", 
        col=colors_vol, las=2)  # las=2 for vertical axis labels

#VaR plot #

barplot(all_var, 
        main="90% VaR (Daily, in %)", 
        ylab="10th Percentile of Returns", 
        col=colors_var, las=2)

#ES plot #

barplot(all_es, 
        main="90% Expected Shortfall (Daily, in %)",
        ylab="Mean of Returns below 10th Percentile",
        col=colors_es, las=2)

#------------------------------------------------------------------------------------------------------------
## 4)

# Diversification is combining various assets or asset classes that don't move perfectly together, thus reducing overall portfolio risk. This spread of fund across different investments lowers overall portfolio volatility, also called risk. The diversification effect is visible across all three risk metrics. As we observe decreased volatility and a reduction in the VaR and ES, as losses in some assets are offset by gains or smaller losses in others, compared to individual stocks. We can conclude that a diversified portfolio is less likely to expeerience extreme losses compared to holding single or highly correlated assets (i.e. assets from the same asset class, geographical location and industry). 



###########################################
##              Exercise 4               ##
###########################################



#------------------------------------------------------------------------------------------------------------
## 1)





#------------------------------------------------------------------------------------------------------------
## 2)





#------------------------------------------------------------------------------------------------------------
## 3)





#------------------------------------------------------------------------------------------------------------
## 4)






