# Build a peer-review simulation specification

Build a peer-review simulation specification

## Usage

``` r
build_peer_review_sim_spec(
  n_submission = 50,
  n_criterion = 4,
  reviewers_per_submission = 3,
  anchor_fraction = 0.1,
  anchor_submissions = NULL,
  anchor_reviewers_per_submission = NULL,
  avoid_self_review = TRUE,
  assignment_mode = c("balanced", "random"),
  seed = NULL,
  score_levels = 4,
  theta_sd = 1,
  reviewer_sd = 0.45,
  criterion_sd = 0.25,
  noise_sd = 0,
  step_span = 1.4,
  model = c("RSM", "PCM", "GPCM"),
  step_facet = "Criterion",
  thresholds = NULL,
  group_levels = NULL,
  dif_effects = NULL,
  interaction_effects = NULL
)
```

## Arguments

- n_submission:

  Number of submissions/authors to generate.

- n_criterion:

  Number of rubric criteria.

- reviewers_per_submission:

  Number of peer reviewers assigned to each ordinary submission.

- anchor_fraction:

  Fraction of submissions treated as common-link anchor submissions when
  `anchor_submissions` is not supplied.

- anchor_submissions:

  Optional number of common-link anchor submissions. Anchor submissions
  receive `anchor_reviewers_per_submission` reviewers.

- anchor_reviewers_per_submission:

  Number of reviewers assigned to each anchor submission. Defaults to
  all eligible peers when anchors are used and self-review is
  disallowed; recorded as 0 when no anchor submissions are requested.

- avoid_self_review:

  Logical; if `TRUE`, a reviewer is never assigned to review their own
  submission.

- assignment_mode:

  Assignment algorithm. `"balanced"` assigns reviewers with the lowest
  current load using deterministic rotating tie-breaks. `"random"`
  samples eligible reviewers without replacement.

- seed:

  Optional seed used only for random peer-review assignment when
  `assignment_mode = "random"`.

- score_levels, theta_sd, reviewer_sd, criterion_sd, noise_sd,
  step_span:

  Generator settings passed to
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md).
  `reviewer_sd` maps to the standard MFRM rater-severity spread.

- model, step_facet, thresholds:

  Measurement-model settings passed to
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md).
  The first public facet is `Reviewer`; the second is `Criterion`.

- group_levels, dif_effects, interaction_effects:

  Optional signal settings passed to
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md).

## Value

An object of class `mfrm_sim_spec` with `peer_review` metadata and a
fixed peer-review design skeleton.

## Details

`build_peer_review_sim_spec()` creates a fixed
person-by-reviewer-by-rubric skeleton for peer-assessment or peer-review
studies. Submissions and peer reviewers share the same ID universe
(`P001`, `P002`, ...), so self-review can be structurally excluded and
checked in the generated data. The specification uses the existing
`assignment = "skeleton"` generator and records peer-review metadata; it
does not introduce a new measurement model. MFRM still estimates
person/submission measures, reviewer severity, and criterion difficulty,
while design-network review can inspect whether the peer-review graph is
sufficiently linked.

The common-link anchor controls follow the same logic used in sparse
rater-mediated designs: when most submissions receive only a few peer
reviews, assigning all or many reviewers to a small anchor set can
strengthen links among reviewers. The helper labels these rows as design
diagnostics, not universal adequacy thresholds for fit, separation, or
recovery.

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

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md),
[`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)

## Examples

``` r
if (FALSE) { # interactive()
peer_spec <- build_peer_review_sim_spec(
  n_submission = 12,
  n_criterion = 3,
  reviewers_per_submission = 2,
  anchor_submissions = 2
)
peer_spec$peer_review$overview
}
```
