#' ---
#' title: "Session 8: Matrix Algebra ctd., Financial mathematics"
#' author: "QM 1"
#' ---

#' Matrix determinant
A <- matrix( c(1,2,3,5,1,6,3,6,8), nrow = 3)
A
det(A)   ## Determinant of A. (It's non-zero if and only if A is invertible)
if (det(A) != 0) { print("A is invertible.") }

#' Continuous compounding (slide 4): 
#' (1 + r/n)^(nt) tends to e^r when n tends to infinity, 
#' consider t=1 year and 
#' compound yearly (n=1), monthly (n=12), daily (n=365), every second 

compound <- function(r = 0, n = 1, t = 1) { (1 + r/n)^(n*t) }

n <- c(1, 12, 365, 365*24*60*60 )

compound(1, n)
exp(1)

# Or we can plot the above for n = 1:1000
r <- 1
n <- 1:1000
plot(n, compound(r, n))
abline(exp(r), 0, col=2)
## lines(n,exp(r-r^2/(2*n)),col = 3)  # adds a line according to n -> exp(r-r^2/(2*n))

#' Example Slide 19
PV <- function(a, r) {
  sum(a/(1+r)^(1:length(a)))
}

a <- c(-10000, 2000, 2500, 3000, 3500)

PV_IRR <- function(r) PV(a, r)
rs <- seq(0, 0.1, by = 0.01)
PVs <- sapply(rs, PV_IRR)
plot(rs, PVs, type = "l")
abline(h=0)
# find the root numerically
IRR <- uniroot(PV_IRR, c(0, 0.1))
IRR$root
PV_IRR(IRR$root)
# adjust tolerance
IRR <- uniroot(PV_IRR, c(0, 0.1), tol = 1e-10)
IRR$root
PV_IRR(IRR$root)


#' Handy programming skills
#' Output several objects of a different type from a function.
c(5, "no") # 5 transformed into a character!

#' defining lists
some_output <- 1:5
other_output <- "Hello"
another_output <- matrix(1:9, nrow = 3)
all_together <- list(some_output, other_output, another_output)
all_together
all_together[[1]]
all_together$some_output
names(all_together) <- c("some_output", "other_output", "another_output")
all_together$some_output
all_together$another_output
# directly definining with names
all_together2 <- list(some_output = some_output, other_output = other_output, another_output = another_output)
all_together2


#' find the largest natural number below x that is divisible by 2, 
#' say whether it is also divisible by 3
foo <- function(x) {
  if(x <= 2) return("There is no natural number divisible by 2 that is smaller than x.")
  max_div_2 <- max((1:(ceiling(x)-1))[1:(ceiling(x)-1) %% 2 == 0])
  div_3 <- ifelse(max_div_2 %% 3 == 0, "divisible by 3", "not divisible by 3")
  return(list(multiple_of_2 = max_div_2, is_divisible_3 = div_3))
}
foo(1)
foo(3)
foo(18.2)


#' which
# max(a) finds the maximal value in a - but where in the vector is the value?
a <- c(1, 8, 2, 15, 3, 18, 4)
max(a)
which(a == max(a))
# which entries in a are divisible by 2?
which(a%%2 == 0)
a[which(a%%2 == 0)]
a[a%%2 == 0]


#' Example: The sieve of Erastothenes (https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes) 
#' Implementing a more complicated algorithm
primes_sieve <- function(n) {
  current_prime <- 2
  primes <- 2
  sequence <- 1:n
  are_primes <- rep(TRUE, n)
  are_primes[current_prime*(2:(n/current_prime))] <- FALSE
  left <- sequence[are_primes]
  continue <- TRUE
  while(continue) {
    current_prime <- min(left[left>current_prime])
    primes <- c(primes, current_prime)
    if(current_prime <= n/2) {
      are_primes[current_prime*(2:(n/current_prime))] <- FALSE
      left <- sequence[are_primes]
    } else {
      continue <- FALSE
    }
  }
  return(left[-1]) # 1 is not a prime
}
