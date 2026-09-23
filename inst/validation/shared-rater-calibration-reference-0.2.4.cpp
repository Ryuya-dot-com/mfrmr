#include <Rcpp.h>
using namespace Rcpp;

// Direct three-category response probabilities, independent of package helpers.
double logden3(double a, double b) {
  double m = std::max(0.0, std::max(a, b));
  return m + std::log(std::exp(-m) + std::exp(a-m) + std::exp(b-m));
}

// [[Rcpp::export]]
NumericMatrix translated_log_weights(NumericMatrix ability, NumericMatrix severity,
    IntegerVector person, IntegerVector rater, NumericVector offset,
    NumericVector steps, NumericMatrix change_eta, NumericMatrix change_steps,
    NumericMatrix shift, NumericVector constant, NumericVector rater_sd,
    NumericVector person_sd, double base_rater_sd, double base_person_sd) {
  int nd = ability.nrow(), np = ability.ncol(), nr = severity.ncol();
  int nq = constant.size(), n = person.size();
  NumericMatrix out(nd, nq);
  for (int i=0; i<nd; ++i) {
    double sum_b2=0, sum_u2=0;
    for (int p=0; p<np; ++p) sum_b2 += ability(i,p)*ability(i,p);
    for (int r=0; r<nr; ++r) sum_u2 += severity(i,r)*severity(i,r);
    for (int q=0; q<nq; ++q) {
      double shifted2=0;
      for (int p=0; p<np; ++p) {
        double b = ability(i,p)+shift(p,q); shifted2 += b*b;
      }
      out(i,q)=constant[q] + np*std::log(base_person_sd/person_sd[q])
        + .5*sum_b2/(base_person_sd*base_person_sd)
        - .5*shifted2/(person_sd[q]*person_sd[q])
        + nr*std::log(base_rater_sd/rater_sd[q])
        + .5*sum_u2/(base_rater_sd*base_rater_sd)
        - .5*sum_u2/(rater_sd[q]*rater_sd[q]);
    }
    for (int j=0; j<n; ++j) {
      double eta=ability(i,person[j]-1)-severity(i,rater[j]-1)-offset[j];
      double a=eta-steps[0], b=2*eta-steps[0]-steps[1];
      double base=logden3(a,b);
      for (int q=0; q<nq; ++q) out(i,q) += base - logden3(
        a+change_eta(j,q)-change_steps(0,q),
        b+2*change_eta(j,q)-change_steps(0,q)-change_steps(1,q));
    }
    if (i % 1000 == 0) Rcpp::checkUserInterrupt();
  }
  return out;
}
