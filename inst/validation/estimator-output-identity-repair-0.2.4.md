# Fit/diagnostics identity repair for estimator-specific reporting

Date: 2026-09-14. Scope: C03/C04/C05/C17 follow-up to the
[integrated ledger](claim-reconciliation-0.2.4.md). Implementation/output repair;
no new statistical coverage, external numerical-parity or release approval.

## Question, reproducer and answer

Can a user reuse diagnostics from an earlier model and accidentally report
that model's uncertainty or precision status as if it belonged to a new fit?

Yes, before this repair. Fit the same `example_core` ratings using MML and JML
RSM, then pass the MML diagnostics to the JML fit. The JML fit itself satisfies
its fit-readiness checks, but its own uncertainty is exploratory. The ordinary
call `summary(jml_fit, diagnostics = mml_diagnostics)` nevertheless returned
`FormalInference = "Yes"` and “Ready for formal inference.”
`precision_review_report()` returned the MML `model_based` precision profile
under JML fit settings. APA tables and Wright-map uncertainty data also
accepted this mixed pair. This is an incorrect source association, not a
question that a recovery simulation could settle.

The initial ten-route probe retained eight accepted results and two refusals.
`mfrm_results()` and the comprehensive summary already refused the mixed pair;
the lightweight summary, precision report, checklist, three APA table variants,
Wright map, and legacy-diagnostics precision probe did not. The legacy probe
removed diagnostic readiness from otherwise matching JML diagnostics; it was
separate from the mixed MML/JML pairs.

The affected fit/diagnostics entry points now reuse the existing structural
identity validator. Matching saved diagnostics remain usable. A different
model/estimator or stale readiness is rejected with instructions to recompute
diagnostics for the fit. Caption/note overrides and the FACETS table branch
cannot bypass validation.

## Root cause and repair

Several direct reporting/plot routes consumed a diagnostic precision profile
or measure SEs without checking their association with the fit. The summary's
fit gate and the supplied precision gate could consequently come from two
different estimators. The structured results route already had a shared
identity check; extending that check avoided separate estimator-specific
rules in every consumer.

The shared native identity check now compares diagnostic readiness with the
fit's current readiness record, including its estimator/model provenance.
Matching observation rows and locations alone is insufficient, especially if
the diagnostic location table is missing. Existing observation/facet/location
checks and imported-fit identity handling remain in place.

| Shared check site | Routes covered by the repair |
| --- | --- |
| `summary.mfrm_fit()` | Lightweight and comprehensive summaries with explicitly supplied diagnostics. |
| `precision_review_report()` / `reporting_checklist()` | Precision profiles, checks, reporting readiness and their derived summaries. |
| `build_apa_reporting_contract()` | APA builder and its narrative, caption and note helpers. |
| `apa_table()` | Supplied diagnostics are checked before selecting a table; custom metadata and FACETS styling do not disable validation. |
| `compute_se_for_plot()` | Native/FACETS Wright maps, unified Wright maps, and fit-plot routes using supplied diagnostics, even when interval drawing is disabled. |
| `build_visual_summaries()` | Combined warning/summary text before plot payload construction. |
| `resolve_mfrm_export_context()` | Fit-level manifests, replay scripts and export bundles. |

No fitting kernel, optimization rule, SE calculation, interval formula or
GPCM/JML eligibility criterion was changed. The
[reporting guide](../../man/mfrmr_reporting_and_apa.Rd) now explains that a
refit must be paired with newly computed diagnostics.

## Verification design and bounded results

The [regression test](../../tests/testthat/test-estimator-output-identity.R)
uses one example dataset and eight fitted configurations: MML/JML crossed
with RSM, PCM, Criterion-owned GPCM and Rater-owned GPCM. Each GPCM has its
step owner equal to its slope owner, as required by the current API. These
are deterministic integration cases, not independent parameter-recovery
replications.

- Matching fit/diagnostics pairs survive an RDS save/load round trip. The
  precision profile remains unchanged, APA estimates preserve their numeric
  values and interval-eligibility flags, and the results/report chain retains
  estimator-specific formal-precision support. The two MML RSM/PCM controls
  retain their existing eligibility; JML stays exploratory and free GPCM
  slope SE/CI remain ineligible.
