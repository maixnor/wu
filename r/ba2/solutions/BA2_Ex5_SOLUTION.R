######################################
## BA II -- EXERCISES 5 // SOLUTION ##
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



#----------------------------------------------------------------------------------------------------

################
## Exercise 1 ##
################

cols <- c("steelblue", "coral", "forestgreen")

# load stock returns
load("../../data/returns_hw4.RData")
time(r) <- floor_date(time(r), unit="month") #round Date to 1st of current month (to match dates with risk-free rates below)


# load FF factors to get the risk-free rate
ff_factors <- read.csv(file = "../../data/F-F_Research_Data_Factors.CSV")
head(ff_factors)
rf <- xts(ff_factors$RF/100, order.by=as.Date(paste0(ff_factors$X, "01"), format="%Y%m%d"))
colnames(rf) <- "rf"

rf <- rf[time(r)] #subset rf to those days also contained in r
rf


r_mkt <- xts(rowMeans(r), order.by=time(r))
plot(cumprod(1+r_mkt))

stock_picks <- c("X10026", "X10308", "X10443")

betas <- rollapply(cbind(r[,stock_picks], r_mkt)-c(coredata(rf)), width=10*12, by=12, fill=NULL, align="right", by.column=FALSE,
                   FUN=function(x){
                     beta <- rep(NA_real_, 3)
                     for(i in 1:3){
                       beta[i] <- coef(lm(x[,i]~x[,4]))[2]
                     }
                     return(beta)
                   } )

tail(betas)
plot(betas, col=cols)


alphas <- rollapply(cbind(r[,stock_picks], r_mkt)-c(coredata(rf)) , width=10*12, by=12,fill=NULL, align="right", by.column=FALSE,
                   FUN=function(x){
                     alpha <- rep(NA_real_, 3)
                     for(i in 1:3){
                       alpha[i] <- coef(lm(x[,i]~x[,4]))[1]
                     }
                     return(alpha)
                   } )

tail(alphas)
plot(alphas, col=cols)




#----------------------------------------------------------------------------------------------------

################
## Exercise 2 ##
################


# 1) COMPUTING THE BETAS OF ALL STOCKS UP TO 2006

# create a matrix X containing a column of 1s and a column with market excess returns up to 2006
# -> used to compute linear regression coefficients as (x'X)^-1 X'y
X <- cbind(1, coredata(r_mkt["/2006"] - rf["/2006"]))

# (x'X)^-1 X'y to obtain linear regression coefficients
coefs <- solve(t(X)%*%X) %*% t(X) %*% coredata(r["/2006"] - as.vector(rf["/2006"])) #first row contains alphas, second row betas, columns correspond to firms

betas <- coefs[2,] #retrieve betas

# retrieve top 3 lowest/highest beta stocks up to 2005
low_beta <- head(sort(betas), 3)
high_beta <- tail(sort(betas), 3)


# compute cumulative returns from 2006 to 2010 for low and high beta stocks
r_low_beta <- apply(r[,names(low_beta)]["2007/2010"], 2, FUN=\(x) cumprod(1+x) )
r_low_beta <- xts(r_low_beta, order.by=ymd(rownames(r_low_beta)) )

r_high_beta <- apply(r[,names(high_beta)]["2007/2010"], 2, FUN=\(x) cumprod(1+x) )
r_high_beta <- xts(r_high_beta, order.by=ymd(rownames(r_high_beta)) )


par(mfrow=c(1,2))
plot(r_low_beta)
plot(r_high_beta)
par(mfrow=c(1,1))




#----------------------------------------------------------------------------------------------------

################
## Exercise 3 ##
################

## load the data
ff_factors <- read.csv(file = "../../data/F-F_Research_Data_Factors.CSV")
industries<-read.csv(file = "../../data/12_Industry_Portfolios.CSV")
head(ff_factors)
head(industries)

all(ff_factors$X == industries$X) #check that all dates are the same

## get industry excess returns
industries_xret <- cbind(industries[,1], industries[,-1]-ff_factors$RF)

## move all into one data frame
xret_data <- cbind(industries_xret, ff_factors[,-1])

## run yearly regressions using "monthly rolling windows"
betas <- rollapply(data = xret_data, width = 24, by.column = FALSE, FUN = function(x){
  #print((x))
  b <- list()
  y <- as.matrix(x[,2:13])
  X <- cbind(rep(1,24), as.matrix(x[,14:16]))
  for(i in 1:12) b[[i]] <- solve(t(X)%*%X)%*%t(X)%*%y[,i]
  return(t(do.call(rbind,b)))
})

alphas <- betas[,seq(1,48,4)]
betas <- betas[,-seq(1,48,4)]
colnames(betas) <- paste0(rep(colnames(xret_data)[2:13],each=3), colnames(betas))
colnames(alphas) <- colnames(xret_data)[2:13]
# CRAN version
# install.packages("ggthemes")
library(ggthemes)
xaxis_time <- as.yearmon(as.Date(paste(ff_factors$X,"01"), "%Y%m%d"))[-(1:23)]

par(mfrow=(c(1,3)))
## plot market betas
plot(xaxis_time, betas[,1], type="l", col=unlist(ggthemes_data$economist$fg[2])[1],
     ylim = c(min(betas[,seq(1,36,3)]), max(betas[,seq(1,36,3)])),
     ylab="Market Beta", xlab="time")
for(i in seq(4,36,3)) lines(xaxis_time, betas[,i], col=unlist(ggthemes_data$economist$fg[2])[ceiling(i/3)])

## plot smb betas
plot(xaxis_time,betas[,2], type="l", col=unlist(ggthemes_data$economist$fg[2])[1],
     ylim = c(min(betas[,seq(2,36,3)]), max(betas[,seq(2,36,3)])),
     ylab="SMB Beta", xlab="time")
for(i in seq(5,36,3)) lines(xaxis_time, betas[,i], col=unlist(ggthemes_data$economist$fg[2])[ceiling(i/3)])


## plot hml betas
plot(xaxis_time,betas[,3], type="l", col=unlist(ggthemes_data$economist$fg[2])[1],
     ylim = c(min(betas[,seq(3,36,3)]), max(betas[,seq(3,36,3)])),
     ylab="HML Beta", xlab="time")
for(i in seq(6,36,3)) lines(xaxis_time, betas[,i], col=unlist(ggthemes_data$economist$fg[2])[ceiling(i/3)])
par(mfrow=c(1,1))

## plot average betas
barplot(height = t(matrix(colMeans(betas), ncol=3, byrow=TRUE)), beside=TRUE,
        col = unlist(ggthemes_data$economist$fg[2])[1:3], border = FALSE, 
        names.arg = (names(industries)[-1]), las=2)
par(xpd=TRUE)
legend(x = -0.7, y = 1.4, legend = c("market", "smb", "hml"),
       col=unlist(ggthemes_data$economist$fg[2])[1:3], pch=15, bty="n", border=FALSE)
par(xpd=FALSE)      

## plot alphas over time
plot(xaxis_time, alphas[,1], type="l", col=unlist(ggthemes_data$economist$fg[2])[1],
     ylim = c(min(alphas), max(alphas)),
     ylab="Alpha", xlab="time")
for(i in 2:12) lines(xaxis_time, alphas[,i], col=unlist(ggthemes_data$economist$fg[2])[i])

barplot(height = colMeans(alphas), 
        col = unlist(ggthemes_data$economist$fg[2])[1:12], border = FALSE, 
        names.arg = (names(industries)[-1]), las=2, main = "Industry Alphas")


