# mfrmr roadmap

Status: public roadmap, updated 2026-08-03.

This file is the single source of truth for mfrmr's public release direction.
It describes intended outcomes and support boundaries, not promises about exact
dates. Completed user-visible changes are recorded in `NEWS.md`.

## Current position

- mfrmr 0.2.2 is the current CRAN release, published on 2026-07-27.
- Development is focused on 0.2.3.
- The package currently supports one observed rating scale per fit and a
  unidimensional latent trait, with RSM, PCM, and bounded GPCM routes under the
  documented JML and MML contracts.
- Existing fitted-object person scoring is not the same as applying a saved,
  frozen calibration to new operational data.

## Direction

mfrmr aims to provide a transparent, reproducible, and reviewable MFRM
workflow in R. Its value is not defined as feature parity with FACETS,
ConQuest, TAM, or any other program. External programs are used as independent
comparators where estimands and parameterizations can be matched.

The project develops in this order:

| Version | Public goal |
| --- | --- |
| 0.2.2 | Published stabilization and contract baseline. |
| 0.2.3 | Establish the numerical and empirical operating envelope of the existing models. |
| 0.2.4 | Add typed fixed calibration, threshold/step anchors, and operational scoring for one observed scale. |
| 0.2.5 | Add explicit multiple-scale routing and mixed response structures without silent pooling. |
| 0.3.0 | Consolidate APIs, object schemas, compatibility policy, examples, performance evidence, and contributor workflows. |
| 1.0.0 | Declare a deliberately bounded, validated core stable. |

## 0.2.3: numerical trust and external validation

0.2.3 is primarily a validation release, not a new-model-family release. It
will strengthen evidence for the RSM, PCM, bounded GPCM, JML, and MML surfaces
published in 0.2.2.

Priorities are:

- parameter recovery and numerical stability by model, estimator, and
  parameter class;
- standard-error and interval coverage where the interval definition is
  supported;
- stress tests for small samples, sparse and weakly linked rating designs,
  planned and unplanned missingness, uneven rater workloads, rare and unused
  categories, extreme scores, severe raters, and disconnected designs;
- matched JML comparison with FACETS for supported RSM/PCM estimands;
- matched MML comparison with ConQuest and TAM where likelihood,
  identification, and integration conventions can be aligned;
- explicit classification of validated, caveated, exploratory, blocked, and
  unsupported combinations; and
- clear separation between optimizer completion, statistical readiness, and
  suitability for use.

Passing simulation and software-comparison checks does not establish construct
validity, fairness, population transportability, or suitability for a
high-stakes decision. Those require separate domain evidence.

## 0.2.4: fixed calibration and operational scoring

The next feature release will target a typed, versioned calibration object for
one observed scale. It is expected to include:

- element, group, and threshold/step anchors with explicit conflict checks;
- saved-calibration provenance and integrity checks;
- scoring of new data with explicit behavior for unknown levels, missing
  categories, disconnected cases, and out-of-range scores; and
- round-trip and compatibility tests that distinguish a fitted object from a
  validated frozen calibration.

## 0.2.5: multiple observed scales

Multiple rating scales will be represented by an explicit per-observation
`ScaleId`. Scale identity will not be inferred from category values. The work
will begin with reduction to the existing single-scale model, then add
scale-specific category maps, PCM step structures, calibration namespaces,
connectivity checks, diagnostics, and reporting.

Multiple observed scales do not automatically imply a multidimensional latent
trait. Native multidimensional estimation and dimension-specific scores remain
separate research claims.

## 0.3.0 and 1.0.0

0.3.0 will emphasize consolidation: stable schemas, documented compatibility
and deprecation behavior, reproducible case studies, a performance envelope,
versioned validation resources, and independent methodological/code review.

1.0.0 will mean that the declared core has stable estimands and APIs,
replicated recovery and negative-control evidence, matched external evidence
where appropriate, cross-platform verification, and an explicit support
envelope. It will not mean support for every MFRM design or FACETS feature.

## Research boundary

The following are research tracks rather than committed near-term features:

- unrestricted GPCM structures;
- native multidimensional MFRM and dimension-specific scores;
- Bayesian or MCMC backends and posterior-predictive checks;
- multivariate G-theory;
- mixture, unfolding, and specialized rater-process models;
- automatic DIF/DFF decision rules; and
- distributed or high-performance estimation engines.

A callable experimental helper is not by itself a public support claim. A
feature becomes supported only after its estimand, identification, failure
behavior, recovery evidence, documentation, and compatibility contract agree.

## Permanent principles

1. Unknown or unidentified designs fail closed or carry an unavoidable caveat.
2. External agreement is evidence within a matched overlap region, not proof
   that either program is ground truth.
3. Failed cells and failed replications are never hidden by pooled summaries.
4. Exploratory diagnostics remain exploratory until independently validated.
5. Public code, help, examples, capability tables, and release notes must state
   the same support boundary.
6. Slow validation remains reproducible without becoming a required runtime
   dependency or routine CRAN workload.
