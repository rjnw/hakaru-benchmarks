data {
  real<lower=0> s;
  int<lower=1> K;          // number of mixture components
  int<lower=1> N;          // number of data points
  real t[N];               // observations
}
parameters {
  simplex[K] theta;          // mixing proportions
  ordered[K] mu;             // locations of mixture components
}
model {
  vector[K] log_theta = log(theta);  // cache log calculation
  mu ~ normal(0, s);
  for (n in 1:N) {
    vector[K] lps = log_theta;
    for (k in 1:K)
      lps[k] += normal_lpdf(t[n] | mu[k], 1);
    target += log_sum_exp(lps);
  }
}
