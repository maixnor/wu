#' ---
#' title: 'Session 2: Functions in R'
#' author: QM 1 
#' ---

#' PLOT FUNCTIONS

# Define a function C with variable x, compare example on slide 9 
C <- function(x) {                    
  100*x*sqrt(x) + 500
}

C(1)
C(1:10)

# generate a plot with coordinates x = 0,...,10 and y = C(0),...,C(10)
plot(0:10, C(0:10))                    

# generate a plot, with specified options 'type' and 'color'
x <- 0:10
plot(x, C(x), type = 'l', col = 'red')
plot(x, C(x), type = 'b', col = 2)                         
x <- 0:1000
plot(x, C(x), type = 'l', col = 5)                         
# set a title on top of the plot
title("Some weird function")          

# naming the axis
plot(x, C(x), type = "l", main = "Cost function", xlab = "products", ylab = "costs")

#colors() #to get all the colors

#' ADDING LINES TO A PLOT:
# compare example on slides 13-15, 
# define and plot the demand and supply functions D and S
D <- function(P) { -10 * P + 400 }
plot(0:30, D(0:30))
S <- function(P) { 10*P }
# add a plot of the supply function, 
# (plot points (p,S(p)) for p = 0,...,30)
points(0:30, S(0:30), col = 2)        

plot(0:30, S(0:30), type = 'l', ylim = c(0, 400))
# add a plot of the demand function, 
# (plot line segments between points (p,D(p)) for p = 0,...,30)
lines(0:30, D(0:30))                  

# add a straight horizontal line at y = 200 in green color
abline(h = 200, col = "green")         

# add a straight vertical line at x = 20 in green color
abline(v = 20, col = 3)                


#' if else vs. ifelse
a <- 4
b <- 8
if (TRUE) { print(a) }
if (FALSE) { print(a) }
if (a > 3) { print(a) }
if (a > 5) {
  print(a)
} else {
  print(b)
}

# Error: c(a,b) > 5 is gonna look like { true, false } and if cannot deal with that
# if (c(a,b) > 5) { "Yeah" } else { "No" } 

# vectorized version of if {} else {}. This one can do collections
ifelse(c(b,a) > 5, "Yeah", "No")

ifelse((1:10)%%2 == 0, "divisible by 2", "not divisible by 2") 
# %% - modulo operator - rest after division

#' max vs. pmax

data <- 1:10
max(5, data)
max(15, data)
pmax(5, data)


#' THE TAX EXAMPLE, slides 39-40:

T1 <- function(y) { y^2 / 1e6 - 100 }
T2 <- function(y) { 9900 + (y - 1e5)/4 }

y <- c(9000, 50000, 80000, 120000, 160000)
T2(y[4:5])
T1(y[1:3])


# wrong implementation using max instead of pmax ...
T_wrong1 <- function(y) {
  ifelse(y < 1e5, max(0, T1(y)), T2(y))
}
# ...returns the maximum of 0, T1(y[1]), T1(y[2]), T1(y[3]), T1(y[4]), T1(y[5]), whenever y<1e5
# and T2(y) otherwise
T_wrong1(y)

# wrong implementation using if (){} else {} instead of ifelse () ...
T_wrong2 <- function(y) {
  if (y < 1e5) {
    pmax(0, T1(y))
  } else {
    T2(y)
  }
}
# ...will not work since "if" only expects one condition 
#TODO uncomment
#T_wrong2(y)

# correctly implemented function
T <- function(y) {
  ifelse(y < 1e5, pmax(0, T1(y)),  T2(y))
}
T(y)


# plot the function and suggested modifications
y <- seq(0, 2e5, by = 100)

# set graphical parameters 'line width' to 1.5 (by default 1)  
# and 'line type' to '2=dashed' (default 1=solid)
par(lwd = 1.5, lty = 2)

plot(y, T(y), type = 'l')
lines(y, T(y - 1e4), col = 2)
lines(y, T(.95*y), col = 3)
lines(y, pmax(T(y) - 1e3, 0), col = 4)
lines(y, .9*T(y), col = 5)

# add a legend in topleft corner
legend("topleft", c("Regular tax",
                    "Deduct 10k before taxes",
                    "Deduct 5% before taxes",
                    "1k tax credit",
                    "10% tax credit"),
       col = 1:5, lty = 2)


#' PLOTTING THE INVERSE

x <- seq(-2, 2, 0.01)
y <- seq(-9, 7, 0.01)

f <- function(x) { x^3 - 1 }
# inverse: (y + 1)^(1/3)
# what if y + 1 < 0?
(-8)^(1/3)

# if b is odd and/or a >=0 (not necessarily both conditions), then the b-th root of a exists, otherwise not
nthroot <- function(a,b) ifelse(b%%2==1 | a>=0, sign(a)*abs(a)^(1/b), NaN)
nthroot(-8,3)
nthroot(-1,2)

# inverse of f: set parameter a = y+1 and b = 3
f_inv <- function(y) nthroot(y+1,3)
f_inv(-9)

plot(x, f(x), type='l', ylim=c(-2,2))
lines(y, f_inv(y), col=2)
abline(0, 1, col=3)


#' NEW FUNCTIONS FROM OLD
par(lty = 1)
f <- function(x) { 3*x - x^3 }
g <- function(x) { x^3 }

x <- seq(-5, 5, by = .01)
plot(x, f(x) + g(x), type = 'l', ylab = '')
lines(x, f(x) - g(x), col = 2)
lines(x, f(x) * g(x), col = 3)
lines(x, f(x) / g(x), col = 4)

plot(x, f(g(x)), type='l',col=5, ylim=c(-10,10))
lines(x, 3*x^3-x^9, col=2)

lines(x, g(f(x)), col=3)
lines(x,(3*x-x^3)^3,col=4)

f(g(1))
g(f(1))
