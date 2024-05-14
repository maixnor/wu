# Dataset of heights
heights <- c(150.4, 147.5, 147.8, 150.9, 148.4, 150.4, 150.7, 149.2, 146.4, 152.3, 150.4, 151.8, 154.7, 152.3, 147.8, 149.6, 150.2, 149.9, 155.2, 143.6, 150.9, 151.9, 149.1, 150.3, 148.6, 151.9, 148.9, 146.3, 143.7, 150, 149.5, 151.4, 153.1, 151.4, 160.3, 140.6, 158.8)

# Calculate mean and standard deviation
mean_height <- mean(heights)
sd_height <- sd(heights)

# Calculate z-score for observation 151.8
observation <- 151.8
z_score <- (observation - mean_height) / sd_height

# Calculate percentage of observations more than two standard deviations from the mean
extreme_threshold <- 2 * sd_height
extreme_count <- sum(abs(heights - mean_height) > extreme_threshold)
extreme_percentage <- (extreme_count / length(heights)) * 100

# Calculate number of observations above and below one standard deviation from the mean
one_sd_above <- mean_height + sd_height
one_sd_below <- mean_height - sd_height
above_count <- sum(heights > one_sd_above)
below_count <- sum(heights < one_sd_below)

# Find the most extreme observation
most_extreme <- max(abs(heights - mean_height))

# Calculate z-scores for all observations and count outliers
z_scores <- (heights - mean_height) / sd_height
outliers_count <- sum(abs(z_scores) > 2)

# Output results
print(paste("5.41% of all observations are more than two sample standard deviations from the mean:", round(extreme_percentage, 2)))
print(paste("Consider the observation 151.8. The z-score of this observation is:", round(z_score, 3)))
print(paste("There are less observations that are more than one sample standard deviation above the mean than those that are more than one sample standard deviation below the mean:", above_count < below_count))
print(paste("The most extreme observation relative to this sample is:", most_extreme))
print(mean_height)
print(paste("According to the definition of outliers based on the z-scores given in the slides, there are exactly 3 outliers in the dataset:", outliers_count == 3))

