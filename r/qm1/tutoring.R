
# A function that mirrors a matrix around the x-axis
mirror_matrix_x <- function(mat) {
    mirrored_mat <- matrix(nrow = nrow(mat), ncol = ncol(mat))
    for (i in 1:nrow(mat)) {
        mirrored_mat[i, ] <- mat[nrow(mat) - i + 1, ]
    }
    return(mirrored_mat)
}

# a function that calculates the rieman sum of a vector of values
riemann_sum <- function(values, x) {
    sum <- 0
    for (i in 2:length(values)) {
        dx <- x[i] - x[i - 1]
        sum <- sum + values[i - 1] * dx
    }
    return(sum)
}

# a function to calculate the determinant, then the inverse of a 2x2 matrix
det_and_inverse <- function(mat) {
    n <- nrow(mat)
    if (n != ncol(mat)) {
        stop("Matrix must be square")
    }
    
    if (n == 2) {
        det <- mat[1,1] * mat[2,2] - mat[1,2] * mat[2,1]
        if (det == 0) {
            stop("Matrix is singular and cannot be inverted")
        }
        inv <- (1 / det) * matrix(c(mat[2,2], -mat[1,2], -mat[2,1], mat[1,1]), nrow = 2)
    } else {
        stop("Only 2x2 are supported")
    }
    inv    
}

# a function that wraps constrOptim for a 2-variable optimization problem
# params: profit function, min x, min y, max x+y
optimize_profit <- function(profit_func, min_x, min_y, max_sum) {
    # Initial guess
    initial_guess <- c((min_x + max_sum) / 2, (min_y + max_sum) / 2)
    
    # Constraints: x >= min_x, y >= min_y, x + y <= max_sum
    ui <- rbind(c(1, 0), c(0, 1), c(1, 1), c(-1, -1))
    ci <- c(min_x, min_y, max_sum, -max_sum)
    
    # Perform constrained optimization with fnscale = -1
    result <- constrOptim(initial_guess, profit_func, NULL, ui, ci, control = list(fnscale = -1))
    
    # Return the optimal values of x and y
    return(result$par)
}
