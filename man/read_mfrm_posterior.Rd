\name{read_mfrm_posterior}
\alias{read_mfrm_posterior}
\title{Load and Verify Saved Bayesian Posterior Summaries with Checksum Validation}
\description{
Loads a saved external Bayesian MFRM posterior summary bundle (\code{posterior-summary.rds} paired with \code{model-data.rds}), verifying cryptographic file checksums, fixed-anchor identities, and MCMC diagnostic metadata (\code{rhat}, \code{ess_bulk}, \code{ess_tail}, and \code{MCSE}) before enabling reporting via \code{summary()}, \code{confint()}, \code{plot()}, \code{predict()}, and \code{as.data.frame()}.
}
\usage{
read_mfrm_posterior(
  path, draws = c("auto", "require", "none"))
}
\arguments{
  \item{path}{Character path to a directory containing \code{posterior-summary.rds} and \code{model-data.rds}, or directly to \code{posterior-summary.rds} in that directory.}
  \item{draws}{Policy for optional posterior draw archives: \code{"auto"} (load if present), \code{"require"} (error if absent), or \code{"none"} (summary metadata only).}
}
\value{
An S3 object of class \code{"mfrm_posterior_summary"} containing \code{parameters}, \code{checks}, \code{sampler}, \code{decision}, and \code{source}, supporting \code{summary()}, \code{print()}, \code{confint()}, \code{plot()}, \code{predict()}, and \code{as.data.frame()}.
}
\seealso{
\code{\link{plot.mfrm_fit}}, \code{\link{mfrmr-s3-methods}}
}
\examples{
bundle_dir <- system.file("extdata", "posterior-example", package = "mfrmr")
post <- read_mfrm_posterior(bundle_dir)
post
head(confint(post), 4)
p_post <- plot(post, type = "intervals")
}
