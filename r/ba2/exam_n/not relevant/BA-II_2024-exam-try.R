###########################################
##    BA II -- FINAL EXAM // 17.01.24    ##
###########################################

## TOTAL  /40

## Libraries
library(zoo)
library(xts)
library(lubridate)
library(colorspace)
library(moments)
library(ggplot2)

## Load the data
load("final_data.RData")

##EX1     /13

#1.   /2

# 1) Convert data1 to an xts object

class(data1$date)
t_index <- as.Date(data1[,1], format="%Y-%m-%d")
class(t_index)

data1_xts <- xts(data1[,-1], order.by = t_index)
head(data1_xts)
ndays(data1_xts)
nweeks(data1_xts)

#2.   /2

# 2) Fill missing values using linear interpolation
data1_xts <- na.approx(data1_xts)

#3.   /1

# 3) Compute daily simple returns
#    r_t = (P_t / P_(t-1)) - 1
daily_returns <- data1_xts / lag(data1_xts, 1) - 1

daily_returns <- daily_returns[-1, ]  # typically remove the first row because lag introduces NA
head(daily_returns)

#4.   /4

# 4) Set extreme values (<10th quantile or >90th quantile) to NA column by column
daily_returns_clipped <- apply(daily_returns, 2, function(x) {
  q10 <- quantile(x, 0.10, na.rm = TRUE)
  q90 <- quantile(x, 0.90, na.rm = TRUE)
  
  # Replace all values below q10 or above q90 with NA
  x[x < q10 | x > q90] <- NA
  x
})

head(daily_returns_clipped)

#5.   /4

# 5) Aggregate (clipped) daily returns to yearly total returns
yearly_returns <- apply.yearly(daily_returns_clipped, FUN = function(x) {
  # x is all daily returns (for each column/asset) in a given year
  # compute total return = prod(1 + daily_return) - 1, omitting NA values
  apply(x, 2, function(col) {
    col <- na.omit(col)
    prod(1 + col) - 1
  })
})

head(yearly_returns)
nyears(data1_xts)

##EX2     /10

# Example: data2 is read into a data frame with columns 'maturity' (years) and 'yield_pa' (annual %).

head(data2)

# 1. Compute the implied bond price for each row:
#    Price (%) = 100 / (1 + yield_in_decimal)^maturity_in_years
data2$price_percent <- 100 / (1 + data2$yield_pa / 100)^data2$maturity
head(data2)

# 2. Create a final data frame that contains maturity and the corresponding price.
bond_prices <- data.frame(
  maturity     = data2$maturity,
  price_percent = data2$price_percent
)

bond_prices

# Example: data2 is a data frame with columns 'maturity' (in years) and 'yield_pa' (annual yield in %).

# Step A: Calculate bond prices in % of notional
data2$price_percent <- 100 / (1 + data2$yield_pa / 100)^data2$maturity

# Step B: Classify bond status based on price
# - discount if price < 100
# - par if price == 100
# - premium if price > 100
data2$status <- ifelse(
  data2$price_percent < 100, "discount",
  ifelse(
    data2$price_percent == 100, "par",
    "premium"
  )
)

head(data2)

# Step C: Create a final data frame containing all relevant info:
bond_prices_status <- data.frame(
  maturity      = data2$maturity,
  yield_pa      = data2$yield_pa,
  price_percent = data2$price_percent,
  status        = data2$status
)

# Print or return the final data frame
bond_prices_status


##EX3     /11

library(xts)

#1.   /1


# 1) Convert data3 into an xts object
head(data3)
class(data3$date)

data3_xts <- xts(data3[,-1], order.by = as.Date(data3$date))

head(data3_xts)
class(data3_xts)

# 2) Create an equally weighted portfolio
#    Note that returns in data3 are in percent, so convert them to decimal format.
data3_decimal <- data3_xts / 100
pf_returns <- rowMeans(data3_decimal)  # Equally weighted => average of all columns
pf_returns_xts <- xts(pf_returns, order.by = index(data3_decimal))

head(pf_returns_xts)

#-------------------------------#
#   Risk Metrics Computation    #
#-------------------------------#


# Historical 99% VaR: the 1% quantile of returns
var_99 <- function(x) {
  # 1% of the worst returns
  quantile(x, probs = 0.01, na.rm = TRUE)
}

# Historical 99% ES: the average of returns <= the 1% quantile
es_99 <- function(x) {
  # find the 1% quantile
  q_1 <- quantile(x, probs = 0.01, na.rm = TRUE)
  # average of all returns at or below q_1
  mean(x[x <= q_1], na.rm = TRUE)
}

