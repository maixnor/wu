getwd()
setwd("~/repo/wu/r/ba2/data")
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


# Task 4: Plot Time Series of Relative Portfolio Weights
# Compute weights for each stock
weight_Dictum <- holdings[, 1] * prices_monthly$`Dictum Ltd` / portfolio_value
weight_Pede <- holdings[, 2] * prices_monthly$`Pede Ltd` / portfolio_value
weight_Sed <- holdings[, 3] * prices_monthly$`Sed LLP` / portfolio_value
weight_Consectetuer <- holdings[, 4] * prices_monthly$`Consectetuer Company` / portfolio_value
weight_Vel <- holdings[, 5] * prices_monthly$`Vel LLC` / portfolio_value

# Combine the weights into a matrix for plotting
weights_portfolio <- cbind(weight_Dictum, weight_Pede, weight_Sed, weight_Consectetuer, weight_Vel)
colnames(weights_portfolio) <- c("Dictum Ltd", "Pede Ltd", "Sed LLP", "Consectetuer Company", "Vel LLC")

# Plot the time series of relative portfolio weights
matplot(index(weights_portfolio), coredata(weights_portfolio), type = "l", lty = 1, col = c("magenta", "aquamarine", "cadetblue", "darkolivegreen", "coral"),
        main = "Time Series of Relative Portfolio Weights", ylab = "Relative Portfolio Weight", xlab = "Date")
legend("topright", legend = colnames(weights_portfolio), col = c("magenta", "aquamarine", "cadetblue", "darkolivegreen", "coral"), lwd = 2)

# Task 5: Compute Volatility and Skewness
# Compute volatility for each stock
volatility_single <- apply(coredata(stock_returns), 2, sd, na.rm = TRUE)
volatility_portfolio <- sd(portfolio_returns, na.rm = TRUE)


# Load the moments library for the skewness function
library(moments)
# Calculate skewness for each stock
skewness_single <- apply(coredata(stock_returns), 2, skewness, na.rm = TRUE)

# Calculate skewness for the overall portfolio
skewness_portfolio <- skewness(portfolio_returns, na.rm = TRUE)

# Print results
cat("Skewness of single stocks:", skewness_single, "\n")
cat("Portfolio skewness:", skewness_portfolio, "\n")

# Print results
cat("Volatility of single stocks:", volatility_single, "\n")
cat("Portfolio volatility:", volatility_portfolio, "\n")
cat("Skewness of single stocks:", skewness_single, "\n")
cat("Portfolio skewness:", skewness_portfolio, "\n")

# Task 6: Compute Historical VaR and Expected Shortfall at 2%
var_2 <- quantile(portfolio_returns, 0.02, na.rm = TRUE)
expected_shortfall <- mean(portfolio_returns[portfolio_returns < var_2], na.rm = TRUE)

cat("VaR at 2% level:", var_2, "\n")
cat("Expected Shortfall at 2% level:", expected_shortfall, "\n")




