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
# Business Analytics II - Financial Market Analysis

## Exercise Sheet 2

*Read sections 4.1 and 6 of the lecture notes first.*

*Use simple returns if not stated otherwise.*  
Re-use the files firm data.csv, price data.csv, and index data.RData from the last home assignment.

---

### Exercise 1
At the beginning of 2003, you buy the portfolio described in the table below.

1. Compute the portfolio value at the end of each month and plot it.
2. Compute the monthly portfolio returns and plot them.
3. Compare the portfolio’s return distribution to the stocks’ return distributions graphically.
4. Plot the time series of relative portfolio weights, \(w_i^t\). (Graph the weight time series in a single plot.)
5. Compute the portfolio’s as well as the stocks’ volatility and skewness.
6. Compute the portfolio’s historical Value at Risk and Expected Shortfall at a 2% level.
7. Compute the portfolio’s Sharpe ratio. For this purpose, use risk-free returns from risk free return monthly.csv (values are already given as monthly returns in %). You may use the arithmetic mean on simple returns to compute the Sharpe ratio.
8. Compare the portfolio’s cumulative return time series to the cumulative return of a portfolio constructed of the stocks of the same five companies, but where every stock has the same weight (i.e., a 1/N portfolio). Weights are set to 1/N at the beginning of each period, so always take the average (across firms) over returns of the period.

#### Formula Reference:
\[ w_i^t = \frac{h_i^t p_i^t}{V_t} \]

*Extra:* When comparing the portfolio return time series to the stocks’ return time series, what do you observe? Do stylized facts about the risk-return relationship hold? What about the crisis period?

#### Portfolio Details:
| Company                | Number of Stocks |
|------------------------|-------------------|
| Dictum Ltd            | 100               |
| Pede Ltd              | 100               |
| Sed LLP               | 200               |
| Consectetuer Company  | 150               |
| Vel LLC               | 50                |

---

### Exercise 2
Again, consider the index data file already used in previous exercises.

1. *S&P500 Index Data:*  
   Load the data, extract the data on the S&P500 stock index, convert it to an xts object, and calculate daily returns. Then calculate the 95% VaR for daily returns over the whole sample period. Plot the returns as points. Then:
   - Add a horizontal line indicating the VaR.
   - Re-draw those return points that fall below the VaR in a different color.
   - *Observation:* What do you observe? Do you think the VaR line adequately indicates the risk of substantial losses? Compute the percentage of observations below the VaR to verify that 5% fall below the VaR, as expected.

2. *Expanding Window VaR:*  
   Calculate the VaR for the next day using an expanding window. For instance:
   - Use the first 250 returns to calculate the VaR for the 251st return.
   - Use the first 251 returns to calculate the VaR for the 252nd return, and so on.
   - Plot daily returns as points, add the 95% VaR line (non-constant over time), and highlight returns below the VaR in a different color.
   - *Observation:* How does this VaR perform in indicating substantial loss risks? Compute the percentage of observations below the VaR and compare it to the intended 5%.

3. *Arithmetic Mean of Daily Returns:*  
   Calculate the arithmetic mean of daily returns over the whole sample period to verify it is slightly positive but very close to zero.

4. *Volatility Clusters:*  
   Calculate rolling daily volatility for overlapping windows of 25 trading days.  
   - Use this value to predict tomorrow’s volatility by lagging the time series by one day.
   - Plot your predictions of tomorrow’s volatility.

5. *VaR Using Predicted Volatility:*  
   Assuming daily returns follow a normal distribution:
   - Use the rolling volatility prediction to calculate tomorrow’s variance.
   - Compute the 5% quantile for the 95% VaR using the formula:
     \[
     \text{VaR} = \text{qnorm}(p = 0.05, sd = \text{predicted volatility})
     \]
   - Convert the forecasts into an xts object.
   - Plot daily returns as points, add the VaR line, and highlight returns below the VaR in a different color.
   - *Observation:* Do you think the VaR has improved compared to the previous method? Compute the percentage of observations below the VaR and compare it to the expected 5%.

6. *Multi-Level VaR:*  
   Using your forecasts of variance, calculate the VaR at levels of 90%, 95%, 99%, and 99.9%. For each level:
   - Compute the percentage of observations below the VaR.
   - Divide the results by the respective desired percentages.  
   - *Observation:* What do you notice? Why do you think this happens?

#### Notes:
- Use rollapply() with align = "right" for rolling calculations.
- To compute quantiles, use qnorm() with p = 0.05 and your volatility forecast.