- Sixteen public reporting/plot/export-preparation routes refuse each of seven
  wrong model/estimator pairings with MML RSM diagnostics: 112 refusals. The
  reverse MML-fit/JML-diagnostics direction is checked separately.
- All sixteen routes refuse diagnostics missing current readiness. Separate
  probes check missing location tables and mismatched readiness states.
- The new test has **187 passing expectations**. The first test draft compared
  numeric-vector names as well as values; eight assertions failed because APA
  data-frame conversion drops those names. The corrected assertions compare
  numeric values without those incidental names. Production code was not
  changed to make this test pass.
- Recomputing the complete MML and JML RSM diagnostics from the pre-repair saved
  fits gives **identical objects** to their pre-repair diagnostics. This is a
  same-fit replay, not a claim of repeated-fit or cross-platform equality.
- The three changed help pages pass Rd parsing/checks. Related tests and the
  current package checkpoint are detailed in the retained execution results.

The final selected regression status is **13 files, 3,003 passing expectations,
zero failures, errors, warnings or skips**. This uses the latest result for
each file: eleven files passed in the initial run; the two affected files were
rerun after their compatibility-test updates. It is not the sum of both runs
and is not the complete package test suite.

The initial 13-file regression run found two expected compatibility-test
updates. One test deliberately removed fit readiness while continuing to
supply the previous diagnostic readiness; it now verifies that this stale pair
is rejected and that freshly computed diagnostics still allow the manifest to
record `legacy_unknown` without claiming inference. The other test expected
APA's old type-error wording; the shared validator now rejects that invalid
input earlier. Initial failures and the focused rerun are retained separately.

## Retained artifacts and source applicability

The [audit bundle](../../validation-results/estimator-output-identity-20260914)
retains the before-repair probe and results, saved example fits/diagnostics,
pre-repair source copies, task-local patches, the new test, initial and final
test logs/tables, same-fit numerical replay, build/check logs, package/source
hashes and a SHA-256 manifest. The initial source is the local working tree
following the integrated ledger; unrelated in-progress changes are preserved.
`internal-roadmap-0.2.3.md` is unchanged by this work.

The earlier tarball `1ad565ec...` and the integrated ledger's 983 passing
expectations describe the preceding source. They are not relabelled as checks
of this repair. The initial and follow-up test runs are also not added together
as if they were independent validations.

The new tarball is `mfrmr_0.2.4.9000.tar.gz`, SHA-256
`25e9c5233d47518156a0068ac01f4fe2df86384d0e07fa04a2f036b5de1d68a9`.
Its 317 R/compiled-source/help files and 171 packaged test/helper files are
byte-identical to current source, as are `NAMESPACE` and `NEWS.md`. Vignettes
were built successfully; the final candidate then incorporated the last
test-only error-message update while reusing those completed vignette outputs.
The candidate reconciliation and per-file comparisons are retained.

On macOS Tahoe 26.6.2, R 4.6.1 arm64,
`NOT_CRAN=false R CMD check --no-manual` finishes with **Status: OK**, including
example checks and rebuilding vignette outputs. Its light test selection has
673 passing expectations, zero failures/warnings and three intended skips.
These overlap other test selections and are not added to the 3,003 count.
This is a local source checkpoint, not a new five-platform or full-suite run.

## What this closes and what remains

This closes the reproduced mixed-diagnostics defect for the stated connected
routes. It advances C03/C04/C05/C17 output restrictions while leaving their
broader numerical and statistical claims open. The identity check uses stored
readiness and structural data; it is not a cryptographic authentication of an
arbitrarily edited R object. Standalone, already assembled reporting bundles
and all other secondary diagnostics still require their own source/claim
review; this record does not declare every exported entry point audited.

Full-model GPCM calculations, estimator-specific JML recovery/uncertainty,
finite-sample decision calibration, paired linking uncertainty and the pending
FairZ/population-parameter confirmations retain the dispositions in the ledger.
No large confirmation was launched. Final release-source and cross-platform
review remain separate work after retained claims and restrictions close.
