
# lesson 2

library(dplyr)
library(ggplot2)

pool_visitors = read.csv('r/eda/data/pool_visitors.csv')
head(pool_visitors)

pool_visitors %>% ggplot(aes(x = visitors)) +
    geom_histogram(bins = 20)

pool_visitors %>% ggplot(aes(x = temperature)) +
    geom_histogram(binwith = 3)

pool_visitors %>% summarize(
    mean_visitors = mean(visitors)
    mean_temperature = mean(temperature)
)

pool_visitors %>%
    group_by(weather) %>%
    summarise(
        mean_visitors = mean(visitors),
        mean_temperature = mean(temperature),
        count = n()
    ) %>% 
    ggplot(aes(x = weather, y = mean_visitors)) +
        geom_bar(stat = "identity")

m1 <- lm(visitors ~ temperature, data=pool_visitors)
summary(m1)

pool_visitors %>%
    ggplot(aes(x = temperature, y = visitors)) +
    geom_point(aes(color = weather)) +
    geom_smooth(method = "lm", se = F)

m2 <- lm(visitors ~ temperature + weather, data=pool_visitors)
summary(m2)

pool_visitors %>%
    ggplot(aes(x = temperature, y = visitors, color = weather)) +
    geom_point() +
    geom_line(aes(y=m2$fitted.values))

m3 <- lm(visitors ~ temperature + weather + temperature*weather, data=pool_visitors)
summary(m3)
# intercept of sunny days is 37 + 13, the 13 is the increase in intercept compared to cloudy days
# slope of sunny days is 1.5 + 1.01, the 1.5 is the increase in slope compared to cloudy days

pool_visitors %>%
    ggplot(aes(x = temperature, y = visitors, color = weather)) +
    geom_point() +
    geom_line(aes(y=m3$fitted.values))


