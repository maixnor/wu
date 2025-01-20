######################################
## BA II -- EXERCISES 6 // SOLUTION ##
######################################
rm(list=ls())
library(viridis)
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




#--------------------------------------------------------------------------------------------------------------------------

################
## Exercise 1 ##
################

yields <- read.csv("../../data/data_yields.csv")
head(yields)
yields <- yields[ , c("Date", "X3M", "X1Y", "X5Y", "X7Y", "X10Y")]
head(yields)


#-----------------------------------
# 1) PLOT YIELD CURVE FOR 2021-08-23
#-----------------------------------

maturities <- c(3/12, 1, 5, 7, 10)
plot(x=maturities, y=yields[1,-1],
     col="steelblue", type="o", pch=16, lty=2,
     xlab="Maturity (in years)", ylab="Yield p.a. (%)",
     main=paste0("German yield curve on ", yields[1,1]))



#----------------------------------------------
# 2) PLOT EVOLUTION OF YIELDS ACROSS MATURITIES
#----------------------------------------------

# convert to xts and plot
# note: viridis colors are accessed using the function viridis()
yields.xts <- xts(yields[,-1], order.by=ymd(yields$Date))

yield_plot <- plot(yields.xts, col=viridis(n=ncol(yields.xts)),
                   main="Euro benchmark yields")
yield_plot <- addLegend("bottomleft",
                        legend.names=c("3M", paste0(c(1,5,7,10),"Y")),
                        fill=viridis(n=ncol(yields.xts)))
yield_plot



#----------------------------------
# 3) CALCULATE PRINCIPAL COMPONENTS
#----------------------------------

#1. drop first column containing dates
#2. standardize each column
yields_std <- apply(yields[,-1], 2, function(x) (x - mean(x))/sd(x))

# check mean of each standardized variable
# -> basically zero (just numerical imprecision)
colMeans(yields_std) 

# check standard deviation of each standardized variable
# -> exactly 1 for all variables
apply(yields_std, 2, sd)

# could omit last two arguments since we previously already scaled data by hand
pca <- prcomp(yields_std, center=TRUE, scale.=TRUE)

plot(pca$sdev^2/sum(pca$sdev^2),
     col="steelblue", type="b", pch=20,
     main="Proportion of explained Variance", ylab="% explained"
     ,xlab="Number of PCs")
abline(h=0, lty=2, col="darkgrey")
# -> two, at most 3 PCs appear to be a good choice



#--------------------------------------------
# 4) APPROXIMATE YIELD CURVE WITH FIRST 3 PCs
#--------------------------------------------

# get mean and SD of original data:
yields_mean <- colMeans(yields[,-1]) #drop 1st col with dates
yields_sd <- apply(yields[,-1], 2, sd)

# D* = X* Lambda'*
#note that we need to transpose Lambda (pca$rotation)!
yields_approx_3pc <- pca$x[,1:3] %*% t(pca$rotation)[1:3,]
head(yields_approx_3pc)

# scale to original SD and add back the mean
for(i in 1:ncol(yields_approx_3pc)){
  yields_approx_3pc[,i] <- yields_approx_3pc[,i] * yields_sd[i] + yields_mean[i]
}

# colnames(yields_approx_3pc) <- colnames(yields[,-1])
yields_approx_3pc.xts <- xts(yields_approx_3pc, order.by=rev(time(yields.xts)) )
# why rev() in the line above?
# -> yields (and therefore yieds_approx_3pc) are ordered from last to first,
# but yields.xts (and therefore time(yields.xts)) are automatically ordered from first to last



#---------------------------------------------
# 5) CHECK APPROXIMATION AGAINST ORIGINAL DATA
#---------------------------------------------

plot_3pc <- plot(yields.xts[,c("X3M", "X5Y", "X10Y")],
                 col="steelblue", multi.panel=TRUE, main="Approximation with 3 PCs")
plot_3pc <- lines(yields_approx_3pc.xts[,"X3M"],
                  col="coral", on=1)
plot_3pc <- lines(yields_approx_3pc.xts[,"X5Y"],
                  col="coral", on=2)
plot_3pc <- lines(yields_approx_3pc.xts[,"X10Y"],
                  col="coral", on=3)
