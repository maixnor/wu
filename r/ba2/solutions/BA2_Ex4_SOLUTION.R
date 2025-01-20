######################################
## BA II -- EXERCISES 4 // SOLUTION ##
######################################

rm(list=ls())
library(xts)


#set Working Directory-----------------------------------------------------------------------------------------------------
tryCatch({
  library(rstudioapi)
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}, error=function(cond){message(paste("cannot change working directory"))
})

# you can also set your working directory using 
# setwd("path_to_your_data_folder")


#----------------------------------------------------------------------------------------------------


## We start by coding a function that computes the frontier with/without a short selling constraint
# asset.eret... expected returns of individual assets
# asset.cov... covariance matrix of returns of individual assets
# no.short_selling... whether or not short selling is allowed
# max.weight/min.weight... maximum/minimum weight allowed for an individual asset
# frontier.r... sequence of target portfolio returns; for each of these, we want to find corresponding the portfolio with minimum variance
# fully invested... whether weights need to sum to 1 (100%)

ba2_optimal_portfolio<-function(asset.eret, asset.cov, 
                                no.short_selling=TRUE, max.weight=NULL, min.weight=NULL,
                                frontier.r=seq(min(asset.eret),max(asset.eret),0.001),
                                fully.invested=TRUE){
  require(quadprog) # check if package 'quadprog' is loaded; if not, load it
  
  
  k <- length(asset.eret) # get number of stocks
  dvec <- rep(0,k) # create zero vector 
  
  
  ## Code the constraints
  
  if(fully.invested){
    c1 <- rep(1,k) # weights need to sum to one
    eq_constraints <- 2
    c2 <- asset.eret # weighted expected returns need to be expected PF return
    C <- t(rbind(c1,c2)) # this matrix represents the LHS of all constraints
  }else{
    c2 <- asset.eret # weighted expected returns need to be expected PF return
    eq_constraints <- 1
    C <- matrix(c2,ncol=1) # this matrix represents the LHS of all constraints
  }
  
  
  
  ## Short selling constraint
  if(no.short_selling){
    c3 <- matrix(0, ncol=k, nrow=k)
    diag(c3) <- 1
    C <- t(rbind(t(C),c3))
  }
  
  ## Maximum weight per asset
  if(!is.null(max.weight)){
    c4 <- matrix(0, ncol=k, nrow=k)
    diag(c4) <- -1 # since it is a geq constraints we check if (-1)*w >= -max.weight
    C <- t(rbind(t(C),c4))
  }
  
  ## Minimum weight per asset
  if(!is.null(min.weight)){
    c5 <- matrix(0, ncol=k, nrow=k)
    diag(c5) <- 1 # since it is a geq constraints we check if w >= min.weight
    C <- t(rbind(t(C),c5))
  }
  
  ## Create vector that contains the estimated min variance given an 
  ## expected portfolio return target
  frontier.s <- rep(NA_real_, length(frontier.r))
  ## Create a container for the corresponding portfolio weights
  pf.weights <- list()
  
  for(i in 1:length(frontier.r)){
    
    if(fully.invested) c0 <- c(1, frontier.r[i]) #this vector contains the RHS of constraints
    else c0 <- frontier.r[i] #this vector contains the RHS of constraints
    if(no.short_selling) c0 <- c(c0, rep(0,k))
    if(!is.null(max.weight)) c0 <- c(c0, -rep(max.weight,k))
    if(!is.null(min.weight)) c0 <- c(c0, -rep(min.weight,k))
    
    w.solution <- solve.QP(Dmat=asset.cov, dvec=dvec, Amat=C, bvec=c0, meq=eq_constraints)
    ## We are interested in the standard deviation but are actually minimizing
    ## (1/2) of the variance, so we need to account for that!
    frontier.s[i] <- sqrt(w.solution$value*2) 
    pf.weights[[i]] <- w.solution$solution
  }
  
  return(list("Volatility"=frontier.s, "Optimal.Weights"=pf.weights,"Expected.Return"=frontier.r))
  
}

# function to compute portfolio return for given asset returns and portfolio weights
pf.return <- function(mu, w) return(t(w)%*%mu)

# function to compute portfolio vola for given asset return covariances and portfolio weights
pf.volatility <- function(Sigma, w) return(sqrt((t(w)%*%Sigma%*%w)))


################
## Exercise 1 ##
################

## Plot the PF frontier in the two asset case w/ following parameters
## E(rA)=.2, E(rB)=.5, sd(rA)=.2, sd(rB)=.4, rho(rA,rB)=-.2
## Vary rho and describe the outcome 

