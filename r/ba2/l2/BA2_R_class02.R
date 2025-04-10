#########################
## BA II --- LECTURE 2 ##
#########################

rm(list=ls())
library(xts)
library(lubridate)


# Set Working Directory ---------------------------------------------------
tryCatch({
  library(rstudioapi)
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}, error=function(cond){message(paste("cannot change working directory"))
})

getwd()


# Loading Price Data ------------------------------------------------------
price_data <- read.csv(file="price_data.csv", sep=";", dec=",") # reading-in the csv file
price_data <- na.omit(price_data) # removing whole rows with NAs
head(price_data)


## create an xts matrix where rows correspond to points in time and each column corresponds to the price series of a different firm

IDs <- unique(price_data$ID) # extracting unique firm IDs included in the dataset 
head(IDs)
p <- list() # create an empty list
          
for (i in 1:length(IDs)) { # loop through firm IDs
  price_data_i <- price_data[price_data$ID==IDs[i], ] # extracting data corresponding to firm i
  p[[i]] <- xts(price_data_i$Price, order.by=as.Date(as.character(price_data_i$Date), format="%Y-%m-%d")) # converting prices of firm i to an xts timeseries
}

p[1]

price <- do.call(cbind, p) # cbinding all listelements together using do.call
colnames(price) <- paste0("X", IDs)
dim(price)
price <- price["1990/"]
price[1:10,1:5]

price <- apply.daily(price, FUN=function(x) x[1,] ) # for each day, take only the first of the available prices
price[1:10,1:5]

price <- abs(price)
plot(price)


# Simple vs Log Returns ---------------------------------------------------
Sys.setenv(TZ = "UTC") # setting system's timezone to UTC

p1 <- na.omit(price[,1])
plot(p1, col="forestgreen", type="o", pch=18)

r1_simple <- p1/lag(p1)-1 
r1_log <- diff(log(p1))
head(r1_simple)
head(r1_log)

# plotting the original series together with simple and log returns
plot(cbind(p1,r1_simple), multi.panel=TRUE,
     col=c("forestgreen", "coral"), type="o", pch=19, lwd=2, yaxis.same=FALSE) 
lines(r1_log, col="steelblue", type="o", lty=2, pch=19, lwd=2, on=2)

# aggregating log returns over time
r1_log_tot <- sum(r1_log, na.rm=TRUE)
r1_log_tot
exp(r1_log_tot)-1
p1[1]*exp(r1_log_tot)
last(p1)

# aggregating simple returns over time
r1_simple_tot_wrong <- sum(r1_simple, na.rm=TRUE)
r1_simple_tot_wrong
p1[1]*(1+r1_simple_tot_wrong)
last(p1)
r1_simple_tot <- prod(1+r1_simple, na.rm=TRUE)-1 # correct way to compute simple return
r1_simple_tot
p1[1]*(1+r1_simple_tot)
last(p1)

r1_simple <- r1_simple[-1]
r1_log <- r1_log[-1]

# cumulative returns
r_cum_simple <- cumprod(1+r1_simple)-1
head(r_cum_simple)
lines(as.vector(p1[1])*(1+r_cum_simple), col="yellow", on=1)

r_cum_log <- cumsum(r1_log)
head(r_cum_log)
lines(as.vector(p1[1])*exp(r_cum_log), col="blue", on=1)


# Measuring Risk ----------------------------------------------------------
r1 <- na.omit(r1_simple)


### VOLATILITY ###

var(r1) # monthly variance over whole sample period
sd(r1) # monthly standard deviation over whole sample period
sd(r1)^2 # == variance

# annualizing volatility)
var(r1)*12 # yearly variance over whole sample period
sd(r1)*sqrt(12) # yearly volatility over whole sample period

# two measures of monthly volatility: (1) square root of squared returns (you could also take absolute value right away)
# and (2) variance over a rolling window
plot(sqrt(r1^2), col="steelblue", lwd=2, main="Monthly Volatility")
lines(rollapply(r1, width=6, align="center", FUN=sd), lwd=2, col="coral")
addLegend("topleft", legend.names=c("vola from squared returns", "vola from 6M rolling standard dev."),
          col=c("steelblue", "coral"), lwd=2)


