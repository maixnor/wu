#' ---
#' title: "Week-3: Differentiation and Derivatives in Use, Workspace management"
#' author: "QM-I Team"
#' ---

# Slopes of curves

f <- function(x) x^4
fPrime <- function(x) 4*x^3

h <- seq(1, 1e-10, length.out = 10)
xs <- seq(.5, 2, by = .01)
plot(xs, f(xs), type = 'l')
colas <- rainbow(length(h)) #  you may also try heat.colors(), terrain.colors()

at <- 1

for (i in seq_along(h) ) { #seq_along() = 1:len(h) ... sequence from 1 till length of array
  slope <- (f(at + h[i]) - f(at)) / h[i]
  points(at, f(at), col = colas[i], pch = 16)
  points(at + h[i], f(at + h[i]), col = colas[i], cex = 2, pch = 16)
  abline(f(at) - slope*at, slope, col = colas[i]) # after a + bx (reverse than standard math)
  print(slope)
  # Sys.sleep(1) # looking like an animation in R Studio, does not work like that with plain R and vim
}


# Visualizing Derivatives (increasing-decreasing functions, convexity concavity)

f <- function(x) sin(exp(-x^2) - x^2)
fPrime <- function(x) (- 2 * exp(-x^2) -2) * x * cos(exp(-x^2) - x^2) 
fPrime2 <- function(x) -2 * exp(-2 * x^2) * (2 * (exp(x^2) + 1)^2 * x^2 * sin(exp(-x^2) - x^2) + 
                                               exp(x^2) * (-2 * x^2 + exp(x^2) + 1) * 
                                               cos(exp(-x^2) - x^2))
xs <- seq(-2.5, 2.5, .005)
plot(xs, f(xs), type = 'l')
x <- c(-2, 0, 2)
for(i in seq_along(x)) {
  k <- fPrime(x[i])
  d <- f(x[i]) - k * x[i]
  abline(d, k, col = i+1)
}



op <- par(mfrow = c(3,1)) # current setting saved to op, par then changes it's internal state
plot(xs, f(xs), type = 'l',
     col = 'dodgerblue3', lwd = 2)
plot(xs, fPrime(xs), type = 'l', 
     col = 'dodgerblue3', lwd = 2)
abline(h = 0)
plot(xs, fPrime2(xs), type = 'l',
     col = 'dodgerblue3', lwd = 2)
abline(h = 0)
par(op) # previous settings are then again read into memory from variable

# Taylor Approximation

f <- function(x) exp(x)
expTaylor <- function(x, n, a = 0) {
  polyCoeff <- exp(a) / factorial(1:n)
  ## we want the function to be vectorized in x
  sapply(x, function(y) {
    poly_x <- (y - a)^(1:n)
    exp(a) + sum(polyCoeff * poly_x)
  })
}

xs <- seq(-4, 4, .005)
m <- 10 # my adjustment
n <- 15
a <- 1 # here you may set different values for a and check the corrsponding result
colX <- rainbow(n)
plot(xs, f(xs), type = 'l', lwd = 2)
points(a, f(a), col = 'black', pch = 16)
text(a, f(a) + 4, expression(f(a)), col = 'black')
for(i in m:n) {lines(xs, expTaylor(xs, i, a), 
                    col = colX[i], lwd = 2, lty = 2)
legend('topleft', legend = m:n, col = colX, lty = 2, 
       lwd = 2, cex = .8)
#lines(xs, expTaylor(xs, 10, a), col = 'purple', lwd = 3)
#Sys.sleep(1)
}

#' WORKSPACE MANAGEMENT (ls, rm, save, load, ...)

# list all variables in workspace:
ls()

# get working directory
getwd()                               

# list files in current working directory
dir()                                 

# change to parent directory
setwd("..")                           
getwd()
dir()

# change to child folder "R Sessions"
setwd("r")
setwd("sessions")                   
getwd()
dir()

# save y in a file called "secret.RData" within the current working directory
save(slope, file = "secret.RData")
dir()

# save an image of the workspace in a file called "First_WorkSpace.RData" 
# within the current working directory
save.image("First_WorkSpace.RData")
dir()

# remove variables from workspace:
rsomething <- 1:5
rm(rsomething)                                 
ls() 

rm(list = ls())

# load data from file "secret.RData" the current working directory
load("secret.RData")
ls()


# load data from file "First_WorkSpace.RData" the current working directory
load("First_WorkSpace.RData")
ls()

