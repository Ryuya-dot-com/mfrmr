# JML LP attribution and independent-solver pilot record for mfrmr 0.2.3

## Decision boundary

This Draft.56 record attributes the remaining additive-recession LP cost and
checks the current `lpSolve` formulation against an independent GLPK route. It
does not change the package solver, public API, fitted-object schema, boundary
classification, readiness, dependency list, runtime criterion, candidate
state, or confirmation authorization.

Independent results are computed only after the production result has been
obtained. They are never returned to `fit_mfrm()` or used in a statistical or
readiness decision. `Rglpk` and `slam` are installed in a package-external
validation library and are not added to `DESCRIPTION`.

## Questions and instrumentation

The pilot separates three costs that Draft.55's component profile combined:

1. construction of the reusable LP base from the observed-contrast matrix;
2. R-side objective, extra-row, and dispatch work in
   `mfrmr_jml_recession_run_lp()`; and
3. execution inside `lpSolve::lp()`.

Temporary namespace wrappers time the production functions and the underlying
`lpSolve::lp()` call separately. Every base receives a repository-only content
identity derived from the sparse contrast and constraint contract. The wrappers
are restored after each fit. A second implementation translates the exact
sparse triplet, directions, right-hand side, default nonnegative variable
bounds, box constraints, objective, strictness row, and timeout to
`Rglpk::Rglpk_solve_LP()`. It then independently repeats the same post-solve
margin certificate.

Completion requires:

- every fixed route to retain the Draft.55 semantic, readiness, boundary, and
  target-status record;
- no LP event on the MML routes;
- optimal production solver status on every observed call;
- exact evaluated/certified/reason parity and tolerance-bounded capacity parity
  for every independent comparison;
- all adversarial controls to pass; and
- baseline/instrumented semantic and readiness identity in the additional RSM
  and GPCM controls.

## Fixed-route attribution

The Draft.55 fixed component portfolio contains 19 fits: 12 JML and seven MML.
All 19 fits succeed, all 19 canonical comparisons match the Draft.55 baseline,
and there are zero false-ready rows. The MML routes generate zero LP events.

After adding the four cross-model controls and content-hashing every loaded
solver/runtime capability, the authoritative v3 profile
contains the following production work:

| Metric | Result |
| --- | ---: |
| LP bases assembled | 40 |
| capacity target comparisons | 40 |
| strictness second-stage calls | 8 |
| total production LP calls | 48 |
| LP-base assembly time | 0.06 s |
| `mfrmr_jml_recession_run_lp()` time | 8.64 s |
| time inside `lpSolve::lp()` | 8.58 s |
| R-side assembly/dispatch residual | 0.06 s |
| solver share of run-LP time | 99.31% |

The structural scope contributes 16 capacity calls and no strictness calls:
2.03 of 2.05 seconds is attributed to `lpSolve::lp()`. The joint scope
contributes 24 capacity and eight strictness calls: 6.55 of 6.59 seconds is
inside `lpSolve::lp()`.

Observed bases span 9--417 additive parameters and 1,359--29,049 constraints.
Each negative cone uses one base and one capacity solve. The eight positive
cones add only one strictness solve against the same base. Consequently,
reusable-model or warm-start work could affect eight of 48 observed calls in
this portfolio; base construction and ordinary R dispatch together consume too
little time to justify a production intervention on this one run.

## Independent solver parity

`lpSolve` 5.6.23 is compared with GLPK through `Rglpk` 0.6-5.1 and `slam`
0.1-56. All 40 target comparisons agree on evaluated state, certified state,
and reason. Thirty-two are `no_target_recession_direction`; eight are
`certified_additive_recession_direction`. The maximum absolute capacity
difference is `1.421085e-14`.

Four baseline/instrumented model controls add coverage outside the fixed PCM
portfolio:

| Control | Structure | Target comparisons | Result |
| --- | --- | ---: | --- |
| `LP-RSM-TWO-RATER-MISSING` | two Raters, missing scores, zero/double weights, category imbalance | 3 | semantic/readiness and solver parity |
| `LP-RSM-INTERACTION` | Rater-by-Criterion interaction | 3 | semantic/readiness and solver parity |
| `LP-GPCM-TWO-RATER-IMBALANCED` | bounded GPCM, two Raters, strong category imbalance with a protected support spine | 3 | semantic/readiness and solver parity |
| `LP-GPCM-SPARSE-PANEL` | bounded GPCM, eight-Rater sparse panel | 2 | semantic/readiness and solver parity |

