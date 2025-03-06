C <- function(x) (4*x[1]^2-4*x[1]*x[2] + 5*x[2]^2)/10
CM <- matrix(c(1, 0, 0, 1, 1, 5, -1, -5), 2, 4, byrow = TRUE)
CV <- c(0, 0, 140 - 1e-5, -140 - 1e-5)
optimal <- constrOptim(c(10, 26), C, ui = CM, ci = CV, grad = NULL) 
print(optimal)

# maximize x^2 + y^2 subject to x + y = 10
obj <- function(x) -(x[1]^2 + x[2]^2)  # negative for maximization
ui <- matrix(c(1, 1, -1, -1), nrow = 2, byrow=TRUE)  # constraints x+y <= 10 and -x-y <= -10
ci <- c(10, -10)  # making equality constraint
constrOptim(c(5, 5), obj, ui=ui, ci=ci, grad=NULL)

# v <- c(2, 3, 1, 4, 5, 6)
# MyFunction(v) = c(6, 1)

MyFunction <- function(v) {
    x <- rep(v[1], 2)
    i <- 1
    m <- length(v)
    while (i <= m) {
        if (v[i] < x[2]) {
            x[2] <- v[i]
        }
        if (v[i] > x[1]) {
            x[1] <- v[i]
        }
        i <- i + 1
    }
    max <- x[1]
    min <- x[2]
    c(max, min)
}
v <- c(5, 6, 1, 2, 3, 4, 10)
MyFunction(v)

t(A)*F - inv(G)
t(E) %*% F - solve(G)

E <- matrix(c(-2, 1, 1, 4, 3, 0), ncol = 2)
F <- matrix(c(0, 4, 5 -3, 1, 1), = 2)

data <- c(1, 2, 3, 4, 5, 6)
matrix(data, nrow = 2, byrow = TRUE)