###################
# 2(a) Volatility
###################
vol_individual <- apply(data3_decimal, 2, sd)       # each column (stock)
vol_portfolio  <- sd(pf_returns_xts)                # portfolio

############################
# 2(b) Historical 99% VaR
############################
var99_individual <- apply(data3_decimal, 2, var_99) # each stock
var99_portfolio  <- var_99(as.vector(pf_returns_xts))

head(var99_individual)
head(var99_portfolio)

###################################
# 2(c) Historical 99% Expected Shortfall
###################################
es99_individual <- apply(data3_decimal, 2, es_99)
es99_portfolio  <- es_99(as.vector(pf_returns_xts))

risk_summary <- data.frame(
  Asset      = c(colnames(data3_decimal), "Portfolio"),
  Volatility = c(vol_individual, vol_portfolio),
  VaR_99     = c(var99_individual, var99_portfolio),
  ES_99      = c(es99_individual, es99_portfolio)
)

risk_summary

###############################################
# 3) Compare Volatility, VaR, and ES in plots
###############################################

# 1) Set up color vector so that individual stocks get one color,
#    and the portfolio gets another.
bar_colors <- rep("steelblue", nrow(risk_summary))
bar_colors[risk_summary$Asset == "Portfolio"] <- "red"

#--- Plot Volatility ---
# To display the bars in ascending order, you can optionally reorder them:
vol_order <- order(risk_summary$Volatility)
barplot(
  risk_summary$Volatility[vol_order],
  names.arg = risk_summary$Asset[vol_order],
  col = bar_colors[vol_order],
  las = 2,            # make axis labels vertical
  ylab = "Volatility (SD)",
  main = "Volatility Comparison"
)

#--- Plot 99% VaR ---
var_order <- order(risk_summary$VaR_99)
barplot(
  risk_summary$VaR_99[var_order],
  names.arg = risk_summary$Asset[var_order],
  col = bar_colors[var_order],
  las = 2,
  ylab = "99% VaR (returns in decimal)",
  main = "99% VaR Comparison"
)

#--- Plot 99% ES ---
es_order <- order(risk_summary$ES_99)
barplot(
  risk_summary$ES_99[es_order],
  names.arg = risk_summary$Asset[es_order],
  col = bar_colors[es_order],
  las = 2,
  ylab = "99% ES (returns in decimal)",
  main = "99% ES Comparison"
)

###############################################
# 4) Explain diversification effect.
###############################################

# Diversification is combining various assets or asset classes that don't move perfectly together, thus reducing overall portfolio risk. This spread of fund across different investments lowers overall portfolio volatility, also called risk. The diversification effect is visible across all three risk metrics. As we observe decreased volatility and a reduction in the VaR and ES, as losses in some assets are offset by gains or smaller losses in others. We can conclude that a diversified portfolio is less likely to expeerience extreme losses compared to holding single or highly correlated assets (i.e. assets from the same asset class, geographical location and industry). 

###############################################
# 5) Forcasting risk
###############################################

# Historical estimates: All three measures (volatility, VaR, ES) are based on historical data. There is no guarantee that tomorrow’s market conditions will mirror the past. A sudden shift in market regime or unexpected events can make these backward-looking metrics less reliable.
# Model assumptions: Even if we use non-parametric historical measures, the assumption is that the past distribution of returns is a good representation of future uncertainty. This assumption can fail if market dynamics change drastically.
# Data frequency: The metrics were computed on daily data, so applying them to a single future trading day might not capture intraday volatility or higher frequency shocks.
# Tail risk: VaR and ES focus on extreme losses, but if market liquidity disappears or correlations jump during a crisis, the realized losses might exceed the historical estimates.

##EX4     /6
#1.   /3

head(data4)

###########################
# 1) Convert percent to decimal
###########################
data4_dec <- data4 / 100

###########################
# 2) Estimate CAPM via linear model
###########################
# Convert 'xts' or 'zoo' to data.frame so lm() can use it easily
df_capm <- as.data.frame(data4_dec)

# Fit the CAPM regression
capm_model <- lm(I(r_health - RF) ~ I(r_mkt - RF), data = df_capm)

# Summarize results
summary(capm_model)

# Extract alpha and beta
alpha_capm <- coef(capm_model)[1]
beta_capm  <- coef(capm_model)[2]

alpha_capm
beta_capm
# ------------------------------------------------------------------------------------------------------------
