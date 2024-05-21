print("+++++++++ Q4 ++++++++")

s1 <- c(720.23, 724.43, 725.34, 728.22, 724.47, 729.21, 730.2, 729.41, 729.28, 729.36, 719, 724.21, 734.55, 725.36, 731.45, 721.81, 730.49, 732.75, 730.53, 732.91, 720.69, 734.48, 729.8, 721.43, 729.61, 722.56, 723.98, 723.21, 725.42, 728.94, 734.24, 724.79, 728.42, 728.56, 720.23, 730.01, 727.28, 728.61, 728.18, 735.74, 728.63, 734.14, 732.08, 726.79)

z <- function(s1, za) {
  lower <- mean(s1) - za * sd(s1)/sqrt(length(s1))
  higher <- mean(s1) + za * sd(s1)/sqrt(length(s1))
  c(lower, higher)
}

mean (s1)
z(s1, 1.282)

733.015-1.96*5.22/sqrt(71)
733.015+1.96*5.22/sqrt(71)

z(s1, 2.576)

733.015-1.645*5.22/sqrt(71)
733.015+1.645*5.22/sqrt(71)

z(s1, 1.440)

print("+++++++++ Q5 ++++++++")

bloodtest<-c(30, 28, 26, 24, 80, 86, 38, 48, 91, 35, 343, 75, 116, 14, 70, 453)
bloodlog <-log (bloodtest)
b1<-mean(bloodlog)-2.947*sd(bloodlog)/sqrt(length(bloodlog))
b2<-mean(bloodlog)+2.947*sd(bloodlog)/sqrt(length(bloodlog))
mean(bloodlog)-2.131*sd(bloodlog)/sqrt(length(bloodlog))
mean(bloodlog)+2.131*sd(bloodlog)/sqrt(length(bloodlog))
b2-b1
mean(bloodlog)-1.341*sd(bloodlog)/sqrt(length(bloodlog))
mean(bloodlog)+1.341*sd(bloodlog)/sqrt(length(bloodlog))
exp(3.778)
exp(4.409)
mean(bloodtest)-1.341*sd(bloodtest)/sqrt(length(bloodtest))
mean(bloodtest)+1.341*sd(bloodtest)/sqrt(length(bloodtest))