plot_3pc <- addLegend("bottomleft", legend.names=c("original", "approximation"),
                      col=c("steelblue", "coral"), lwd=1, on=3)
plot_3pc

# looks quite good!





#--------------------------------------------------------------------------------------------------------------------------

################
## Exercise 2 ##
################

#------------------------------------------------------------------------------------
# 1) VISUALLY SHOW LOADINGS FROM LOADINGS MATRIX LAMBDA FOR FIRST 3 PCs (in one plot)
#------------------------------------------------------------------------------------

plot(x=maturities, y=pca$rotation[,1], col="steelblue", type="o",
     ylim=c(-1,1), ylab="loading", xlab="maturity (in years)")
lines(x=maturities, y=pca$rotation[,2], col="coral", type="o")
lines(x=maturities, y=pca$rotation[,3], col="forestgreen", type="o")
abline(h=0, lty=2, col="grey")
legend("bottomleft", legend=colnames(pca$rotation)[1:3], bty="n",
       lty=1, pch=1, col=c("steelblue", "coral", "forestgreen"))



#----------------------------------------------------------------------------
# 2) COMPARISON OF PCs AGAINST DIRECT MEASURES OF LEVEL, SLOPE, AND CURVATURE
#----------------------------------------------------------------------------

#[a]
measure_level <- (yields.xts[,"X5Y"]-yields_mean["X5Y"])/yields_sd["X5Y"]
plot(measure_level , col="steelblue")
lines(xts(pca$x[,1], order.by=ymd(yields$Date))/sd(pca$x[,1]), col="coral")

#[b]
measure_slope <- yields.xts[,"X10Y"] - yields.xts[,"X3M"]
measure_slope <- (measure_slope-mean(measure_slope) ) / sd(measure_slope)
plot(measure_slope , col="steelblue")
lines(xts(pca$x[,2], order.by=ymd(yields$Date))/sd(pca$x[,2])*(-1), col="coral")

#[c]
measure_curvature <- yields.xts[,"X10Y"] + yields.xts[,"X3M"] - 2*yields.xts[,"X5Y"]
measure_curvature <- (measure_curvature-mean(measure_curvature) ) / sd(measure_curvature)
plot(measure_curvature , col="steelblue")
lines(xts(pca$x[,3], order.by=ymd(yields$Date))/sd(pca$x[,3])*(-1), col="coral")



#--------------------------------------------------------------------------------------------------------------------------

################
## Exercise 3 ##
################

#----------------------------------------------------
# 1) PRESENT VALUE OF BOND PORTFOLIO AS OF 2021-08-23
#----------------------------------------------------

yields.xts["2021-08-23"]
maturities

cf <- c(5,5,15,8,25) #net cash flows
pv <- sum(cf/(1+as.vector(yields.xts["2021-08-23"])/100)^maturities)
pv



#----------------------------------
# 2) EXTREME YIELD CURVE STEEPENING
#----------------------------------

#[a] convert 2nd PC to xts and take differences
pc2 <- xts(pca$x[,"PC2"], order.by=ymd(yields$Date))
d_pc2 <- diff.xts(pc2)

#[b]
pc2_var95 <- quantile(na.omit(d_pc2), probs=0.05) #5%, since we found positive loadings for short end and negative loadings for long end of the yield curve



#--------------------------------------------------------------------
# 3) TRANSLATE EXTREME CHANGE IN PC2 TO YIELD CHANGES ACROSS MATURIES
#--------------------------------------------------------------------

yields_sd #original sd of yields
d_yields_var95 <- pc2_var95*t(pca$rotation)[2,]*yields_sd #change in PC2 translated to change in standardized yield data; then scaled back to changes on original scales



#---------------------------------------------------
# 4) RE-EVALUATE THE PORTFOLIO WITH NEW YIELD LEVELS
#---------------------------------------------------

yields_var95 <- yields.xts["2021-08-23"] + d_yields_var95
pv_var95 <- sum(cf/(1+yields_var95/100)^maturities)
pv_var95



#-----------------------------
# 5) CHANGE IN PORTFOLIO VALUE
#-----------------------------

pv_var95 - pv
