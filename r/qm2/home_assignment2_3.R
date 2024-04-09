# Given data
E_r1 <- 0.13; E_r2 <- 0.18; E_r3 <- 0.14
V_r1 <- 0.0025; V_r2 <- 0.0064; V_r3 <- 0.0036
Cov_r1_r2 <- -0.002; Cov_r1_r3 <- 0.0015; Cov_r2_r3 <- -0.00144

# Anne's weights
w_A1 <- 0.27; w_A2 <- 0.73; w_A3 <- 0.00 # Anne invests in r1 and r2

# Bob's weights
w_B1 <- 0.00; w_B2 <- 0.44; w_B3 <- 0.56 # Bob invests in r2 and r3

# Expected return of Anne and Bob
E_A <- w_A1 * E_r1 + w_A2 * E_r2 + w_A3 * E_r3
E_B <- w_B1 * E_r1 + w_B2 * E_r2 + w_B3 * E_r3

# Variance of Anne and Bob's return
Var_A <- w_A1^2 * V_r1 + w_A2^2 * V_r2 + w_A3^2 * V_r3 + 
         2 * w_A1 * w_A2 * Cov_r1_r2 + 2 * w_A1 * w_A3 * Cov_r1_r3 + 
         2 * w_A2 * w_A3 * Cov_r2_r3

Var_B <- w_B1^2 * V_r1 + w_B2^2 * V_r2 + w_B3^2 * V_r3 + 
         2 * w_B1 * w_B2 * Cov_r1_r2 + 2 * w_B1 * w_B3 * Cov_r1_r3 + 
         2 * w_B2 * w_B3 * Cov_r2_r3

# Covariance between the returns of Anne and Bob
Cov_A_B <- w_A1 * w_B1 * V_r1 + w_A2 * w_B2 * V_r2 + w_A3 * w_B3 * V_r3 + 
           (w_A1 * w_B2 + w_A2 * w_B1) * Cov_r1_r2 + 
           (w_A1 * w_B3 + w_A3 * w_B1) * Cov_r1_r3 + 
           (w_A2 * w_B3 + w_A3 * w_B2) * Cov_r2_r3

E_A
Var_A
E_B
Var_B
Cov_A_B

