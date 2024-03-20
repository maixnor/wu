C <- function(x) (4*x[1]^2-4*x[1]*x[2] + 5*x[2]^2)/10
CM <- matrix(c(1, 0, 0, 1, 1, 5, -1, -5), 2, 4, byrow = TRUE)
CV <- c(0, 0, 140 - 1e-5, -140 - 1e-5)
optimal <- constrOptim(c(10, 26), C, ui = CM, ci = CV, grad = NULL) 
print(optimal)
