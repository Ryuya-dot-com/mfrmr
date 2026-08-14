# FACETS multifacet confirmation design record (0.2.3)

Status: semantic no-fit design frozen on 2026-08-14; execution blocked because
no numerical acceptance rule has been frozen. No response, fit, FACETS result,
or confirmation seed outcome has been opened.

## Scope and denominator

The design fixes 30 new base seeds, 460001 through 462901 in increments of
100. Each seed is crossed with RSM and Criterion-step PCM at total facet counts
3, 4, and 5. Total facets include Person. This produces 180 expected cases,
with 30 replicates in every model-by-facet-count cell.

The confirmation band is disjoint from the protected 451000--452999 candidate,
qualification, and pilot range. RSM uses `BaseSeed + 1`; PCM uses
`BaseSeed + 2`. The design does not generate responses to test this property:
seed identity is checked without opening seed outcomes.

Every future case retains the fixed-information structure of 40 Persons, 4
Raters, 4 Criteria, 640 observations, three Task levels when present, and two
Occasion levels when present. The complete expected denominator is:

- 180 case rows;
- 9,120 element-coordinate rows;
- 1,350 step-coordinate rows; and
- 720 facet-block metric rows.

Failed generation, FACETS execution, report parsing, convergence, mfrmr fit,
or coordinate matching remains in the 180-case denominator. Failed replicates
are not replaced, and neither early stopping nor adaptive extension is
permitted.

## Precision contract

For element and step agreement, the replicate-level endpoint is the maximum
absolute mfrmr--FACETS difference within a case. Cell means report
`sample_sd / sqrt(n_eligible)` and a 95% t interval. The MCSE target is 0.0001
logits for both endpoints.

FACETS convergence and comparison eligibility are proportions over all 30
planned replicates in each cell, including failures. They report binomial MCSE
and a 95% Wilson interval; the MCSE target is 0.06. Thirty all-success
replicates would place the exact one-sided 95% upper bound for an unobserved
failure probability below 0.10. These are precision statements, not model-
agreement thresholds.

FACETS 4.5.0, `Convergence=.01,.0001`, JML, complete element/step coordinate
contracts, raw warnings/errors, and final-iteration evidence are fixed. A
return code of zero cannot substitute for achieved convergence.

## Why execution remains blocked

The five-seed pilot was inspected before this design. Its observed maximum
differences therefore cannot be reused as a confirmation acceptance rule. This
design freezes sample size, seeds, endpoints, MCSE calculations, and failure
accounting, but leaves `AcceptanceTolerance=NA` and
`AcceptanceRuleFrozen=FALSE`.

Before execution, a separate scientific decision must state what numerical
agreement is substantively sufficient and why. It must not use confirmation
outcomes. Until then, `ExecutionAuthorized`, `ConfirmationAuthorized`, and
`EquivalenceClaimAuthorized` remain false.

## Environment independence

No file-byte equality, SHA, serialized-object identity, or floating-point bit
identity is required. The contract is protected by its explicit version,
semantic registry fields, exact seed set, complete denominators, and tests.
The future run must record the package commit and FACETS version for provenance,
but those identifiers do not determine scientific equality across user
machines.
