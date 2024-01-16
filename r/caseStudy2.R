# Function to find vertices of the feasible region
findVertices <- function(A, b) {
  m <- nrow(A)
  V <- matrix(0, ncol = 2, nrow = m)  # Matrix to store vertices
  v <- 0  # Vertex counter

  for (i in 1:(m - 1)) {
    for (j in (i + 1):m) {
      system_matrix <- matrix(c(A[i, ], A[j, ]), ncol = 2, byrow = TRUE)
      system_rhs <- c(b[i], b[j])

      if (det(system_matrix) != 0) {
        solution <- solve(system_matrix, system_rhs)

        valid_solution <- TRUE
        for (k in 1:m) {
          if (k != i && k != j) {
            if (A[k, 1] * solution[1] + A[k, 2] * solution[2] > b[k]) {
              valid_solution <- FALSE
              break
            }
          }
        }

        if (valid_solution) {
          v <- v + 1
          V[v, ] <- solution
        }
      }
    }
  }

  V <- V[1:v, , drop = FALSE]
  return(V)
}

# Function to find the optimal solution
findOptSolution <- function(f, c, V, max = TRUE) {
  v <- nrow(V)
  zOpt <- V[1, ]

  for (i in 2:v) {
    z <- V[i, ]

    if (max) {
      if (f(c, z) > f(c, zOpt)) {
        zOpt <- z
      }
    } else {
      if (f(c, z) < f(c, zOpt)) {
        zOpt <- z
      }
    }
  }

  return(zOpt)
}

# Example usage:
A <- matrix(c(1, 1, 2, -1, -1, 2), nrow = 3, byrow = TRUE)
b <- c(5, 1, 2)

# Find vertices
vertices <- findVertices(A, b)
print("Vertices:")
print(vertices)

# Define an objective function (example: sum of squares)
objective_function <- function(c, z) {
  return(sum((c * z)^2))
}

# Define the coefficients
c <- c(1, 1)

# Find the optimal solution using the vertices
optimal_solution <- findOptSolution(objective_function, c, vertices, max = TRUE)
print("Optimal Solution:")
print(optimal_solution)

