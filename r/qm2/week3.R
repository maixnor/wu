#' ---
#' title: "Week-3: Descriptive Statistics " 
#' author: "QM-II"
#' ---
#' DESCRIBING QUALITATIVE DATA
#' ---
#'Example on slide 59:
# First introduce the data matrix:
mydata <- rbind(c(180, 179, 510, 862), c(145, 106, 196, 23))
rownames(mydata) <- c("male", "female")
colnames(mydata) <- c("1st", "2nd", "3rd","crew")
mydata
mydata["male","2nd"]

#we can convert it to a data frame
converteddata <- as.data.frame(mydata)
converteddata
converteddata$crew

#'Another example:
# In general we can work with  a data frame:
kids <- c("Jack", "Jill")
ages <- c(12, 10)
d <- data.frame(kids, ages, stringsAsFactors = FALSE)
d
d$ages
d$kids

icecream <- c('Yes', 'Yes')
dd <- data.frame(kids, ages, icecream, stringsAsFactors = TRUE)
dd

#'to see the overall structure of this data frame:
str(dd)
str(d)

#if the data is raw, one could use table() to obtain absolute frequencies
rdat <- c(1, 1, 1, 3, 3, 4, 3, 2, 2, 1, 1, 2, 2, 1, 1, 4, 5, 5, 6, 2, 3, 3)
table(rdat)


#' Calculating frequencies for the travel classes (Slide 61):
freq <- colSums(mydata)
freq

#' Now calculate relative frequencies (Slide 61):
rel.freq <- freq/sum(freq)
# or alternatively
rel.freq <- prop.table(freq)
old = options(digits=4)
rel.freq
options(old)

#' bar chart with frequencies (Slide 63)
barplot(freq) 

#' Now we plot something more colourfull (Slide 64)
# First define the colours to be used
colors = c("red", "yellow", "green", "violet", "orange", "blue", "pink", "cyan") 
#'now use the colors via 'col='
barplot(rel.freq, col = colors, main = "Bar graph of travel classes")    


#' Pie Chart with Percentages
pie(freq) 
#' We can change the colors on the pie chart (slide 63):
pie(freq, col = colors)
#'Now we want to put labels 
pct <- round(rel.freq*100)
lbls <- c("1st", "2nd", "3rd", "crew")
lbls <- paste(lbls, pct) # add percents to labels 
lbls <- paste(lbls, "%", sep = "") # ad % to labels 
#'A pie chart with labels and colors from build-in R color palette 'rainbow'
pie(freq, labels = lbls, col = rainbow(length(lbls)),
    main = "Pie Chart of travel classes") 


#' GRAPHICAL METHODS for DESCRIBING QUANTITATIVE DATA
#' ---

# R's internal data sets 
data()
# one of the data sets is called Nile and contains data on the flow of the Nile River.
str(Nile)

#' Frequency distribution:
#first find the range,i.e., the interval of observed values:
range(Nile)
#divide the range into non-overlapping intervals:
nbreaks <- seq(450, 1400, by=50)

#As the intervals are to be closed on the left,
#and open on the right in an emprical cdf, we set the 'right' argument as FALSE.
nile.cut <- cut(Nile, nbreaks, right = FALSE)
nile.freq <- table(nile.cut)
cbind(nile.freq)

#' Histogram via hist() or histogram() (Slide 68):
#intervals closed on the left
hist(Nile, right = FALSE, xlab = "flow", main = "Histogram: flow of Nile") 
#different number of break points
hist(Nile, right = FALSE, breaks = 20, xlab = "flow", main = "Histogram: flow of Nile")
#histogram with relative frequencies
hist(Nile, right = FALSE, freq = FALSE, xlab = "flow", main = "Histogram: flow of Nile")



#'Empirical distribution function 

#via function ecdf()
#an example:
plot(ecdf(c(2, 3, 6, 6, 7)), main = "Emprical distribution function (Mini example)")

#another example (try)
plot(ecdf(c(2, 2, 3, 3, 2, 4, 3, 2, 6, 6)), main = "ECDF: find sample")

# ecdf for Nile flow data (slide 72)
Fn <- ecdf(Nile)
plot(Fn, main = "Empirical distribution function", 
     xlab = "flow", ylab = "Cumulative flow proportion")

#' Scatter plot (Slide 74):
engel <- read.csv("engel.csv") #the data set 'engel.csv' is under week-3 folder
inc <- engel[,"income"]
fdexp <- engel$foodexp # two ways of accessing variables
plot(inc, fdexp, xlab = "income", ylab = "food expenditure")





