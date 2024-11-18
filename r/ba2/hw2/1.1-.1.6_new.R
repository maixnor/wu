getwd()
setwd("/Users/vivienarns/Downloads")
getwd()
price_data <- read.csv(file="price_data.csv", sep=";", dec=",")
price_data <- na.omit(price_data) #removing NA (always removes whole row if at least 1 NA occurs)

dim(price_data)
price_data$Date <- as.Date(price_data$Date, format="%Y-%m-%d")

price_data <- price_data[price_data$Name %in% c("Dictum Ltd", "Pede Ltd", "Sed LLP", "Consectetuer Company", "Vel LLC"), ]

library(xts)

names <- unique(price_data$Name)
p <- list()
for (i in 1:length(names)) {
  price_data_i <- price_data[price_data$Name == names[i], ]
  p[[i]] <- xts(price_data_i$Price, order.by = price_data_i$Date) 
}
price <- do.call(cbind, p) 

colnames(price) <- names
price <- price["2003/"] 
price <- abs(price)
price <- apply.daily(price, FUN = function(x) x[1, ])
price <- na.omit(price)
price

#Task 1.1. Compute the portfolio value for each month
prices_monthly <- apply.monthly(price, function(x) last(x)) #last because at the end of each month

portfolio_holdings<- matrix(c(100, 100, 200, 150, 50), nrow = nrow(prices_monthly), ncol = ncol(prices_monthly), byrow = TRUE) # we make sure the dimensions are right for the holdings and the monthly prices
pv <- rowSums(prices_monthly * portfolio_holdings) #portfolio values in each month
pv
pv_xts <- xts(pv, order.by = index(prices_monthly)) #portfolio value in an xts file
dim(pv_xts)
pv_xts [1:159,]

plot(pv_xts, main= "Monthly Portfolio Values", col='darkred')

#Task 1.2: Compute the monthly portfolio returns and plot them.

#we are using simple returns, as it is not stated otherwise
pv_returns<- (pv_xts-lag(pv_xts))/ lag(pv_xts)
plot(pv_returns, main='Monthly Portfolio Returns', col="orange")

#Task 1.3: Compare the portfolio’s return distribution to the stocks’ return distributions graphically.
stock_r <-(price-lag(price))/lag(price) #we compute the stock returns
stock_r

#we compute densities and plot 
stock_densities <- apply(stock_r, 2, function(x) density(na.omit(x)))
portfolio_density <- density(na.omit(pv_returns))

stock_names <- colnames(stock_r)
stock_color <- rainbow(5) #assign different colors to the different firms

plot(portfolio_density, col='black', ylim=c(0,10), main='Density Of Portfolio Returns ')
for (i in 1:ncol(stock_r)) {
  lines(stock_densities[[i]], col=stock_color[i], )
}
legend("topleft", legend = c("Portfolio", stock_names), col = c("black",stock_color), lwd = 2)




library(xts)
library(lubridate)
library(PerformanceAnalytics)

# Task 1.4
# Filter for portfolio companies and prepare xts time series
company_names <- unique(price_data$Name)
price_list <- lapply(company_names, function(company) {
  company_data <- subset(price_data, Name == company)
  xts(company_data$Price, order.by = company_data$Date)
})
price <- do.call(cbind, price_list)
colnames(price) <- company_names

# Define initial holdings for each stock in the portfolio (adjust as per actual holdings)
holdings <- c(100, 100, 200, 150, 50)  # For Dictum Ltd, Pede Ltd, Sed LLP, Consectetuer Company, Vel LLC

# Task 1.4: Calculate and Plot Time Series of Relative Portfolio Weights
monthly_prices <- apply.monthly(price, last)  # Get last price of each month
portfolio_value <- rowSums(monthly_prices * holdings)  # Monthly portfolio value

# Calculate relative weights for each stock in the portfolio
weights_Dictum <- holdings[1] * monthly_prices$`Dictum Ltd` / portfolio_value
weights_Pede <- holdings[2] * monthly_prices$`Pede Ltd` / portfolio_value
weights_Sed <- holdings[3] * monthly_prices$`Sed LLP` / portfolio_value
weights_Consectetuer <- holdings[4] * monthly_prices$`Consectetuer Company` / portfolio_value
weights_Vel <- holdings[5] * monthly_prices$`Vel LLC` / portfolio_value

# Combine weights into a matrix for plotting
weights_portfolio <- cbind(weights_Dictum, weights_Pede, weights_Sed, weights_Consectetuer, weights_Vel)

# Plot portfolio weights with distinct colors and legend
plot(weights_portfolio, main = "Time Series of Relative Portfolio Weights",
     ylab = "Relative Weight in Portfolio", col = c("darkgreen", "purple", "skyblue", "darkorange", "goldenrod"))
legend("topright", legend = c("Dictum Ltd", "Pede Ltd", "Sed LLP", "Consectetuer Company", "Vel LLC"),
       col = c("darkgreen", "purple", "skyblue", "darkorange", "goldenrod"), lty = 1, lwd = 2)

# Load additional libraries if needed
library(moments)  # For skewness calculations

# Task 1.5: Compute Volatility and Skewness
# Calculate individual stock returns if not already done
stock_returns <- (price - lag(price)) / lag(price)  # Daily returns for individual stocks

# Monthly portfolio returns (already calculated as pv_returns)
portfolio_volatility <- sd(na.omit(pv_returns))
portfolio_skewness <- skewness(na.omit(pv_returns))

# Calculate volatility and skewness for each stock
volatility_individual <- apply(stock_returns, 2, sd, na.rm = TRUE)
skewness_individual <- apply(stock_returns, 2, skewness, na.rm = TRUE)

# Print results for Task 1.5
cat("Portfolio Volatility:", portfolio_volatility, "\n")
cat("Portfolio Skewness:", portfolio_skewness, "\n")
cat("Individual Stock Volatilities:", volatility_individual, "\n")
cat("Individual Stock Skewnesses:", skewness_individual, "\n")

# Task 1.6: Compute Historical Value at Risk (VaR) and Expected Shortfall at 2% Level
VaR_2_percent <- quantile(na.omit(pv_returns), 0.02)
ES_2_percent <- mean(na.omit(pv_returns[pv_returns <= VaR_2_percent]))

# Print VaR and Expected Shortfall
cat("Portfolio Value at Risk (2% level):", VaR_2_percent, "\n")
cat("Portfolio Expected Shortfall (2% level):", ES_2_percent, "\n")

