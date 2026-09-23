// Independent fixed-calibration joint latent posterior. No quadrature/Laplace.
data {
  int<lower=1> P;
  int<lower=1> R;
  int<lower=2> K;
  int<lower=1> N;
  array[N] int<lower=1, upper=P> person;
  array[N] int<lower=1, upper=R> rater;
  array[N] int<lower=1, upper=K> y;
  vector[N] facet_offset;
  vector[K - 1] step;
  real<lower=0> person_sd;
  real<lower=0> rater_sd;
}
parameters {
  vector[P] theta;
  vector[R] severity;
}
model {
  theta ~ normal(0, person_sd);
  severity ~ normal(0, rater_sd);
  for (n in 1:N) {
    vector[K] lp;
    lp[1] = 0;
    for (k in 2:K)
      lp[k] = lp[k - 1] + theta[person[n]] - severity[rater[n]] - facet_offset[n] - step[k - 1];
    y[n] ~ categorical_logit(lp);
  }
}
generated quantities {
  real log_joint = normal_lpdf(theta | 0, person_sd) + normal_lpdf(severity | 0, rater_sd);
  for (n in 1:N) {
    vector[K] lp;
    lp[1] = 0;
    for (k in 2:K)
      lp[k] = lp[k - 1] + theta[person[n]] - severity[rater[n]] - facet_offset[n] - step[k - 1];
    log_joint += categorical_logit_lpmf(y[n] | lp);
  }
}
