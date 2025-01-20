######################################
## BA II -- EXERCISES 2 // SOLUTION ##
######################################

rm(list=ls())
library(xts)
library(lubridate)


#set Working Directory-----------------------------------------------------------------------------------------------------
tryCatch({
  library(rstudioapi)
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}, error=function(cond){message(paste("cannot change working directory"))
})

# you can also set your working directory using 
# setwd("path_to_your_data_folder")



# Exercise 1 --------------------------------------------------------------

price_data <- read.csv("price_data.csv", sep=";", dec=",")

stock1 <- price_data[price_data$Name == "Dictum Ltd",4:5]
stock2 <- price_data[price_data$Name == "Pede Ltd",4:5]
stock3 <- price_data[price_data$Name == "Sed LLP",4:5]
stock4 <- price_data[price_data$Name == "Consectetuer Company",4:5]
stock5 <- price_data[price_data$Name == "Vel LLC",4:5]

stock1 <- xts(stock1$Price, order.by = as.Date(stock1$Date))
stock2 <- xts(stock2$Price, order.by = as.Date(stock2$Date))
stock3 <- xts(stock3$Price, order.by = as.Date(stock3$Date))
stock4 <- xts(stock4$Price, order.by = as.Date(stock4$Date))
stock5 <- xts(stock5$Price, order.by = as.Date(stock5$Date))


#---------------------------
# 1) COMPUTE PORTFOLIO VALUE
#---------------------------

pf.value <- 100*stock1 + 100*stock2 + 200*stock3 + 150*stock4 + 50*stock5
stocks <- cbind(stock1*100, stock2*100, stock3*200, stock4*150, stock5*50)

pf.value2 <- xts(rowSums(stocks["2003/"],na.rm = T), time(stocks["2003/"]))

head(pf.value["2003/"])
head(pf.value2)
tail(pf.value)
tail(pf.value2)

plot(pf.value["2003/"])
plot(pf.value2)


#------------------------------------
# 2) COMPUTE AND PLOT MONTHLY RETURNS
#------------------------------------

pf.ret <- pf.value/lag(pf.value)-1
pf.ret2 <- pf.value2/lag(pf.value2)-1

plot(pf.ret["2003/"])


#--------------------------------
# 3) COMPARE RETURN DISTRIBUTIONS
#--------------------------------

stock1.ret <- (stock1/lag(stock1) -1)
stock2.ret <- (stock2/lag(stock2) -1)
stock3.ret <- (stock3/lag(stock3) -1)
stock4.ret <- (stock4/lag(stock4) -1)
stock5.ret <- (stock5/lag(stock5) -1)

plot(density(pf.ret["2003/"]), xlim=c(-1,1))
lines(density(stock1.ret["2003/"]), col = "steelblue")
lines(density(stock2.ret["2003/"]), col = "coral")
lines(density(stock3.ret["2003/"]), col = "darkorange")
lines(density(stock4.ret["2003/"]), col = "darkorchid")
lines(density(stock5.ret["2003/"]), col = "green")


#--------------------------------------------
# 4) VISUALIZE EVOLUTION OF PORTFOLIO WEIGHTS
#--------------------------------------------

rw1 <- 100*stock1/pf.value
rw2 <- 100*stock2/pf.value
rw3 <- 200*stock3/pf.value
rw4 <- 150*stock4/pf.value
rw5 <- 50*stock5/pf.value

plot(merge(rw1,rw2,rw3,rw4,rw5)["2003/"])


#-----------------------------------
# 5) COMPUTE VOLATILITY AND SKEWNESS
#-----------------------------------

sd(pf.ret["2003/"],na.rm = T)
sd(pf.ret2["2003/"],na.rm = T)
sd(stock1.ret["2003/"], na.rm = T)
sd(stock2.ret["2003/"], na.rm = T)
sd(stock3.ret["2003/"], na.rm = T)
sd(stock4.ret["2003/"], na.rm = T)
sd(stock5.ret["2003/"], na.rm = T)

