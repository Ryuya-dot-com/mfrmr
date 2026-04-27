# M3 GPCM Fair-Average Audit

Date: 2026-04-04  
Package baseline: `mfrmr` 0.1.5

## 1. Purpose

This note records a narrow source-backed decision about `fair_average_table()`
and closely related score-side reporting semantics under the first-release
`GPCM` branch.

The question is not whether generalized expected scores exist. They do.
The question is whether the current package can honestly describe its
fair-average output as the same kind of FACETS-style adjusted score that is
documented for many-facet Rasch workflows.

## 2. Source base

Primary sources:

- FACETS fair-average help page: <https://www.winsteps.com/facetman/fairaverage.htm>
- FACETS manual, fair-average discussion: <https://www.winsteps.com/ARM/Facets-Manual.pdf>
- Muraki (1992), generalized partial credit model:
  <https://www.ets.org/research/policy_research_reports/publications/report/1992/ihkr.html>
- Muraki (1993), generalized partial credit information:
  <https://www.ets.org/research/policy_research_reports/publications/report/1993/ihfu.html>
- mirt `fscores` manual (illustrates expected-score summaries under generalized
  IRT scoring): <https://search.r-project.org/CRAN/refmans/mirt/html/fscores.html>

## 3. What FACETS is actually defining

FACETS describes the fair average as:

- an adjusted expected raw-score quantity in the original score metric;
- computed by putting all non-target facets at their mean or zero baseline;
- explicitly tied to the many-facet Rasch model;
- accompanied by an extreme-score handling rule for the adjusted score
  calculation.

Operationally, the FACETS note describes a Rasch-family workflow:

1. estimate the additive many-facet Rasch model;
2. place the non-target facets at their mean or zero reference values;
3. compute the expected category distribution for the target element under
   that standardized environment;
4. report the expected score as the fair average.

This is a score-side measure-to-score transformation under a Rasch-family
identification convention.

## 4. What the current `mfrmr` implementation does

The current local `fair_average_table()` implementation:

- computes a facet-level linear predictor in a standardized environment;
- maps that predictor through `expected_score_from_eta()`;
- optionally inverts the same Rasch-family score map for extreme-score
  adjustments;
- formats the result as a FACETS-style fair-average table.

That is coherent for `RSM` and for the current `PCM` path because the local
implementation still uses a threshold-only ordered-category score map with no
free discrimination parameter.

## 5. Why first-release `GPCM` is different

The first-release `GPCM` branch adds positive facet-linked discriminations.
Under Muraki's formulation, the category probabilities remain ordered and an
expected score is still well defined for a given observation. But the score map
is no longer determined by thresholds alone:

- the expected score depends on the relevant slope value;
- any score-to-logit inversion used for extreme-score adjustment also depends
  on that slope;
- the package must decide what score-side reference environment means when the
  target element is evaluated under free discrimination.

In other words, a generalized expected score exists, but the package has not
yet validated a **FACETS-style fair-average contract** for free-discrimination
fits.

## 6. Decision

For the current release:

- keep `fair_average_table()` source-backed and active for `RSM` / `PCM`;
- keep `fair_average_table()` blocked for first-release `GPCM`;
- keep `plot_qc_dashboard()` open for `GPCM`, but expose the fair-average
  panel only as an explicit unavailable placeholder;
- keep writer / scorefile / bias-adjusted reporting layers blocked when they
  depend on the same fair-average semantics.

This is not a claim that `GPCM` expected scores are impossible.
It is a claim that the current package has not yet validated the same
fair-average meaning that FACETS documents for the Rasch-family branch.

## 7. Implication for future work

If `mfrmr` later chooses to open fair-average style reporting for `GPCM`, it
should first define, document, and test:

1. the slope-aware reference environment;
2. the slope-aware expected-score mapping;
3. the slope-aware extreme-score adjustment rule;
4. the user-facing distinction between:
   - FACETS-style fair averages under the Rasch family, and
   - any generalized adjusted-score analogue used for `GPCM`.

Until that work is done, keeping the score-side fair-average layer blocked is
the more defensible position.
