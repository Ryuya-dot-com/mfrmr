# GPCM conditional and marginal kernel: paired-owner stress audit

Date: 2026-09-15. C03/C04 follow-up to the
[integrated ledger](claim-reconciliation-0.2.4.md). This is a deterministic
implementation check of raw optimizer coordinates, not a parameter-recovery,
standard-error, confidence-interval or release-acceptance study.

## Question and bounded answer

Does the current GPCM evaluate the stated complete adjacent predictor,
including nonzero effects of the other facet, for both Criterion and Rater
slope owners and for both JML and MML?

**Yes in the 48 finite-point cases below.** Independent probabilities,
negative log likelihoods (NLLs), numerical derivatives and the production
optimizer's cached evaluations agree within the documented numerical checks.
No production calculation was changed. This extends the older Criterion/MML
oracle evidence to both owners and JML, five categories, irregular observation
patterns and unequal positive response weights. It does not establish that
an optimizer finds a finite global maximum or that estimates are stable.

**Fixed Gauss–Hermite integration remains sensitive to order in these cases.**
The two implementations agree at each order, including their substantial
between-order changes. Positive tail weights alone do not imply an adequate
integration rule for a particular response pattern and parameter point.

## Design and independence

The [runnable audit](gpcm-paired-owner-kernel-0.2.4.R) crosses:

- JML and direct, fixed-quadrature MML with its current free normal population;
- Criterion or Rater as both step and slope owner;
- three deterministic datasets with 12 Persons, four Raters, four Criteria
  and scores 0–4: complete (192 rows), an eight-edge cycle (96), and two
  four-edge blocks joined by one observed bridge (97);
- two finite coordinate vectors: moderate relative slopes and slopes
  `exp(c(-3, -1, 1, 3))`, approximately 0.0498–20.085;
- Q31, Q61 and Q121 for MML; JML has no integration dimension.

The bridge dataset has unequal weights 0.25, 1, 3 and 8 (weighted total
294.25), a predominance of score zero, and deliberately shuffled rows. Its
single bridge concerns the Rater-by-Criterion graph; Persons occur in both
blocks. This is not a demonstration that weak links carry adequate
information. Each dataset retains all five score categories. The other
facet effects and owner locations are nonzero in every case. MML evaluates
population mean 0.35 and SD 1.3; JML evaluates 12 specified finite abilities.
Facet locations and each row of steps sum to zero; relative slopes have
geometric mean one.

One iteration of `fit_mfrm()` obtains each public preparation/configuration
contract. All 12 setup calls report an iteration-limit warning, retained in
`setup-conditions.csv`. Their fitted estimates are not used. The audit
evaluates independently specified coordinates: **these are not 48 successful
fits or independent simulated replications.** JML targets its raw weighted
joint likelihood, not bias-corrected or extreme-adjusted output estimates.

The reference reuses the repository's independent
[p3a adjacent-logit kernel](gpcm-slope-action-projection-p3a-0.2.3.R).
It independently expands the fixed coordinate layout and indexes the original
input rows, constructs stable log probabilities, applies response weights
inside each Person's likelihood and marginalizes with statmod 1.5.2 normal
quadrature. It does not call production parameter expansion, indexing,
probability, population-transformation or marginalization helpers. The common
reference kernel treats the selected owner as its Criterion axis, so the
Rater-owned comparison explicitly swaps the two axes. Existing central
finite-difference support is reused to differentiate this reference NLL.

The intentionally different `loading_only` slope action is a negative
control. In all 48 cases its maximum probability discrepancy exceeds 0.1204;
the fixtures can therefore detect that specific wrong model identity.
This is not an external-software comparison or proof against every possible
implementation error.

## Results, initial failures and derivative adjudication

| Quantity | Maximum absolute difference, all 48 cases |
| --- | ---: |
| Category probability | 1.399e-14 |
| Weighted observed log probability | 4.730e-11 |
| NLL, independent versus ordinary or cached production evaluation | 4.548e-13 |
| Cached versus ordinary analytic gradient | 5.912e-12 |