library(moments)
skewness(pf.ret["2003/"])
skewness(pf.ret2, na.rm = T)
skewness(stock1.ret["2003/"])
skewness(stock2.ret["2003/"])
skewness(stock3.ret["2003/"])
skewness(stock4.ret["2003/"])
skewness(stock5.ret["2003/"])


#------------------------------------------------
# 6) COMPUTE VALUE-AT-RISK AND EXPECTED SHORTFALL
#------------------------------------------------

quantile(x = pf.ret["2003/"], probs=.02)
mean(pf.ret["2003/"][which(pf.ret["2003/"] < quantile(x = pf.ret["2003/"], probs = .02))], na.rm = T)

quantile(x = pf.ret2, probs = .02, na.rm=T)
mean(pf.ret2[which(pf.ret2 < quantile(x = pf.ret2, probs = .02, na.rm = T))], na.rm = T)


#------------------------
# 7) COMPUTE SHARPE RATIO
#------------------------

rf <- read.csv("risk_free_return_monthly.csv")
head(rf)
rf$date <- as.Date(paste0(rf$date, "01"), format="%Y%m%d")
rf <- xts(rf$rf/100, order.by = rf$date)

time(pf.ret) <- ceiling_date(time(pf.ret), unit = "month") - 1
time(pf.ret2) <- ceiling_date(time(pf.ret2), unit = "month") - 1
time(rf) <- ceiling_date(time(rf), unit = "month") - 1
all(time(pf.ret2) %in% time(rf))

((1 + mean(pf.ret2-rf, na.rm = T))^12-1) / (sd(pf.ret2-rf, na.rm = TRUE)*sqrt(12))


#------------------------------
# 8) COMPARE CUMULATIVE RETURNS
#------------------------------

pf.ret.ew <- (stock1.ret + stock2.ret + stock3.ret + stock4.ret + stock5.ret)/5
time(pf.ret.ew) <- ceiling_date(time(pf.ret.ew), unit = "month") - 1

plot(pf.ret.ew["2003/"])
lines(pf.ret["2003/"], lwd=2, col="blue")

plot(cumprod(1 + pf.ret.ew["2003/"]))
lines(cumprod(1 + pf.ret["2003/"]), lwd = 2, col = "blue")

plot(cumprod(1 + pf.ret.ew["2003/"]))
lines(cumprod(1 + pf.ret2[-1]), lwd = 2, col = "blue")



#---------------------------------------------
# EXTRA: COMPARE INDIVIDUAL CUMULATIVE RETURNS
#---------------------------------------------

cumprods <- cumprod(1 + pf.ret["2003/"])
indiviudal_stocks <- cbind(cumprod(1 + stock1.ret["2003/"]),
                           cumprod(1 + stock2.ret["2003/"]),
                           cumprod(1 + stock3.ret["2003/"]),
                           cumprod(1 + stock4.ret["2003/"]),
                           cumprod(1 + stock5.ret["2003/"]))

cumprods <- cbind(cumprods, indiviudal_stocks)
plot(cumprods)
# plot(na.approx(cumprods))


# Exercise 2 --------------------------------------------------------------

#-----------------------
# 1) INVESTIGATE 95%-VaR
#-----------------------

load("index_data.RData")

# convert the file into xts, extract the S&P500 and order it by the corresponding date
SP <- xts(indices$sp.xts, order.by = as.Date(rownames(indices)))

# compute the simple return
SPreturns <- SP/lag(SP)-1
SPreturns <- na.omit(SPreturns)  

# compute the 95% Value at Risk for the whole S&P
VaR95 <- quantile(SPreturns, probs=0.05)
VaR95

# plot it (we converted the VaR into an xts document in order to plot it over a certain time period)
VaRplot <- rep(VaR95, length(SPreturns))
VaRxtsI <- xts(VaRplot, order.by = time(SPreturns))

