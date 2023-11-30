
library(purrr)

rieman_left = function(f,x,dx) f(x) * dx
rieman_center <- function(f,x,dx) f(x + (dx/2)) * dx
rieman_right <- function(f, x, dx) f(x + dx) * dx

f0 <- function(x) 30 - 3*x^2

fa <- function(x) exp(x)
fb <- function(x) 1/x
fc <- function(x) x^5 - x^4 - 27*x^3 + x^2 + 146*x + 120
fd <- function(x) sin(x)

gaussian <- function(x) 1 / (sqrt(2 * pi)) * exp(-1 * (x^2) / 2)

rieman_combined <- function(f, x, dx) c(rieman_left(f,x,dx), rieman_center(f,x,dx), rieman_right(f,x,dx))

rieman_combined(fa, 1, 0.1)

evaluate <- function(f, from, to, dx) {
	x <- seq(from, to - dx, by = dx)

	yal <- modify(x, \(x) rieman_left(f, x, dx))
	yac <- modify(x, \(x) rieman_center(f, x, dx))
	yar <- modify(x, \(x) rieman_right(f, x, dx))

	sum_al <- sum(yal)
	sum_ac <- sum(yac)
	sum_ar <- sum(yar)

	c(sum_al, sum_ac, sum_ar)
}

evaluate(f0, 0, 3, 0.1)
evaluate(f0, 5, 1000, 1)

evaluate(fa, 0, 3, 0.1)
evaluate(fb, -10, -2, 0.1)
evaluate(fc, -3, 5, 0.1)
evaluate(fd, -2, 2, 0.1)

evaluate(gaussian, -1.96, 1.96, 0.1)
