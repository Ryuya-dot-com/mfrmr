# Model and assignment plot review — 2026-09-10

This follow-up to the [dataset/device review](plot-generality-record-0.2.4.md)
checks whether native and ggplot displays retain the intended model meaning
with GPCM, incomplete assignments, missing scores, and fitted interactions.
It found missing/truncated explanations and a replay-file location failure.
This is a rendering and workflow review, not a recovery simulation or a new
TAM, standard-error, or inference-validation result.

## Design

The [runner](plot-models-0.2.4.R) generates four datasets and fits six models:

| Model | Step/slope owner | Estimator | Fitted interaction |
| --- | --- | --- | --- |
| GPCM | Criterion | JML | None |
| GPCM | Criterion | MML | None |
| GPCM | Rater | JML | None |
| GPCM | Rater | MML | None |
| RSM | Common steps | MML | Rater × Criterion |
| PCM | Criterion steps | MML | Rater × Criterion |

Each dataset has 60 persons, four raters, four items, and scores 1–4. Each
person is assigned two raters on a rotating schedule. Of 480 assigned response
rows, every seventh score is replaced with `NA`: 68 missing scores and 412
retained rows. These are deliberate, connected incomplete designs, not a
general missing-data experiment. Seeds are 9511, 9512, 9521, and 9522.

The GPCM generator receives relative slopes `c(0.6, 0.85, 1.2, 1.6)`, which
it normalizes under its documented identification. Both step and slope owners
are the same designated facet. The RSM/PCM generators add balanced effects
of ±0.8 in the R01/R02 × C01/C02 cells; fitted interaction tables contain
16 cells. GPCM with fitted facet interactions remains unsupported and was
not combined with these interaction fits.

All fits use `maxit = 30`; MML uses 11 quadrature points and GPCM's default
free-population identification. The [fit review](plot-models-0.2.4/fit-review.csv)
records two blocked JML fixtures and four review-only MML fixtures. These
short fits are rendering inputs, not approved substantive results. Their
warnings and review labels are retained, not treated as evidence of estimator
performance. See [conditions](plot-models-0.2.4/conditions.csv),
[fits](plot-models-0.2.4/fits.rds), and
[fit warnings](plot-models-0.2.4/fit-warnings.rds).

## Repairs

1. **Pathway conditioning was missing from the figure.** Expected-score
   pathways and CCCs use fitted thresholds and GPCM slopes with additive
   facet effects and fitted interactions fixed at zero. CCCs already stated
   this; pathways did not. They now share a `curve_basis` table, including in
   plot bundles. Native pathways reserve space for the note; ggplot pathways
   disclose it in their subtitle. These curves are not averages over observed
   rater assignments or predictions for a particular interaction cell.
2. **ggplot explanations were clipped and blank captions printed `NA`.**
   The shared label helper now wraps text at 72 columns, retains explicit
   line breaks, and returns `NULL` for absent labels. Original payload text
   remains available; `ggplot2::labs()` can override the display for narrower
   exports. This is a fixed wrapping convention, not automatic device fitting.
3. **Repeated CCC legends covered curves.** Multi-group native CCCs now use
   a common margin legend even with five or fewer categories. Single-group
   CCCs retain their existing small-category legend behavior.
4. **Nested replay chose the outer script's directory.** A GPCM integration
   test run through an Rscript driver failed to read its person-data CSV.
   Generated replay code preferred the outer `--file` argument, or the first
   source frame, over the replay script itself. It now uses the innermost
   `source()`/`sys.source()` frame, accounts for `chdir`, and uses `--file`
   for standalone execution. The regression executes the generated CSV-loading
   block standalone and through both source functions with `chdir = FALSE`
   and `TRUE`; the complete GPCM export/replay integration also passes.

## Evidence

