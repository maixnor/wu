# Business Analytics II - Financial Market Analysis

## Exercise Sheet 4

*Read section 7 of the lecture notes first.*  
Use the return data contained in returns hw4.RData. Use the (sub)sample historical mean and covariance matrix as estimates for the expected return vector and covariance matrix.

---

### Exercise 1
Plot the portfolio frontier and the efficient frontier for the case with two risky assets using the following parameters:

- \( E[r_A] = 0.2, E[r_B] = 0.5 \)
- \( \sigma_A = 0.2, \sigma_B = 0.4 \)
- \( \rho(r_A, r_B) = -0.2 \)

Try different values for \( \rho(r_A, r_B) \). Describe the outcome intuitively!

---

### Exercise 2
Compute the efficient frontier using return data up to the year 2001 (no short selling, no risk-free asset). Pick five portfolios that are on the efficient frontier.

- *Plot all stocks in the risk-return plane.*
- *Add the efficient frontier to the plot.*
- *Add the five portfolios you picked to the plot.*

Compute the efficient frontier using return data for the whole sample (no short selling, no risk-free asset).

- *Plot all stocks in the risk-return plane.*
- *Add the efficient frontier to the plot.*
- *Add the five portfolios you picked previously, but using the new data.*

*Question:* Are the five portfolios you picked still efficient?  
*Note:* To check whether or not your chosen five portfolios are still efficient in the full sample, you need to keep their asset weights fixed (as estimated from the sample up to 2001) and consider the expected asset returns and covariance matrix of the whole sample.

---

### Exercise 3
Compute the efficient frontier using return data up to the year 2001 (allow for short selling and no risk-free asset).

- *Plot all stocks in the risk-return plane.*
- *Add the efficient frontier to the plot.*
- *Plot the weights for a portfolio that has an expected return of 1%.*
- *Plot the weights for a portfolio that has an expected return of 1.5%.*
- *Plot the weights for a portfolio that has an expected return of 2%.*

Expand the time frame by one year (i.e., up to 2002) and redo the plots.  
*Question:* How stable are the weights?  

If you restrict short selling, what happens to the stability of weights?  
*Steps to check stability of weights:*

1. Compute the differences in weights obtained using the sample ending in 2001 and the sample ending in 2002.
2. Take the absolute value of the differences.
3. Compute the mean across assets.

Do this separately for each portfolio return level (1%, 1.5%, or 2%) and also separately for the scenarios with and without short selling constraints.  

Create a bar plot showing the mean absolute weight change for the no short selling and the short selling scenario for each of the three return levels (all in one plot).  

*Explain your findings intuitively:* Why does your finding make sense?