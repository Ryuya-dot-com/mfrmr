# Independent RSM MML information: first numerical pilot

Date: 2026-09-09. Status: one bounded numerical check passed; C05 remains open.

Follow-up: the [RSM/PCM condition extension](mml-independent-information-conditions-record-0.2.4.md)
adds separate population, constraint, interaction and weight fixtures. The
original dataset and results below are unchanged.

## Question and design

Does the current RSM MML observed-information calculation agree with a
likelihood implementation that does not use the package's probability,
quadrature, derivative, constraint-expansion or Hessian routines?

The [standalone runner](mml-independent-rsm-information-0.2.4.R) generates one
balanced dataset: 80 standard-normal Persons, two Raters, two Criteria, four
ratings per Person and categories 0--2. Seed: 20260909. Rater effects are
`(0.3, -0.3)`, Criterion effects `(0.4, -0.4)`, and thresholds `(-0.6, 0.6)`.
The fitted population is fixed standard normal, with unit weights and no
anchors or interactions. This small three-parameter case makes every
coordinate explicit; it does not test sparse designs or long response vectors.

The independent adjacent-category logits are `(0, eta - step, 2 * eta)`,
where `eta = theta - rater - criterion` and each two-level effect is
sum-centered. For each Person, base R `integrate()` integrates the product of
the observed-category probabilities against the normal density over the whole
real line. No package integration grid is reused. Central differences at
steps 0.001 and 0.0005 then give two independent Hessian approximations.

The package fit uses 61 quadrature points, `maxit = 200`, and `reltol = 1e-10`.
The runner asserts the three free-coordinate positions and inference
readiness before comparison. Its numerical checks were specified before the
first execution: objective discrepancy below 1e-6; normalized Hessian
step-change and package discrepancy below 1e-5; relative free-coordinate SE
discrepancy below 1e-5. These are reproducibility checks for this fixture,
not empirically calibrated release criteria.

## Results and answer

| Quantity | Observed magnitude |
| --- | ---: |
| Absolute negative-log-likelihood difference | 4.832e-12 |
| Hessian step-change, normalized by `max(1, max(abs(reference_H)))` | 3.819e-8 |
| Package Hessian difference, using the same normalization | 7.739e-8 |
| Maximum relative SE difference across three free coordinates | 4.043e-8 |

All specified numerical checks passed. The package covariance status was
`ok`; the independent covariance is the inverse of the finer-step reference
Hessian. This supplies independent numerical support for the three-coordinate
RSM calculation in this one balanced fixture. It does not establish
frequentist SE calibration or interval coverage.

From the package root:

```sh
Rscript inst/validation/mml-independent-rsm-information-0.2.4.R /tmp/rsm-information.rds
```

The saved RDS contains the metrics, fitted object, both reference Hessians,
package Hessian/covariance, reference covariance and session information.
Execution used R 4.6.1 and the current `mfrmr 0.2.4.9000` working source after
the facet-equivalence repair. The saved runner was rerun with the same checks;
no threshold or dataset was changed after viewing the first results.

## Remaining work

Next cover PCM and the retained population, anchor, interaction and weight
conditions, with explicit coordinate maps and entry/contrast-level checks.
Then separate short- and long-response integration sensitivity and the
prespecified recovery/SE-versus-SD/coverage/availability evaluation. This pilot
does not validate full GPCM, JML, transported populations, or a universal
quadrature order. It advances the numerical part of C05 without closing the
release's uncertainty requirements.
