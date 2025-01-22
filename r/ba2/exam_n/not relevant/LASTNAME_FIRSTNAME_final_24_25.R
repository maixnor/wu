# Load the objects from the file
load("final_data.RData")

# Verify that data1, data2, data3, data4 are now in your environment
ls()

# Load required library
library(xts)

# 1) Convert data1 to an xts object
data1_xts <- xts(data1[,-1], order.by = as.Date(data1$date))

# 2) Fill missing values using linear interpolation
data1_xts <- na.approx(data1_xts)

# 3) Compute daily simple returns
#    r_t = (P_t / P_(t-1)) - 1
daily_returns <- data1_xts / lag(data1_xts, 1) - 1
daily_returns <- daily_returns[-1, ]  # typically remove the first row because lag introduces NA

# 4) Set extreme values (<10th quantile or >90th quantile) to NA column by column
daily_returns_clipped <- apply(daily_returns, 2, function(x) {
  q10 <- quantile(x, 0.10, na.rm = TRUE)
  q90 <- quantile(x, 0.90, na.rm = TRUE)
  
  # Replace all values below q10 or above q90 with NA
  x[x < q10 | x > q90] <- NA
  x
})

# Convert the resulting matrix back to an xts object (if desired)
daily_returns_clipped <- xts(daily_returns_clipped, order.by = index(daily_returns))

# Load xts if not already loaded
library(xts)

# 5) Aggregate (clipped) daily returns to yearly total returns
yearly_returns <- apply.yearly(daily_returns_clipped, FUN = function(x) {
  # x is all daily returns (for each column/asset) in a given year
  # compute total return = prod(1 + daily_return) - 1, omitting NA values
  apply(x, 2, function(col) {
    col <- na.omit(col)
    prod(1 + col) - 1
  })
})

library(xts)
library(dplyr)
library(tidyr)

# 1) Convert data2 to an xts time series.
data2_xts <- xts(data2[,-1], order.by = as.Date(data2$date))

# Example: Assign maturities (in years) in the same order as columns.
# Adjust or expand this vector to match your actual columns.
# For instance, if the columns are c("X3M","X1Y","X5Y","X7Y","X10Y"), then:
maturities <- c(3/12, 1, 5, 7, 10)  # 3 months, 1 year, 5 years, 7 years, 10 years

# 2) Compute implied bond prices for each date & maturity.
#    Price in % of notional = 100 / (1 + (yield / 100))^maturity
bond_prices_xts <- data2_xts
for(i in seq_along(maturities)) {
  bond_prices_xts[, i] <- 100 / (1 + bond_prices_xts[, i]/100)^maturities[i]
}

# 3) Convert the result to a data frame with date, maturity, and price columns.
bond_prices_df <- data.frame(
  date = index(bond_prices_xts),
  coredata(bond_prices_xts)
)

# Optional: pivot to a "long" format that explicitly shows each date-maturity-price triple
bond_prices_long <- bond_prices_df %>%
  pivot_longer(cols = -date, names_to = "maturity_label", values_to = "price_percent")

# 4) If needed, you can map your "maturity_label" (e.g., "X3M") to a numeric maturity (e.g., 0.25 years).
#    Below is an example if the columns exactly match the order in 'maturities':
maturity_map <- data.frame(
  maturity_label = colnames(data2_xts),
  maturity_years = maturities
)

# Merge the mapping to add an explicit numeric maturity:
final_prices_df <- bond_prices_long %>%
  left_join(maturity_map, by = "maturity_label") %>%
  select(date, maturity_years, price_percent)

# final_prices_df now contains:
#   date, maturity_years, and price_percent (the zero-coupon bond price as a % of notional)

library(xts)
library(PerformanceAnalytics)

# 1) Convert data3 into an xts object
data3_xts <- xts(data3[,-1], order.by = as.Date(data3$date))

# 2) Create an equally weighted portfolio
#    Note that returns in data3 are in percent, so convert them to decimal format.
data3_decimal <- data3_xts / 100
pf_returns <- rowMeans(data3_decimal)  # Equally weighted => average of all columns
pf_returns_xts <- xts(pf_returns, order.by = index(data3_decimal))

#-------------------------------#
#   Risk Metrics Computation    #
#-------------------------------#

# a) Volatility (standard deviation)
vol_individual <- apply(data3_decimal, 2, sd, na.rm=TRUE)
vol_portfolio <- sd(pf_returns_xts, na.rm=TRUE)

# b) 99% Value at Risk (historical)
#    By default, VaR() from PerformanceAnalytics calculates *left-tail* VaR.
#    If we say p=0.99, it looks for the 1% worst return.
#    invert = FALSE keeps the sign as-is.
var99_individual <- apply(data3_decimal, 2, function(x) {
  VaR(x, p=0.99, method="historical", invert=FALSE)
})
var99_portfolio <- VaR(pf_returns_xts, p=0.99, method="historical", invert=FALSE)

