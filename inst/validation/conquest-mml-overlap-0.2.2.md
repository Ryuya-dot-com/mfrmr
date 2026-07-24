# ConQuest MML overlap check for mfrmr 0.2.2

This note records one external-software check within the deliberately narrow
scope documented by `build_conquest_overlap_bundle()`. It is evidence for that
case only, not a claim that mfrmr reproduces arbitrary ConQuest analyses or
that the two programs are numerically identical.

## Software and design

- Run date: 2026-07-24
- mfrmr: 0.2.2
- ConQuest: 5.47.5, Demonstration Version
- Model: unidimensional binary item-only RSM with one numeric person covariate
- Estimator: quadrature MML in both programs
- Design: 60 persons, 6 items, 360 complete person-by-item responses
- Quadrature nodes: 31 in both programs
- mfrmr controls: `maxit = 400`, `reltol = 1e-13`
- mfrmr terminal gradient sup-norm: 0.000000150318
- mfrmr inference-ready status: `TRUE`
- ConQuest stopping result: deviance change below its convergence criterion

The `1e-13` portable tolerance setting pins the package-side calculation used
for this fixed external comparison. The public-default route was separately
confirmed to clear the current numerical-readiness gate. The analytical
gradient was independently compared with a central finite-difference gradient;
their largest absolute discrepancy was approximately 0.00000000646.

An initial seven-node external run was not accepted as release evidence because
ConQuest recommended rerunning with more nodes after retaining an earlier,
higher-likelihood iteration. The matched 31-node run did not issue that
warning.

## Normalized comparison

The four native CSV exports requested by the generated command were normalized
with `normalize_conquest_overlap_exports()` and reviewed with
`review_conquest_overlap()`.

| Target | Result |
|---|---:|
| Covariate-slope absolute difference | 0.00125900 |
| Population-variance absolute difference | 0.00589376 |
| Centered item correlation | 0.9999999982 |
| Centered item mean absolute difference | 0.00062312 |
| Centered item maximum absolute difference | 0.00127374 |
| Case-EAP correlation | 0.9999945481 |
| Case-EAP mean absolute difference | 0.00724600 |
| Case-EAP maximum absolute difference | 0.01348363 |
| Missing, duplicate, or non-numeric attention rows | 0 |

The package-side bundle and comparison were regenerated after the 0.2.2
optimizer-workspace changes, using the same responses and stored native
ConQuest exports. The review again produced zero missing, duplicate, or
non-numeric attention rows.

The population intercept is recorded as constraint-dependent and is not counted
as a directly comparable parameter. Item locations are compared after
centering, and ConQuest's final sum-constrained item location is reconstructed
by the documented normalizer.

## Reproduction route

1. Build the package's `synthetic_latent_regression` overlap bundle with
   `quad_points = 31`, `maxit = 400`, and `reltol = 1e-13`.
2. Run the generated `.cqc` file in ConQuest 5.47.5.
3. Normalize the generated parameter, regression, covariance, and case-EAP CSV
   files with `normalize_conquest_overlap_exports()` while recording the
   external version, edition, and date.
4. Pass the normalized object to `review_conquest_overlap()` and inspect the
   overall, population, item, case, and attention tables.

The response and case-level files contain identifiers and must remain in an
approved restricted location. They are intentionally not included in the
package source.
