######################################
## BA II -- EXERCISES 1 // SOLUTION ##
######################################

rm(list=ls())
library(xts)


# set Working Directory ---------------------------------------------------

tryCatch({
  library(rstudioapi)
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}, error=function(cond){message(paste("cannot change working directory"))
})

# you can also set your working directory using 
# setwd("path_to_your_data_folder")


# Exercise 1 --------------------------------------------------------------

#---------------------
# 1) READ-IN FIRM DATA
#---------------------

firm_data <- read.csv(file="firm_data.csv", sep=",", dec=".")
head(firm_data)


#------------------------------------
# 2) CONVERT EARNINGS TO XTS AND PLOT
#------------------------------------

firm1 <- firm_data[firm_data$ID==10001,]
head(firm1)

earn1 <- xts(firm1$Earnings, order.by=as.Date(as.character(firm1$Date)) )
head(earn1)             
plot(earn1, col="steelblue")


#---------------------------------------------
# 3) CONVERT EARNINGS TO XTS AND SUBSET PERIOD
#---------------------------------------------

IDs <- unique(firm_data$ID) # get the IDs of unique firms in the data set
head(IDs)
e <- list()
for (i in 1:length(IDs)) {
  firm_data_i <- firm_data[firm_data$ID==IDs[i], ] #take all the price data of one firm with firm ID equal to IDs[i]
  e[[i]] <- xts(firm_data_i$Earnings, order.by=as.Date(as.character(firm_data_i$Date), format="%Y-%m-%d")) # convert the series of prices of this one firm to an xts object
}

# we now have a list, where each list element holds an xts time series with prices from one particular firm
e[1]

earn <- do.call(cbind, e)
colnames(earn) <- paste0("X", IDs) 
dim(earn)

earn <- earn["1990/2018"]
dim(earn)


#----------------------------------
# 4) CONVERT TO YEARLY OBSERVATIONS
#----------------------------------

earn_avg <- apply.yearly(earn, FUN=function(A) apply(A, 2, FUN=function(x) mean(x, na.rm=TRUE) ) )
head(earn_avg[,1:5])

earn_last <- apply.yearly(earn, FUN=function(A) apply(A, 2,
                                                      FUN=function(x) if(all(is.na(x))){
                                                        return(NA)
                                                      } else {
                                                        last(na.omit(x))
                                                      } ))
  
head(earn_last[,1:5])

head(price[,1:10])


#--------------------------
# 5) COMPUTE YEARLY RETURNS
#--------------------------

price_last <- apply.yearly(price, FUN=function(A) apply(A, 2,
                                                        FUN=function(x) if(all(is.na(x))){
                                                          return(NA)
                                                        } else {
                                                          last(na.omit(x))
                                                        }
                                                          ) )

head(price_last[,1:5])

r_yearly <- price_last / lag.xts(price_last) -1
head(r_yearly[,1:5])


#-----------------------------
# 6) PLOT RETURNS AND EARNINGS
#-----------------------------

dates <- seq(from=as.Date("1990-12-31"),
             to=as.Date("2018-12-31"),
             by="year")

earn1 <- xts(coredata(earn_avg[,1]), order.by=dates)
r1 <- xts(coredata(r_yearly[,1]), order.by=dates)

firm1 <- cbind(r1, earn1)
colnames(firm1) <- c("return", "earnings")
head(firm1)          

plot(firm1, multi.panel=2, col="steelblue", yaxis.same=FALSE)

earn1_ma <- rollapply(earn1, width=3, align="center", FUN=function(x) mean(x, na.rm=TRUE))
head(earn1_ma)

lines(earn1_ma, on=2, col="coral")


# Exercise 2 --------------------------------------------------------------

load("index_data.RData")
head(indices)


#------------------------
# 1) CONVERT INDEX TO XTS
#------------------------

indices <- xts(indices, order.by=as.Date(rownames(indices), format="%Y-%m-%d"))
head(indices)
plot(indices)

spx <- indices$sp.xts
ftse <- indices$ftse.xts


#------------------------------------
# 2) COUNT TRADING DAYS AND VISUALIZE
#------------------------------------

trading_days_m <- apply.monthly(spx, FUN=length)
trading_days_y <- apply.yearly(spx, FUN=length)

par(mfrow=c(2,2))
plot(trading_days_m, col="steelblue")
hist(trading_days_m, col="steelblue")
plot(trading_days_y["1991/2018"], col="coral")
hist(trading_days_y["1991/2018"], col="coral")
par(mfrow=c(1,1))


#---------------------------
# 3) PLOT EVOLUTION OF INDEX
#---------------------------

spx_first <- apply.monthly(spx, FUN=first)
spx_last <- apply.monthly(spx, FUN=last)
spx_monthly <- cbind(spx_first, spx_last)
colnames(spx_monthly) <- c("first","last")
head(spx_monthly)
plot(spx_monthly, col=c("steelblue", "coral"), legen.loc="topright")

spx <- spx["1995/2015"]
head(spx[c(endpoints(spx, on = "months"))])
head(spx[c(endpoints(spx, on = "months")[-253]+1)])


#------------------------------------
# 4) COMPUTE AND PLOT MONTHLY RETURNS
#------------------------------------

r_m <- spx_last / lag(spx_last) -1
plot(r_m, col="magenta")


#-------------------------
# 5) COMPUTE DAILY RETURNS
#-------------------------

r <- spx/lag(spx) -1
head(r)


#--------------------------------
# 6) VISUALIZE DENSITY OF RETURNS
#--------------------------------

hist(r, col="steelblue", breaks=100, probability=TRUE)
lines(density(na.omit(r)), col="coral", lwd=2)


#----------------------
# 7) PLOT DAILY RETURNS
#----------------------

r2 <- r^2
plot(cbind(r, r2), multi.panel=TRUE, col="steelblue", yaxis.same=FALSE)


#---------------
# 8) LAG RETURNS
#---------------

r_lag <- lag(r)
r2_lag <- lag(r2)


#---------------------------
# 9) COMPUTE AUTOCORRELATION
#---------------------------

cor(r[-(1:2)], r_lag[-(1:2)])
cor(r2[-(1:2)], r2_lag[-(1:2)])

r_ftse <- ftse/lag(ftse) -1
r_ftse_l <- lag(r_ftse)

r2_ftse <- r_ftse^2
r2_ftse_l <- lag(r2_ftse)

cor(r_ftse["2000/2018"], r_ftse_l["2000/2018"],use = "complete.obs")
cor(r2_ftse["2000/2018"], r2_ftse_l["2000/2018"],use = "complete.obs")


# Exercise 3 --------------------------------------------------------------

#-------------------------------------------------
# 1) VISUALIZE EVOLUTION OF INDICES IN SINGLE PLOT
#-------------------------------------------------

plot(indices["1995/2018"])


#----------------------------------------------------
# 2) VISUALIZE EVOLUTION OF INDICES IN MULTIPLE PLOTS
#----------------------------------------------------

plot(indices["1995/2018"], multi.panel=TRUE, yaxis.same=FALSE)


#---------------------------
# 3) COMPUTE MONTHLY RETURNS
#---------------------------

indices_m <- apply.monthly(indices, FUN=function(A) apply(A, 2,
                                                          FUN=function(x) last(na.omit(x)) ))

r_m <- indices_m / lag.xts(indices_m) -1
# easier, but cannot cope with NAs:
indices_m <- apply.monthly(indices, FUN=function(x) last(x) )
# or
indices_m <- indices[endpoints(indices, on="months"),]
r_m <- indices_m / lag.xts(indices_m) -1

head(indices_m)
