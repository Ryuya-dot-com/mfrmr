## Release focus

This is the 0.2.2 update after CRAN 0.2.1.

Work that had been labelled locally as a larger minor-release branch has been
narrowed into a 0.2.2 release candidate. The package version, NEWS heading,
validation artifacts, and release-readiness checks now use 0.2.2; no broader
minor-release claim is intended for this submission.

Headline changes relative to CRAN 0.2.1 are:

- an explicit data -> fit -> required Wright map -> focused diagnostics ->
  report/export reading order, including a reader-first starter index;
- an opt-in FACETS Table 6-style Wright renderer with person-frequency
  asterisks, signed facet columns, and labeled score-transition lines, while
  retaining the native renderer and its opt-in facet SE/CI display; the
  canonical results route enables those intervals;
- a distinct Infit/Outfit-versus-measure pathway with bounded person-row
  inclusion and editable plot data;
- reader-first summaries, report views, and starter exports for the
  `fit_mfrm()` -> `mfrm_results()` -> `mfrm_report()` ->
  `export_mfrm_results()` workflow;
- observed-score G-study interaction sensitivity, design checks, comparison
  summaries, and person-cluster bootstrap intervals;
- opt-in free normal population-SD estimation for additive `RSM`/`PCM` and
  bounded-`GPCM` MML fits, while retaining the fixed-SD default;
- fixed-calibration EAP power-sensitivity diagnostics for scoring-stage
  robustness review;
- optional `ggplot2` conversion through `as_ggplot()` for draw-free plot
  payloads;
- bounded-`GPCM` score-side expected-score SE correction and fixed smoke
  evidence for the score-side estimand;
- diagnostic-network and rater-network stress evidence, including projected
  rater-linkage graphs, zero-overlap rater pairs, and group-anchor-only
  recommendation coverage;
- explicit bounded-`GPCM`, model-family, and estimator/back-end scope helpers
  so users do not read the current route as complete unrestricted GPCM,
  posterior-predictive, MCMC, or full FACETS score-side support;
- observed-score Mantel-Haenszel DIF screening support and DIF/DFF APA
  reporting-boundary checks, with wording that keeps screening evidence
  separate from fairness, invariance, or subgroup-decision claims;
- a 0.2.2 release-scope review and versioned evidence map/checklist used by
  the release-readiness helper.

The release is documented in two layers: the short summary above, plus this
scope map. `fit_mfrm()` remains the unidimensional engine; the new work is
mainly report, review, visual, G-theory, bounded-`GPCM`, DIF, linking, and
release-evidence infrastructure around that engine.

| Area | Included in 0.2.2 | Explicit boundary |
| --- | --- | --- |
| Core engine | Existing unidimensional `RSM`/`PCM`/bounded-`GPCM` `fit_mfrm()` route. | No multidimensional latent trait, Q-matrix, arbitrary covariance, `formulaA`, mixture, or response-process engine. |
| Workflow/reporting | Reader-first result/report summaries, starter exports, minimum report checklist, and psychometric guide. | Organizes evidence; does not refit, certify validity, or create acceptance rules. |
| G-theory | Observed-score G-study/D-study, interaction sensitivity, design checks, comparisons, and bootstrap intervals. | `G`/`Phi` are not fitted-logit MFRM reliability, agreement, or validity evidence. |
| Bounded `GPCM` | Capability matrix, score-side contract, score-side SE correction, smoke simulation, and external probability-kernel comparison. | Not complete unrestricted GPCM, full FACETS score-side equivalence, posterior predictive checking, or Bayesian heavy-backend support. |
| FACETS transition | Terminology, feature, visual, and file-contract crosswalks. | Migration/presentation contracts, not numerical equivalence claims. |
| DIF/linking/visuals/simulation/RT | Conservative DIF/DFF screening, anchor/linking helpers, draw-free visuals, simulation planning, and descriptive response-time QC. | Screening/planning/QC evidence only; no final fairness, equating, validity, speed-model, or automatic operational decision. |

## Test environments

The refreshed local lightweight source-tarball check was run against the
generated `mfrmr_0.2.2.tar.gz` source tarball on:

- local macOS Tahoe 26.5.2, aarch64-apple-darwin23, R 4.6.1
  (2026-06-24).

Final local source-tarball check refreshed on 2026-07-23 JST:

```sh
R CMD build .
_R_CHECK_FORCE_SUGGESTS_=false R CMD check --no-manual --as-cran mfrmr_0.2.2.tar.gz
```

The check reported `Status: OK` with 0 errors, 0 warnings, and 0 notes.
The release-readiness review is run
against the final `mfrmr.Rcheck/00check.log`, which must report package
version 0.2.2.

## CRAN-time test scope

The CRAN-eligible test suite is intentionally limited to lightweight
namespace, alias, citation/data, and package-contract checks so the package
stays within the CRAN timing budget on slower Windows check hosts. This is a
practical CRAN submission constraint, not the full regression boundary.

Long integration, fit-backed guide, documentation-scan, coverage-expansion,
MML, external-Suggests, plotting, simulation, recovery, and stress tests
remain in the repository and are run outside CRAN timing constraints by
setting `NOT_CRAN=true`.

The 0.2.1 CRAN submission passed the incoming content checks on Windows and
Debian but hit the Windows overall-checktime limit before being accepted on
review. The example-execution policy introduced after that check keeps
long-running illustrations behind `\dontrun` or `@examplesIf interactive()`;
the underlying routes remain covered by the non-CRAN regression surface and
versioned validation artifacts.

## R CMD check results

For the current tree, the final local source-tarball check was refreshed with
vignettes enabled:

```sh
R CMD build .
_R_CHECK_FORCE_SUGGESTS_=false R CMD check --no-manual --as-cran mfrmr_0.2.2.tar.gz
```

The check reported `Status: OK` with 0 errors, 0 warnings, and 0 notes.
The separate non-CRAN regression run covers the Wright renderers, Infit
pathway, person inclusion, starter export, editable ggplot conversion,
network, anchor, GPCM-boundary, reporting, namespace, and release-readiness
paths. The release-readiness gate verifies the
network/anchor stress and self-/other-speaking network validation artifacts
rather than relying only on their presence, and expected optimizer
convergence-review warnings from the live DIF/DFF APA review are captured in
structured status fields. win-builder checks should still be run and recorded
immediately before CRAN submission.

## Downstream dependencies

No reverse dependencies are listed in the current CRAN package index for
Depends, Imports, or LinkingTo, checked against `https://cloud.r-project.org`
on 2026-07-09 JST.

## Default changes

No defaults change between CRAN 0.2.1 and 0.2.2.

The 0.1.6 defaults (`quad_points = 31`, `diagnostic_mode = "both"`,
`plot.mfrm_fit(type = "wright")`, `keep_original = FALSE`) are retained.
The FACETS-style renderer and fit-oriented pathway are opt-in; the native
Wright renderer remains the default, and its SE/CI overlay remains available
through `show_ci = TRUE`.

## Deferred to a follow-up release

- Posterior-predictive checks for bounded GPCM.
- Complete unrestricted GPCM slope-design support beyond the current bounded
  `slope_facet == step_facet` route.
- Full FACETS-equivalent score-side contract review for bounded GPCM.
- Additional observed-score DIF wrappers beyond the Mantel-Haenszel screening
  helper, such as logistic regression and SIBTEST. Residual-method DFF remains
  the fitted-MFRM route.
- Heavy-backend Bayesian/HMC integration and posterior-predictive validation.
