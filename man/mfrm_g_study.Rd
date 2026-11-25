\name{mfrm_g_study}
\alias{mfrm_g_study}
\title{Estimate Univariate and Multivariate Generalizability Study Variance Components}
\description{
Estimates variance and covariance components for balanced or unbalanced crossed and nested rating designs using Henderson Method 1 (\code{method = "urgenova"}), ANOVA, or \code{MINQUE(0)}.
}
\usage{
mfrm_g_study(
  data, scores = NULL, person = "Person", rater = "Rater", task = "Task",
  method = c("anova", "minque0", "urgenova"), missing = c("error", "omit"),
  facets = NULL, nesting = NULL, score = NULL, weights = NULL,
  d_study_grid = NULL, truncate_negative = TRUE)
}
\arguments{
  \item{data}{A \code{data.frame} of observed ratings.}
  \item{scores}{Character vector naming one or more score columns.}
  \item{person}{Character string naming the person identifier column.}
  \item{rater}{Character string naming the rater column when \code{facets = NULL}.}
  \item{task}{Character string naming the task column when \code{facets = NULL}.}
  \item{method}{Variance-component estimator (\code{"anova"}, \code{"minque0"}, or \code{"urgenova"}).}
  \item{missing}{Missing-value policy (\code{"error"} or \code{"omit"}).}
  \item{facets}{Character vector of non-person facet column names.}
  \item{nesting}{Optional named character vector \code{c(Child = "Parent")} declaring nested facets.}
  \item{score}{Alias for \code{scores} in univariate designs.}
  \item{weights}{Optional nonnegative composite weights matching \code{scores}.}
  \item{d_study_grid}{Optional candidate D-Study design grid \code{data.frame}, with one column per facet and positive integer counts only. Nested-facet counts are per parent level.}
  \item{truncate_negative}{Logical; whether to clamp negative variance estimates at zero.}
}
\value{
For \code{method = "urgenova"}, an \code{mfrm_fast_gtheory} object with
\code{variance_components} (raw and optionally truncated estimates, SE and df),
\code{vc_vcov}, \code{g_study_summary}, \code{d_study}, and \code{covariance_basis}.
For other estimators, an \code{mfrm_multivariate_gstudy} object.
}
\details{
Henderson Method 1 solves the expected mean-product equations for the declared
crossed or nested random-effects design. A rank-deficient coefficient matrix is
rejected: the data cannot distinguish the requested variance components.
For \code{urgenova}, unidentified components and too few complete observations
signal an error of class \code{"mfrm_gstudy_unavailable"}.
Negative raw estimates are retained in \code{RawEstimate}; \code{truncate_negative}
controls their use in projected point estimates.
For \code{urgenova}, zero total variance or negative universe/projected error
variance gives an unavailable G/Phi (\code{NA}), with the reason in
\code{GStatus}/\code{PhiStatus}; see \code{\link{mfrm_d_study}}.

The \code{urgenova} sampling covariance uses the Gaussian quadratic-form identity
\eqn{\operatorname{Cov}(y'Ay,y'By)=2\operatorname{tr}(AVBV)} with the actual
assignment pattern, including imbalance and replication. The working covariance
\eqn{V} substitutes nonnegative component estimates (negative raw estimates are
zeroed for this calculation). This is a plug-in covariance, not an exact
finite-sample distribution or a model-free uncertainty estimate.
\code{confint()} uses Satterthwaite chi-square approximations for positive
components and logit delta intervals for G/Phi; boundary coefficients may have
unavailable intervals (\code{NA}). The approximation is particularly limited
near zero components and in sparse designs.
}
\examples{
ratings <- load_mfrmr_data("example_core")
gt <- mfrm_g_study(ratings, scores = "Score", person = "Person",
                   facets = c("Rater", "Criterion"), method = "urgenova")
mfrm_d_study(gt)
}