mu <- c(0.2, 0.5)
s <- c(0.2, 0.4)
rho <- -0.2
S <- matrix(c(s[1]^2, rho*s[1]*s[2], rho*s[1]*s[2], s[2]^2), 2, 2)
frontier <- ba2_optimal_portfolio(mu, S)

plot(frontier$Volatility, frontier$Expected.Return,
     ylab="Exp. PF return", xlab="Risk", type="l", lwd=2,
     main="PF Frontier for different rho", xlim = c(0.08, 0.41))

# rho = 0
S <- matrix(c(s[1]^2, 0*s[1]*s[2], 0*s[1]*s[2], s[2]^2), 2, 2)
frontier_2 <- ba2_optimal_portfolio(mu, S)

lines(frontier_2$Volatility, frontier_2$Expected.Return, col="blue", lwd=2, lty=2)

# rho = 0.8
S <- matrix(c(s[1]^2, 0.8*s[1]*s[2], 0.8*s[1]*s[2], s[2]^2), 2, 2)
frontier_3 <- ba2_optimal_portfolio(mu, S)

lines(frontier_3$Volatility, frontier_3$Expected.Return, col="red", lwd=2, lty=3)

# rho = -0.8
S <- matrix(c(s[1]^2, -0.8*s[1]*s[2], -0.8*s[1]*s[2], s[2]^2), 2, 2)
frontier_4 <- ba2_optimal_portfolio(mu, S)

lines(frontier_4$Volatility, frontier_4$Expected.Return, col="purple", lwd=2, lty=4)

legend("bottomright", legend=c(-0.8, -0.2, 0, 0.8), title="Rho", bty="n",
       col=c("purple", "black", "blue", "red"), lwd=2, lty=c(4, 1, 2, 3))



#----------------------------------------------------------------------------------------------------

################
## Exercise 2 ##
################


## We load the return data set
load("returns_hw4.RData")


#---------------------------------------------------------------------------------
# 1) Compute the frontier using returns up to 2002 (no short selling, no rf asset)
#---------------------------------------------------------------------------------

r_2001 <- r["/2001"] #subset return
expret_2001 <- colMeans(r_2001) # compute the expeceted returns
Sigma_2001 <- cov(r_2001) # compute the variance-covariance matrix

frontier_2001 <- ba2_optimal_portfolio(asset.eret = expret_2001, 
                                       asset.cov = Sigma_2001,
                                       no.short_selling = TRUE)

## 2) Compute the frontier using all returns (no short selling, no rf asset)
expret_full <- colMeans(r) # compute the expeceted returns
Sigma_full <- cov(r) # compute the variance-covariance matrix

frontier_full <- ba2_optimal_portfolio(asset.eret = expret_full, asset.cov = Sigma_full,
                                       no.short_selling = TRUE)

## Pick five portfolios (randomly)
mvp <- which.min(frontier_2001$Volatility) # find minimum variance portfolio
set.seed(1234) # set seed to make random draw reproducible
five_pfs <- sample(mvp:length(frontier_2001$Optimal.Weights), size=5)
five_pfs

## Plot the result
par(mfrow=c(1,2))
plot(sqrt(diag(Sigma_2001)), expret_2001, pch=19, col="yellow", main="Until 2001", ylim = c(-.02,.05), xlim=c(0,.3), ylab="Exp. Return", xlab="Risk")
lines(frontier_2001$Volatility, frontier_2001$Expected.Return, lwd=2, col="coral")
points(frontier_2001$Volatility[five_pfs], frontier_2001$Expected.Return[five_pfs], col="steelblue", pch=19)

plot(sqrt(diag(Sigma_full)), expret_full, pch=19, col="yellow", main="Full Sample", ylim = c(-.02,.05), xlim=c(0,.3), ylab="Exp. Return", xlab="Risk")
lines(frontier_full$Volatility, frontier_full$Expected.Return, lwd=2, col="coral")
points(pf.volatility(Sigma_full, frontier_2001$Optimal.Weights[[five_pfs[1]]]), pf.return(expret_full, frontier_2001$Optimal.Weights[[five_pfs[1]]]), col="steelblue", pch=19)
points(pf.volatility(Sigma_full, frontier_2001$Optimal.Weights[[five_pfs[2]]]), pf.return(expret_full, frontier_2001$Optimal.Weights[[five_pfs[2]]]), col="steelblue", pch=19)
points(pf.volatility(Sigma_full, frontier_2001$Optimal.Weights[[five_pfs[3]]]), pf.return(expret_full, frontier_2001$Optimal.Weights[[five_pfs[3]]]), col="steelblue", pch=19)
points(pf.volatility(Sigma_full, frontier_2001$Optimal.Weights[[five_pfs[4]]]), pf.return(expret_full, frontier_2001$Optimal.Weights[[five_pfs[4]]]), col="steelblue", pch=19)
points(pf.volatility(Sigma_full, frontier_2001$Optimal.Weights[[five_pfs[5]]]), pf.return(expret_full, frontier_2001$Optimal.Weights[[five_pfs[5]]]), col="steelblue", pch=19)
par(mfrow=c(1,1))



