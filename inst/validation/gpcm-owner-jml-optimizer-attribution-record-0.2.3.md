# Owner-specific GPCM JML optimizer-attribution record for mfrmr 0.2.3

Status: completed Draft.66 common-data optimizer sensitivity and Draft.67
boundary-rejection recheck; calibration attribution only, not confirmation,
threshold freeze, or release authorization

Run date: 2026-08-08 JST

## Question and fixed comparison

The corrected 120-row owner pilot retained two unexpected JML failures:
criterion-owned weak-bridge replicate 3 and rater-owned
workload-imbalance replicate 4. This record asks whether those failures arise
from the measurement design, the fixed optimizer policy, or a floating-point
line-search proposal. It does not rerun only the two failed rows and select a
preferred answer. The fixed sensitivity crosses all 40 non-negative JML
datasets (two slope owners, four designs, and five replicates) with both BFGS
and L-BFGS-B, using the same retained data, starting values, `maxit = 400`, and
model contract.

The excluded JML conditions are the prespecified negative controls:
zero-common-Person rows are structurally unidentified and internal-zero rows
stop at the category-support guard. Their failure mechanisms do not depend on
optimizer dispatch.

## Historical Draft.66 sensitivity identity

| Field | Value |
| --- | --- |
| Source owner execution | `f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037` |
| Source owner runtime | `ebd9e8eb219ece646adfd37301eba997392637749513191ca7c52d33ce77356d` |
| Source owner RDS | `2355b6f023fa5641261cf2f8bae51b3bd09eb94ad38bb7527ae17201b06e30bd` |
| Sensitivity runner | `76026472579919be5da205ad55f0fb26a9c9cc5439bbe6179ba80f964b11a40a` |
| Manifest | `05dc10c47aeffed8eefe8b584e12cab1adc7ba2e71da6233f60b4b2374b0ce2a` |
| Execution | `15aafe52e32a729bfb245895604d7ec8fc0ec7157c2db5020a607d675587882b` |
| Completion inventory | `210baba78b46741ab9d1cf84dc4a31059c86b7afbb3ee961d271ce224c0751e1` |
| Completed UTC | 2026-08-08 14:48:16 UTC |
| Local bundle | ignored workspace path `validation-results/gpcm-owner-jml-optimizer-sensitivity-draft66/` |

All 80 policy rows and 40 exact-data pairs completed. BFGS returned 38 fitted
objects and 22 optimizer-convergence passes; L-BFGS-B returned 40 fitted
objects and 31 passes. Neither policy produced a raw inference-ready result,
because the GPCM estimator-specific boundary/readiness work remains open.
These counts are numerical diagnostics, not operating-characteristic rates.

For 29 of the 38 pairs in which both optimizers returned a fit, objective
differences were at most `1e-6`. Core and workload-imbalance paired differences
were at floating-point scale. The material differences concentrated in the
weak-bridge condition:

- criterion-owned weak-bridge L-BFGS-B retained all five fits but passed
  convergence in 0/5, with maximum fitted slopes from about 1,462 to 3,168;
- rater-owned weak-bridge L-BFGS-B passed only 1/5 versus BFGS 4/5 at the same
  nominal iteration ceiling; and
- consequently, replacing the default JML optimizer wholesale would exchange
  one failure mode for another and would not resolve the weak-link geometry.

## Exact failure traces

The BFGS expansion trace identifies one non-representable log-slope proposal
in each failed row:

| Scenario | Expansion call | Previous representable expanded log-slope range | Fault range | Maximum absolute full parameter |
| --- | ---: | ---: | ---: | ---: |
| Criterion / weak bridge / replicate 3 | 1019 | [-2.701, 12.513] | [-3066.515, 2105.573] | 31795.589 |
| Rater / workload imbalance / replicate 4 | 13 | [-0.612, 0.236] | [-1122.398, 550.899] | 550.899 |

The first path had already moved toward an extreme weak-link slope solution;
the second occurred during an early BFGS line search from an otherwise regular
workload-imbalance dataset. Thus the common error message represented two
different substantive states: a genuine boundary-risk design and a numerical
trial-step accident.

## Draft.67 implementation and full-panel recheck

Draft.67 makes two narrow numerical changes without altering the likelihood,
identification, default optimizer selection, starting values, or readiness
rules:

1. parameter-cache updates are transactional, so a failed trial vector cannot
   be paired with the preceding valid expanded parameters; and
2. only the typed non-representable GPCM slope condition is converted to a
   finite dominating objective during direct-optimizer line search. Other
   errors remain fail-hard, and an invalid retained parameter still fails at
   expansion.

The fitted object records the number of rejected proposals in
`fit$opt$evaluation_cache$GPCMSlopeNumericBoundaryRejections`. Rejection is a
numerical trace, not an inference-ready signal.

The complete 40-row BFGS recheck is paired to the historical sensitivity by
scenario and retained-data SHA-256.

| Field | Value |
| --- | --- |
| Draft.67 runtime | `31c87d7a888ca760afa02476f1c226bae148403475e34b75eefaaa9679522920` |
| Recheck runner | `6e42e97ba8bf67cdda1f516051d71ef645f8ce2e3aacd7a51a7bf87c6526509f` |
| Recheck execution | `042f08cee4cd43113cd1e1f84c5d58cd16e02b5929e2a0312f61198fb5dca7de` |
| Completion inventory | `5ef27553744133ba2aa2b626bdf0986efb6369ced4b3c28a02f6ae1d019bcd17` |
| Completed UTC | 2026-08-08 14:58:55 UTC |
| Local bundle | ignored workspace path `validation-results/gpcm-owner-jml-boundary-rejection-recheck-draft67/` |

All 40 rows returned fitted objects. Exactly the two historical failure rows
recorded rejected proposals. The other 38 objectives reproduce the historical
BFGS values to maximum absolute difference `4.55e-12`, isolating the code
change to the intended failure path.

The workload-imbalance row now converges with a finite slope range and becomes
the only added optimizer pass, raising BFGS convergence passes from 22 to 23.
It remains inference-ineligible under the broader readiness contract. The
criterion weak-bridge row now returns a reviewable failed fit rather than
aborting: convergence code 1, maximum fitted slope about 271,874, centered
log-slope RMSE 5.619, and no inference readiness. Across all five
criterion-owned weak-bridge rows, convergence remains 0/5 and maximum slopes
remain about 30,202--271,874. The repair therefore preserves, rather than
hides, the substantive weak-link boundary signal.

## Gate consequences and next decision sequence

This work resolves the two-row *artifact-loss* mechanism but does not establish
a finite JML maximum, owner comparability, recovery adequacy, or a sample-size
rule. No checklist row becomes `ok`; no threshold is frozen; confirmation
remains unauthorized.

The next GPCM sequence is now sharper:

1. keep criterion weak-bridge JML in the boundary/weak-information lane and
   complete the joint Person--additive--slope geometry rather than increasing
   `maxit` until a desired status appears;
2. run the separately identified MML q=31 versus denser-node sensitivity on
   common data for core, weak bridge, range restriction, and zero shared
   Persons;
3. create the paired owner/estimator attribution design without interpreting
   the current distinct-seed owner rows causally;
4. expand owner-specific replication and add facet-location, steps, Person
   estimands, interval coverage, and failed-row consequences; and
5. keep fit, DFF, dimensionality, response style, and local dependence as
   separate ADEMP operating-characteristic lanes.
