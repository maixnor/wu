#########################
## BA II --- LECTURE 1 ##
#########################


rm(list=ls())
setwd("path_to_your_data_folder")


# Reading-in Data from CSV ------------------------------------------------

# read-in data on firms' stock prices
price_data <- read.csv(file="price_data.csv")
?read.csv

# specify separator appropriately
price_data <- read.csv(file="price_data.csv", sep=";")
head(price_data)

head(price_data$Name)
class(price_data$Name) # character variables are read into R as variables of class character by read.csv()

mean(price_data$Price) # let's take the mean of Price
class(price_data$Price)
# R didn't get that this should be numeric,
# read.csv() does not recognize "," as a decimal point unless you explicitly specify this


price_data <- read.csv(file="price_data.csv", sep=";", dec=",") # sep and dec specified correctly
dim(price_data)
head(price_data)
class(price_data$Name)
class(price_data$Price)
mean(price_data$Price)
which(is.na(price_data$Price))


# load firm data
firm_data <- read.csv(file = "firm_data.csv", sep=",", dec=".")


### SAVING / LOADING R OBJECTS ###
save(price_data, file="price_data.RData")
rm(price_data)
head(price_data)
load(file="price_data.RData")
head(price_data)
save(firm_data, file="firm_data.RData")


# Visualizing Cross-Sectional Data ----------------------------------------

## BARPLOT

## plot the number of firms per industry in 2012
par(mar=c(12,4.1,4.1,2.1)) # adjust margin in order to display the x-axis labels properly
par(xpd=TRUE) # allow the graphics device to draw outside of the plot area
data.freqs <- table(substr(firm_data$Industry[firm_data$Date=="2012-12-31"],1,1)) # get number of firms per industry, aggregated to highest industry classification level

bp <- barplot(data.freqs, col="steelblue", border=FALSE, las=2, ## Barplot: use las=2 to write the x-axis vertically instead of horizontally
            main="Number of firms per industry in 2012",
            names.arg = c("Agriculture,...","Manufacturing I","Manufacturing II",
                          "Transportation & Utilities","Wholesale & Retail","Finance","Services I","Services II"))
text(x=bp, y=data.freqs, labels=data.freqs, pos=3) # write the number of firms in each industry above the respective bars
## reset graphcis device 
par(xpd=FALSE) 
par(mar=c(5.1,4.1,4.1,2.1))


## HISTOGRAM

## plot the distribution of market equity values in 2018 for small firms 
## with a histogram and add a density line
me <- (price_data$Price*price_data$Shares.Outstanding)[price_data$Date=="2018-12-31"]

den <- density(me[which(me>0&me<4000000)], from=0)
cord.x <- c(den$x[1],den$x,rev(den$x)[1])
cord.y <- c(0,den$y,0)

hist(me[which(me>0&me<4000000)], breaks = 100, probability = TRUE,
     main="Distribution of market equity",xlab="Market value",
     border=FALSE, col="steelblue")
lines(den, lwd=2,col="lightgrey")
polygon(x=cord.x, y=cord.y, col=adjustcolor("lightgrey", alpha.f=.5), border=FALSE)


## BOXPLOT

## Boxplot of book values of equity
boxplot(firm_data$Equity[(firm_data$Date=="2018-12-31") & (firm_data$Equity>0)]) # there are a a few outliers that make the plot "unreadable"

boxplot(firm_data$Equity[(firm_data$Date=="2018-12-31") & (firm_data$Equity>0&firm_data$Equity<5000)],
        main="Firm Equity")


## SCATTERPLOT

##  plot market value against book value
plot(x = firm_data$Equity[firm_data$Date=="2012-12-31"],
     y = firm_data$Debt[firm_data$Date=="2012-12-31"], 
     main="Book vs. market value - December 2012", ylab="Debt value", xlab="Equity value", 
     pch=20, ylim = c(0,6000), xlim = c(0,6000))
abline(a = 0, b = 1, col="steelblue", lty=2) #Add the "45 degree" line


## QQ-PLOT

load("gspc_ret.RData")

## QQ-Plot
qqnorm(gspc.ret, main="Normal Q-Q Plot for S&P 500 returns", pch=20)
qqline(gspc.ret, lwd=1.5, lty=2, col="steelblue")



# Handling Time Series Data with XTS --------------------------------------

library(xts) # load the xts package (after installing it once)
library(lubridate)


### R's Date format ###

dates <- c("2016-03-02", "2016-03-25")
class(dates)
dates <- as.Date(dates, format="%Y-%m-%d") #could also use ymd(dates)
class(dates)
dates[2]-dates[1]
seq(from=dates[1], to=dates[2], by="day")
seq(from=as.Date("2000-12-31"), to=as.Date("2010-12-31"), by="year")


## rounding dates (functions from lubridate)
dates
round_date(dates, unit = "month")
floor_date(dates, unit = "month")
ceiling_date(dates, unit = "month")


head(price_data)
summary(price_data)

price_data <- na.omit(price_data) #removing whole rows if at least one NA

# extracting data on just the first firm
f1 <- price_data[price_data$ID==10001 ,]


head(f1$Date)
class(f1$Date)

f1$Date <- as.Date(f1$Date, format="%Y-%m-%d") #convert the date to class "Date"
head(f1$Date)
class(f1$Date)


# convert the price into an xts object, using the dates in the appropriate "Date" format
p1 <- xts(f1$Price, order.by=f1$Date)
head(p1)
class(p1)
plot(p1, col="steelblue")


