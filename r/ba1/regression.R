
story <- read.csv('Storyline_Data.csv')

str(story)

lm0 = lm(Sales ~ Adv_Spending, data=story); summary(lm0)
lm1 = lm(Sales ~ Quality_flour, data=story); summary(lm1)
lm2 = lm(Sales ~ RD_spending, data=story); summary(lm2)

lmm = lm(Sales ~ Adv_Spending+Quality_flour+RD_spending, data=story); summary(lmm)
