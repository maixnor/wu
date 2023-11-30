
rieman_left = function(f,x,dx) f(x) * dx
rieman_center <- function(f,x,dx) f(x + (dx/2)) * dx
rieman_right <- function(f, x, dx) f(x + dx) * dx

fa <- function(x) exp(x)
fb <- function(x) 1/x
fc <- function(x) x^5 - x^4 - 27*x^3 + x^2 + 146*x + 120
fd <- function(x) sin(x)

evaluate <- function(f, from, to, dx) {

	x <- seq(from, to - dx, by = dx)

	library(purrr)

	yal <- modify(x, function(x) rieman_left(fa, x, dx))
	yac <- modify(x, function(x) rieman_center(fa, x, dx))
	yar <- modify(x, function(x) rieman_right(fa, x, dx))

	sum_al <- sum(yal)
	sum_ac <- sum(yac)
	sum_ar <- sum(yar)
	print(sum_al)
	print(sum_ac)
	print(sum_ar)

}

evaluate(fa, 0, 3, 0.1)
evaluate(fb, -10, -2, 0.1)
evaluate(fc, -3, 5, 0.1)
evaluate(fd, -2, 2, 0.1)
