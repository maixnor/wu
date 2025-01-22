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
# 1) Convert daily prices (data1) to an xts time series
# HELPME: No direct example found, using # ...existing code... from solutions
library(xts)
# suppose final_data_1296.RData is loaded
data1_xts <- xts(data1[,-1], order.by = as.Date(data1[,1]))
# 2) Forward-fill missing values
data1_ff <- na.locf(data1_xts)
# 3) Compute daily returns (simple)
ret_data1 <- data1_ff/lag(data1_ff) - 1
# 4) Extreme values -> NA (2.5% & 97.5%)
for(j in 1:ncol(ret_data1)){
  q_low <- quantile(na.omit(ret_data1[,j]), probs = 0.025)
  q_high <- quantile(na.omit(ret_data1[,j]), probs = 0.975)
  idx_out <- which(ret_data1[,j] < q_low | ret_data1[,j] > q_high)
  ret_data1[idx_out, j] <- NA
}
# 5) Aggregate to monthly frequency
ret_data1_m <- apply.monthly(ret_data1, FUN = function(x) mean(x, na.rm=TRUE))



###########################################
##              Exercise 2               ##
###########################################
# #HELPME example from prior solutions
# data2: yields, in percent per annum, with maturities in "years"
# Compute implied zero-coupon bond prices: P = 1 / (1 + y/100)^maturity
# Return a data.frame with bond prices and maturities
yields <- data2$yield
maturities <- data2$maturity
bond_prices <- 1 / (1 + yields/100)^maturities
bond_df <- data.frame(maturities = maturities, price = bond_prices)
# #INTERPRETATION about discount, par, premium goes here



###########################################
##              Exercise 3               ##
###########################################
# data3 has daily returns for 20 stocks (cleaned, in %).
# 1) Equally weighted portfolio:
stock_ret <- data3  # in percent
n_stocks <- ncol(stock_ret)
pf_ret <- rowMeans(stock_ret) 
# 2) Volatility, 90% VaR, 90% ES
library(moments)
vols <- apply(stock_ret, 2, sd, na.rm=TRUE)
pf_vol <- sd(pf_ret, na.rm=TRUE)
# #HELPME VaR and ES no direct example for entire approach
var90 <- apply(stock_ret, 2, function(x) quantile(x, probs=0.1, na.rm=TRUE))
es90 <- apply(stock_ret, 2, function(x) mean(x[x < quantile(x, 0.1, na.rm=TRUE)], na.rm=TRUE))
pf_var90 <- quantile(pf_ret, 0.1, na.rm=TRUE)
pf_es90 <- mean(pf_ret[pf_ret < pf_var90], na.rm=TRUE)
# 3) Plots for (a) volatility, (b) VaR, (c) ES  #INTERPRETATION needed
# Mark portfolio value with a different color or shape
# 4) Diversification effect #INTERPRETATION needed



###########################################
##              Exercise 4               ##
###########################################
# data4: monthly returns for 300 stocks & r_mkt, rf  (in %)
# data5: momentum scores
# 1) Trading strategies: high MOM & low MOM
# #HELPME rebalancing approach from prior solutions
yrs <- unique(format(index(data4), "%Y"))
yrs <- yrs[yrs >= "2002" & yrs <= "2018"]
highMOM_ret <- NULL
lowMOM_ret <- NULL
for(yy in yrs){
  # pick last month of year yy
  idx_yy <- tail(which(format(index(data4), "%Y")==yy), 1)
  mom_scores <- data5[idx_yy, ]
  # rank the momentum scores
  sorted <- sort(mom_scores, decreasing=TRUE, index.return=TRUE)
  top_ids <- sorted$ix[1:floor(ncol(data5)/3)]
  bot_ids <- sorted$ix[(2*floor(ncol(data5)/3)+1):ncol(data5)]
  # hold for next 12 months (or until year-end)
  # get start idx -> idx_yy+1, end next year
  # #HELPME handle indexing carefully
  # store monthly returns in the sample
}
# 2) Plot monthly + cumulative returns of the two MOM portfolios + market
# #INTERPRETATION needed
# 3) Compare annual average returns, vol, Sharpe ratio 
# 4) Which should have higher CAPM beta #INTERPRETATION






