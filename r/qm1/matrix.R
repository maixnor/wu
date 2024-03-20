# Calculate the matrix value based on x and y
calculate_value <- function(initial, x, y, x_constant, y_constant) {
  return(initial + (x-1) * x_constant + (y-1) * y_constant)
}

# Example usage
matrix_A <- outer(1:33, 1:33, function(x, y) calculate_value(44, x, y, 10, 23))
matrix_B <- outer(1:33, 1:35, function(x, y) -10 * 1.2^((x-1) + (y-1)))

# Print the resulting matrices
print(matrix_A)
print(matrix_B)

print(matrix_B[28,15])
print(matrix_A[5,11])
print(sum(matrix_A[,18]))
print((matrix_A %*% matrix_B)[13,10])
print((matrix_A %*% matrix_A)[14,8])



