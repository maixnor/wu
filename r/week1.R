#' ---
#' title: "Session 1: Getting to Know R, Defining functions"
#' author: "QM-1"
#' ---
#' R as a calculator
#' 

4*10^1 + 2*10^0 + 1*10^(-1) + 4*10^(-2)
1/100000000
1 / 10 # spaces around operator signs don't matter
2.34e-02
13/11  # a cutoff after 6 decimal places (per default)
print(13/11, digits = 9) # display 9 digits 
sqrt(2)
2^0.5 
27^(1/3)
(1/32)^(1/5)
.0001^.25 #no need for leading zeros in front of '.'

#' R knows pi
pi
#e # R does know the Euler constant, but not this way

#' Some more built in functions
exp(1) # the Euler constant
exp(5)
log(exp(5))
choose(5, 2) # calculates the binomial coefficient. (combinations)
factorial(5) # 5!

#' Getting help in R:
#How can I get help with built in functions? 
?log
?choose

#If the name of the command is unknown, typing two question marks activates a buzzword search.
?? '!='

#' Storing values a.k.a. the "gets" operator:
r <- 4
13/11 -> somenumber
1.02*r -> r # the "old" r will be overwritten

points <- 30 * (1 + .8 + 1.1)/3  
points
(points <- 30 * (1 + .8 + 1.1)/3) # result is displayed


# R is  vectorized. 
#' In order to create a vector use c( ... ) - for combine  
r <- c(2, 3, 4, 5) # a vector with the entries  2, 3,4,5 is generated 

2:5 # the same result can be achieved using colon operator
1:3
r^2 # squares all entries of the vector elementwise 

r2 <- 1:4
r*r2
r + r2
r - r2
r/r2

r + 5
r*5
r - 5
r/5

r3 <- 1:3
r + r3 # recycling in the shorter vector

r4 <- 1:8
r + r4

rsomething <- c(r, r) # combine two vectors to one new vector
rsomething

#' More complex sequences (seq, rep, ...):

seq(1, 10, by = 2) 
seq(10, 1, by = -1) 
seq(1, 10, length.out = 55)
rep(r, 2) 
rep(r, 2, each = 2) 
rep(r, times = 1:4)

#' Even more built in functions (length, sum, min, summary, mean, prod, ...):
mean(r)
min(r)
length(r)
sum(r)

#' Simple indexing:
r[4]
r[c(1, 3)]
r[-4] # minus in index means except. Everything except the 4th entry
r[-c(1, 3)]

#' Comparison Operators
2 == 3  #== sign use to compare the left and right handside
2 < 3  
r < 4
1 != 1  # != ... used to ask/check for unequality 

r < 5 & r > 2   # logical 'and' operator works elementwise in a vector
r < 3 | r > 3 # logical 'or' workds elementwise in a vector
#' WARNING: && and || both work as the logical 'and' and the logical 'or', respectively, too, but only they are
#' not vectorized - only work for a single number
#r < 5 && r > 2 # error
#r < 3 || r > 3 # error
pi < 5 && pi > 2 # valid
pi < 3 || pi > 3 # valid

#' More complex indexing:

r[r < 4]
r[r != 4]

#' Logicals can be translated to numbers
(2 == 3)*5
(2 != 3)*5
sum(r > 2)


# Define a function C with variable x, compare example on slide 9
C <- function(x) {                    
  100 * x * sqrt(x) + 500
}

# print objective value at x=1
C(1)       
# print all objective values for x = 0,...,10
C(0:10)                               
C


#' DEFINE A FUNCTION WITH DEFAULT VALUES
# Define a linear function of x, called linfun, with parameters a, b
# set a = 0, b = 0 as default values
linfun <- function(x, a = 0, b = 0) { a*x + b }

# print objective values of linfun at x = 1,...,5 where

# a = 1, b = 2
linfun(1:5, 1, 2)                               
linfun(1:5, a = 1, b = 2)

# a = 2, b = 1
linfun(1:5, a = 2, b = 1)

# a = 0, b = 0 by default
linfun(1:5)           

# a = 0 y default, set b = 1
linfun(1:5, b = 1)  