All four controls pass. The first three contain a positive joint recession
result; the sparse-panel GPCM control is negative. For GPCM this verifies the
retained conditional-additive recession LP only. It is not an independent
global certificate for nonlinear log-slope paths, curved paths, or the
non-concave GPCM likelihood.

An exploratory imbalance generator initially removed internal-category support
within two GPCM step scopes. Both uninstrumented and instrumented fits stopped
before optimization with the existing unsupported-step-contrast error. The
authoritative generator protects one observation per category and Criterion
from imbalance, missingness, and zero weights. This preserves a genuinely
imbalanced control without bypassing the category-support contract.

## Adversarial controls

Thirteen controls pass:

- positive, empty-cone, guarded `5e-7` near-boundary, ordinary-tolerance
  near-boundary, and target-changing flat-direction problems under both sparse
  triplet and dense-reference formulations; and
- forced independent capacity error, nonoptimal capacity status, and
  nonoptimal strictness status.

The injected failures remain unevaluated and uncertified with stage-specific
failure reasons. They cannot replace or mutate the already obtained production
result.

## Timing interpretation

The independent GLPK target evaluations total 1.94 seconds, versus 8.64 seconds
for the production run-LP calls. This is not a valid speed comparison: each
problem is run once, `lpSolve` always runs first, process and cache state are not
balanced, and GLPK conversion time is included under a different wrapper.
Neither a speedup claim nor solver selection follows from these values.

The immediately preceding v2 run records 8.80 of 8.82 run-LP seconds inside the
solver (99.77%), whereas v3 records 8.58 of 8.64 seconds (99.31%). All 40
classification/capacity records are identical across v2 and v3. Thus the
supported conclusion is narrower: within the observed portfolio, more than 99%
of production run-LP time is inside the solver rather than in R-side assembly,
and an independent solver reproduces the current classifications and capacities
over the recorded bounded portfolio. Sub-percentage timing differences are not
stable enough to report as a rule.

## Evidence identity

The authoritative promoted bundle is
`mfrmr/jml-lp-attribution-20260806-v3`. The earlier v1 bundle is retained as a
PCM-only intermediate. v2 adds cross-model controls but is superseded because
its execution identity contains solver versions rather than the runtime-content
hashes added in v3.

| Artifact | SHA-256 or identity |
| --- | --- |
| Runner source | `801a748e69f505a41c332980e5488804cbdfcbecfc6b7c22c7a920b1f964390f` |
| Installed package content | `ab03e1293272a7e77fe3167e28ff42b639912315ff574a76c304d39b82766103` |
| Capability manifest identity | `1fbc393c181fd7e000c79824bd0abd912db4aab11572d1872d2b10295093f2f5` |
| Capability CSV | `c91b2ab872ef5b43d91ff90210bd678b84d09215d9d4acd57dfa52fc4b4f137f` |
| Execution identity | `4919a47b445e52962c8c73cd5ae7c44f4e9876ad8053fb5f54e69ec82e75f1ec` |
| Completion marker file | `8d0ae232b122a4ed520c32a2801d73e1666854576f6cb4b567bb354a574e25cd` |
| Artifact inventory | `81958d7da8b0ea6945aee43b02c570a3414522036b1d59281a22a533b3518335` |
| Overall attribution CSV | `63960cc51d6db819694792e1481ca45df85cf243837fa974d532f6eee70ea475` |
| Independent parity CSV | `767b6aa67971a6dc79925fc6119f28a4f07498b62f8ea929b36260b7a712daee` |
| Model-control summary CSV | `e15dee61abc51416dd1a14894631f8f8f3fb0b9e4b769e9ef19f5bf3d9074836` |
| Adversarial controls CSV | `3e3c54d583806c54e6756efd17be866b871c8c41260a2fd9845f375f19428ebc` |
| Draft.55 baseline comparison CSV | `8bc19e93b593ce782c7e3a530c5502101acc856eb6caa2df539a82d2bfa7111f` |

## Next controlled decision

Draft.57 should qualify solver candidates rather than immediately alter
dispatch. It should freeze a set of positive, negative, near-boundary, scaled,
permuted, RSM, PCM, and bounded-GPCM conditional-additive LP problems; run
`lpSolve` and GLPK in alternating order with multiple repetitions and isolated
process memory measurement; map optimal, infeasible, unbounded, timeout, and
numeric-failure statuses; and add generated-property parity around the frozen
tolerance ladder. Nonlinear GPCM slope recession remains a separate proof
obligation.

Only after those controls may an optional solver abstraction, a fallback, or a
dependency change be proposed. Public `ROADMAP.md` and `NEWS.md` remain
unchanged, and no release-gate row or numeric rule is promoted by Draft.56.
