# FACETS multifacet numerical agreement rule record (0.2.3)

Status: rule frozen on 2026-08-14 before any confirmation response, fit, or
result was opened. Confirmation execution remains unauthorized.

## The numerical question

The confirmation asks whether mfrmr and FACETS 4.5.0 produce practically the
same RSM/PCM JML element and step coordinates under the already frozen,
fixed-information 3--5 facet design. It does not ask whether files, serialized
objects, printed tokens, or hidden binary floating-point values are identical.

For every comparison-eligible element and step coordinate, the frozen rule is

```
absolute(mfrmr - FACETS) <= 0.005 logits
```

The boundary is inclusive. The same rule applies to RSM and PCM at total facet
counts 3, 4, and 5. Agreement must hold coordinate by coordinate; a correlation,
mean signed difference, or pooled average cannot hide a failed coordinate.

## Why 0.005 logits

The FACETS convergence documentation calls 0.01 logits its standard maximum
element change and the smallest useful or printable difference. It also gives
0.0001 logits as an exaggerated-accuracy setting for a final decisive analysis.
The comparison already fixes that tighter FACETS setting. Half of the documented
0.01-logit practical increment, 0.005 logits, is therefore used as a conservative
cross-implementation numerical-agreement envelope.

This envelope was not fitted to the five-seed pilot maximum. The pilot values
were known before this rule was written and remain qualification evidence only.
The rule also is not derived from mfrmr's optimizer `reltol`: R's documented
`reltol` concerns relative objective reduction and does not by itself imply a
coordinate-distance bound.

References:

- FACETS convergence criteria: https://www.winsteps.com/facetman64/convergencecriteria.htm
- R `optim()` convergence controls: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html

## Floating-point handling

The scientific tolerance is 0.005 logits. The executable comparison adds only
`8 * .Machine$double.eps * max(1, |difference|, tolerance)` at the inclusive
boundary so that decimal parsing and one subtraction do not turn a boundary
value into a failure by a few representational ulps. This allowance is about
1.8e-15 near the present boundary. It is not an empirical tolerance, an
environment fingerprint, or permission to absorb optimizer differences.

No SHA, file-byte, serialized-object, or binary64 identity enters the decision.
Package commit and FACETS version are provenance fields only.

## Failure and claim boundaries

FACETS convergence and comparison eligibility remain operational endpoints,
not numerical-agreement tolerances. Generation, execution, parsing,
convergence, fit, or coordinate-matching failures remain in the 180-case
denominator and are `not_comparable`; they cannot count as numerical passes.
Conditional agreement among eligible coordinates may be reported separately,
but complete fixed-core confirmation requires all 180 planned cases to be
accounted for and eligible, all expected coordinates to be present, and every
coordinate to pass the inclusive envelope. MCSE targets describe precision and
do not replace the 0.005-logit rule.

Passing this rule would support only numerical agreement within the tested
fixed-information RSM/PCM JML envelope. It would not establish exact equality,
formal statistical equivalence, unbiasedness, fit-statistic parity, sparse or
large-data robustness, 30-facet capacity, GPCM parity, or that FACETS can be
replaced for every workflow.

## Remaining execution boundary

This artifact freezes the rule but does not run confirmation seeds. A separate
runner/preflight must bind the semantic design, complete denominators, raw
warnings and errors, convergence evidence, coordinate matching, and a fresh
output location. Until that exists and is reviewed, execution and confirmation
claims remain unauthorized.
