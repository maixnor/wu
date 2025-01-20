# Business Analytics II - Financial Market Analysis

## Exercise Sheet 1

*Read sections 1-3 of the lecture notes first.*

*Use simple returns if not stated otherwise.*

---

### Exercise 1
You need to execute the BA2 Ex1.R script uploaded on Canvas prior to dealing with the points below.

1. Read-in the firm data.csv dataset.
2. Convert the data on earnings for the first firm to an xts object and plot it.
3. Convert the data on earnings for all firms to an xts object and subset the data to the period from 1990 to 2018.
4. The firm characteristics are reported on frequencies lower than monthly. Convert both the time-series of prices and the time-series of earnings to yearly data:
   - a) Take yearly averages of available earnings in each year (don’t forget to use na.rm=TRUE).
   - b) Take only the last price of each year.
5. Calculate yearly returns from the yearly prices.
6. Take the first company of the dataset and make a 2-panel multipanel plot:
   - a) The upper panel shows the return series; the lower panel shows yearly average earnings.
   - b) Add the 3-year moving average of earnings to the lower panel.

---

### Exercise 2
Use index data.RData. Pick one index of your choice.

1. Convert the data to an xts object.
2. Count the number of trading days in each:
   - a) Month
   - b) Year
   between 1995 and the end of 2015. Visualize the results appropriately to give an idea of the typical number of trading days over the respective time window.
3. Plot the:
   - a) First
   - b) Last index value of each month as two separate lines in one plot.
4. Plot the monthly returns of the index using the last index value of each month.
5. Calculate daily returns of the index.
6. Visualize the density of daily returns.
7. Draw a plot of the time series of daily returns and another plot with the squared values of daily returns below the first one. Daily squared returns can be interpreted as an estimate of the variance (assuming zero-mean of the returns, on average). Are incidences of high volatility (variance) evenly spread across time or clustered?
8. Lag the time series of returns by one day. Do the same for the series of squared returns.
9. Compute the sample correlation between daily returns and lagged returns between 2000 and 2018. Do the same for the series of squared returns and lagged squared returns. What do the results tell you?

---

### Exercise 3
Use index data.RData. Plot the price series of the S&P 500, the Dow Jones Industrial, and the FTSE 100 from the beginning of 1995 until the end of 2018.

1. Draw all price time series in a single plot.
2. Draw all price time series in multiple plots.
3. Compute monthly non-overlapping returns from the daily data for all indices.