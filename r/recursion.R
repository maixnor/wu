
fib_slow <- function(n) {
  ifelse(n == 0 || n == 1, n, fib_slow(n-1) + fib_slow(n-2))
}

fib_fast <- function(n, n_2 = 0, n_1 = 1) {
  ifelse(n == 0, n_2, fib_fast(n-1, n_1, n_2 + n_1))
}

fib_slow(5)
fib_slow(10)
fib_slow(50) 

fib_fast(5)
fib_fast(10)
fib_fast(50)
fib_fast(100)
fib_fast(1000)
