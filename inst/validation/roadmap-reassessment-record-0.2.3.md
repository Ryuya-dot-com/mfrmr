# Roadmap reassessment record for mfrmr 0.2.3

Status: repository-only draft.46 governance record, 2026-08-05. This record
changes sequencing and release-scope interpretation. It does not freeze a
statistical criterion, authorize confirmation, or convert pilot evidence into
release evidence.

## Trigger

Draft.45 closed the first complete small-design RSM/PCM/GPCM MML metamorphic
grid. That changed the planning question from "which invariance control is
missing?" to "which remaining claims truly determine 0.2.3 release, and which
belong to conditional promotion or later research?"

The existing checklist has 87 rows:

| State | Count |
| --- | ---: |
| `ok` | 1 |
| `review` | 39 |
| `not_run` | 47 |
| `pilot_required` criterion | 49 |
| `frozen_structural` criterion | 26 |
| `candidate_required` criterion | 8 |
| `roadmap_guard` | 4 |

Treating every row as one undifferentiated serial release blocker would turn
0.2.3 into an open-ended research programme. In particular, native
multidimensional work, HRM/CML/CCML research comparisons, posterior
prediction, heavy backends, FACETS diagnostic promotion, and broad GPCM
ecosystem extension are not all necessary to release a defensibly bounded
validation update.

## External state rechecked

Official sources were rechecked on 2026-08-05:

- CRAN distributes mfrmr 0.2.2, published 2026-07-27:
  <https://cran.r-project.org/package=mfrmr>;
- CRAN distributes TAM 4.3-25:
  <https://cran.r-project.org/package=TAM>;
- CRAN distributes immer 1.5-13:
  <https://cran.r-project.org/package=immer>;
- the FACETS update history identifies 4.5.1 as the current July 2026 release
  and 4.5.0 as the April 2026 release:
  <https://www.winsteps.com/facgood.htm>.

The local licensed FACETS 4.5.0 executable remains the required primary
execution stratum. The 4.5.1 changes remain a version-sensitivity boundary:
they concern the R G-theory route, display/report corrections, missing-label
reporting, and Table 7 subgroup t-test precision/variance. In particular,
4.5.0 Table 7 subgroup Welch-test output cannot be treated as a current 4.5.1
numeric reference. These changes do not require stopping the core 4.5.0
RSM/PCM measure comparison.

## Decision: claim-based exit instead of checklist completion by volume

The 0.2.3 release decision is reorganized into three portfolios.

### A. Mandatory release spine

The following must be complete for one frozen candidate:

1. candidate, data, tool, dependency, seed, and execution identity;
2. deterministic numerical stationarity, exact-reduction, category/step,
   estimability, extreme/boundary, and readiness-propagation guards for every
   result that remains in the supported core;
3. an ADEMP-style internal recovery and failure-mode design with declared
   denominators, failed-run accounting, Monte Carlo precision, two-rater,
   sparse/weak/disconnected, missingness, category-imbalance, and extreme-score
   strata;
4. target-envelope runtime/memory evidence sufficient to state a supported
   range, without claiming FACETS-scale capacity parity;
5. metric-specific external eligibility plus a minimal matched overlap:
   FACETS 4.5.0 for eligible RSM/PCM JML claims and ConQuest or TAM for eligible
   RSM/PCM MML claims; bounded-GPCM external rows enter only when their kernel,
   slope, constraint, and estimator coordinates match;
6. a machine-readable support envelope and consistent public help, examples,
   NEWS, capability tables, and roadmap wording; and
7. exact-candidate branch, package, cross-platform, CRAN-workload, and
   reproducible release-decision checks.

### B. Claim-conditional promotion

These surfaces do not automatically block the entire release. They block the
associated claim. If their required evidence is not frozen, the candidate must
disable promotion or retain an unavoidable caveat:

- primary bounded-GPCM slope estimates and ordinary slope uncertainty;
- JML uncertainty and any bias-correction or extreme-score-adjustment claim;
- automatic information-criterion ranking under unmatched integration,
  non-unit weights, or an unsupported likelihood/sample-size basis;
- inferential bias/DIF, interaction, DFF, residual-PCA, Q3, dimensionality, or
  subgroup diagnostic decisions; and
- external numeric aggregation for an unmatched parameter class or method
  mode.

A caveat is acceptable only if every affected public surface derives it from
the same readiness/support state. Silent exposure of an unvalidated primary
number is not an acceptable fallback.

### C. Deferred research and later-version work

The following do not block a bounded 0.2.3 release:

- native multidimensional estimation or dimension-specific scores;
- native CML/CCML, HRM, posterior-predictive, MCMC, or heavy-compute backends;
- unrestricted GPCM or broad free-slope ecosystem parity;
- automatic diagnostic decision rules and FACETS DFF promotion;
- FACETS-scale capacity parity;
- fixed calibration and operational scoring, retained for 0.2.4; and
- multiple observed scales and mixed response routing, retained for 0.2.5.

External CML/CCML, HRM, and multidimensional results may remain adversarial
research comparators, but the release cannot wait for them unless a public
0.2.3 claim is explicitly expanded to depend on them.

## Dependency correction

The former wording made the programme look fully serial: WP5 waited for all of
WP4, WP6 waited for WP5, and WP7 pilot work waited for WP0--WP6. That is too
coarse.

The corrected dependency policy is:

- metric-specific WP5 accepted/rejected fixtures may proceed for a stable
  RSM/PCM slice while unrelated GPCM or diagnostic propagation remains open;
- WP6 target-size construction/runtime measurement may proceed in parallel
  with statistical threshold calibration, provided it does not interpret
  unfinished readiness states as valid inference;
- WP7 may prespecify replication counts, MCSE targets, seeds, and execution
  manifests in parallel, and may run calibration pilots only for explicitly
  stable slices;
- any later code or contract change invalidates only the affected evidence
  rows through declared dependency hashes; and
- confirmation remains globally prohibited until the mandatory release spine,
  claim-disposition profile, criteria, and candidate identity are frozen.

This allows productive parallel work without allowing incomplete evidence to
leak into a release decision.

## Revised near-term sequence

1. Create a machine-readable claim-disposition profile mapping every gate item
   to `release_spine`, `claim_conditional`, or `deferred`, with an explicit
   fallback for every conditional claim.
2. Close the deterministic RSM/PCM category/step, estimability, boundary, and
   cross-surface readiness slices; retain bounded-GPCM parameter rows as
   non-primary wherever the global status is still not evaluated.
3. Implement metric-specific accepted/rejected external fixtures and run the
   minimal FACETS 4.5.0 JML plus ConQuest/TAM MML overlap on new pilot seeds.
4. Run target-size sparse runtime/memory and serialization/replay properties,
   stratified by model and estimator.
5. Freeze the ADEMP core design, replication count, MCSE goals, failure
   denominators, and diagnostic promotion/defer decisions before the larger
   new-seed pilot.
6. Freeze one candidate; run confirmation only for retained supported and
   explicitly conditional claims; then perform the full release-engineering
   lane.

The immediate next artifact is the claim-disposition profile, not another
unbounded stress family. It will reduce ambiguity without deleting any
existing checklist row or retroactively promoting existing pilot results.

## Public/private boundary

The public roadmap should state only the durable outcome: 0.2.3 exits by
validated claim and support boundary, not by forcing every exploratory surface
to become supported. Internal WP names, gate IDs, hashes, executable paths,
seed partitions, tolerances, authorization states, and candidate operations
remain repository-only. The public roadmap and the source-package payload must
not expose this record.