#----------------------------------------------------------------------------------------------------

################
## Exercise 3 ##
################


## We start by computing the frontier up until 2001
r_2001 <- r["/2001"] #subset return
expret_2001 <- colMeans(r_2001) # compute the expeceted returns
Sigma_2001 <- cov(r_2001) # compute the variance-covariance matrix

frontier_2001 <- ba2_optimal_portfolio(asset.eret = expret_2001, 
                                       asset.cov = Sigma_2001,
                                       no.short_selling = FALSE,
                                       frontier.r = seq(min(expret_2001)+0.0001, max(expret_2001)-0.0001, 0.001)) #we add/subtract a small constant to avoid numerical instability precisely at the min/max asset return

r_2002 <- r["/2002"] #subset return
expret_2002 <- colMeans(r_2002) # compute the expected returns
Sigma_2002 <- cov(r_2002) # compute the variance-covariance matrix

frontier_2002 <- ba2_optimal_portfolio(asset.eret = expret_2002, 
                                       asset.cov = Sigma_2002,
                                       no.short_selling = FALSE,
                                       frontier.r = seq(min(expret_2002)+0.0001, max(expret_2002)-0.0001, 0.001))


three_pfs2001 <- c(which.min((frontier_2001$Expected.Return-0.01)^2),
               which.min((frontier_2001$Expected.Return-0.015)^2),
               which.min((frontier_2001$Expected.Return-0.02)^2))
three_pfs2002 <- c(which.min((frontier_2002$Expected.Return-0.01)^2),
                   which.min((frontier_2002$Expected.Return-0.015)^2),
                   which.min((frontier_2002$Expected.Return-0.02)^2))

par(mfrow=c(1,2))
plot(sqrt(diag(Sigma_2001)), expret_2001, pch=19, col="yellow", main="Until 2001", ylim = c(-.02,.05), xlim=c(0,.3), ylab="Exp. Return", xlab="Risk")
lines(frontier_2001$Volatility, frontier_2001$Expected.Return, lwd=2, col="coral")
points(frontier_2001$Volatility[three_pfs2001[1]], frontier_2001$Expected.Return[three_pfs2001[1]], col="steelblue", pch=19)
points(frontier_2001$Volatility[three_pfs2001[2]], frontier_2001$Expected.Return[three_pfs2001[2]], col="steelblue", pch=19)
points(frontier_2001$Volatility[three_pfs2001[3]], frontier_2001$Expected.Return[three_pfs2001[3]], col="steelblue", pch=19)

plot(sqrt(diag(Sigma_2002)), expret_2002, pch=19, col="yellow", main="Until 2002", ylim = c(-.02,.05), xlim=c(0,.3), ylab="Exp. Return", xlab="Risk")
lines(frontier_2002$Volatility, frontier_2002$Expected.Return, lwd=2, col="coral")
points(frontier_2002$Volatility[three_pfs2002[1]], frontier_2002$Expected.Return[three_pfs2002[1]], col="steelblue", pch=19)
points(frontier_2002$Volatility[three_pfs2002[2]], frontier_2002$Expected.Return[three_pfs2002[2]], col="steelblue", pch=19)
points(frontier_2002$Volatility[three_pfs2002[3]], frontier_2002$Expected.Return[three_pfs2002[3]], col="steelblue", pch=19)
par(mfrow=c(1,1))


par(mfrow=c(2,3))
barplot(frontier_2001$Optimal.Weights[[three_pfs2001[1]]], border=FALSE, col="black", main="1%")
barplot(frontier_2001$Optimal.Weights[[three_pfs2001[2]]], border=FALSE, col="black", main="1.5%")
barplot(frontier_2001$Optimal.Weights[[three_pfs2001[3]]], border=FALSE, col="black", main="2%")
barplot(frontier_2002$Optimal.Weights[[three_pfs2002[1]]], border=FALSE, col="black", main="1%")
barplot(frontier_2002$Optimal.Weights[[three_pfs2002[2]]], border=FALSE, col="black", main="1.5%")
barplot(frontier_2002$Optimal.Weights[[three_pfs2002[3]]], border=FALSE, col="black", main="2%")
par(mfrow=c(1,1))