The initial run correctly failed its probability check because the comparison
script paired ascending statmod nodes with descending production nodes.
Their marginal NLLs already agreed: permuting quadrature nodes does not alter
that sum. The script now aligns the node order before comparing node-specific
probabilities. No fitting code or tolerance was changed for this correction.
The initial script, logs and results remain in the evidence archive.

The initial relative central-difference step `h = 1e-5` meets the scaled
gradient tolerance `1e-6` in **47/48**, not 48/48 cases. The exception is the
weighted bridge, Criterion-owned MML, wide slopes, Q31. For its population
mean derivative, errors shrink from 2.916e-4 to 3.241e-5 to 2.898e-6 at
relative widths 3e-5, 1e-5 and 3e-6, consistent with second-order truncation.

The follow-up cancels the leading central-difference error using
`(9 * D(h) - D(3h)) / 8`, and independently retains the finest-width check.
Across all cases, the maximum scaled analytic/reference discrepancy is
**3.737e-8** for this Richardson estimate and **4.656e-7** at width 3e-6.
Both meet the unchanged `1e-6` numerical tolerance. Scaling divides each
absolute discrepancy by `max(1, abs(analytic), abs(reference))`.
All **3,672 coordinate-by-width comparisons** are saved, not just maxima.
This follow-up was chosen after the initial diagnostic failure; it is not a
preregistered acceptance rule for a recovery or inferential study. It supports
the truncation-error explanation within the tested finite points.

## Quadrature agreement versus integration stability

Both implementations retain positive weights at all three orders. At Q121,
the smallest production weight is 7.899e-97. Maximum node discrepancy is
5.685e-14 and maximum relative weight discrepancy is 9.864e-13.

| Fixed coordinate family | Largest absolute NLL change Q31→Q61 | Largest absolute NLL change Q61→Q121 |
| --- | ---: | ---: |
| Moderate slopes | 1.4640 | 0.4206 |
| Wide slopes | 45.4878 | 49.3827 |

These are unnormalized weighted NLL changes, not changes in estimated
parameters. Some changes reverse direction; Q121 is not declared an accurate
continuous-integral reference. The bridge/Rater/wide-slope case still changes
by about 49.38 from Q61 to Q121. The two implementations reproduce that change.
The [weight repair](gauss-hermite-weight-repair-0.2.4.md) addresses a different
defect and is not contradicted by this integration sensitivity.

## Checks, reproducibility and remaining work

The final audit's executable assertions pass. Four existing regression files
also pass: **289 expectations, zero failures, errors, warnings or skips**
(Gauss–Hermite weights 43; GPCM MML identification 116; JML terminal-gradient
stability 83; historical nonunit oracle 47). This turn adds only repository
validation code/evidence and ledger updates. It does not rerun or replace the
preceding source package's `R CMD check` result.
All 317 current R/src/man files compared byte-for-byte with the
[preceding checked package](estimator-output-identity-repair-0.2.4.md) are
identical; the comparison is retained in the archive.

Evidence: `validation-results/gpcm-paired-owner-kernel-20260915/`, including
the inputs, all cases/derivatives, integration ladder, captured setup
conditions, tests, initial failed probe, source snapshot and SHA-256 manifest.
The archive retains the exact R/src implementation and local statmod function
used. Reproduction from the development root with statmod available:

```r
pkgload::load_all()
source("inst/validation/gpcm-paired-owner-kernel-0.2.4.R")
run_gpcm_paired_owner_kernel("/tmp/gpcm-kernel-replay")
```

The next numerical question is whether integration and refitted parameters
stabilize under an appropriate continuous-integral reference, at representative
retained solutions. This audit does not test adaptive GPCM integration,
anchors, interactions, missing-data mechanisms, unrestricted data sizes,
recovery, global boundary absence or interval coverage. Free-slope SE/CI
remain ineligible, JML precision remains exploratory, and C03/C04 stay open.
