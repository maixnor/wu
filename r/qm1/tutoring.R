
# nested for loop
for (i in 1:3) {
    sum <- 0
    for (j in 1:5) {
        sum <- sum + a[i,j]
    }
    print(sum)
}

# tell me what does does?
mirror_matrix_x <- function(mat) {
    mirrored_mat <- matrix(nrow = nrow(mat), ncol = ncol(mat))
    for (i in 1:nrow(mat)) {
        mirrored_mat[i, ] <- mat[nrow(mat) - i + 1, ]
    }
    return(mirrored_mat)
}

# a function that calculates the rieman sum of a vector of values
# word cloud:
# 0, 1, 2
# values, sum, i
# length, dx

riemann_sum <- function(values, dx) {
    sum <- 0
    for (i in 2:length(values)) {
        sum <- sum + values[i] * dx
    }
    return(sum)
}

# a function to calculate the determinant, then the inverse of a 2x2 matrix
det_and_inverse <- function(mat) {
    n <- nrow(mat)
    if (n != ncol(mat)) {
        stop("Matrix is not square!")
    }
    
    if (n == 2) {
        det <- mat[1,1] * mat[2,2] - mat[1,2] * mat[2,1]
        if (det == 0) {
            stop("Cannot inverse when determinant is 0!")
        }
        inv <- (1 / det) * matrix(c(mat[2,2], -mat[1,2], -mat[2,1], mat[1,1]), nrow = 2)
    } else {
        stop("This is not a 2x2 matrix!")
    }
    inv    
}

optimize_profit <- function(profit_func, min_x, min_y, max_sum) {
    initial_guess <- c(min_x + 0.1, min_y + 0.1)
    
    ui <- rbind(c(1, 0), c(0, 1), c(1, 1), c(-1, -1))
    ci <- c(min_x, min_y, max_sum, -max_sum)
    
    result <- constrOptim(initial_guess, -profit_func, grad=NULL, ui=ui, ci=ci, control = list(fnscale = -1))
    
    return(result$par)
}
optimize_profit(\(x, y) {x^2 + y^2}, 0, 0, 10)
