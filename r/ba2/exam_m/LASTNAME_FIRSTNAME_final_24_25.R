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
load("./exam_m/final_data_1296.RData", envir = parent.frame(), verbose = FALSE)
library(xts)
library(zoo)

data1_xts <- xts(data1[,-1], order.by = as.Date(data1[,1]))

# 2) Forward-fill missing values
data1_ff <- na.locf(data1_xts)

# 3) Compute daily returns (simple)
ret_data1 <- data1_ff / lag(data1_ff) - 1

# 4) Extreme values -> NA (2.5% & 97.5%)
for(j in 1:ncol(ret_data1)){
  q_low <- quantile(na.omit(ret_data1[, j]), probs = 0.025)
  q_high <- quantile(na.omit(ret_data1[, j]), probs = 0.975)
  idx_out <- which(ret_data1[, j] < q_low | ret_data1[, j] > q_high)
  ret_data1[idx_out, j] <- NA
}

# 5) Aggregate daily returns to monthly frequency (omitting NA)
ret_data1_m <- apply.monthly(ret_data1, function(x) mean(x, na.rm=TRUE))

###########################################
##              Exercise 2               ##
###########################################
# data2: yields in % per annum, maturities in years
# Compute zero-coupon bond prices (in fraction of notional)
maturities <- data2$maturity
yields <- data2$yield
price <- 1 / (1 + yields/100)^maturities
bond_data <- data.frame(Maturity = maturities, Price = price)

# Determine discount, par, premium
bond_data$Trade <- ifelse(bond_data$Price < 1, "Discount",
                   ifelse(abs(bond_data$Price - 1) < 1e-8, "Par", "Premium"))

# colors <- c("Discount" = "blue", "Par" = "green", "Premium" = "red")
# plot(
#   bond_data$Maturity, bond_data$Price,
#   col = colors[bond_data$Trade],
#   pch = 19,
#   xlab = "Maturity (Years)",
#   ylab = "Price (Fraction of Notional)",
#   main = "Zero-Coupon Bond Prices by Maturity"
# )
# abline(h = 1, lty = 2, col = "black")
# legend(
#   "topright",
#   legend = names(colors),
#   col = colors,
#   pch = 19,
#   title = "Trade Status"
# )

###########################################
##              Exercise 3               ##
###########################################
# data3: daily returns for 20 stocks (in %)

# 1) Equally weighted portfolio
stock_ret <- as.matrix(sapply(data3, as.numeric))
pf_ret <- rowMeans(stock_ret, na.rm=TRUE)

# 2) Volatility, 90% VaR, 90% ES
vol_stocks <- apply(stock_ret, 2, sd, na.rm=TRUE)
vol_pf <- sd(pf_ret, na.rm=TRUE)

var_stocks <- apply(stock_ret, 2, function(x) quantile(x, probs=0.1, na.rm=TRUE))
var_pf <- quantile(pf_ret, probs=0.1, na.rm=TRUE)

es_stocks <- apply(stock_ret, 2, function(x){
  cvar_thresh <- quantile(x, probs=0.1, na.rm=TRUE)
  mean(x[x < cvar_thresh], na.rm=TRUE)
})
es_pf <- mean(pf_ret[pf_ret < var_pf], na.rm=TRUE)

# 3) Example plot comparing volatilities, marking portfolio
barplot(vol_stocks, main="Volatility of Individual Stocks", las=2)
abline(h=vol_pf, col="red", lwd=2, lty=1)
legend("topright", legend="Portfolio Volatility", col="red", lwd=2, lty=1)

# 4) Diversification effect (brief mention in normal text)

###########################################
##              Exercise 4               ##
###########################################
# data4: monthly returns of 300 stocks, r_mkt, rf
# data5: momentum scores
library(dplyr)

yrs <- unique(format(index(data4), "%Y"))
yrs <- yrs[yrs >= "2002" & yrs <= "2018"]
highMOM_ret <- xts()
lowMOM_ret <- xts()

for(yy in yrs){
  idx_yy <- tail(which(format(index(data4), "%Y") == yy), 1)
  # Momentum scores at end of year
  mom_scores <- data5[idx_yy, ]
  
  # Sort scores descending
  sorted_mom <- sort(mom_scores, decreasing=TRUE)
  top_ids <- names(sorted_mom)[1:floor(ncol(data5)/3)]
  bot_ids <- names(sorted_mom)[(2*floor(ncol(data5)/3)+1):ncol(data5)]
  
  # Next year's monthly returns
  start_idx <- idx_yy + 1
  end_idx <- idx_yy + 12
  if(end_idx > nrow(data4)) {
    end_idx <- nrow(data4)
  }
  
  next_period <- data4[start_idx:end_idx, ]
  high_returns <- rowMeans(next_period[, top_ids], na.rm=TRUE)
  low_returns <- rowMeans(next_period[, bot_ids], na.rm=TRUE)
  
  highMOM_ret <- rbind(highMOM_ret, high_returns)
  lowMOM_ret <- rbind(lowMOM_ret, low_returns)
}

# 2) Monthly + cumulative returns for both portfolios + market
combined_ret <- merge(highMOM_ret, lowMOM_ret, data4$r_mkt, join="inner")
colnames(combined_ret) <- c("High_MOM", "Low_MOM", "Market")

plot.zoo(combined_ret, screens=1, col=c("blue","green","red"), lty=1,
         main="Monthly Returns", ylab="Returns (%)")
legend("topright", legend=colnames(combined_ret), col=c("blue","green","red"), lty=1)

cum_ret <- cumprod(1 + combined_ret/100)
plot.zoo(cum_ret, screens=1, col=c("blue","green","red"), lty=1,
         main="Cumulative Returns", ylab="Cumulative Returns")
legend("topleft", legend=colnames(cum_ret), col=c("blue","green","red"), lty=1)

# 3) Compare average returns, vol, Sharpe
annual_stats <- data.frame(
  Portfolio = c("High_MOM","Low_MOM"),
  Avg_Return = c(mean(highMOM_ret, na.rm=TRUE)*12, mean(lowMOM_ret, na.rm=TRUE)*12),
  Volatility = c(sd(highMOM_ret, na.rm=TRUE)*sqrt(12), sd(lowMOM_ret, na.rm=TRUE)*sqrt(12)),
  Sharpe_Ratio = c(
    (mean(highMOM_ret, na.rm=TRUE) - mean(data4$rf, na.rm=TRUE))*12 /
      (sd(highMOM_ret, na.rm=TRUE)*sqrt(12)),
    (mean(lowMOM_ret, na.rm=TRUE) - mean(data4$rf, na.rm=TRUE))*12 /
      (sd(lowMOM_ret, na.rm=TRUE)*sqrt(12))
  )
)
print(annual_stats)

# 4) Higher CAPM beta typically goes with higher average return (CAPM perspective).