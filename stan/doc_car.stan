data {
  int<lower = 1> n;
  int<lower = 1> p;
  int<lower = 1> l;
  matrix[n, p] X;
  vector[n] t;
  int<lower = 0> y[n];
  matrix<lower = 0, upper = 1>[l, l] W;
} 
transformed data{
  matrix<lower = 0>[l, l] D;
  {
    vector[l] W_rowsums;
    for (i in 1:l) {
      W_rowsums[i] = sum(W[i, ]);
    }
    D = diag_matrix(W_rowsums);
  }
}
parameters {
  vector[p] beta;
  vector[l] psi;
  vector[l] phi;
  real phi_naught;
  real psi_naught;
  real<lower = 0> tau_phi;
  real<lower = 0> tau_psi;
  real<lower = 0, upper = 1> rho;
  real<lower = 0> sigma;
}
model {
  phi ~ multi_normal_prec(phi_naught, tau_phi * (D - rho * W));
  psi ~ multi_normal_prec(phi_naught, tau_psi * (D - rho * W));
  tau_phi ~ normal(0, 1);
  tau_psi ~ normal(0, 1);
  phi_naught ~ normal(0, 1);
  psi_naught ~  normal(0, 1);
  rho ~ uniform(0, 1);
  sigma ~ normal(0, 1);
  beta ~ normal(0, 1);
  y ~ normal(X * beta + psi * t + psi, sigma);
}