Six fits × three plots (Wright/pathway/CCC) × two renderers (base/ggplot) ×
two sizes (7 × 5 and 12 × 8 inches) produced **72 PNG drawings without
errors**, using macOS Quartz at 110 dpi. The [drawing log](plot-models-0.2.4/drawings.csv)
retains readiness warnings. Four additional base-PDF exports at 7 × 5 inches
were rendered with `pdftoppm` and visually inspected. Selected examples follow;
the 72 drawings were not subjected to a comprehensive geometry/collision audit.

| Example | Native PDF | ggplot PDF |
| --- | --- | --- |
| GPCM with rater slopes, MML | [PDF](plot-models-0.2.4/GPCM-Rater-MML-ccc-base.pdf) · [Preview](plot-models-0.2.4/GPCM-Rater-MML-ccc-base-preview.png) | [PDF](plot-models-0.2.4/GPCM-Rater-MML-ccc-ggplot.pdf) · [Preview](plot-models-0.2.4/GPCM-Rater-MML-ccc-ggplot-preview.png) |
| PCM with fitted interactions | [PDF](plot-models-0.2.4/PCM-interaction-MML-pathway-base.pdf) · [Preview](plot-models-0.2.4/PCM-interaction-MML-pathway-base-preview.png) | [PDF](plot-models-0.2.4/PCM-interaction-MML-pathway-ggplot.pdf) · [Preview](plot-models-0.2.4/PCM-interaction-MML-pathway-ggplot-preview.png) |

The pre-change [clipped subtitle/NA caption](plot-models-0.2.4/before-GPCM-Rater-MML-ccc-ggplot-7x5.png)
and [missing pathway condition](plot-models-0.2.4/before-PCM-interaction-MML-pathway-base-7x5.png)
are retained as defect evidence.

Independent R calculations reconstruct normalized category probabilities from
the fitted thresholds and slope using `a * (k * theta - cumulative_threshold)`.
They compute expected scores and information directly from those probabilities,
without calling the package probability kernel. Across all six fits, maximum
absolute discrepancies are **6.99e-15** for probabilities, **2.80e-14** for
expected scores, and **2.61e-12** for information. Information uses subtraction
of score moments and multiplication by squared slopes, magnifying roundoff;
the check allows 1e-10 for information and 1e-12 for probabilities/moments.
See [curve checks](plot-models-0.2.4/curve-checks.csv).

All six before/after comparisons preserve category probability tables,
expected-score tables, and complete Wright payloads exactly. The pathway's
new metadata/subtitle and renderer formatting are intentional changes. The
[comparison results](plot-models-0.2.4/numerical-comparison.csv) and
[paired payloads](plot-models-0.2.4/payload-comparison.rds) retain the evidence.

The [focused results](plot-models-0.2.4/tests.csv) contain **1,547 successful
expectations in 161 blocks across nine files**, with no failures, errors,
unexpected warnings, or skips. The [plot/model test log](plot-models-0.2.4/tests.log)
and [export test log](plot-models-0.2.4/export-tests.log) are archived.

## Reproduction and limits

From the package root:

```sh
Rscript inst/validation/plot-models-0.2.4.R /tmp/mfrmr-plot-models
```

For the focused tests, set `Sys.setenv(NOT_CRAN = "true")`, load the source
with `pkgload::load_all(".")`, and run `testthat::test_file()` on the nine
files named in `tests.csv` under `tests/testthat/test-<File>.R`. Tests were
executed both through an Rscript driver for the eight plot/model files and
through `Rscript -e` for the export file.

The [source hashes](plot-models-0.2.4/source-md5.csv),
[session information](plot-models-0.2.4/session-info.txt), and
[execution log](plot-models-0.2.4/execution.log) identify this source revision.
Only selected inspected figures are archived; the runner regenerates the full
grid. Earlier plot and simulation archives remain unchanged.

Cross-platform rendering, Japanese ggplot labels, extremely dense ggplot
layouts, other missingness mechanisms, and broader DRF designs remain open.
ggplot's existing overlap checks may suppress dense annotation labels; this
pass does not establish label completeness for arbitrary data. No full package
check, release approval, estimator comparison, or new inference permission
is implied by these rendering and replay results.
