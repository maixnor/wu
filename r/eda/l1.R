
load("data/testdata.Rdata")
head(testdata)

testdata$size <- ifelse(testdata$str < 20, "small", "large")

t_output <- t.test(testscr ~ size, data = testdata)
t_output$p.value

lm(
    formula = testscr ~ size, 
    data = testdata
) -> ols
summary(ols)

mls <- lm(testscr ~ county, testdata)
summary(mls)

library("dplyr")

testdata %>%
    group_by(county) %>%
    summarise(mean(testscr))

f(2,3)
2 $>$ f(3)

library('ggplot2')

testdata %>%
    ggplot(
        mapping = aes(x = str, y = testscr)
    ) +
    geom_point() +
    geam_smooth(method = "lm", "se" = FALSE)
