# Define a function to calculate the proportion of data within k standard deviations
calc_rule <- function(dataset, k) {
  # Compute the mean and standard deviation
  mean_val <- mean(dataset)
  sd_val <- sd(dataset)
  
  # Determine the open interval corresponding to k standard deviations
  lower_bound <- mean_val - k * sd_val
  upper_bound <- mean_val + k * sd_val
  
  # Calculate the proportion of observations within the interval
  prop_within_interval <- mean((dataset > lower_bound) & (dataset < upper_bound))
  
  # Return relevant information
  return(list(mean = mean_val,
              standard_deviation = sd_val,
              lower_interval_bound = lower_bound,
              upper_interval_bound = upper_bound,
              proportion_within_interval = prop_within_interval))
}

data_sets <- readRDS("Chebyshev-empirical-data.RDS")

# Access the data sets using the dollar sign
data1 <- data_sets$data1
data2 <- data_sets$data2
data5 <- data_sets$data5
data7 <- data_sets$data7

# Calculate proportions for each data set
result_data1 <- calc_rule(data1, k = 1)
result_data2 <- calc_rule(data2, k = 1)
result_data5 <- calc_rule(data5, k = 1)
result_data7 <- calc_rule(data7, k = 1)

result_data1
result_data2
result_data5
result_data7

# Compare with theoretical proportions (if applicable)
# You can also repeat this for k = 2, 3, etc.
# For example, result_data1 <- calc_rule(data1, k = 2)
# and compare with empirical and Chebyshev rules

