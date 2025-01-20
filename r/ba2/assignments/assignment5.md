# Business Analytics II - Financial Market Analysis

## Exercise Sheet 5

*Read section 8 of the lecture notes first.*  
If not stated otherwise, use stock returns from the workspace returns hw4.RData, available for download on Canvas.

---

### Exercise 1
The CAPM assumes that a stock’s \( \beta \) is constant over time. Test this assumption by computing the \( \beta \)s of three stocks of your own choosing. Use 10-year windows, compute the \( \beta \)s, shift the window by one year, compute the \( \beta \)s, and so on.  

For simplicity:
- Take the equally weighted average of all returns in returns hw4.RData as the market return.
- Use the monthly risk-free returns provided in F-F Research Data Factors.CSV.

1. Plot the time-series of \( \beta \)s and check if the CAPM assumption holds.
2. Also check the presence and persistence of the stocks’ alphas.

---

### Exercise 2
*(Continuation of Exercise 1.)*  
A CAPM insight is that higher expected returns go hand in hand with greater risk of performing poorly in bad times. Can you confirm this claim?

1. Compute the \( \beta \)s of all individual stocks using data up to 2006.
2. Pick the three highest \( \beta \) stocks and three lowest \( \beta \) stocks and examine their returns during the Great Financial Crisis.  
   - Compute and visualize cumulative monthly returns from 2007 until 2010.

---

### Exercise 3
Use the data on the three Fama & French factors and 12 industry portfolios available for download on Canvas.  
(The data originates from the website of Kenneth R. French: [Data Library](http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html).)  

Run the following regressions for each industry \( i \):  
\[
r_{i,t} - r_{f,t} = \alpha_i + \beta_{mkt}(r_{mkt,t} - r_{f,t}) + \beta_{smb}SMB_t + \beta_{hml}HML_t + \epsilon_{i,t}
\]
Where:
- \( r_{i,t} \): Return of industry \( i \) in \( t \),
- \( r_{mkt,t}, SMB_t, HML_t \): The three Fama & French factors,
- \( r_{f,t} \): Risk-free return in \( t \).

For each industry, estimate these regressions repeatedly over a rolling window of 24 months. For example:
- The first set of regressions uses data from July 1926 to June 1928.
- The second set of regressions uses data from August 1926 to July 1928, and so on.

By estimating all these models, you obtain a time-series for all industry alphas and betas.

1. Compare the \( \beta \)s and \( \alpha \)s over time. What do you observe? Are the results in line with your expectations?
2. Compare the average (over time) \( \beta \)s and \( \alpha \)s of each industry graphically.  
   - What do you conclude from these plots?  
   - Which industry seems to outperform the others?  
   - Which industries seem to deliver negative abnormal returns?