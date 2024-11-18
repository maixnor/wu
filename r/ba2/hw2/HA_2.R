## Exercise 2

#Task 1

library(xts)
load("index_data.RData")
head(indices)
sp500 <- indices$sp.xts #extracting the s&p500 indices
dates <- as.Date(row.names(indices))
sp500xts <- xts(indices$sp.xts, order.by=dates) #conversion to xts object 

(returns_daily <- sp500xts / lag(sp500xts, k=1) -1) #calculating simple daily returny
returns_daily <- na.omit(returns_daily) #removing NA-s
VaR95 <- quantile(returns_daily, probs=0.05) #lower endpoint of the 95% VaR
VaR95

plot(returns_daily, type="p", col="steelblue", main="Daily return series of the S&P 500 including VaR 95% (coral)")
VaR95_seq <- rep(VaR95,times=length(returns_daily) ) #adjusting the length of the 95% VaR
VaR95_seq <- xts(VaR95_seq, order.by = time(returns_daily)) #converting it to an XTS object

lines(VaR95_seq, col="coral", lwd = 3)
points(returns_daily[returns_daily < VaR95], col = "gold", pch = 19, cex = 1.2)

#During market crashes and high volatility (e.g. in 2008) the VaR often underestimates the actual risk,
# as VaR is static and does not adapt to market condition changes.
#Therefore, it does not always adequately indicate the risk of substantial losses. 

below_VaR95_number <- length(returns_daily[returns_daily< VaR95]) #number of returns below the 5% quantile
total_number <- length(returns_daily) #total number of returns
(below_VaR95_percentage <- below_VaR95_number/total_number*100) #verification whether
#indeed 5% of all values lies below VaR 95%

#Task 2


#Conclusion: With the expanding window calculation method of the VaR at 95%,
#we could verify that the theory - similarly to our previous calculation - holds -->
#Indeed 5% of all returns lie below the 5th quantile of VaR 95%. 

#The expanding window method is better at indicating the risk of substantial losses 
#as its threshold value is constantly adjusted based on the cumulative returns data
# up to the current year measured. As an example, one can refer to the graph
# at the period after the 2008's stock market crash. The value of VaR 95% decreased,
#indicating that negative returns are more likely based on recent negative returns. 