plot(SPreturns, col = "steelblue",type = "p")
lines(VaRxtsI,col = "coral")
points(SPreturns[SPreturns < VaR95], col = "gold", pch = 20, cex = 1.2)

# computing the number of points which is below the VaR-line 
mean(SPreturns < VaR95)


#-------------------------------
# 2) INVESTIGATE ROLLING 95%-VaR
#-------------------------------

# setting up a for loop which computes the VaR for the next day, using past data only (from the 250th on)
VaR95I <- quantile(SPreturns[1:250], probs=0.05)
VaR_expand <- rep(NA,250)
for (i in 251:length(SPreturns)) {
  VaR_expand[i] <- quantile(SPreturns[1:(i-1)], probs = 0.05)
}

# checking whether the new VaR has the same length as the returns and converting it into an xts file
length(VaR_expand)
length(SPreturns)
VaRxtsII <- xts(VaR_expand, order.by = time(SPreturns))

# plotting it again with the new VaR line
plot(SPreturns, col = "steelblue", type = "p")
lines(VaRxtsII, col = "coral", lty = 1, lwd = 3)
points(SPreturns[SPreturns < VaRxtsII], col = "gold", pch = 20,cex = 1.4)

# and computing what percentage really is below the line --> 0.015 percentage points too much
mean(SPreturns < VaRxtsII, na.rm=TRUE)
# according to this calculation ~1.5% of our returns are below our VaR line even though they shouldn't 


#--------------------------
# 3) COMPUTE AVERAGE RETURN
#--------------------------

# computing the arithmetic mean of all of the returns --> slightly positive
armean <- sum(SPreturns) / length(SPreturns)
armean


#-------------------------
# 4) PREDICTING VOLATILITY
#-------------------------

# applying the sd function over all the returns for overlapping windows of 25 trading days in order to get the volatility
volatility <- rollapply(SPreturns, width = 25, align = "right", FUN = sd)

# lag the time series and apply it to our volatiltiy to get "next days volatility"
tomorrowsvolatiltiy <- lag(volatility)
plot(tomorrowsvolatiltiy)


#----------------------
# 5) PREDICTING 95%-VaR
#----------------------

# we now assume that tomorrows returns follow a normal distribution with mean 0 and our volatility prediction
# we want to get the 95% Value at risk from this normal distribution
VaRIII <- qnorm(p = 0.05, mean = 0, sd = tomorrowsvolatiltiy)

# and do the same plotting as done above
plot(SPreturns, col = "steelblue", type = "p")
lines(VaRIII, col = "coral", lty = 1, lwd = 2)
points(SPreturns[SPreturns < VaRIII], col = "gold",pch = 20,cex = 1.2)

# now we check the percentage of returns that really is below our VaR
lowerIII <- which(SPreturns < VaRIII)
length(lowerIII) / length(coredata(SPreturns))
mean(SPreturns < VaRIII, na.rm = TRUE)
# and see that just ~0.7% additional returns are below our VaR line which is quite good


#--------------------------------------
# 6) COMPARING DIFFERENT LEVELS FOR VaR
#--------------------------------------

# we compute the VaR for different types of percentages
VaR90 <- qnorm(p = 0.1, sd = tomorrowsvolatiltiy)
VaR95 <- qnorm(p = 0.05, sd = tomorrowsvolatiltiy)
VaR99 <- qnorm(p = 0.01, sd = tomorrowsvolatiltiy)
VaR99_9 <- qnorm(p = 0.001, sd = tomorrowsvolatiltiy)

#and check how close they are to the actual number of points below the VaR line
mean(SPreturns < VaR90, na.rm = TRUE) / 0.1

mean(SPreturns < VaR95, na.rm = TRUE) / 0.05

mean(SPreturns < VaR99, na.rm = TRUE) / 0.01

mean(SPreturns < VaR99_9, na.rm = TRUE) / 0.001

