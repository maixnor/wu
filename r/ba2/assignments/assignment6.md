# Business Analytics II - Financial Market Analysis

## Exercise Sheet 6

*Read section 9 of the lecture notes first.*  
For both Exercises 1 and 2, use daily data on the Euro area risk-free yield curve (maturities: 3M, 1Y, 5Y, 7Y, 10Y) contained in data yields.csv. Yields are given in percent per year. For Exercise 2, directly build on your calculations from Exercise 1.

---

### Exercise 1
This exercise is about summarizing the information in the raw data using PCA.

1. *Load data yields.csv.*  
   Plot the yield curve for August 23, 2021, with maturities (in years) on the x-axis and the corresponding yield on the y-axis.

2. *Visualize the yield curve across time.*  
   Simultaneously plot all maturities for all days in the sample. By visually inspecting the plot, what can you infer about the co-movement of yields over time?

3. *Standardize yields for every maturity.*  
   Subtract the mean and divide by the standard deviation (SD). Obtain all principal components (PCs) of the standardized data and visualize the relative share of overall variance captured by each PC.  
   - *Question:* How many PCs are sufficient to summarize the data?

4. *Reconstruct the yield curve using the first three PCs.*  
   - Compute the mean and SD for every maturity and store them.
   - Approximate the standardized data using the first 3 PCs:
     \[
     D^* = X^* \Lambda^{\prime *}
     \]
   - Scale back the approximation to the original data scale (multiply by the SD and add back the mean).

5. *Check your approximation for the 3M, 5Y, and 10Y maturities.*  
   - Convert the approximated yield curve data to xts.  
   - Create a multi-panel plot with the original and approximated data for these maturities.

---

### Exercise 2
This exercise is about interpreting the principal components from Exercise 1.

1. *Plot the loadings matrix for the first three PCs.*  
   Plot the loadings across maturities (x-axis: maturity in years, y-axis: loadings for each PC).  
   - *Question:* Do the interpretations of the PCs as "level," "slope," and "curvature" align with your data?

2. *Compare the PCs with directly computed measures of level, slope, and curvature.*  
   - *Level:* Use the 5Y maturity yield and compare it to the 1st PC.
   - *Slope:* Compute the difference between 10Y and 3M yields. Compare this to the 2nd PC.
   - *Curvature:* Add the 10Y and 3M yields, subtract twice the 5Y yield, and compare to the 3rd PC.  
   For each measure:
   - Standardize the data and visually compare it to the standardized PC.  
   - *Question:* How well do the PCs align with these interpretations?

---

### Exercise 3
This example applies PCA to interest rate risk modeling.

*Scenario:*  
You manage a stylized (risk-free) bond portfolio with cash flows in Table 1.

| Maturity   | Amount (EUR billions) |
|------------|------------------------|
| 3 months   | 5                     |
| 1 year     | 5                     |
| 5 years    | 15                    |
| 7 years    | 8                     |
| 10 years   | 25                    |

#### Tasks:
1. *Calculate the portfolio value as of August 23, 2021.*  
   Assume all cash flows are risk-free. Use appropriate maturities for discounting.

2. *Estimate the impact of a steepening yield curve (95% VaR).*  
   - Compute daily changes in the 2nd PC.
   - Calculate the 95% VaR for steepening. Check whether the 5% or 95% quantile is relevant based on the loadings matrix.

3. *Apply the steepening scenario to each maturity.*  
   Multiply the 2nd PC's 95% VaR change by the respective loadings to estimate yield changes for each maturity.

4. *Recompute the yield curve.*  
   Add the estimated changes to the yields as of August 23, 2021, to generate a steeper yield curve. Use this new curve to revalue portfolio cash flows.

5. *Compute the portfolio value change.*  
   Compare the new value to the original portfolio value.  
   - *Interpret your findings.*