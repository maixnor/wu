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




#------------------------------------------------------------------------------------------------------------
# Data frame:





#------------------------------------------------------------------------------------------------------------
# Verbal answer:








###########################################
##              Exercise 3               ##
###########################################



#------------------------------------------------------------------------------------------------------------
## 1)





#------------------------------------------------------------------------------------------------------------
## 2)

#a) Volatility


#b) VaR


#c) ES



#------------------------------------------------------------------------------------------------------------
## 3)

#Volatility plot #


#VaR plot #


#ES plot #



#------------------------------------------------------------------------------------------------------------
## 4)








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






