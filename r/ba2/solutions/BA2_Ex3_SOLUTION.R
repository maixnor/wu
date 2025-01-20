######################################
## BA II -- EXERCISES 3 // SOLUTION ##
######################################

rm(list=ls())
library(xts)
library(lubridate)
library(colorspace)


#set Working Directory-----------------------------------------------------------------------------------------------------
tryCatch({
  library(rstudioapi)
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}, error=function(cond){message(paste("cannot change working directory"))
})

# you can also set your working directory using 
setwd("../../data")



#--------------------------------------------------------------------------------------------------------------------------

######################
## Data Preparation ##
######################

#----------
# 1) PRICES
#----------

# reading-in the csv file
price_data <- read.csv(file="price_data.csv", sep=";", dec=",")

# removing whole rows with NA's
price_data <- na.omit(price_data)

# extracting unique firm IDs included in the dataset 
IDs <- unique(price_data$ID)
head(IDs)

# create an empty list:
# each list element will store the whole xts time series of prices corresponding to one particular firm (identified through the ID)
p <- list()

# looping through all firm IDs
for(i in 1:length(IDs)){
  
  # extracting all data corresponding to firm i
  price_data_i <- price_data[price_data$ID == IDs[i], ] 
  
  # converting prices of firm i to an xts timeseries
  p[[i]] <- xts(price_data_i$Price, order.by = as.Date(as.character(price_data_i$Date), format = "%Y-%m-%d"))
}

# cbinding all list-elements together using do.call
price <- do.call(cbind, p)

# add the X to get alpha-numeric colnames instead of numeric colnames, which might be an issue
colnames(price) <- paste0("X", IDs) 

dim(price)

price <- price["1990/"]
price[1:10,1:5]
# we see that some firms actually have two prices for the same month (e.g. 1990-03-30 is included twice for this reason)

# for each day, take only the first of the available prices
# -> if there are more prices, only the first is considered;
# if there is only one price, then this is also the "first price" of that day
price <- apply.daily(price, FUN = function(x) x[1,] )

price[1:10,1:5]
dim(price)

price <- abs(price)
plot(price)

# filling up NA values
price <- na.approx(price)



#--------------
# 2) MARKET CAP
#--------------

# compute market cap
price_data$mcap <- price_data$Price * price_data$Shares.Outstanding * 1000

#extracting unique firm IDs included in the dataset 
IDs <- unique(price_data$ID)

# create an empty list:
# each list element will store the whole xts time series of prices corresponding to one particular firm (identified through the ID)
mcap <- list()

# looping through all firm IDs
for(i in 1:length(IDs)){ 
  
  # extracting all data corresponding to firm i
  price_data_i <- price_data[price_data$ID == IDs[i], ] 
  
  # converting prices of firm i to an xts timeseries
  mcap[[i]] <- xts(price_data_i$mcap, order.by = as.Date(as.character(price_data_i$Date), format = "%Y-%m-%d"))
}

# cbinding all listelements together using do.call
mcap <- do.call(cbind, mcap)

# add the X to get alpha-numeric colnames instead of numeric colnames, which might be an issue
colnames(mcap) <- paste0("X", IDs)

dim(price)
mcap <- mcap["1990/"]
mcap[1:10,1:5]

# for each day, take only the first of the available prices
# -> if there are more prices, only the first is considered;
# if there is only one price, then this is also the "first price" of that day
mcap <- apply.daily(mcap, FUN = function(x) x[1,] )
mcap <- abs(mcap)



#------------------------
# 3) FIRM CHARACTERISTICS
#------------------------

firm_data <- read.csv(file = "firm_data.csv", sep=",", dec=".") 
head(firm_data)

IDs <- unique(firm_data$ID)
head(IDs)

debt <- list()
equity <- list()

for(i in 1:length(IDs)){
  firm_data_i <- firm_data[firm_data$ID == IDs[i], ]
  debt[[i]] <- xts(firm_data_i$Debt * 1000000, order.by = as.Date(as.character(firm_data_i$Date), format = "%Y-%m-%d"))
  equity[[i]] <- xts(firm_data_i$Equity * 1000000, order.by = as.Date(as.character(firm_data_i$Date), format = "%Y-%m-%d"))
}

length(debt)
length(equity)

debt <- do.call(cbind, debt)
colnames(debt) <- paste0("X", IDs)
debt <- debt["1990/2018"]

equity <- do.call(cbind, equity)
colnames(equity) <- paste0("X", IDs)
equity <- equity["1990/2018"]

price_full <- price
mcap_full <- mcap
debt_full <- debt
equity_full <- equity



#--------------------------------------------------------------------------------------------------------------------------

################
## Exercise 1 ##
################

set.seed(1234)

firm_sample <- sample(1:500, size=400)
firm_sample <- paste0("X", IDs[firm_sample])

price <- price_full[ , firm_sample]
mcap <- mcap_full[ , firm_sample]
debt <- debt_full[ , firm_sample]
equity <- equity_full[ , firm_sample]

dim(price)
dim(mcap)
dim(debt)
dim(equity)



#-----------------------
# 1) PLOT YEARLY RETURNS
#-----------------------

mcap2002 <- as.vector(na.approx(mcap)[endpoints(mcap, on="years")]["2002"]) # this might be problematic
names(mcap2002) <- firm_sample
mcap2002

sort(mcap2002)
sort_names <- names(sort(mcap2002))

r <- as.vector(tail(price["2003"], 1)) / as.vector(tail(price["2002"], 1)) -1
names(r) <- firm_sample

plot(mcap2002, r)

no_outlier <- mcap2002 >= quantile(mcap2002, 0.05) & mcap2002 <= quantile(mcap2002, .95)
plot(mcap2002[no_outlier], r[no_outlier])

