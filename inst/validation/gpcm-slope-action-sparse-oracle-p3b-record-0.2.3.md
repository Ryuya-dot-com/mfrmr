# GPCM slope-action sparse known-ability oracle

Status: completed repository-only design-identifiability audit; no public
family, model-selection, readiness, or release change

Review date: 2026-08-14

## Question

When can a sparse Rater-by-Criterion assignment distinguish the implemented
complete-predictor GPCM slope action from a loading-only action?

The p3a audit established the full-crossing discriminator

\[
D=-(\alpha_c-\alpha_d)(\rho_r-\rho_s).
\]

The present audit asks what remains when only selected Rater-by-Criterion
edges are observed.

## Structural result

For equal conditional probabilities across all ability values, the two models
must represent the observed edge values \(\alpha_c\rho_r\) as a sum of a Rater
term and a Criterion term. Any such values can be represented exactly on a
forest. A graph cycle adds a constraint; its alternating sum can expose the
slope-by-severity product.

Therefore ordinary graph connectedness is necessary for common facet
calibration but is not sufficient for distinguishing these two slope actions.

## Fixed designs

All designs contain all four Raters and all four Criteria and are connected.

| Design | Edges | Cycle rank | Minimum degree | Maximum degree |
| --- | ---: | ---: | ---: | ---: |
| `complete` | 16 | 9 | 4 | 4 |
| `balanced_cycle` | 8 | 1 | 2 | 2 |
| `localized_cycle` | 8 | 1 | 1 | 3 |
| `connected_tree` | 7 | 0 | 1 | 2 |

The balanced cycle passes through every Rater and Criterion. The localized
cycle is confined to Raters 1--2 and Criteria 1--2; its remaining edges only
connect the other levels. The tree is a connected no-cycle negative control.

The moderate crossed p3a parameters are retained: Criterion slopes
`exp(-0.30, -0.10, 0.10, 0.30)` and Rater severities
`(-0.45, -0.15, 0.15, 0.45)`.

## Population projections

Both directions were re-estimated at q=31 and q=41. The following are q=41
results.

| Design | Truth | Projected KL / response | Maximum probability difference |
| --- | --- | ---: | ---: |
| `complete` | complete | 0.0015929961 | 0.04669380 |
| `complete` | loading-only | 0.0015814828 | 0.06149158 |
| `balanced_cycle` | complete | 0.0005458253 | 0.01644331 |
| `balanced_cycle` | loading-only | 0.0006399922 | 0.03628518 |
| `localized_cycle` | complete | 0.0000263949 | 0.00433152 |
| `localized_cycle` | loading-only | 0.0000357890 | 0.00743792 |
| `connected_tree` | complete | numerical zero | numerical zero |
| `connected_tree` | loading-only | numerical zero | numerical zero |

All nontrivial optimizations returned convergence code zero. This does not
prove a global KL minimum. The maximum q=31-to-q=41 change was `1.71e-10` for
projected KL and `3.55e-9` for the common-grid maximum probability difference.

## Finite-sample oracle

For each identifiable design and truth direction, 400 datasets were generated
at 50, 100, and 250 Persons. Every Person was observed on every edge retained
by that design. Person abilities and both fixed parameter vectors were supplied
to the likelihood comparison. The candidate was the q=41 population
projection. Thus this is an optimistic known-ability, fixed-parameter
benchmark. It is not JML, MML, AIC, cross-validation, or a comparison after
parameter estimation.

Truth-selection rates were:

| Design | Truth | N=50 | N=100 | N=250 |
| --- | --- | ---: | ---: | ---: |
| `complete` | complete | 0.778 | 0.850 | 0.958 |
| `complete` | loading-only | 0.770 | 0.855 | 0.955 |
| `balanced_cycle` | complete | 0.620 | 0.698 | 0.758 |
| `balanced_cycle` | loading-only | 0.643 | 0.690 | 0.778 |
| `localized_cycle` | complete | 0.538 | 0.560 | 0.575 |
| `localized_cycle` | loading-only | 0.543 | 0.588 | 0.585 |
| `connected_tree` | either | not identifiable | not identifiable | not identifiable |

At 400 replications the largest binomial Monte Carlo standard error is about
0.025. The simulation restores the caller's random-number state.

## Interpretation

1. Connectedness alone does not identify the slope action. A connected tree
   admits an exact re-expression of either family as the other on its observed
   edges.
2. Edge count and cycle rank alone are also insufficient. The two eight-edge,
   one-cycle designs carry very different information because only the
   balanced cycle spans all slope and severity contrasts.
3. Increasing Persons reduces sampling noise but cannot create a missing graph
   constraint. Even the optimistic localized-cycle oracle remains close to
   chance at 250 Persons.
4. An actual JML or MML comparison must estimate abilities or their population
   distribution and all nuisance parameters. Its performance must not be
   inferred from these oracle rates.
5. A future design diagnostic should report relevant Rater-by-Criterion cycle
   coverage, not recommend a universal anchor percentage from density alone.

PublicFamilyAdded = FALSE

ModelSelectionEnabled = FALSE

ReadinessOverridden = FALSE

PracticalThresholdFrozen = FALSE

ReleaseAuthorized = FALSE
