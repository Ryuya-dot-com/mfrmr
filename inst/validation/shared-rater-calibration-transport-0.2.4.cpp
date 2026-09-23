#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector calibration_joint_logdensity(NumericMatrix draws, int np,
    IntegerVector person, IntegerVector rater, IntegerVector score,
    NumericVector offset, NumericVector par) {
  int nd=draws.nrow(), nr=draws.ncol()-np, n=score.size();
  NumericVector out(nd);
  double sp=par[5], sr=par[4];
  double constant=-np*std::log(sp)-nr*std::log(sr)-.5*(np+nr)*std::log(2*3.14159265358979323846);
  for(int i=0;i<nd;++i) {
    double v=constant;
    for(int p=0;p<np;++p) v-=.5*draws(i,p)*draws(i,p)/(sp*sp);
    for(int r=0;r<nr;++r) v-=.5*draws(i,np+r)*draws(i,np+r)/(sr*sr);
    for(int j=0;j<n;++j) {
      double eta=draws(i,person[j]-1)-draws(i,np+rater[j]-1)-offset[j];
      double a=eta-par[2], b=2*eta-par[2]-par[3];
      double m=std::max(0.0,std::max(a,b));
      double denominator=m+std::log(std::exp(-m)+std::exp(a-m)+std::exp(b-m));
      v+=(score[j]==0 ? 0 : (score[j]==1 ? a : b))-denominator;
    }
    out[i]=v;
    if(i%1000==0) Rcpp::checkUserInterrupt();
  }
  return out;
}