# look at a second firm
f2 <- price_data[price_data$ID==10002, ]
p2 <- xts(f2$Price, order.by=as.Date(f2$Date))

plot(p2, col="coral")


# plotting the two time series together
length(p1)
length(p2)
p12 <- cbind(p1, p2)
colnames(p12) <- c("p1", "p2")
head(p12)
dim(p12)
tail(p12)

plot(p12, col=c("steelblue", "coral"), legend.loc="topright")


# using lines() instead
plot(p12[,1],col="steelblue") # plot first series
lines(p12[,2], col="coral") # add second series
addLegend("topleft", legend.names=c("p1", "p2"), col=c("steelblue", "coral"), lwd=1)


### converting all time series to xts ###

IDs <- unique(price_data$ID)
head(IDs)
p <- list()
for (i in 1:length(IDs)) {
  price_data_i <- price_data[price_data$ID==IDs[i], ]
  p[[i]] <- xts(price_data_i$Price, order.by=as.Date(as.character(price_data_i$Date), format="%Y-%m-%d"))
}

p[1]


?do.call
# test <- list(a=c(1,2,3), b=10:12)
# test
price <- do.call(cbind, p)
colnames(price) <- paste0("X", IDs) # add the X to get alpha-numeric colnames instead of numeric colnames, which might be an issue
dim(price)
price <- price["1990/"]
price[1:10,1:10]



# Subsetting Time ---------------------------------------------------------

p12[1] #gives you entire timepoint #1 for all columns

# subsetting to particular timewindow
p12["2010"]
plot(p12["2010"], col=c("steelblue", "coral"))
plot(p12["2010-03/"], col=c("steelblue", "coral"))
plot(p12["/2010"], col=c("steelblue", "coral"))
plot(p12["2005-12-03/2010-04"], col=c("steelblue", "coral"))


# endpoints of time periods
endpoints(p12, on="quarters")
p12[endpoints(p12, on="quarters"), ]
# equivalent
p12[endpoints(p12, on="quarters")]

plot(p12[endpoints(p12, on="years")], col=c("steelblue", "coral"))


# startpoints of time periods
p12[xts:::startof(p12, "quarters"), ]


# further time-related functionality
time(p12)
weekdays(time(p12))
nyears(p12)
nquarters(p12)
nweeks(p12)

# subsetting to all observations on a monday
p12[weekdays(time(p12))=="Monday", ]

# getting rid of xts
coredata(p12)



# Arithmetic and Time-Shifting Operations on XTS Objects ------------------

# time lags
(p1 <- p12["2000-01/2000-06",1])
(p1_lag <- p12["1999-12/2000-05",1])
dim(p1)
dim(p1_lag)

# taking differences from one period to the next
p1 - p1_lag # does not work since xts aligns dates of the two time series and throws away dates not included in both series
cbind(p1, p1_lag)

# instead, use lag() to properly lag the timesries
cbind(p1, lag(p1))
p1 - lag(p1)

# to calculate differences between timepoints, there is also diff()
diff(p1)

# calculating returns
p1/lag(p1)-1

# forward or backfilling missing observations
na.locf(diff(p1), fromLast=TRUE)
# na.locf is often useful when dealing with multiple timeseries
plot(p12, col=c("steelblue", "coral"))
plot(na.locf(p12),  col=c("steelblue", "coral"))

# na.approx
# used to linearly interpolate between observations to fill missing values
test <- p12[1:10,1]
test[3] <- NA
test
na.approx(test)


### APPLY.WHATEVER ###
price[1:10,1:10]

price <- apply.daily(price, FUN=function(x) x[1,] )
price[1:10,1:10]

price_avg_yearly <- apply.yearly(price, FUN= function(x) mean(x) )
price_avg_yearly

price_avg_yearly <- apply.yearly(price, FUN= function(x) mean(x, na.rm=TRUE) )
price_avg_yearly

price_avg_yearly <- apply.yearly(price, FUN= function(x) colMeans(x, na.rm=TRUE) )
price_avg_yearly[,1:5]

# na.approx to plot yearly and monthly frequency together
price_ym <- cbind(price_avg_yearly[,1], price[,1])
colnames(price_ym) <- c("yearly", "monthly")
head(price_ym, 24)
plot(price_ym, legend.loc="topleft")
plot(na.approx(price_ym), legend.loc="topleft")


### ROLLAPPLY ###
?rollapply
p2_rollapp <- rollapply(p2, width=12, align="right", FUN=mean)
p2_rollapp
plot(p2, col="coral")
lines(p2_rollapp, col="steelblue", lty=2, lwd=2)


# Visualizing Multiple XTS Series -----------------------------------------

library(colorspace) #package for nicer colors


plot(price[,1:10], col=rainbow_hcl(10))

plot(price["1990/2000"][,1:3], multi.panel=3, col=rainbow_hcl(10)[1:3])
lines(price["1990/2000"][,10], on=2, col=rainbow_hcl(10)[10])




# Final Remarks -----------------------------------------------------------

any(apply(coredata(price),2,FUN=function(x) min(x, na.rm=TRUE) ) <0) # some prices are negative!

# negative prices correspond to averages of bid/ask instead of actual trades
price <- abs(price) # we don't care about bid/ask quotes vs traded here
plot(price["1990/2000"][,1:10], col=rainbow_hcl(10))

