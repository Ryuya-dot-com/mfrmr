# Build a peer-review design review

Build a peer-review design review

## Usage

``` r
build_peer_review_design_review(peer_review_design, top_n = 10)
```

## Arguments

- peer_review_design:

  A generated data frame carrying the `mfrm_peer_review_design`
  attribute, the attribute itself, or its `overview` data frame.

- top_n:

  Number of reviewer-load, submission-load, common-link, and
  reciprocal-pair rows to keep in compact summary tables.

## Value

A bundle of class `mfrm_peer_review_design_review`.

## Details

`build_peer_review_design_review()` converts peer-review simulation
metadata into a reportable design-review object. The review summarizes
self-review checks, reviewer and submission load, common submissions per
reviewer pair, and reciprocal review pairs. These rows are
assignment-design diagnostics: they do not replace MFRM estimates, fit,
separation, reliability, or substantive review-quality evidence.

Peer-review use of MFRM follows studies that model peer/self/teacher
rater severity and leniency. Common-link anchor interpretation follows
sparse rater-mediated design work; the review status is therefore
descriptive and conservative rather than a literature-derived universal
adequacy cutoff.

## References

- Farrokhi, F., Esfandiari, R., & Schaefer, E. (2012). A many-facet
  Rasch measurement of differential rater severity/leniency in three
  types of assessment. *JALT Journal*, 34(1), 79-102.
  doi:10.37546/JALTJJ34.1-3.

- Uto, M., & Ueno, M. (2020). A generalized many-facet Rasch model and
  its Bayesian estimation using Hamiltonian Monte Carlo.
  *Behaviormetrika*, 47, 469-496. doi:10.1007/s41237-020-00115-7.

- DeMars, C. E., Shapovalov, Y. A., & Hathcoat, J. D. (2023).
  *Many-Facet Rasch Designs: How Should Raters be Assigned to
  Examinees?* NCME presentation.

## See also

[`build_peer_review_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_peer_review_sim_spec.md),
[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)

## Examples

``` r
if (FALSE) { # interactive()
peer_spec <- build_peer_review_sim_spec(
  n_submission = 12,
  n_criterion = 3,
  reviewers_per_submission = 2,
  anchor_submissions = 2
)
peer_sim <- simulate_mfrm_data(sim_spec = peer_spec, seed = 123)
review <- build_peer_review_design_review(peer_sim)
summary(review)$overview
}
```
