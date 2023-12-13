#' ---
#' title: "Session 7: Matrix Algebra"
#' author: "QM 1"
#' ---

#' Definition of matrices

matrix(1:6, 2, 3)
matrix(1:6, 2, 3, byrow = TRUE)

?matrix

matrix(1:6, nrow = 2)
matrix(1:6, ncol = 3)

# matrix definition uses recycling
matrix(1:6, ncol = 4)
matrix(1:6, nrow = 4, ncol = 4)
matrix(1:8, nrow = 4, ncol = 4)

#' Special matrices - The identity matrix and the zero matrix
matrix(0, nrow = 3, ncol = 4)
diag(4)

#' General diagonal matrices
diag(c(2, 3, 1, 4))


#' Indexing
(A <- matrix(1:15, nrow = 5, byrow = TRUE))
A[1, 2]
A[2, 3]
A[1]
A[5]

#' R drops dimensions (does not case whether a vector is a row or column vector), unless told otherwise
A[1,]
A[, 3]
A[ , 1, drop = FALSE]


A[2:3, c(1, 3)]
A[, c(1, 3)]

A[-1, ]
A > 5
A[A > 5]



#' nrow, ncol, dim
nrow(A)
ncol(A)
dim(A)



#' rbind and cbind
R <- rbind(A, matrix(0:2, 2, 3))
R
dim(R)


C <- cbind(A, matrix(1:10, 5, 2))
C
dim(C)


#' dimnames
colnames(A)
rownames(A)
colnames(A) <- c("C1", "C2", "C3")
rownames(A) <- paste("R", 1:5, sep =  "")
A
rownames(A)
dimnames(A)
A["R4", "C3"]
A["R3",]

#' rowSums, colSums
rowSums(A)
colSums(A)


#' Element-wise matrix operations
A + 2
A * 1.5
A + A
A / A
A^2
A * A
A * t(A)

#' Matrix multiplication is different!
A %*% t(A)
t(A) %*% A



#' Market share example
T <- matrix(c(85, 5, 10, 10, 55, 35, 10, 5, 85), nrow = 3)/100 
## Note the different color of T: R knows T as a shortcut for T, we are rewriting that now!
s <- c(0.2, 0.6, 0.2)
T %*% s
T %*% T %*% s
T %*% T %*% T %*% s
T %*% T %*% T %*% T %*% s    # market share vector after 4 time periods



T.power.n <- function(n,T) {
  if (n == 0) {return(diag(dim(T)[1]))}
  Z <- T 
  if (n > 1) { 
    for (j in 2:n) {
      Z <- Z %*% T
    }
  }
  Z
}

L <- 30

M <- matrix(0, nrow = 3, ncol = L + 1)
for (j in 1:(L + 1)) {M[ , j] = T.power.n(j - 1, T) %*% s}

plot(0:L, M[1, ], ylim = c(0, 1))
points(0:L, M[2, ], col = 2)
points(0:L, M[3, ], col = 3)
title("Black: A, Red: B, Green: C")

library("expm")
T %*% T
T %^% 2


#' Matrix inverse
A <- matrix(c(1, 2, 3, 5, 1, 6, 3, 6, 8), nrow = 3)
A
B <- solve(A)  
B
A %*% B
round(A %*% B, digits = 10)
A2 <- matrix(c(1, 1, 1, 1, 1, 0, 0, 0, 1), nrow = 3)
solve(A2) # singular matrix - inverse does not exist


#' Solve a system of equations
b <- c(9, 9, 17)
solve(A, b)
A%*%solve(A, b)
