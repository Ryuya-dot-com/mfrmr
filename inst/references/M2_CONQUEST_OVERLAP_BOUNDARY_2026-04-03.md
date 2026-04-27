# M2 ConQuest Overlap Boundary

Date: 2026-04-03

## Purpose

This note fixes the exact boundary for what `mfrmr` can currently claim about
ConQuest overlap after the first latent-regression implementation wave.

The goal is not to maximize claims. The goal is to keep user-facing language
strictly inside the overlap that is both:

- implemented in `mfrmr`, and
- supported by the ConQuest official documentation and primary latent-
  regression literature already adopted in the roadmap.

## Official source basis

Primary official references:

- ACER ConQuest Tutorial: <https://conquestmanual.acer.org/s2-00.html>
- ACER ConQuest Technical Matters: <https://conquestmanual.acer.org/s3-00.html>
- ACER ConQuest Command Reference: <https://conquestmanual.acer.org/s4-00.html>

Primary methodological anchors:

- Bock and Aitkin (1981)
- Mislevy (1991)

These sources justify treating latent regression as a response-model plus
population-model estimation problem, not as a secondary regression on EAP or
MLE scores.

## What can now be claimed

`mfrmr` now has defensible overlap with the ConQuest latent-regression
materials only in the following narrow sense:

- ordered-response many-facet Rasch estimation under `RSM` / `PCM`
- unidimensional `MML`
- one-dimensional conditional-normal person population model
- person-level covariates supplied in an explicit one-row-per-person table and
  expanded through the fitted `stats::model.matrix()` contract
- posterior scoring and plausible-value draws that condition on the fitted
  population model
- scenario-level simulation / planning workflows that can repeatedly refit the
  same first-version latent-regression `MML` branch

This is an overlap in model class and workflow logic, not a claim of exact
software equivalence.

## What must not be claimed

The current package should **not** be described as having ConQuest parity for:

- arbitrary linear design matrices
- imported design specifications
- multidimensional latent regression
- generalized model families beyond the current ordered `RSM` / `PCM` scope
- arbitrary factor coding or contrast behavior beyond the fitted
  `stats::model.matrix()` contract
- the full ConQuest plausible-values workflow
- exact equivalence of optimization details, defaults, or reporting output

## Safe user-facing phrasing

Acceptable:

- "`mfrmr` includes a first-version latent-regression `MML` branch for
  ordered-response `RSM` / `PCM` many-facet models."
- "Current overlap with ConQuest is limited to unidimensional conditional-
  normal population modeling with person-level covariates represented through
  the fitted model-matrix contract."
- "Posterior scoring for active latent-regression fits uses the fitted
  population model."

Not acceptable:

- "`mfrmr` is equivalent to ConQuest."
- "`mfrmr` reproduces the ConQuest latent-regression feature set."
- "`mfrmr` now supports ConQuest-style arbitrary latent-regression design
  modeling."

## Current implementation consequence

This boundary should control:

- `fit_mfrm()` help language,
- package-level help language,
- roadmap wording,
- and any future external benchmark claims.

If a future benchmark against ConQuest is added, it should be restricted to a
case where model family, dimensionality, covariate coding, and estimation path
match exactly.

That condition is now operationalized in
`build_conquest_overlap_bundle()`, which exports only the narrow binary
item-only latent-regression case with one numeric person covariate and labels
the ConQuest text as a command template rather than as an automation guarantee.

`audit_conquest_overlap()` then compares normalized external tables against
that exact-overlap contract without treating any finite numeric agreement as a
general software-equivalence result.
