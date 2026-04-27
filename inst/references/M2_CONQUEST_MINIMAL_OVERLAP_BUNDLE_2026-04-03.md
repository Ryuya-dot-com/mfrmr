# M2 ConQuest Minimal Overlap Bundle

Date: 2026-04-03

## Purpose

This note documents the scope and intended use of
`build_conquest_overlap_bundle()`, `normalize_conquest_overlap_files()`,
`normalize_conquest_overlap_tables()`, and `audit_conquest_overlap()`.

The goal is not to automate ConQuest generally. The goal is to export one
strictly limited comparison case where:

- the current `mfrmr` implementation is already in scope,
- the overlap is consistent with the ConQuest official materials,
- and the resulting external comparison does not overstate software parity.

## Official source basis

Primary official references:

- ACER ConQuest Tutorial: <https://conquestmanual.acer.org/s2-00.html>
- ACER ConQuest Technical Matters: <https://conquestmanual.acer.org/s3-00.html>
- ACER ConQuest Command Reference: <https://conquestmanual.acer.org/s4-00.html>

Primary methodological anchors:

- Bock and Aitkin (1981)
- Mislevy (1991)

These sources support the narrow template structure used by the bundle:

- CSV-style data import,
- `regression` for person covariates,
- `model item` for the binary item-only case,
- and case-level EAP summaries from the fitted population model.

## Implemented scope

`build_conquest_overlap_bundle()` currently supports only:

- binary responses,
- exactly one non-person facet,
- ordered-response `RSM` / `PCM` within that binary item-only surface,
- `MML`,
- an active latent-regression population model,
- exactly one numeric person covariate beyond the intercept,
- and a complete person-by-item response matrix.

This is the smallest external-comparison case that stays inside the current
documented ConQuest overlap boundary.

## Bundle contents

The helper exports:

- a long-format binary response table,
- a wide CSV tailored to the minimal ConQuest template,
- a one-row-per-person covariate table,
- an item-map table from exported response columns to original facet levels,
- `mfrmr` population estimates,
- centered item estimates,
- fitted-person EAP summaries,
- and a ConQuest command template.

## Audit workflow

`normalize_conquest_overlap_files()`, `normalize_conquest_overlap_tables()`,
and `audit_conquest_overlap()` are the companion helpers for this bundle.

The intended split is:

- `normalize_conquest_overlap_files()` reads extracted CSV/TSV/TXT files into
  the same audit contract;
- `normalize_conquest_overlap_tables()` standardizes extracted tables to the
  audit contract;
- `audit_conquest_overlap()` compares those normalized tables against the
  bundle.

The workflow still expects already extracted ConQuest output tables rather
than raw ConQuest text, and it compares:

- population parameters directly,
- item estimates after centering,
- and case EAP summaries directly.

This split is deliberate. The bundle defines the exact-overlap comparison
contract. The file-wrapper and normalization helpers standardize extracted
external tables, and the audit helper checks whether those tables satisfy the
contract. None of these helpers, by itself, justifies a parity claim.

The current auto-alias support is intentionally conservative. In particular,
the case-level aliases are anchored in the official `show cases` description,
which documents `Sequence ID`, `PID`, and `EAP_1` for the one-dimensional
latent/EAP output structure. If multiple plausible columns are present, the
helpers stop and require explicit column names rather than guessing.

Item estimates can be matched against either the exported response variable
names or the original item/facet levels. With `item_id_source = "auto"`,
`audit_conquest_overlap()` chooses the larger overlap and resolves ties toward
the exported response-variable names. If the user explicitly requests the wrong
source, the audit reports missing comparison rows as attention items rather than
silently switching the contract.

## Package-native dry-run benchmark

`reference_case_benchmark(cases = "synthetic_conquest_overlap_dry_run")` now
uses this bundle and the normalization/audit helpers as an internal regression
harness. It copies the package-native population, item, and case-EAP tables into
the normalized ConQuest-table contract and verifies that the audit surface
round-trips cleanly.

This dry run is useful for checking the `mfrmr` export/audit contract before
external tables are available. It is not a substitute for executing ConQuest and
auditing real extracted ConQuest output.

## Why the command is called a template

The generated ConQuest text is intentionally described as a **template** rather
than as a guaranteed automation artifact.

That wording is deliberate because:

- the package has not executed ConQuest itself,
- local ConQuest versions and output routing may differ,
- and the roadmap explicitly avoids stronger equivalence claims than the
  evidence can support.

## Comparison rules

- Compare the numeric regression slope directly.
- Compare `sigma2` directly.
- Compare the intercept only if the external run uses the same location
  convention for item centering.
- Compare item estimates after centering.
- Compare case EAP values as posterior summaries under the fitted population
  model.

## What this note does not justify

These helpers do not justify claims that:

- `mfrmr` is equivalent to ConQuest,
- `mfrmr` reproduces the ConQuest latent-regression feature set,
- or the generated command template is a universal ConQuest automation script.
