# Mantel-Haenszel DIF R-package alignment notes

This note records how the first `mfrmr` observed-score Mantel-Haenszel helper
is aligned with existing R DIF package help pages. It is a scope-control
artifact and records the current cross-package numerical check.

## Current `mfrmr` surface

`analyze_dif_mh()` implements a strict two-group Mantel-Haenszel observed-score
screen for binary or explicitly dichotomized responses. It requires exactly
one response per person x item/facet level and reports MH common odds ratios,
MH D-DIF deltas, MH chi-square values, adjusted p-values, and screening labels.
`analyze_dif_classical()` is retained as a compatibility wrapper around
`analyze_dif_mh()`.

The helper is intentionally narrower than the major R DIF packages and is not
the fitted-MFRM route in `mfrmr`. It does not use `fit_mfrm()`, does not depend
on `RSM`, `PCM`, or bounded `GPCM` likelihoods, and should be used as an
observed-score screening surface, not as an operational fairness decision.

## Alignment references

- [`difR::difMH()`](https://search.r-project.org/CRAN/refmans/difR/html/difMH.html)
  is the closest public R reference for a two-group Mantel-Haenszel DIF
  screen. Its help page defines the response data as an item response matrix,
  requires a two-level group vector, supports a focal group, anchor items,
  total-score or external matching, continuity correction, exact tests,
  purification, and p-value adjustment.
- [`difR::mantelHaenszel()`](https://rdrr.io/cran/difR/man/mantelHaenszel.html)
  documents the lower-level statistic with one row per subject and one column
  per item. It supports `"score"` and `"restscore"` matching; the latter
  excludes the tested item from the matching score. This is the main reason
  `mfrmr` exposes both `"total"` and `"restscore"` and uses `"restscore"` as
  the conservative default.
- [`difR::difGMH()`](https://www.rdocumentation.org/packages/difR/versions/6.1.0/topics/difGMH)
  documents generalized Mantel-Haenszel testing for multiple groups. `mfrmr`
  does not yet implement this path.
- [`lordif::lordif()`](https://cran.r-universe.dev/lordif/doc/manual.html)
  documents an iterative hybrid of ordinal logistic regression and IRT for
  dichotomous and polytomous DIF, including IRT-score matching and
  purification-style updates. `mfrmr` does not yet implement this
  logistic/ordinal route.
- [`mirt::DIF()`](https://search.r-project.org/CRAN/refmans/mirt/html/DIF.html)
  documents Wald and likelihood-ratio DIF tests over `multipleGroup()` fitted
  IRT models, with anchor-item and group-parameter considerations. `mfrmr`
  does not yet implement a multiple-group IRT parameter-test route.

## Deliberate differences from existing R helpers

- Input shape: `mfrmr` accepts long-format data but requires a person x item
  response-table contract internally. Existing helpers such as `difR` typically
  take an item response matrix directly.
- Model scope: `analyze_dff()` / `analyze_dff_moderation()` are the
  fitted-MFRM routes and cover `RSM`, `PCM`, and caveated bounded `GPCM`
  screens. `analyze_dif_mh()` is not a fitted-MFRM route.
- Repeated ratings: `mfrmr` stops on duplicate person x item/facet rows instead
  of aggregating them. In many-facet rating designs, repeated rows often encode
  rater/task structure and should not be silently collapsed into MH DIF.
- Matching default: `mfrmr` defaults to rest-score matching to reduce
  target-item contamination. Users can request total-score matching with
  `matching = "total"`.
- Scope: exact tests, item purification, external matching variables,
  generalized MH, logistic/ordinal DIF, SIBTEST, and IRT multiple-group DIF are
  deferred until separate validation and cross-package agreement checks are
  available.

## Follow-up validation work

The optional harness
`inst/validation/mh-dif-package-comparison-0.2.2.R` compares
`analyze_dif_mh()` against `difR::difMH()` on a seeded binary fixture
(`seed = 202603`, `N = 800`). With total-score matching, no purification,
no p-value adjustment, `difR::difMH(correct = TRUE)`, and
`analyze_dif_mh(zero_correction = 0)`, the MH common odds ratios, MH D-DIF
deltas, MH chi-square values, and p-values agree to the script tolerance
(`1e-8`; observed maximum differences were machine-rounding scale under
`difR` 6.1.0).

The `zero_correction = 0` setting is intentional for this package-alignment
check: `difR::difMH()` reports the uncorrected common odds-ratio estimate,
while `analyze_dif_mh()` defaults to `.5` for sparse-cell screening stability.
The default remains a screening choice, not a claim of exact identity with
`difR`'s `alphaMH` output.

The optional simulation harness
`inst/validation/mh-dif-simulation-0.2.2.R` reviews the helper beyond
cross-package identity. With `seed = 73031`, `N = 800`, and 60 replications
per scenario, it checks null false-positive behavior, focal-harder and
focal-easier direction recovery, monotone response to increasing DIF shifts,
rest-score versus total-score matching sensitivity, sparse-cell
`zero_correction` behavior, explicit dichotomization for 3-level scores, and
the `analyze_dif_classical()` compatibility wrapper. In the current local
run all decision checks returned `ok`.

Before promoting the MH DIF surface beyond screening:

- add a second lower-level comparison against `difR::mantelHaenszel()`;
- add explicit tests for missing-response handling if missing item responses
  are supported later;
- add generalized MH comparison fixtures before any native polytomous
  multi-group route;
- add logistic/ordinal DIF comparisons against `lordif` before implementing a
  regression-based helper;
- add multiple-group parameter-test comparisons against `mirt::DIF()` before
  advertising IRT-model DIF claims.
