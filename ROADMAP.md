# mfrmr roadmap

Status: public roadmap, updated 2026-08-26.

This roadmap describes the package's intended user-facing direction. It is not
a promise of release dates. Completed changes are documented in `NEWS.md`.

## Current releases

- mfrmr 0.2.3.1 is the current CRAN source release.
- mfrmr 0.2.4.9000 is under development and has not been released.

The 0.2.4 development version retains the established MFRM fitting workflow
and adds portable calibration objects for supported RSM and PCM analyses. These
objects are designed to preserve the model, scale, category mapping, facet
levels, anchors, and scoring settings needed to score new Persons consistently.

## What 0.2.4 is intended to support

The planned portable workflow is deliberately narrow:

- one observed rating scale per analysis;
- RSM or PCM;
- MML calibration on a fixed standard-normal Person distribution;
- stored direct and group facet anchors;
- validation before a calibration is frozen;
- EAP scoring of new Persons from the frozen calibration; and
- explicit rejection of incompatible data, levels, categories, models, and
  scoring settings.

The ordinary fitted-object workflow continues to support the model and
estimation combinations documented by `fit_mfrm()`. A fitted model and a
portable calibration are different objects: the latter has a stricter identity
and compatibility contract for later scoring.

## Model scope

| Area | Current direction |
| --- | --- |
| RSM | Supported in the established fitting workflow and the planned 0.2.4 portable calibration workflow. |
| PCM | Supported in the established fitting workflow and the planned 0.2.4 portable calibration workflow. |
| GPCM | Available only within the documented bounded fitting routes. Portable GPCM calibration is not part of 0.2.4. |
| JML | Retained for documented fitted-model analyses. The 0.2.4 portable calibration workflow is MML-only. |
| Interactions | Supported where documented for fitted models; portable interaction calibration is not part of 0.2.4. |
| Multiple scales | Not silently pooled. Explicit multiple-scale routing is planned for a later version. |

The GPCM limitation is substantive, not merely a user-interface restriction.
Slope identification, boundary behavior, and portable scale identity require a
stronger contract than the RSM/PCM workflow currently provides.

## Generalizability theory

mfrmr does not currently offer a stable exported G-theory workflow. A possible
future direction includes multivariate designs, with separate handling of:

- universe-score covariance across outcomes;
- outcome-specific and cross-outcome error components;
- relative and absolute decisions;
- admissible positive-semidefinite covariance structures; and
- design-dependent decision coefficients.

Multivariate support will be described as available only after the public API,
identifiability conditions, numerical behavior, and examples are complete.
Univariate calculations do not by themselves establish multivariate support.

## Rater assignment and anchors

Rater assignment and anchoring are treated as design problems rather than as a
single recommended percentage. Planned guidance distinguishes:

- complete and incomplete rating designs;
- connectedness of Persons, raters, and tasks;
- direct anchors, group anchors, and unanchored linking;
- assignment order and workload balance;
- overlap patterns and bridge raters; and
- sensitivity of facet estimates and Person measures to missing ratings.

Examples and simulations will state the exact design and estimand. Results from
one allocation pattern will not be generalized to all incomplete designs.

## External comparison

FACETS, ConQuest, TAM, and other software may be used as independent
comparators when model, parameterization, constraints, anchors, categories, and
estimands can be aligned. Agreement with another program is useful evidence,
but it is not the definition of correctness and does not imply feature parity.

## Version direction

| Version | User-facing goal |
| --- | --- |
| 0.2.4 | Portable fixed calibration and operational scoring for one observed RSM/PCM scale, preserving supported facet anchors. |
| 0.2.5 | Explicit multiple-scale routing and mixed response structures without silent pooling. |
| 0.3.0 | Consolidated APIs, object schemas, compatibility policy, examples, performance evidence, and contributor workflows. |
| 1.0.0 | A deliberately bounded, documented, and validated stable core. |

Later-version goals may change in response to empirical use, statistical
evidence, and compatibility needs. New functionality will be described as
supported only when its interface, documentation, and numerical behavior are
ready for use.

## Compatibility principles

- Incompatible objects should fail clearly rather than be silently coerced.
- Stored scale and anchor semantics matter more than incidental file hashes.
- Object schema changes require an explicit compatibility or refusal policy.
- Examples should use realistic defaults even when compact examples use
  smaller settings for illustration.
- Help, messages, vignettes, and printed output should use clear reader-facing
  language.

## Not part of the 0.2.4 promise

Version 0.2.4 is not intended to provide:

- portable GPCM calibration;
- portable JML calibration;
- portable interaction calibration;
- automatic cross-scale linking;
- multiple observed scales in one portable calibration;
- exported multivariate G-theory analysis; or
- complete feature parity with external MFRM software.

These exclusions keep the supported claims aligned with the statistical and
operational behavior that users can rely on.
