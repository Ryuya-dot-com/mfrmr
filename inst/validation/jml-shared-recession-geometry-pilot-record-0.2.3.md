# JML shared recession geometry pilot record for mfrmr 0.2.3

Status: repository-only draft.54 change-local evidence, 2026-08-06. This
implements one optional shared construction path for the structural and joint
additive JML recession audits. It changes no likelihood, optimizer, estimator,
public API, fitted-object schema, readiness rule, public roadmap, or release
criterion; authorizes no confirmation; and freezes no runtime claim.

## Problem and decision order

Draft.53 removed redundant target LP enumeration, but the structural and joint
audits still rebuilt closely related geometry. A reversible one-route function
probe preserved the Draft.53 semantic hash and attributed the R12 audit pair
to observed-contrast construction, LP execution, target mapping, and adjacent-
design construction. This supported testing shared geometry before considering
warm starts, a different LP solver, or optimizer dispatch.

The implemented order is deliberately conservative:

1. construct one full Person-plus-structural adjacent design, expanded target
   system, and observed-category contrast matrix;
2. use it only when its version, state, sparse objects, row counts, column
   counts, and optimizer-index mapping are internally coherent;
3. project the exact non-Person columns and non-Person target rows for the
   structural audit, while the joint audit uses the full geometry; and
4. if shared construction fails or the optional object is malformed, discard
   it and rerun both audits through their pre-Draft.54 construction paths.

MML never constructs or consumes this JML geometry. The shared object remains
local to `mfrm_estimate()` and is not stored in a fit or exposed through the
public API.

## Exact projection contract

Let `A` be the full free-coordinate adjacent-logit design and let `S` select
its non-Person columns. The observed-versus-alternative contrast builder is a
fixed sparse left-linear operator `L` determined by the retained scores and
category count. Therefore:

`L(A[, S]) = L(A)[, S]`.

The structural target system is likewise the non-Person row projection of the
joint expanded-target Jacobian on the same optimizer coordinates. The fast
path requires unique, non-missing optimizer indices and dimensionally aligned
metadata, Jacobian rows, adjacent columns, and contrast columns before either
projection is used.

Change-local tests verify bit-identical sparse contrasts and whole-audit object
identity under:

- PCM with criterion-specific steps, nonuniform positive weights, zero-weight
  removal, missing-score removal, a direct Rater anchor, and a Criterion group
  anchor;
- a Rater-by-Criterion interaction;
- RSM shared steps;
- bounded GPCM with its supported common Criterion step/slope facet;
- ordinary Person extremes and existing joint quotient/nullspace logic; and
- a malformed optional geometry object plus an injected shared-construction
  failure, both of which reproduce the legacy fit tables, readiness, and
  boundary audits.

The existing joint, structural, phase-timing, sparse/dense, row-order,
constraint-coupled, interaction, GPCM-conditional, MML, readiness, and release-
readiness controls remain in force.

## Canonical target-status identity correction

Adversarial comparison found that two target-status data frames could be
`identical()` in row order, column names, row names, types, and values but have
different `digest(..., serialize = TRUE)` hashes after one was obtained by row
projection. The old ledger therefore encoded an R internal serialization or
ALTREP representation detail, not only the intended target classification.

Phase-profile target-status identity is now versioned as
`mfrmr-jml-target-status-canonical-v1`. Each retained field is converted to a
type-explicit UTF-8 representation with explicit logical, integer, numeric,
character, and missing-value encodings before hashing. CSV empty strings and
in-memory `NA` are also normalized to the same not-applicable state when two
result ledgers are compared.

The unchanged installed Draft.53 runtime was replayed over the fixed 19 routes
to create `jml-phase-profile-20260806-d53-canonical-v1`. Relative to the
original v8 bundle, all 16 selected data, semantic-result, readiness, numerical,
boundary, optimizer, structural-state, joint-state, relevance, nullspace, and
false-ready fields match on all 19 routes. Both old serialized target hashes
change on 19 of 19 routes, as expected from the identity-version change; this
is not treated as a statistical change. The canonical replay is a comparison
bridge and does not supersede v8 as the historical Draft.53 performance record.

## Fixed 19-route component result

The final component bundle is
`mfrmr/jml-recession-component-20260806-v1`. It uses the unchanged seven-cell,
19-route PCM manifest, fixed data and seeds, 60-iteration ceiling, seven MML
quadrature points, and `1e-9` relative tolerance. Namespace wrappers are
installed only around the fit call, record nested inclusive/exclusive elapsed
time, and are restored before the phase runner's legacy structural re-audit.

All 19 fits, 19 ordinary phase contracts, 19 component contracts, and 19
canonical Draft.53 comparisons pass; false-ready count is zero. Every JML
route constructs the adjacent design, target map, and full contrast exactly
once in the shared scope and zero times inside the structural or joint audit.
MML constructs no shared JML geometry.

