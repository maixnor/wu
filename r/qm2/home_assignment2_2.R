# Load necessary library
library(stats)

# 1. P(Z^2 < 1.44)
p_z_squared_less_144 <- 2 * pnorm(sqrt(1.44)) - 1
cat("P(Z^2 < 1.44):", round(p_z_squared_less_144, 4), "\n")
cat("Is P(Z^2 < 1.44) = 0.9251:", round(p_z_squared_less_144, 4) == 0.9251, "\n")

# 2. Transformation to standard normal distribution
# This is a theoretical verification, no direct calculation needed. It is true if variance is correctly squared.

# 3. Monthly expense not exceeded by 96% households
z <- qnorm(0.96) # Find z such that P(Z <= z) = 0.96
monthly_expense_96_percentile <- 20 * z + 430
cat("Monthly expense not exceeded by 96%:", round(monthly_expense_96_percentile, 2), "\n")

# 4. Standard deviation of chicken egg weight
# Given that 85% range is symmetric around the mean, we use qnorm to find the Z-scores at the 7.5th and 92.5th percentiles (since it's symmetric).
lower_bound <- qnorm(0.075)
upper_bound <- qnorm(0.925)
std_dev_estimate <- (75 - 70) / (upper_bound - lower_bound)
cat("Standard deviation of chicken egg weight > 3g:", std_dev_estimate > 3, "\n")

# 5. Probability within one standard deviation from the mean
p_within_one_sd <- pnorm(1) - pnorm(-1)
cat("P(mu - sigma < X < mu + sigma):", round(p_within_one_sd, 3), "\n")
cat("Is P(mu - sigma < X < mu + sigma) ~~ 68.3%:", round(p_within_one_sd * 100, 1) == 68.3, "\n")

