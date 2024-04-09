
# Assuming D follows an exponential distribution with a rate (lambda) parameter
lambda <- 1/14

# 1. Variance of the distance people are willing to commute
variance <- 1/(lambda^2)
print(paste("Variance:", round(variance, 2)))
print(variance == 0.07) # Check if the variance is 0.07

# 2. P(D<11)
p_d_less_11 <- pexp(11, rate=lambda)
print(paste("P(D<11):", p_d_less_11))
print(dexp(11, rate=lambda)) # This is not the correct way to compute P(D<11), dexp gives the density

# 3. E[A] = E[πD^2]
# Since E[D^2] for an exponential distribution is 2/lambda^2
expected_area <- pi * 2 / (lambda^2)
print(paste("Expected area:", round(expected_area, 3)))
print(round(expected_area, 3) == 1231.504)

# 4. Checking the density function formula
# This involves understanding the exponential distribution's PDF, which is λe^(-λx)
# Let's just affirm the provided function aligns with this distribution's PDF for a given value
density_at_x <- lambda * exp(-lambda * 1) # Example at x=1
print(paste("Density at x=1:", round(density_at_x, 4)))

# 5. Probability of commuting more than 17 kilometers
p_more_than_17 <- 1 - pexp(17, rate=lambda)
print(paste("Percentage willing to commute more than 17 km:", round(p_more_than_17 * 100, 2)))
print(round(p_more_than_17 * 100, 2) == 29.69)

