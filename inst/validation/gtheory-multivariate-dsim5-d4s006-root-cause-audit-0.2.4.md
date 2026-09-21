# D-SIM-5 D4-S006 read-only root-cause audit (0.2.4)

Date: 2026-09-06
Scope: repository-internal source/result audit; no generation or fitting
Disposition: `response_scale_estimand_mismatch_identified_no_repair_authorized`

## Evidence boundary

This audit reads the completed D-SIM-5 artifact and the frozen generator,
truth, fit-worker, and executor sources. It creates no response, opens no RNG
stream, calls no backend, changes no checkpoint, and does not recompute the
D-SIM-5 disposition.

- D-SIM-5 artifact:
  `d46b8918e3386c36bb3ca38e54ca79a1fb1e2ceab0a4d89eb33a044f36e2aa13`
- D-SIM-5 adjudication:
  `4c3f74548d578694d8cfe436a9cfd8b5a7190487334fa794ec11eb0b06cacb3d`
- response-generator source:
  `6a2e5cfbdb837079ec07650b4494af068fa7cbbcafb3fceae985e5d7fa4e2bc0`
- truth-coefficient source:
  `476dad72321404cf16e81369c06beb3a7450c5825ba8cf728c5d85b1927d93ed`
- fit-worker source:
  `6acac1c8665685f1b9b700daade2d5c3354516b3e6677c86bd1313bf10e746a6`
- D-SIM-5 executor source:
  `44ffdfda0f72c43af036f1e99187c5286adcf273d543158cd677a5f85ad07735`

## First mismatched seam

The generator sums the latent component effects, divides that latent response
by its total latent variance scale, and, for `ordinal_aggregate`, thresholds it
at `-1.25`, `-0.35`, `0.35`, and `1.25` to produce the integer score 0--4.
The worker then fits that numeric `Score` with a Gaussian `lmer` model and
computes G and Phi from the fitted observed-score variance components.

The truth adapter follows a different scale. It allocates the pre-threshold
latent component covariance diagonals through the D-study operator and computes
G and Phi from those latent allocated variances. It does not apply the ordinal
threshold transformation or derive the induced observed-score covariance.

Consequently, D4-S006 compares a Gaussian observed-score pseudo-coefficient
with a pre-threshold latent coefficient. The comparison is not a same-scale
recovery test. This is the first unsupported seam; changing an optimizer,
random-slope syntax, convergence cutoff, or bootstrap replicate count cannot
repair it.

## Result decomposition

Every D4-S006 point and interval value is available. The fitted coefficient
transformation itself agrees exactly with the independent scalar formula
(`ReferenceMaximumError = 0`), so the failure is upstream of the final G/Phi
algebra.

For REL-G, truth is `0.93023256`, while mean estimates are `0.91988448` and
`0.91992013`. Mean interval widths are `0.01492441` and `0.01494615`.
The truth lies above the upper endpoint in 2,071 and 2,070 of 2,500 attempts;
coverage is `0.1716` and `0.1720`. The mean interval midpoints remain near the
downward-shifted point estimates. Thus the principal failure is point centering
on the observed-score scale, propagated by a comparatively narrow parametric
bootstrap interval, not interval unavailability.

ABS-PHI shows the same direction less extremely: truth is `0.90909091`, mean
estimates are `0.89934303` and `0.89936210`, and coverage is `0.8948` and
`0.8852`. Its absolute bias is about 0.48 median half-widths; REL-G bias is
about 1.39 median half-widths.

Negative cross-stratum covariance is not used in either the frozen
separate-univariate truth coefficient or its per-stratum fit coefficient.
It therefore cannot by itself explain this marginal-scale discrepancy.
Partial sharing, MCAR, and their interactions remain bundled in D4-S006 and
cannot be causally ranked from this one confirmation cell. The nearly equal S1
and S2 results are consistent with the common response transformation but are
not an axis-isolation experiment.

## Roadmap consequence

The D-SIM-5 `fail` remains unchanged. D4-S006 cannot be relabeled after seeing
its result, and the 857/858 seeds cannot validate a revised target.

The next design decision must separate two scientific objects:

1. **continuous observed-score G theory:** retain the current Gaussian mixed-
   model route only for response distributions whose variance decomposition
   and truth live on the fitted score scale; and
2. **ordinal latent or observed-score dependability:** first declare whether
   the target is an induced 0--4 observed-score coefficient or a latent ordinal
   coefficient. The former needs an independent threshold-transformed truth
   oracle; the latter needs an ordinal model rather than numeric-score `lmer`.

The preferred near-term action is scope correction, not new production code:
keep ordinal analysis in the parked GRM/external-integration lane until a real
problem packet chooses the estimand and justifies lifecycle cost. If a future
study is admitted, begin with a deterministic threshold/covariance oracle and
axis-separating controls, then issue a new exploratory contract. Only after
that work may a new disjoint confirmation seed band be considered.

## Claim boundary

- source/result root-cause audit complete: **yes**
- first semantic mismatch identified: **yes**
- D-SIM-5 disposition changed: **no**
- revised estimator or interval authorized: **no**
- new simulation authorized: **no**
- ordinal G/Phi support ready: **no**
- package-level maturity remains: **`specified`**
