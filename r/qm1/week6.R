#' ---
#' title: "Session 6: Optimization"
#' author: "QM1"
#' ---
library(emdbook)
#' SINGLE-VARIABLE OPTIMIZATION
#Example on slide 8
#' Visualization:
R<-function(q) {4000*q-33*q^2}
C<-function(q) {2*q^3-3*q^2+400*q+5000}
P<-function(q) {-2*q^3-30*q^2+3600*q-5000}
#' Below we use curve() for plotting. You could of course use 'plot' function as well
curve(R,0,60,n=100,xname="Q",ylab=" ",col=2, lwd=2) 
curve(C,0,60,n=100,add=TRUE,lwd=2)
curve(P,0,60,n=100,add=TRUE,lwd=2,col=5)
abline(v=20, col="blue", lwd=1)
legend("topleft", c("R","C","P"), col = c(2,1,5), lty = 1)
#' Solution:
?optimize 
out<-optimize(P,c(0,60),maximum="TRUE")
optimizer<-out$maximum
optimizer
optimalval<-out$objective
optimalval
#' Retry with a different tolerance level:
out2<-optimize(P,c(0,60),maximum="TRUE",tol=1e-10)
optimizer2<-out2$maximum
optimizer2
optimalval2<-out2$objective
optimalval2
#' MULTIVARIABLE OPTIMIZATION
#Example on Slide 14
#' Visualization:
profit <- function(x,y) {64*x-2*x^2+4*x*y-4*y^2+32*y-14}
curve3d(profit, from = c(0, 0), to = c(100, 100), varnames = c("x", "y"), sys3d="wireframe")
curve3d(profit, from=c(20,10), to = c(50, 30), varnames = c("x", "y"), sys3d="contour",n = 100)
points(40, 24, col = 2, pch = 3)

#' Solution:
?optim # helps us to solve multivariate optimization problems

#we need to be careful on how we define our function.
#This trick is needed to be able to use the optim().

profit2 <- function(a) {
  profit(a[1], a[2])
}

outmv<-optim(c(0.1,0.1),profit2, control=list(fnscale = -1))
#optim() computes (by default) the minimum of a given function f
# if you are interested in computing the maximum of a given function
#you should set 'control=list(fnscale = -1)'. 

outmv$par
outmv$value


#' CONSTRAINED OPTIMIZATION
#' ---

#'Lagrange multipliers (Example on Slide 23)

#function to be maximized
P<-function (x) {80*(x[1])-2*(x[1])^2-x[1]*x[2]-3*(x[2])^2+100*x[2]}

#' Visualization:
P2 <- function(x, y) P(c(x, y))
curve3d(P2, to = c(12, 12), sys3d = "contour")
abline(a = 12, b = -1, col = "red")
points(5, 7, col = 2, pch = 3)

#' Solution:

?constrOptim
# Default option is minimisation, 
#can be converted to maximisation problem via  'control'.
# Inequalities are in the form >=,
#constraint vector and matrices must be modified accordingly
#To solve a problem with equality constraints, represent = as >= & <=,
#and subtract tolerance from constraints...   
#Provide initial values that are in the feasible set (i.e. satisfying constraints)

# | x | y |  result  |
# |---|---|----------|
# | 1 | 0 |        0 |
# | 0 | 1 |        - |
# |-1 |-1 | -12-1e-5 |
# | 1 | 1 |  12-1e-5 |
constM<- matrix(c(1, 0,0, 1,-1, -1,1,1), 4, 2, byrow = TRUE)
# epsilon e ... something that is positive and very small
constV<- c(0, 0, -12-1e-5,12-1e-5)

# starting at (6,6) ... the starting point needs to meet the constraint
# (1,11) would also work
solution=constrOptim(c(6,6),P,ui=constM,ci = constV, grad = NULL,control = list(fnscale = -1))

print('The function is maximized at the point')
solution$par
# notice that optimal value of lagrange multiplier is not part of output! 
print('with a maximum value')
solution$value

# interested students may check the package 'ROI' 
#which is helpful in the solution of more sophisticated optimization problems.