Against the same-day canonical Draft.53 replay:

| Measurement | Draft.53 canonical | Draft.54 | Change |
| --- | ---: | ---: | ---: |
| structural phase, including shared construction | 13.72 s | 14.47 s | +5.5% |
| joint phase | 19.28 s | 6.60 s | -65.8% |
| structural plus joint phases | 33.00 s | 21.07 s | -36.2% |
| JML outer fits | 44.12 s | 31.71 s | -28.1% |
| MML outer fits | 7.39 s | 7.49 s | timing noise |

All 12 JML routes are faster for the combined audit pair; route-level changes
range from -21.0% to -42.3%. The structural phase increases because it now owns
the one shared full-geometry construction that the joint phase subsequently
reuses. This accounting movement is not a structural-audit regression.

The JML exclusive-time decomposition is:

| Component | Seconds | Share of 21.03 component seconds |
| --- | ---: | ---: |
| observed-contrast construction | 10.28 | 48.9% |
| LP solver calls | 8.11 | 38.6% |
| adjacent-design construction | 1.13 | 5.4% |
| expanded-target mapping | 1.01 | 4.8% |
| LP-base assembly | 0.20 | 1.0% |
| orchestration, nullspace rank, and post-solve work | 0.30 | 1.4% |

The 21.03 component seconds agree with the 21.07 top-level phase total within
clock resolution. The new leading remainder is therefore the current observed-
contrast constructor, followed by the LP solver. Draft.55 should first replace
the constructor's repeated vector growth with an exact preallocated or direct
sparse formulation, under sparse/dense, category-count, row-order, missingness,
anchor, interaction, and GPCM equality tests. Solver or warm-start work follows
only after that pure construction correction is measured.

## Critical limitations

The fixed timing profile is one PCM replicate on one Windows machine. The
RSM, interaction, weighted/missing, anchored, and bounded-GPCM results are
small change-local equality controls, not target-scale performance evidence.
There is no replicated runtime distribution, isolated-process memory result,
general independent-solver parity, target-scale positive quotient, nonlinear
GPCM recession closure, FACETS comparison, recovery, coverage, candidate, or
confirmation evidence. No checklist row or numeric release threshold is
promoted.

## Evidence integrity

The final bundle was promoted from a staging directory only after every fit,
phase, component, construction-count, baseline-equivalence, and false-ready
contract passed. Its completion marker independently matches all 11 pre-marker
artifacts.

| Field | SHA-256 |
| --- | --- |
| Installed Draft.54 runtime | `788a4d0732bb8df9d435cd0f7419b9b5da908ad7a55deb50b10156a98f07c89d` |
| Component runner | `26219e45d9691ea168174ba6cd0bed986c65dfbfc6b467bd25c475f7c1650131` |
| Phase runner | `fc7bda3520d85755326d7751d913bb5e0a8cb1d44be5325fb811882140e753f4` |
| Component execution identity | `77ad194b97c0f18286aba77e0d017f14d1463edb88be7d9546e9b934243c5d59` |
| Component artifact inventory | `1f2b876c894fb618dd75abf027cee2a44f13b6fdb38f2b82882a5017053ef9d9` |
| Component completion marker file | `9912e0b80b8abbf5e06c37a952dbd488f76c008b6ea6a9c7cb26bae1b847bd9f` |
| Component result CSV | `42dc07a17d47edbe0a8a018df1605e0d6df621938798b823b912279384ebbcae` |
| Component call CSV | `cfeadffbe4aee78bb4410606e6121162a636003c7b7d5f9d0abc4b248ffb77f8` |
| Component summary CSV | `6bcb551f7221e530f31ddd337ae30e5b4e92e7a09adaabfe276220574349f105` |
| Baseline-comparison CSV | `8bc19e93b593ce782c7e3a530c5502101acc856eb6caa2df539a82d2bfa7111f` |
| Canonical Draft.53 completion marker file | `462e1484162c452f799d1ac308904186cc4059595c68aa1c02aa280c3c258029` |
| Canonical Draft.53 artifact inventory | `8becacbe6d6a3888f9748b6fa94f1efabbeba92f3c927b8ac34f6466b54233fd` |

A clean exact local source package contains 492 tar entries and passes
`R CMD check --no-manual` with `Status: OK`, including installation, static and
documentation checks, examples, the package test suite, and vignette
rebuilding. Its tarball and check-log identities are stored outside the package
source in
`mfrmr/.check-draft54-standard-no-manual-v4/verification-receipt.txt` so that
recording a hash cannot mutate the artifact it identifies.

Public `ROADMAP.md` and `NEWS.md` remain unchanged. Full-manual, `--as-cran`,
`--run-donttest`, dependency-present, external, candidate-linked, and
confirmation checks remain open for Draft.54.
