# Fresh confirmation of the three structural-bias review cells

Date: 2026-09-09. Status: fixed before new outcomes; execution pending.
This follows the [original confirmation](mml-structural-coverage-record-0.2.4.md)
and its [post-confirmation diagnostic](mml-structural-bias-diagnostic-record-0.2.4.md).
It is a separate study, not an extension until the old results pass.

## Question, conditions and targets

On fresh fixed seeds, do the three reviewed conditions meet the original
conditional standardized-bias, SE-scale, coverage, availability and numerical
criteria? Does the score decomposition again support a small finite-sample
curvature component? Keep those questions distinct: the unconditional
decomposition does not replace the conditional primary bias target.

Retain original cells 1, 5 and 7: RSM with 80 Persons; PCM with 80 Persons;
PCM with 320 Persons. Every Person receives three ratings, under the original
two complementary, balanced Criterion assignments. Retain three Raters,
two Criteria, categories 0--2, unit weights, fixed standard-normal Person
population and the exact original parameter values. The model and estimation
source remain unchanged. This study does not independently repeat the original
80-versus-320 scaling comparison for every target, or cover other designs.

Use the original complete list of expanded facets, thresholds and pair
contrasts: 11 coordinates in cell 1 and 13 in each PCM cell, 37 rows in total.
All are primary performance checks, preserving the original within-cell
decision rule. Sign/proportional copies do not add independent replications.
Pointwise MC intervals do not supply a simultaneous 95% assertion.

## Precision and fixed replication count

Use 10,000 independent datasets per cell, 30,000 total. The diagnostic
suggested the largest relevant standardized systematic bias was about 0.061.
Use 0.065 as a conservative planning value and 1.05 as the planning SD of
the standardized-bias influence values. These are planning assumptions based
on the old data, not a requirement that the new outcomes resemble them.

For a two-sided 95% MC interval to fall inside +/-0.10 with 90% probability
at positive bias 0.065, the normal planning approximation requires

```
R >= ((qnorm(.975) + qnorm(.90)) * 1.05 / (.10 - .065))^2
```

Rounding up gives 9,457; choose 10,000. The planned bias MC half-width is
0.02058 and the corresponding probability about 91.5%, per coordinate.
This is not a 91.5% joint chance that every retained claim passes. At 95%
coverage the rate MCSE is 0.002179, or 0.218 percentage points. Actual MC
intervals determine the decisions, even if outcomes violate planning values.

## Unchanged primary computation and criteria

Reuse `mml_coverage_one()` and `mml_coverage_coordinate()` from the frozen
original runner. Use direct MML q61, maxit 200 and reltol 1e-10; repeat q121
objective, information and terminal-displacement checks on every fitted
dataset. Preserve every attempted seed, estimate, SE, warning, readiness
state and failure. Availability uses original fit readiness, unregularized
q61 covariance and finite positive SE. Numerical discordance does not remove
an otherwise available interval from coverage.

Retain the exact original decision rules:

- Coverage's exact 95% binomial MC interval wholly within [0.93, 0.97].
- RMS-SE / empirical-SD MC interval wholly within [0.90, 1.10].
- Available-only standardized-bias MC interval wholly within [-0.10, 0.10].
- Availability's exact lower bound at least 0.99.
- No observed ready numerical counterexample, and its exact upper rate bound
  at most 0.002. Numerical bounds remain objective change <=1e-6, relative
  expanded-SE change <=0.001, scaled q121 Newton displacement <=0.001, with
  unregularized positive-definite information at both grids.

Boundary overlap remains review; a performance interval wholly outside the
margin is concern. Any observed ready numerical counterexample is concern.
Incomplete execution cannot pass. Report all-finite and available-only bias
separately and available-and-covered / assigned separately from coverage.
No bias correction is applied to estimates or intervals.

## Prespecified secondary mechanism check

Freeze the old diagnostic's enumerated response-pattern scores, expected
information and curvature coefficients by archive fingerprint. Reuse its
score replay and explicit expanded-coordinate maps. On each new dataset
compute L = inverse(I_total) U_at_truth and remainder = estimate - truth - L.
The coefficient on L is exactly one. Retain counts and pair each displacement
with its actual original-pipeline estimate. Use all attempted datasets for
this secondary unconditional target; if any finite estimate is missing, its
unconditional mechanism conclusion remains review.

The three prespecified mechanism targets are shared Step 2 in cell 1,
C1 Step 2 in cell 5, and Criterion C1 in cell 7. Report the decomposition
for every coordinate, but do not count its sign/proportional copies as
additional mechanism confirmations. For the three targets:

1. Compare mean L with its known zero expectation using variance
   `map * inverse(I_total) * t(map) / R`. An absolute standardized deviation
   above `qnorm(.9995)` triggers review of this unusual aggregate, not silent
   seed replacement. The three pointwise tails have a union bound of 0.003
   under the planning normal approximation; they do not certify a generator.
2. Require the 95% MC interval of mean remainder to be positive to support
   the predicted bias direction. A nonpositive/overlapping result remains
   concern/review respectively.
3. Compare the remainder with the fixed order-1/N prediction using
   D = (mean remainder - predicted bias) / empirical SD of all errors.
   Its 95% MC interval must lie within +/-0.01 to support this scoped
   approximation. This is one tenth of the original practical bias margin:
   the permitted approximation error is small relative to sampling SD.
   It is a new, explicit explanatory tolerance, not a relaxed primary bound
   or a requirement of exact equality to an asymptotic formula.

For D use the paired influence values
`(remainder-mean(remainder))/s - D*((error-mean(error))^2-v)/(2*v)`
where `v=var(error)` and `s=sqrt(v)`, then their mean MCSE and a normal 95%
MC interval. Validate this algebra before new outcomes. Keep the raw bias,
L, remainder and their MCSEs visible; favorable secondary results cannot
override a failed or unresolved primary criterion.

## Seeds, preflight and resources

Fresh confirmation seeds are `62000000 + 10000*cell + replicate`, replicate
1--10000. The ranges for cells 1, 5 and 7 do not overlap each other or the
original 61-million confirmation family. Preflight uses five other datasets
per cell, seeds `52000000 + 10000*cell + replicate`, replicate 1--5. The
preflight is excluded from confirmation and supplies no performance decision.

Preserve the original fitting function by passing it replicate index
`1000000 + replicate` with its corresponding preflight/confirmation stage.
That index supplies the fresh seed offset only; the new wrapper records both
the actual seed index and the new study's sequential replication number.
Assert the resulting seed explicitly. Do not edit the frozen original runner.

Preflight checks generator/replay identity, the existing public diagnostic
cross-checks, finite secondary outputs, errors and numerical concordance, and
times the combined pipeline. A legitimate unavailable fit is retained and
reviewed; it is not replaced. Fix actual execution defects before confirmation.
Preserve the tested source/protocol/old-evidence fingerprint through the run.

Use three local R processes. Split each cell into ten fixed blocks of 1,000
sequential replication IDs. Rotate worker assignment across cells by block
so expensive 320-Person fits are spread across the three processes. Each
worker writes only its own block files; checkpoint every 50 attempts using
atomic replacement. Aggregation sorts by cell and replication ID and verifies
all 30,000 seeds, block identities and the same source payload. Execution
order does not change the seeds or add replications.

Use a four-hour wall ceiling per worker and no statistical early stopping.
Any implementation counterexample may pause for investigation; retain the
failed/incomplete evidence and do not silently restart with modified source.
Do not add repetitions because an MC interval is unfavorable. Keep the old
study and new study separate rather than pooling results selected for review.
Release and remaining GPCM/TAM/JML claims stay under the controlling roadmap.
