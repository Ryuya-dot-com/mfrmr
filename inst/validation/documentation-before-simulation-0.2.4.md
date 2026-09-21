# Documentation audit before simulation - 2026-09-10

**Status:** documentation corrections and non-fitting checks complete.
The user paused numerical execution. FairZ confirmation remains **0/20,000**;
no simulation, preflight, model refit, or executable analysis example ran in
this audit. The separate population confirmation also remains unrun.

## Findings and corrections

| Surface | Correction and reason |
| --- | --- |
| [README](../../README.md) | Identify the development version; state the portable-calibration example's required objects; replace the stale GPCM-only quadrature lead-in with the actual general MML call. |
| README and GPCM vignette | Free-slope SE/CI eligibility is currently false. Convergence and grid stability do not make ordinary slope inference available. Non-unit observation weights also retain ordinary-inference restrictions. |
| Fair-average help, README, visual and GPCM guides | Distinguish the RSM/PCM focal-measure plot interval from the GPCM-MML structural table/plot interval. The table's `fair_se` option does not supply RSM/PCM score SEs. Both routes remain diagnostic-only; full-refit coverage is unverified. |
| Fair-average help and examples | Explain mean/zero references, FairZ as an expected score rather than a z-score, assignment/person-mix effects on gaps, and the fixed observed mean in gap whiskers. Export data.frames with `write.csv`; a fair-average bundle is not an accepted `export_summary_appendix` input. |
| Visual help and vignette | Add clean-figure examples with `show_title`, `show_notes`, returned notes, and optional ggplot conversion. Describe six line types / fair-score point shapes and their repetition limits; do not imply every helper accepts these controls. |
| Linking help and vignette | Refit DFF remains screening-only even with adequate linking, because baseline-anchor uncertainty and cross-refit covariance are omitted. Clarify the default five anchored levels **in total across linking facets per subgroup**, the status columns, and population/interaction/group-anchor replay refusals. This count is not a universal design recommendation. |
| [Cheatsheet PDF](../cheatsheet/mfrmr-cheatsheet.pdf) | Synchronize the Fair-score caveat, retain the preceding source changes, prevent code examples from splitting across pages, and keep page numbers inside the page. Six rendered pages inspected. |

The primary comparison is between current implementation and user guidance.
This does not certify every statistical claim in every helper or establish
new external-software equivalence. No inference eligibility or model-fitting
algorithm was changed.

## Checks

- Existing `tests/testthat/test-documentation-terminology.R`: 54 expectations
  passed, no skips or failures; this test file does not fit models.
- All 226 Rd files passed `tools::parse_Rd()` / `tools::checkRd()`.
- All 125 R chunks in README, eight vignettes and the cheatsheet parsed without
  execution. The examples were not evaluated for numerical results.
- 2,358 unqualified help references resolved against local help aliases or
  installed package help; all ten relative README/vignette links existed.
  External websites were not rechecked.
- Static interval and GPCM capability tables retained the diagnostic-only
  contract and table/plot distinction.
- Regenerated three changed Rd pages with roxygen2 using
  `pkgload::load_all(compile = FALSE, helpers = FALSE, attach_testthat = FALSE)`;
  no remaining generation warnings. Rendered those pages to HTML without
  evaluating examples. A preliminary source-only loader produced link/S3
  lookup artifacts; namespace-aware regeneration removed those artifacts.
- Rendered the cheatsheet with `eval = FALSE` and inspected all six PNG pages.
  Full pkgdown/vignette execution and package-wide fitting tests were not run.
- `git diff --check` passed.

## Source identity and restart boundary

The four R files differing from the saved FairZ source manifest are
`R/api-tables.R`, `R/help_linking_and_dff.R`, `R/help_visual_diagnostics.R`, and
`R/help_gpcm_scope.R`. Parsed executable expressions are unchanged in every R
file except the latter two help-table sources, whose user-facing strings were
updated. The fitting and interval-calculation expressions are unchanged.

All 40 files under `fairz-coverage-0.2.4/` retained their start-of-audit MD5s;
there is no confirmation output directory. The recorded preflight remains
valid evidence about its original source, not a matching-source preflight for
the revised tree. The strict runner correctly requires source reconciliation
and a matching preflight when computation is authorized again. Do not edit
saved hashes, replace historical results, or run the main study while this
pause remains active. The [FairZ record](fairz-coverage-record-0.2.4.md) and
active roadmaps now state that pause.