cor(na.omit(cbind(mcap2002[no_outlier], r[no_outlier])))



#--------------------------------------
# 2) VISUALIZE DECILE PORTFOLIO RETURNS
#--------------------------------------

?cut
deciles <- cut(x = mcap2002, breaks = quantile(x = mcap2002, probs = seq(0,1,.1)),
               include.lowest = TRUE)

deciles_pf <- list()
deciles_yr <- NULL

for(i in levels(deciles)){
  deciles_pf[[length(deciles_pf)+1]] <- ((price["2003", deciles == i] / lag(price["2002-12/2003", deciles == i])) - 1)
  deciles_yr <- c(deciles_yr, mean(r[deciles == i], na.rm = T))
}

plot(cumprod(1 + rowMeans(deciles_pf[[1]])), type = "l", col = 1, ylab = "Return", xlab = "Month", ylim = c(0.9, 2.5))
for(i in 2:10){
  lines(cumprod(1 + rowMeans(deciles_pf[[i]])), col = i)
}
legend("topleft", legend = paste("PF", 1:10), col = 1:10, bty = "n", lty = 1)

barplot(deciles_yr)


# plot(cumprod(1 + rowMeans(deciles_pf[[1]])), type = "l", col = 1, ylab = "Return", xlab = "Month")
# for(i in 2:10){
#   lines(cumprod(1 + rowMeans(deciles_pf[[i]])), col = i)
# }
# legend("topleft", legend = paste("PF", 1:10), col = 1:10, bty = "n", lty = 1)


# plot(cumprod(1 + rowMeans(deciles_pf[[1]])))
# lines(rowMeans(cumprod(1 + deciles_pf[[1]])))



#------------------------------
# 3) TEST FOR RETURN DIFFERENCE
#------------------------------

t.test(as.numeric(rowMeans(deciles_pf[[1]])), as.numeric(rowMeans(deciles_pf[[10]])))
wilcox.test(as.numeric(rowMeans(deciles_pf[[1]])), as.numeric(rowMeans(deciles_pf[[10]])))

t.test(as.numeric((deciles_pf[[1]])), as.numeric((deciles_pf[[10]])))
wilcox.test(as.numeric((deciles_pf[[1]])), as.numeric((deciles_pf[[10]])))



#--------------------------------------------------------------------------------------------------------------------------

################
## Exercise 2 ##
################

all(colnames(price) == colnames(mcap))
all(time(price) == time(mcap))

head(price[,1:10])
head(mcap[,1:10])

price <- price["2001/2018"]
mcap <- mcap["2001/2018"]



#------------------------------------
# 1) COMPUTE YEARLY RETURNS OF STOCKS
#------------------------------------

# convert to yearly
price <- apply.yearly(price, FUN=function(x) last(x))
mcap <- apply.yearly(mcap, FUN=function(x) last(x))

all(time(price) == time(mcap))
price[1:5, 1:3]

return <- (price/lag.xts(price) - 1)[-1,]

return[1:5,1:3]

# lag mcap so that previous year's macp determines membership to decile portfolio in next year
mcap <- lag.xts(mcap)[-1,]
mcap[1:5, 1:3]

# removing extreme values
cutoffs <- quantile(na.omit(c(coredata(return))), probs=c(0.005, 0.995))
return[return < cutoffs[1]] <- NA
return[return > cutoffs[2]] <- NA



#-----------------------------------------------
# 2) COMPUTE YEARLY RETURNS OF DECILE PORTFOLIOS
#-----------------------------------------------

# create an object to store portfolio returns that the for-loop below will compute
pf_returns <- NULL
avg_return <- NULL

for(i in 1:nrow(return)){
  return_not_na <- !is.na(return[i,]) # vector with elements TRUE if return is *not* na
  mcap_not_na <- !is.na(mcap[i,]) # vector with elements TRUE if mcap is *not* na
  
  # retain only firms for which both return and mcap is available
  return_i <- as.vector(return[i, return_not_na&mcap_not_na]) 
  mcap_i <- as.vector(mcap[i, return_not_na&mcap_not_na])
  
  # assign firms to deciles based on mcap
  deciles <- cut(mcap_i, breaks = quantile(mcap_i, probs = seq(0, 1, by = 0.1)), include.lowest = TRUE, label = 1:10)
  
  # aggregate returns (by taking averages -> equally weighted portfolio) based on membership to different deciles
  decile_pfs <- aggregate(return_i, by = list(deciles), FUN=mean)$x
  
  # store the resulting portfolio returns by binding them as another row to the existing object pf_returns
  pf_returns <- rbind(pf_returns, decile_pfs)
  
  # average yearly return
  avg_return <- c(avg_return, mean(return_i))
}

pf_returns <- xts(pf_returns, order.by=time(return))
colnames(pf_returns) <- paste0("pf", 1:10)
head(pf_returns)

avg_return <- xts(avg_return, order.by=time(return))



#--------------------------------------
# 3) VISUALIZE DECILE PORTFOLIO RETURNS
#--------------------------------------

pf_cumreturns <- apply(pf_returns, 2, FUN = function(x) cumprod(1 + x) - 1 )
pf_cumreturns <- xts(pf_cumreturns, order.by = time(return))

plot(pf_cumreturns, col = rainbow_hcl(10), legend.loc = "topleft")
lines(cumprod(1 + avg_return) - 1, col = "black", type = "b")

boxplot(coredata(pf_returns))
barplot((1 + pf_cumreturns[16])^(1/16) - 1, beside=TRUE)



#------------------------------
# 3) TEST FOR RETURN DIFFERENCE
#------------------------------

t.test(as.vector(pf_returns$pf1), as.vector(pf_returns$pf10))
wilcox.test(as.vector(pf_returns$pf1), as.vector(pf_returns$pf10))


