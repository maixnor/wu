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
# Determine if bonds trade at discount, par, or premium
bond_df$trade <- ifelse(bond_df$price < 100, "Discount",
                        ifelse(bond_df$price == 100, "Par", "Premium"))
# Display the trade status
print(bond_df)



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
# Calculate 90% VaR
var90 <- apply(stock_ret, 2, function(x) quantile(x, probs=0.1, na.rm=TRUE))
pf_var90 <- quantile(pf_ret, 0.1, na.rm=TRUE)

# Calculate 90% Expected Shortfall (ES)
es90 <- apply(stock_ret, 2, function(x) mean(x[x < quantile(x, probs=0.1, na.rm=TRUE)], na.rm=TRUE))
pf_es90 <- mean(pf_ret[pf_ret < pf_var90], na.rm=TRUE)

# Display VaR and ES
print(data.frame(Stock=colnames(stock_ret),
                 VaR90=var90,
                 ES90=es90))
print(data.frame(Portfolio_VaR90=pf_var90,
                 Portfolio_ES90=pf_es90))

# 3) Plots for (a) volatility, (b) VaR, (c) ES  #INTERPRETATION needed
# Plot Volatility
barplot(vols, main="Volatility of Individual Stocks", ylab="Standard Deviation (%)", las=2)
abline(h=pf_vol, col="red", lwd=2)
legend("topright", legend=c("Portfolio Volatility"), col="red", lwd=2)

# Plot VaR
barplot(var90, main="90% VaR of Individual Stocks", ylab="VaR (%)", las=2)
abline(h=pf_var90, col="red", lwd=2)
legend("topright", legend=c("Portfolio VaR90"), col="red", lwd=2)

# Plot ES
barplot(es90, main="90% Expected Shortfall of Individual Stocks", ylab="ES (%)", las=2)
abline(h=pf_es90, col="red", lwd=2)
legend("topright", legend=c("Portfolio ES90"), col="red", lwd=2)

# 4) Diversification effect #INTERPRETATION needed
# Calculate correlation matrix
cor_matrix <- cor(stock_ret, use="complete.obs")
average_correlation <- mean(cor_matrix[upper.tri(cor_matrix)])
cat("Average Correlation among Stocks:", average_correlation, "\n")
# Diversification reduces risk when average correlation is low



###########################################
##              Exercise 4               ##
###########################################
# data4: monthly returns for 300 stocks & r_mkt, rf  (in %)
# data5: momentum scores
# 1) Trading strategies: high MOM & low MOM
# #HELPME rebalancing approach from prior solutions
library(dplyr)

yrs <- unique(format(index(data4), "%Y"))
yrs <- yrs[yrs >= "2002" & yrs <= "2018"]
highMOM_ret <- xts()
lowMOM_ret <- xts()

for(yy in yrs){
  # pick last month of year yy
  idx_yy <- tail(which(format(index(data4), "%Y") == yy), 1)
  mom_scores <- data5[idx_yy, ]
  
  # rank the momentum scores
  sorted <- sort(mom_scores, decreasing=TRUE)
  top_ids <- names(sorted)[1:floor(ncol(data5)/3)]
  bot_ids <- names(sorted)[(2*floor(ncol(data5)/3)+1):ncol(data5)]
  
  # Define the period for holding
  start_idx <- idx_yy + 1
  end_idx <- idx_yy + 12
  if(end_idx > nrow(data4)){
    end_idx <- nrow(data4)
  }
  
  period_returns <- data4[start_idx:end_idx, ]
  
  # Calculate average returns for high MOM portfolio
  high_returns <- rowMeans(period_returns[, top_ids], na.rm=TRUE)
  highMOM_ret <- rbind(highMOM_ret, high_returns)
  
  # Calculate average returns for low MOM portfolio
  low_returns <- rowMeans(period_returns[, bot_ids], na.rm=TRUE)
  lowMOM_ret <- rbind(lowMOM_ret, low_returns)
}

# 2) Plot monthly + cumulative returns of the two MOM portfolios + market
# Combine returns
combined_ret <- merge(highMOM_ret, lowMOM_ret, data4$r_mkt, join="inner")
colnames(combined_ret) <- c("High_MOM", "Low_MOM", "Market")

# Plot Monthly Returns
plot.zoo(combined_ret, screens = 1, col=c("blue", "green", "red"), lty=1, main="Monthly Returns",
         ylab="Returns (%)")
legend("topright", legend=colnames(combined_ret), col=c("blue", "green", "red"), lty=1)

# Plot Cumulative Returns
cum_ret <- cumprod(1 + combined_ret/100)
plot.zoo(cum_ret, screens = 1, col=c("blue", "green", "red"), lty=1, main="Cumulative Returns",
         ylab="Cumulative Returns")
legend("topleft", legend=colnames(cum_ret), col=c("blue", "green", "red"), lty=1)

# 3) Compare annual average returns, vol, Sharpe ratio 
# Compute annual statistics
annual_stats <- data.frame(
  Portfolio = c("High_MOM", "Low_MOM"),
  Avg_Return = c(mean(highMOM_ret, na.rm=TRUE)*12, mean(lowMOM_ret, na.rm=TRUE)*12),
  Volatility = c(sd(highMOM_ret, na.rm=TRUE)*sqrt(12), sd(lowMOM_ret, na.rm=TRUE)*sqrt(12)),
  Sharpe_Ratio = c((mean(highMOM_ret, na.rm=TRUE)-mean(data4$rf, na.rm=TRUE))*12 / (sd(highMOM_ret, na.rm=TRUE)*sqrt(12)),
                   (mean(lowMOM_ret, na.rm=TRUE)-mean(data4$rf, na.rm=TRUE))*12 / (sd(lowMOM_ret, na.rm=TRUE)*sqrt(12)))
)
print(annual_stats)

# 4) Which should have higher CAPM beta #INTERPRETATION
# Higher expected returns portfolios typically have higher CAPM beta
# Based on the Sharpe Ratios and returns, High_MOM portfolio should have higher CAPM beta






