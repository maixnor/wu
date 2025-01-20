# Business Analytics II - Financial Market Analysis

## Exercise Sheet 3

*Read sections 4 and 5 of the lecture notes first.*  
Use price data.csv and firm data.csv and simple returns if not stated otherwise.  

*Note:* Shares outstanding are reported in thousands of shares, and the book value of debt and equity is reported in millions of USD.

---

### Exercise 1
Select 400 firms of your choosing, sort them according to their market value at the end of 2002, and compute their stock return for the year 2003.

1. Plot the yearly return of all firms as a function of size. Redo the plot, but this time only use the firms that are in the 5% to 95% range of market cap.
2. Form size decile portfolios and compute their returns:
   - Visually compare the ten portfolio returns over time by plotting the cumulative monthly returns.
   - Compare their yearly returns using a suitable plot. What do you observe compared to single stock returns?
3. Use a parametric hypothesis test to check whether stocks sorted by size have different returns. Does the result fit your visual inspection?

---

### Exercise 2
Construct ten equally weighted portfolios according to size (market cap) and rebalance the portfolios at the end of every year.  
Start at the end of the year 2002 and stop at the end of 2018.  
This means:
- a) Take market caps at the end of 2002, sort stocks into decile-portfolios (from firms with the lowest to firms with the highest market cap).
- b) Hold equally weighted versions of each portfolio until the end of 2003.
- c) At the end of 2003, again sort stocks into decile-portfolios.
- d) Hold the new 10 equally weighted portfolios until the end of 2004, and so on.

*Note:* Always consider only those firms for which you have a market cap from the end of the previous year and prices at the end of the following year.

1. Start by computing yearly returns of every stock together with the corresponding market cap from the end of the previous year.  
   - Set the most extreme 1% of returns (i.e., the lowest 0.5% and the highest 0.5%) to NA.
2. Compute yearly returns for the decile-portfolios:
   - For every year, first check for NA values in this year for both the returns and the relevant market caps.
   - Consider only those firms that have all information available.
   - *Hint:* Use cut(), as outlined in the lecture notes, to classify firms by market cap size, and aggregate() to take the average across all firms in a particular portfolio (because portfolios are equally weighted).
3. Visually compare the cumulative return of the ten portfolios and the average yearly returns.
4. Use a parametric hypothesis test to check whether stocks sorted by size have different returns. Does the result fit your visual inspection?