weight_change <- c(mean(abs(frontier_2001$Optimal.Weights[[three_pfs2001[1]]]-frontier_2002$Optimal.Weights[[three_pfs2002[1]]])),
                   mean(abs(frontier_2001$Optimal.Weights[[three_pfs2001[2]]]-frontier_2002$Optimal.Weights[[three_pfs2002[2]]])),
                   mean(abs(frontier_2001$Optimal.Weights[[three_pfs2001[3]]]-frontier_2002$Optimal.Weights[[three_pfs2002[3]]])))


## No short selling PFs
frontier_2001_ns <- ba2_optimal_portfolio(asset.eret = expret_2001, 
                                          asset.cov = Sigma_2001,
                                          no.short_selling = TRUE,
                                          frontier.r = seq(min(expret_2001)+0.0001, max(expret_2001)-0.0001, 0.001))
frontier_2002_ns <- ba2_optimal_portfolio(asset.eret = expret_2002, 
                                          asset.cov = Sigma_2002,
                                          no.short_selling = TRUE,
                                          frontier.r = seq(min(expret_2002)+0.0001, max(expret_2002)-0.0001, 0.001))
par(mfrow=c(1,2))
plot(sqrt(diag(Sigma_2001)), expret_2001, pch=19, col="yellow", main="Until 2001", ylim = c(-.02,.05), xlim=c(0,.3), ylab="Exp. Return", xlab="Risk")
lines(frontier_2001_ns$Volatility, frontier_2001_ns$Expected.Return, lwd=2, col="coral")
points(frontier_2001_ns$Volatility[three_pfs2001[1]], frontier_2001_ns$Expected.Return[three_pfs2001[1]], col="steelblue", pch=19)
points(frontier_2001_ns$Volatility[three_pfs2001[2]], frontier_2001_ns$Expected.Return[three_pfs2001[2]], col="steelblue", pch=19)
points(frontier_2001_ns$Volatility[three_pfs2001[3]], frontier_2001_ns$Expected.Return[three_pfs2001[3]], col="steelblue", pch=19)

plot(sqrt(diag(Sigma_2002)), expret_2002, pch=19, col="yellow", main="Until 2002", ylim = c(-.02,.05), xlim=c(0,.3), ylab="Exp. Return", xlab="Risk")
lines(frontier_2002_ns$Volatility, frontier_2002_ns$Expected.Return, lwd=2, col="coral")
points(frontier_2002_ns$Volatility[three_pfs2002[1]], frontier_2002_ns$Expected.Return[three_pfs2002[1]], col="steelblue", pch=19)
points(frontier_2002_ns$Volatility[three_pfs2002[2]], frontier_2002_ns$Expected.Return[three_pfs2002[2]], col="steelblue", pch=19)
points(frontier_2002_ns$Volatility[three_pfs2002[3]], frontier_2002_ns$Expected.Return[three_pfs2002[3]], col="steelblue", pch=19)
par(mfrow=c(1,1))

par(mfrow=c(2,3))
barplot(frontier_2001_ns$Optimal.Weights[[three_pfs2001[1]]], border=FALSE, col="black", main="1%")
barplot(frontier_2001_ns$Optimal.Weights[[three_pfs2001[2]]], border=FALSE, col="black", main="1.5%")
barplot(frontier_2001_ns$Optimal.Weights[[three_pfs2001[3]]], border=FALSE, col="black", main="2%")
barplot(frontier_2002_ns$Optimal.Weights[[three_pfs2002[1]]], border=FALSE, col="black", main="1%")
barplot(frontier_2002_ns$Optimal.Weights[[three_pfs2002[2]]], border=FALSE, col="black", main="1.5%")
barplot(frontier_2002_ns$Optimal.Weights[[three_pfs2002[3]]], border=FALSE, col="black", main="2%")
par(mfrow=c(1,1))

weight_change_ns <- c(mean(abs(frontier_2001_ns$Optimal.Weights[[three_pfs2001[1]]]-frontier_2002_ns$Optimal.Weights[[three_pfs2002[1]]])),
                   mean(abs(frontier_2001_ns$Optimal.Weights[[three_pfs2001[2]]]-frontier_2002_ns$Optimal.Weights[[three_pfs2002[2]]])),
                   mean(abs(frontier_2001_ns$Optimal.Weights[[three_pfs2001[3]]]-frontier_2002_ns$Optimal.Weights[[three_pfs2002[3]]])))


barplot(rbind(weight_change, weight_change_ns),beside = TRUE, border=FALSE, col=c("steelblue","coral"), legend.text = c("Short selling","No short selling"))
