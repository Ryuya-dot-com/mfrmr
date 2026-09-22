# Draft.85b0 multivariate G-theory incidence contract

Status: repository-only long-form semantic preflight, 2026-08-24.

This contract advances the supplied-matrix Draft.85a0 algebra by defining the
observed links that must exist before a multivariate covariance backend is even
called. It does not estimate a variance or covariance component, fit a mixed
model, form G/Phi, or alter the public package API.

## Long-form identity

Every audit receives explicit columns for:

- one globally linked object of measurement;
- one observed-score `Stratum`;
- one numeric response;
- one or more condition facets; and
- an exact ordered set of declared strata.

Object, stratum, response, and condition columns must be distinct. Identifier
values cannot be missing or empty, observed strata cannot fall outside the
declared order, and scores must be finite or explicitly missing. `Inf` and
`NaN` fail rather than becoming omissions.

Each condition facet has one required scope:

- `global`: equal labels denote the same condition across strata and direct
  cross-stratum support is audited; or
- `stratum_local`: labels are qualified by stratum and their cross-stratum
  covariance contribution is structurally zero by declared identity.

The audit never guesses whether repeated labels such as `R1` identify one
rater or different local raters. This distinction is necessary before a
random-slope covariance can be interpreted.

## Object and condition overlap

The retained rows produce an exact object-by-stratum Boolean incidence matrix,
an object missing-stratum pattern table, all pairwise direct object overlaps,
and a thresholded stratum graph. Graph connectivity and complete direct
pairwise overlap remain separate:

- a connected A--B--C graph is sufficient to show that the strata do not form
  independent islands;
- it is not sufficient to identify an unrestricted A--C covariance when no
  object is observed in both A and C; and
- therefore the preflight requires direct overlap for every covariance pair it
  admits to the later matched-backend gate.

For each condition facet and stratum pair, the audit records global or local
scope, marginal level counts, shared levels, common/partial/disjoint support,
and whether direct component-covariance overlap reaches the declared minimum.
Local facets can pass the incidence contract with zero shared labels because
their cross-stratum target is explicitly structural zero. A global facet with
insufficient direct sharing blocks the preflight.

The three minimum counts are structural preflight controls, not validated
sample-size rules and not evidence of statistical power or precision.

## Missingness and identity

Score omissions are retained in separate canonical input, retained-data, and
omission-pattern hashes. A `complete` declaration with omitted scores and an
`unknown` declaration with omissions both produce typed issues. Row order does
not change any scientific hash.

The object-pattern table distinguishes complete and incomplete multivariate
records without filling, deleting, or treating structural absence as a zero
score. Future likelihood work must preserve this denominator and declare its
missingness assumption.

## Readiness boundary

A passing result means only that the long-form identity is sufficiently
explicit for a matched backend preflight:

```text
IncidenceReady      = TRUE
EstimationReady     = FALSE
InferenceReady      = FALSE
CoefficientEligible = FALSE
DecisionReady       = FALSE
```

The preflight does not yet bind a typed component/effect map, distinguish
Person-by-facet and residual pairing identities, construct an `lme4` or
`glmmTMB` formula, estimate an unstructured component covariance, repair a PSD
matrix, select ML/REML, compute uncertainty, or pass recovery.

## Ordered next gate

Draft.85b1 must add an explicit component map and observation-pair identity,
then construct exactly matched Gaussian random-slope models for `lme4` and
`glmmTMB`. It must bind retained rows, component roles, raw backend parameters,
stratum order, optimizer controls, and ML/REML identity before comparing point
estimates. Local-scope components must remain structurally diagonal rather
than acquiring correlations from formula convenience.

Draft.85c remains responsible for two-/three-stratum recovery, sparse and
unequal workloads, missing strata, PSD/rank recovery, allocation sharing,
composite recovery, and full-refit uncertainty. No multivariate public route
is eligible before those gates and the univariate prerequisites are complete.
