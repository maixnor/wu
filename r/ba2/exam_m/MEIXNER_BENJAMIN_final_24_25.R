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
library(xts)

# 1) Implement momentum trading strategies
# Get all dates and years
all_dates <- index(data4)
years <- format(all_dates, "%Y")

# Find December dates for 2002-2018
dec_indices <- which(months(all_dates) == "December" & 
                    years >= "2002" & years <= "2018")

# Initialize containers with dates
highMOM_ret <- numeric()
lowMOM_ret <- numeric()
dates_used <- as.Date(character())

if(length(dec_indices) > 1){
    for(i in 1:(length(dec_indices)-1)) {
        current_idx <- dec_indices[i]
        next_dec_idx <- dec_indices[i+1]
        
        # Get momentum scores at current December
        mom_scores <- as.numeric(data5[current_idx,])
        
        # Determine portfolio composition
        n_stocks <- ncol(data4) - 2  # subtract r_mkt and rf columns
        n_select <- floor(n_stocks/3)
        
        # Sort and select stocks
        rank_order <- order(mom_scores, decreasing = TRUE)
        high_idx <- rank_order[1:n_select]
        low_idx <- rank_order[(2*n_select + 1):min(3*n_select, n_stocks)]
        
        # Get returns for next year
        if(next_dec_idx > current_idx + 1){
            period_idx <- (current_idx + 1):next_dec_idx
        } else {
            next
        }
        
        returns_high <- rowMeans(data4[period_idx, high_idx], na.rm = TRUE)
        returns_low <- rowMeans(data4[period_idx, low_idx], na.rm = TRUE)
        
        # Store returns and dates
        highMOM_ret <- c(highMOM_ret, returns_high)
        lowMOM_ret <- c(lowMOM_ret, returns_low)
        dates_used <- c(dates_used, all_dates[period_idx])
    }
}

# Convert to xts objects
highMOM_ret <- xts(highMOM_ret, order.by = dates_used)
lowMOM_ret <- xts(lowMOM_ret, order.by = dates_used)

# 2) Plot monthly and cumulative returns
# First merge high and low momentum returns
combined_ret <- merge(highMOM_ret, lowMOM_ret)
# Then merge with market returns
combined_ret <- merge(combined_ret, data4$r_mkt[index(combined_ret)])
colnames(combined_ret) <- c("High_MOM", "Low_MOM", "Market")

# Monthly returns plot
plot.zoo(combined_ret, screens=1, col=c("blue","red","black"), lty=1,
         main="Monthly Portfolio Returns", ylab="Returns (%)")
legend("topright", legend=colnames(combined_ret), 
       col=c("blue","red","black"), lty=1)

# Cumulative returns plot
cum_ret <- cumprod(1 + combined_ret/100)
plot.zoo(cum_ret, screens=1, col=c("blue","red","black"), lty=1,
         main="Cumulative Portfolio Returns", ylab="Cumulative Value")
legend("topleft", legend=colnames(cum_ret), 
       col=c("blue","red","black"), lty=1)

# 3) Calculate annual statistics
rf_annual <- mean(data4$rf[index(combined_ret)], na.rm=TRUE)

annual_stats <- data.frame(
    Portfolio = c("High_MOM", "Low_MOM", "Market"),
    Avg_Return = apply(combined_ret, 2, function(x) mean(x, na.rm=TRUE) * 12),
    Volatility = apply(combined_ret, 2, function(x) sd(x, na.rm=TRUE) * sqrt(12)),
    row.names = NULL
)
annual_stats$Sharpe_Ratio <- ifelse(annual_stats$Volatility != 0,
                                    (annual_stats$Avg_Return - rf_annual*12) / annual_stats$Volatility,
                                    NA)

print(annual_stats)

# 4) CAPM perspective discussion follows in comments