### COVARIANCE AND CORRELATION ###

p <- na.omit(price[,1:10])
plot(p)
r <- na.omit(p/lag(p)-1)

# covariance
round(var(r), digits=4)
round(cov(r), digits=4)

# correlation
round(cor(p), digits=4)

price <- na.approx(price)
r <- price/lag(price)-1

plot(r)
plot(r, ylim=c(-2,10))

quantile(r, probs=c(0.005, 0.995), na.rm=TRUE)
qlower <- quantile(r, probs=0.005, na.rm=TRUE)
qupper <- quantile(r, probs=0.995, na.rm=TRUE)

dates <- time(r)
r <- coredata(r)
r[r<qlower] <- NA
r[r>qupper] <- NA
r <- xts(r, order.by=dates)[-1,]
plot(r)

r_mkt <- rowMeans(r, na.rm=TRUE)
r_mkt <- xts(r_mkt, order.by=time(r))
plot(r_mkt, col="steelblue")
plot(cumprod(1+r_mkt))


### COMPARING VOLATILITY OF MARKET AND SINGLE STOCKS

vola_single <- apply(coredata(r), 2, FUN=function(x) sd(x, na.rm=TRUE) )
vola_mkt <- sd(r_mkt, na.rm=TRUE)

hist(vola_single)
points(x=vola_mkt,y=1, col="coral", pch=10, cex=3)


### SKEWNESS ###
library(moments)

skewness(r_mkt, na.rm=TRUE)

roll_skew_mkt <- rollapply(r_mkt, width=24, FUN=function(x) skewness(x, na.rm=TRUE))
plot(roll_skew_mkt)


### VALUE AT RISK ###
r_mkt <- na.omit(r_mkt)

VaR95 <- quantile(r_mkt, probs=0.05)
VaR95
plot(coredata(r_mkt), col="steelblue")
abline(h=VaR95, col="coral", lty=2)
points(x=which(coredata(r_mkt)<VaR95),
       y=coredata(r_mkt)[coredata(r_mkt<VaR95)], col="coral" )


### EXPECTED SHORTFALL ###
VaR95
mean(r_mkt[r_mkt < VaR95])


### SHARPE RATIO ###
ff <- read.csv(file="risk_free_return_monthly.csv", header=TRUE, sep=",", dec=".")
head(ff)
ff <- na.omit(ff)
rf <- xts(ff$rf, order.by = ceiling_date(as.Date(paste0(as.character(ff$date),"01"), format="%Y%m%d"), unit="month") - 1)

plot(rf)

time(r_mkt) <- ceiling_date(time(r_mkt), unit="month") - 1

plot(cbind(r_mkt, r_mkt-rf))

rex_avg <- mean(r_mkt-rf) # average monthly excess return

((1+rex_avg)^12 - 1) / (sd(r_mkt-rf)*sqrt(12)) # annualized sharpe ratio


( prod(1+r_mkt-rf)^(12/length(r_mkt)) -1) / (sd(r_mkt-rf)*sqrt(12)) # annualized SR using geo. mean


# Market Return using Market Cap for Weights ------------------------------
head(price_data)
price_data$mcap <- price_data$Price * price_data$Shares.Outstanding

IDs <- unique(price_data$ID)
head(IDs)
mcap <- list() 

for (i in 1:length(IDs)) {
  price_data_i <- price_data[price_data$ID==IDs[i], ]
  mcap[[i]] <- xts(price_data_i$mcap, order.by=as.Date(as.character(price_data_i$Date), format="%Y-%m-%d"))
}

mcap[1]

mcap <- do.call(cbind, mcap)
colnames(mcap) <- paste0("X", IDs)
dim(price)
mcap <- mcap["1990/"]
mcap[1:10,1:5]

mcap <- apply.daily(mcap, FUN=function(x) x[1,] ) 
mcap <- abs(mcap)

mcap_weights <- lag(mcap)/rowSums(lag(mcap), na.rm=TRUE)
mcap_weights[1:10,1:5]

r_mkt <- xts(rowSums(r*mcap_weights, na.rm=TRUE), order.by=time(r))

plot(r_mkt, col="steelblue")