# c) 99% Expected Shortfall (ES)
es99_individual <- apply(data3_decimal, 2, function(x) {
  ES(x, p=0.99, method="historical", invert=FALSE)
})
es99_portfolio <- ES(pf_returns_xts, p=0.99, method="historical", invert=FALSE)

#--------------------------------------------------#
# Combine results into a summary data frame if desired
# (All values shown in decimal form; multiply by 100 for percentage.)
risk_summary <- data.frame(
  Asset = c(colnames(data3_decimal), "Portfolio"),
  Volatility = c(vol_individual, vol_portfolio),
  VaR_99 = c(var99_individual, var99_portfolio),
  ES_99 = c(es99_individual, es99_portfolio)
)

# risk_summary now contains:
# - Volatility (SD) 
# - 99% VaR 
# - 99% ES 
# for each individual stock and for the equally weighted portfolio
risk_summary

# Example of 'risk_summary' structure:
#   Asset      Volatility     VaR_99      ES_99
# 1  HUM         0.0253      -0.0421     -0.0543
# 2  TSLA.O      0.0548      -0.1010     -0.1362
# ...
# 20 AWK         0.0175      -0.0312     -0.0419
# 21 Portfolio   0.0132      -0.0233     -0.0316

library(ggplot2)
library(dplyr)

# For convenience, label the portfolio row:
risk_summary <- risk_summary %>%
  mutate(
    is_portfolio = ifelse(Asset == "Portfolio", TRUE, FALSE)
  )

#-------------------------------#
# Plot for Volatility
#-------------------------------#
ggplot(risk_summary, aes(x = reorder(Asset, Volatility), y = Volatility)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_bar(
    data = subset(risk_summary, is_portfolio),
    aes(x = Asset, y = Volatility), 
    fill = "red"
  ) +
  labs(
    title = "Volatility Comparison",
    x = "Asset",
    y = "Volatility (std. dev)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#-------------------------------#
# Plot for 99% VaR
#-------------------------------#
ggplot(risk_summary, aes(x = reorder(Asset, VaR_99), y = VaR_99)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_bar(
    data = subset(risk_summary, is_portfolio),
    aes(x = Asset, y = VaR_99), 
    fill = "red"
  ) +
  labs(
    title = "99% VaR Comparison",
    x = "Asset",
    y = "99% VaR (returns in decimal)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#-------------------------------#
# Plot for 99% ES
#-------------------------------#
ggplot(risk_summary, aes(x = reorder(Asset, ES_99), y = ES_99)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_bar(
    data = subset(risk_summary, is_portfolio),
    aes(x = Asset, y = ES_99), 
    fill = "red"
  ) +
  labs(
    title = "99% ES Comparison",
    x = "Asset",
    y = "99% ES (returns in decimal)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

library(dplyr)
library(lubridate)

# 1) Convert data4 into an R data frame or tibble (if not already)
#    Here, we assume data4 is already a data frame with columns:
#      date, r_mkt, r_health (monthly), and RF (daily).

# STEP A: Convert the daily RF to monthly by compounding within each month
# (If data4 already has monthly RF, skip this step)
rf_daily <- data4 %>%
  select(date, RF) %>%
  # assume 'date' is daily for the RF component, so let's group by year and month
  mutate(YearMonth = floor_date(as.Date(date), unit = "month")) %>%
  group_by(YearMonth) %>%
  summarize(
    # Convert percent to decimal, compound over the month, revert to percent
    RF_monthly = (prod(1 + RF / 100) - 1) * 100
  )

# STEP B: Merge the monthly RF data back with the monthly market and healthcare returns
# Assume r_mkt and r_health are recorded at the first of each month or similar
# so 'date' in the r_mkt / r_health row identifies the month
mkt_health <- data4 %>%
  select(date, r_mkt, r_health) %>%
  distinct()  # Keep only unique monthly rows

capm_data <- mkt_health %>%
  mutate(YearMonth = floor_date(as.Date(date), unit = "month")) %>%
  left_join(rf_daily, by = "YearMonth")

# You now have a monthly data frame with columns:
#   date, r_mkt, r_health, RF_monthly
# all in percent form

# STEP C: Estimate the CAPM via a linear model
# Convert everything from % to decimal form for typical CAPM computations
capm_data <- capm_data %>%
  mutate(
    r_mkt_dec     = r_mkt / 100,
    r_health_dec  = r_health / 100,
    RF_monthly_dec= RF_monthly / 100
  )

# CAPM model:  (r_health - RF) = alpha + beta * (r_mkt - RF) + error
capm_model <- lm(
  I(r_health_dec - RF_monthly_dec) ~ I(r_mkt_dec - RF_monthly_dec),
  data = capm_data
)

summary(capm_model)

# From summary(capm_model), you get:
# - The intercept (alpha), typically annualized by multiplying if needed
# - The slope (beta)
alpha_capm <- coef(capm_model)[1]
beta_capm  <- coef(capm_model)[2]
