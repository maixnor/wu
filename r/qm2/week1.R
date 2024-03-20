#' ---
#' title: "Session 1: Probability "
#' author: "QM-II "
#' ---

## Defining a vector with possible outcomes of a random variable
out <- c( -1, 1, 2.4, 7.286 )

## We also define a vector with probabilities for each of these outcomes
p <- c( 1/6, 1/4, 1/3, 1/4)


## We can also define the distribution function
F <- function(a) { 
  sum((out <= a)*p )
}
x <- seq(-2, 10, 0.1)
y <- sapply(x, F)
plot(x, y, xlim=c(-2, 10), 'p')
abline(v = out, col = 2)


## Let us calculate the expectation
EX <- sum(out*p)
cat("Expectation is: ", EX, "\n")


## ... and the variance
VX <- sum((out - EX)^2*p)
cat("Expectation is: ", VX, "\n")


## Or we bundle this in a single function that produces both
EnVar <- function(out,p) {
  EX <- sum(out*p)
  VX <- sum((out - EX)^2*p)
  return(c(EX, VX))
}
EnVar(out, p)

## If we have another random variable we can produce the covariance
outY <- c(2, 4, -1, 0)

EY <- EnVar(outY, p)[1] 

CovXY <- sum((out - EX)*(outY - EY)*p)  # note: this assumes that X and Y take on the defined values
# simultaneously, that is, whenever X is -1, Y is 2, etc. - order matters!
print(CovXY)


#' For most of the distributions, the d/p-functions are available
#' d	density function if continuous; OTHERWISE probability mass function
#' p	(cumulative) distribution function

# Example: Binomial Distribution with n = 10 trials and p = 0.5 success probability.
# The following command produces the probabilities for the 11 possible outcomes.
# The possible outcomes for a binomial distribution with n = 10 trials are the integers 
# from 0 to 10.
n <- 10
p.suc <- 0.5

out <- 0:n
p <- dbinom(0:n, n, p.suc)

cat("Outcomes: ", out, "\n\nProbabilities: ", p[0:4], "\n\n", p[5:11])


## Formula from the lecture slides:
cat("Expectation: ", n*p.suc, "\nVariance: ", n*p.suc*(1-p.suc))

## And now with our routine
cat("Expectation: ", EnVar(out, p)[1], "\nVariance: ", EnVar(out, p)[2])


#' Recall: function choose(k, n) calculates the number of sets with
#' n elements than can be chosen from a set with k elements, that is the binomial coefficient
choose(3, 5)  ## Why is the result zero?
choose(5, 3)


#Please check the following distributions and repeat the above exercises:
#Poisson Ditribution: d/p pois() 
lambda <- 1
N <- 1000  # cutoff point. You need this as the possible outcomes range from 0 to infinity!
out <- 0:N
p <- dpois(0:N, lambda)

# ... now its your turn

## Formula from the lecture slides:
cat("Expectation: ",NULL,"\nVariance: ",NULL)






