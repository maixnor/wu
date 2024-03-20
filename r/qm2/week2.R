#' ---
#' title: "Session 2: Probability-II "
#' author: "QM-II "
#' ---

## library("extraDistr") might need to be installed first via: 
#install.packages("extraDistr")


library("extraDistr")

## ddunif is the density of the DISCRETE uniform
ddunif(72, 1, 360)
# probability for the outcome to be in 90 to 180 degrees
print(sum(ddunif(91:180, 1, 360)))
## Can also be calculated with the cumulatativ distribution function pdunif
print(pdunif(180, 1, 360) - pdunif(90, 1, 360))  ## Why 90 here and 91 two lines above?


## CONTINUOUS uniform uses a similar command:  dunif for the density and punif for
## the cumulative distribution function. No special packages needed.
print(punif(180, 0, 360) - punif(90, 0, 360))   ## Why here parameters 0 and 360 and not as above?

## We can plot the density function
f <- function(x) dunif(x, 0, 360)
plot(f, xlim = c(0, 360), col = 2)



## The normal distribution uses the:  dnorm, pnorm  commands 
# the commands with default options provide values for standard normal distribution
plot(pnorm, xlim = c(-3, 3), ylim = c(0, 1), main = "Cumulative (standard) normal distribution 
function (black) and density function (red)")
par(new = TRUE) # makes sure that the next command only adds to the plot instead of creating a new one
plot(dnorm, xlim = c(-3, 3), ylim = c(0, 1), col=2)

##We also have the command: qnorm 
# qnorm does the opposite of pnorm: given an area under the normal density,
# i.e. given a probability, it finds the boundary value that determines this area.
z_80 <- qnorm(0.80, mean = 50, sd = 3)

# We have the following interpretation: 80% of the values in a population that is
# normally distributed with mean 50 and standard deviation 3 will lie below z_80.

## The log-normal distribution uses the:  dlnorm, plnorm  commands
plot(plnorm, xlim = c(-3, 3), ylim=c(0, 1), main = "Cumulative log-normal distribution 
function (black) and density function (red)")
par(new = TRUE)
plot(dlnorm, xlim = c(-3, 3), ylim = c(0, 1), col = 2)



## One has the functional relation of the cumulative distribution functions:
## pnorm(x) = plnorm(exp(x))  for any x
x = seq(-3, 3, by = 0.1)
z = pnorm(x) - plnorm(exp(x))
round(max(abs(z)), digits = 10)

## The density is the derivative of the distribution function. Taking the derivative
## of the functional equation yields:
## dnorm(x) = dlnorm(exp(x)) * exp(x)


## Exponential distribution is via the commands dexp, pexp
# Be careful about the parameter specification of R: e.g., dexp(x,rate = lambda) 
# gives the value of the density of an exponentially distributed random variable with 
# mean (expected) value 1/lambda.  

plot(pexp, xlim = c(-3, 3), ylim = c(0, 1), main = "Cumulative exponential
distribution function (black) and density function (red)")
par(new = TRUE)
plot(dexp, xlim = c(-3, 3), ylim = c(0, 1), col = 2)
# Warning: The plotted image reveals a numerical instability of R's plot command. 
# The red line should start to move up from zero NOT before

