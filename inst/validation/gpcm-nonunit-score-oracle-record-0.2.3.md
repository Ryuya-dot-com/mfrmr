# mfrmr 0.2.3 non-unit GPCM score-oracle record

## Decision boundary

This repository-only record strengthens checklist rows 5--6 for the current
aligned, single-owner, direct-MML GPCM. It independently expands the free log
slopes, constructs the non-unit GPCM softmax kernel, performs fixed-quadrature
Person-wise marginalization, and numerically differentiates that independent
objective.

It is calibration evidence, not confirmation evidence. It does not freeze the
general absolute/scaled `NUM-SCORE-TOL`, prove a likelihood boundary, authorize
model selection, or promote the broad GPCM claim. The independent oracle
deliberately reuses the package's declared additive-facet, step, population,
and quadrature contracts. Its independent scope is the non-unit slope
expansion, response kernel, marginal aggregation, and free-coordinate numeric
score.

## Identity

| Field | Value |
| --- | --- |
| Contract | `mfrmr_gpcm_nonunit_score_oracle_v1` |
| Runner | `gpcm-nonunit-score-oracle-0.2.3.R` |
| Run date | 2026-08-11 |
| Repository baseline | `7ee1fd5cb9cb` plus the recorded working-tree changes |
| Branch | `development/0.2.3` |
| Installed mfrmr during development | `0.2.2` |
| R / platform | R 4.6.1 / `aarch64-apple-darwin23` |
| Fixture | `polytomous_fixed`; 60 Persons x 4 Items; 4 categories; 240 rows |
| Fixture SHA-256 | `383979d685be5719d2844476eeb1126dd586d070c7a1926199ac31f89867ae1e` |
| Evidence status | `review` |
| General score-tolerance status | `pilot_required` |
| Boundary claim | No |
| Selection / confirmation authorized | No / No |

Because this is not an exact-candidate manifest, all results must be rerun
after the source and candidate tarball are frozen.

## Mathematical contract

For four slope-owner levels, the optimizer retains three finite coordinates
`u`. The independent oracle maps

`z = (u[1], u[2], u[3], -sum(u))`,

and `a = exp(z)`. Thus `sum(z) = 0`, every `a` is positive, and the geometric
mean of `a` is one. For observation `i` and category `k`, it independently
computes

`log K[i,k] = a[s(i)] * (k * eta[i] - cumulative_step[t(i),k])`,

normalizes with a row-wise log-sum-exp, sums conditional log probabilities by
Person, and integrates with the fixed 31-point quadrature weights. A
three-point central difference of this independent marginal objective is
compared with the package's analytic identified-free-coordinate score.

The original draft.12 step ladder was `1e-4`, `3e-5`, and `1e-5`. At slopes
near 0.05 and 20, the two larger steps showed the expected central-difference
truncation error in nuisance coordinates. The smallest already-declared step,
`1e-5`, is therefore the calibration evaluation step here. This choice is
recorded after pilot inspection and cannot be represented as a prespecified
confirmatory choice.

## Fixed-point results

Structural oracle limits are `1e-12` for log probability and probability,
`1e-10` for the marginal objective, `1e-12` for slope transformations and the
geometric-mean residual, and `1e-6` for the repository-only numeric score
comparison. These limits apply only to this structural oracle; they are not
the general `NUM-SCORE-TOL`.

| Point | Min slope | Max slope | Max score difference | Max slope-score difference | Log-probability / probability / objective difference |
| --- | ---: | ---: | ---: | ---: | ---: |
| retained solution | 0.841583 | 1.277933 | 1.27766e-8 | 1.11315e-8 | 0 / 0 / 0 |
| high-dispersion probe | 0.452267 | 2.211083 | 1.24916e-8 | 1.24824e-8 | 0 / 0 / 0 |
| finite slope stress, forward | 0.049787 | 20.085537 | 2.19226e-7 | 6.54136e-9 | 0 / 0 / 0 |
| finite slope stress, reverse | 0.049787 | 20.085537 | 5.94747e-7 | 9.18038e-9 | 0 / 0 / 0 |

Every expanded-log-slope and expanded-slope difference was exactly zero at
the recorded precision. The largest geometric-mean residual was
`3.47e-17`. All four rows produced finite evaluations and the bounded decision
was `review_oracle_agreement`.

For transparency, at the earlier draft.12 primary step `3e-5`, the two stress
points had whole-vector score differences `1.97e-6` and `5.24e-6`, while their
slope-block differences remained `4.12e-8` and `5.21e-8`. At `1e-5`, the
whole-vector discrepancies decreased by the expected central-difference
pattern. This is why the result is calibration evidence rather than a frozen
general rule.

## Fail-closed checks

The focused repository test passed 47 expectations. It verifies the contract,
no source-time fitting, the exact independent slope map, geometric-mean-one
identification, four required points, finite stress slopes, every bounded
numeric comparison, and absence of selection/confirmation authority. It
rejects missing or duplicate points, a changed contract, a changed evaluation
step, incomplete evaluation, score or transformation drift, and a mutated
authorization flag.

| File | SHA-256 |
| --- | --- |
| `gpcm-nonunit-score-oracle-0.2.3.R` | `878e8bff3cca5fd8f2fbc04ae4a516e21f741a3b14223cd6c455a235aea008f8` |
| `../../tests/testthat/test-gpcm-nonunit-score-oracle.R` | `95e3baedbcd69b4b73638fcb07f2a97bac5dc7a7ced542f97330220631e0ac62` |
| `numerical-stationarity-pilot-0.2.3.R` | `68df33bc1c114309f875a0cf8056ac720254740633fe55ca909535d032663344` |

## Line drawn for 0.2.3

This record removes one specific ambiguity: agreement at slope one is no
longer the only independent likelihood evidence, and a shared bug in the
package slope expansion or non-unit GPCM response kernel cannot by itself
manufacture the recorded agreement.

Rows 5--6 remain `review` and `pilot_required`. Before promotion, the project
still needs a prespecified grid spanning criterion-owned and rater-owned
aligned fits, five-category responses, sparse and workload-unbalanced
assignments, weak links and category imbalance, plus parameter-class-specific
absolute/scaled score and Jacobian margin rules. Disjoint exact-candidate
confirmation and eligible external overlap follow that freeze. Expanding now
to a large simulation would not answer the remaining numerical-contract
question as directly as these deterministic cells.
