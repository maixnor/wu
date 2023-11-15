#' ---
#' title: "Session 5: Functions of many variables"
#' author: "QM1"
#' ---

library(emdbook) # if not available: install.packages("emdbook")

#' Demand for milk (slide 4)
f <- function(p, m) p^(-1.5)*m^2.08  


# Function curve3d()
curve3d(f, from = c(.5, .5), to = c(1, 1), varnames = c("p", "m"), sys3d = "wireframe")
curve3d(f, from = c(.5, .5), to = c(1, 1), varnames = c("p", "m"), sys3d = "persp",
        ticktype = "detailed")

#Level curves, contour plots
#'The graph of the function in three-dimensional space is visualized as being
#'cut by horizontal planes parallel to the xy-plane. 
#'If the intersecting plane is z = c, then the corresponding level curve
#'will consist of the points satisfying f(x,y)=c

#one can use the function curve3d() to create contour plots (level curves)
#contour is like a map looking like a chinese leveled rice field
curve3d(f, from = c(.5, .5), to = c(1, 1), varnames = c("p", "m"), sys3d = "contour") 
#heatmap
curve3d(f, from = c(.5, .5), to = c(1, 1), varnames = c("p", "m"), sys3d = "image")


#' demand for money (slide 7)
M <- function(Y, r) .14*Y + 76.03*(r-2)^(-0.84)
curve3d(M, from = c(0, 2.01), c(40000, 2.5), sys3d = "wireframe",
        varnames = c("Y", "r"))

#' Another function
f <- function(x,y) x * (25 - x) + y * (24 - 2*y) - (3*x^2 + 3 * x * y + y^2)
curve3d(f, to = c(5, 5))
#In order to change number of grid points in each direction, change n
curve3d(f, to = c(5, 5), sys3d = "contour",n = 100)

points(2, 3, col = 2, pch = 3)


#' while cycle
#' 
#' What is the smallest number n for which the sum of 1:n is more than 1000?

n <- 1
while(sum(1:n) < 1000){
  n <- n+1
}

# alternatively:
n <- 1
cond <- F
while(!cond) {
  n <- n+1
  if(sum(1:n) >= 1000) cond <- TRUE
}


#' return() will stop the rest of the function from executing
#' If this is not required (output only given at the end of the function), 
#' return() is not necessary
#' e.g. function Foo will output n if n<=10, 2*n if 10<n<=20 and 3*n otherwise
Foo <- function(n) {
  if(n <= 10) return(n)
  if(n <= 20) return(2*n)
  3*n
}

Foo(2)
Foo(12)
Foo(35)

#' Functions can have several outputs
#' e.g.: For two natural numbers x and y, return the whole division result and its remainder
Foo2 <- function(x, y) {
  div <- floor(x/y) # floor rounds to nearest lower/equal number
  rem <- x%%y
  c(div, rem)
}

Foo2(6, 3)
Foo2(6, 4)
Foo2(4, 6)
