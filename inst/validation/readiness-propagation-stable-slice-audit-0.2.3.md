# 0.2.3 readiness-propagation stable-slice audit

Status: deterministic retained-core slice, 2026-08-11. This record narrows
row 23 `readiness_scope_and_propagation`; it does not close that row, authorize
confirmation, or promote an unfinished GPCM, interaction, uncertainty, or
legacy-migration claim.

## Decision addressed

The frozen v3 schema is useful only if a fit-level decision remains the same
decision at downstream entry points. The bounded question here is whether
native retained-core RSM/PCM fits can carry one current readiness record from
fit construction through summary, convergence review, `mfrm_results`,
`mfrm_report`, `reporting_checklist`, APA output, manifest, export, and replay
provenance without either of these failures:

1. an optimizer return code silently becoming an inference-ready decision; or
2. a source fit's readiness being copied into a newly replayed fit instead of
   being recomputed.

No Monte Carlo quantity or external-program comparison can answer this
contract question. Deterministic positive and negative cases are the relevant
evidence.

## Implemented boundary

`build_mfrm_manifest()` now exposes three separate source-fit tables:

- `readiness`: the exact one-row v3 fit contract;
- `readiness_components`: input, estimability, category, boundary, and
  numerical component states; and
- `readiness_parameters`: the parameter-scoped table, including its empty
  schema when no parameter class is currently governed.

The manifest summary repeats the contract version, fit state, inference-ready
flag, and reason codes for indexing. `Converged` now records optimizer-code
convergence, while `InferenceReady` records the stricter v3 decision. These
fields are intentionally allowed to disagree.

`build_mfrm_replay_script()` embeds the same three tables under
`source_readiness*`. The generated script fits the model first, obtains
`replay_readiness` from that new fit, compares the fit-level identity fields,
and warns on disagreement. It never assigns the source status to the replayed
fit. `export_mfrm_bundle()` writes both manifest and replay-source readiness
tables as CSV files and includes nonempty readiness tables in the HTML handoff.

`mfrm_results()`, `mfrm_report()`, `reporting_checklist()`, and
`build_apa_outputs()` now retain the same exact fit/component/parameter tables
separately from their workflow or draft-completeness summaries. APA precision
wording is conjunctive: a diagnostic precision flag cannot make formal
inference available when the stored fit readiness is not inference-ready.
`export_mfrm_results()` writes the exact tables through its summary export.

For CSV verification, readiness columns must be read under their schema. In
particular, an empty `ReasonCodes` string means "no blocking reason"; default
`read.csv()` type inference can turn an all-empty character column into
logical `NA`. The regression test therefore reads readiness CSVs with
`colClasses="character"` and a nonempty NA token. This is a serialization
rule, not permission to replace the frozen empty-string contract with a new
sentinel.

The legacy adapter remains fail-closed. In addition to the mutation control,
`mfrm-fit-0.2.2-pcm-jml.rds` is a real fit serialized under the frozen CRAN
0.2.2 tarball. Its old scalar is `InferenceReady=TRUE`, optimizer convergence
is visible, and it contains no v3 readiness object. Current code records
`legacy_unknown`, `InferenceReady=FALSE`, and `legacy_contract_missing` through
summary, results, manifest, and replay provenance.

The repository-only fresh-session validator installs the current 0.2.3 source
into a temporary library and executes the generated replay script. The source
record remains `legacy_unknown/FALSE`; the newly fitted PCM/JML model obtains a
new `ready/TRUE` v3 record; equality is false; and the required mismatch
warning is observed. This is the intended migration: a refit may establish new
readiness, but it cannot retroactively upgrade the saved 0.2.2 object.

## Deterministic evidence

The following checks use installed package code through `devtools::test()` and
small fixed inputs. They run no large simulation and no external engine.

| Surface | Check | Result |
| --- | --- | --- |
| Core fit/summary/convergence/manifest/replay/results | RSM plus PCM JML/MML positive and iteration-limited negative paths, including the real saved-0.2.2 fixture | 93 assertions, 0 failures, 0 warnings |
| Results propagation | iteration-limited MML, disconnected design, population-assumption hold, connected positive, and legacy reconstruction | 74 assertions, 0 failures, 0 warnings |
| Manifest/export/replay regression | exact source tables, legacy fail-closed mapping, generated-script parse, CSV/HTML/bundle writing, and existing export behavior | 881 assertions, 0 failures, 0 warnings |
| Comprehensive results/report/export | exact record through `mfrm_results`, summaries, `mfrm_report`, HTML/table routes, and results CSV export | 337 assertions, 0 failures, 0 warnings |
| Reporting checklist | exact record through checklist and checklist summary without equating draft completeness to inference readiness | 84 assertions, 0 failures, 0 warnings |
| APA/report helpers | exact record plus an adversarial blocked-fit test that forces the diagnostic precision flag to TRUE | 399 assertions, 0 failures, 0 warnings |
| Fresh-session legacy replay | temporary current-source install; source `legacy_unknown/FALSE`, replay `ready/TRUE`, mismatch warning required | pass; no candidate or release promotion |

The PCM positive fixtures use the package default numerical precision contract
(`reltol=1e-9`) and reach `FitReadiness=ready` under both JML and MML. Their
otherwise identical `maxit=1`, `reltol=1e-12` controls terminate at the
iteration ceiling and remain `blocked` with
`optimizer_failed;iteration_limit`.

An intermediate check deliberately exposed why optimizer status must stay
separate: with `reltol=1e-6`, both PCM runs returned optimizer code zero but
had terminal gradients large enough for `FitReadiness=review` and
`InferenceReady=FALSE`. That result was not relabelled as a positive fixture;
the retained positive fixture instead uses the package's actual default
precision contract.

## Bound source identities

These hashes bind this stable-slice record to the audited implementation and
tests. They are development identities, not candidate identities.

| File | SHA-256 |
| --- | --- |
| `R/api-export-bundles.R` | `767e1f72e876643e7a2ebbfe3623b972fc420f94c73a0ea05da16d19baef3201` |
| `R/core-readiness.R` | `58437622f8154310cd7073b0a704c6fc18cce039c62264d27f101b3134fe111f` |
| `R/api-results.R` | `b9e54be7c874a02c0ceed35e8a9d24fe834814b0c8367b22e0dd791e07747226` |
| `R/api-reporting-checklist.R` | `3bfddc8de0942ce2e11d299529739eea477c972e793d989cac1840d19aa807fa` |
| `R/api-reports.R` | `b3112234702a2bbc4f1eeb2dcec4fd1e1d71aa800f7b9d4b95d5b68ad1a085e0` |
| `R/reporting.R` | `1ce710e06bd48091a86c48dacb9e45e828017859cad54405a937c157652b7942` |
| `tests/testthat/test-readiness-propagation.R` | `053ed8836b9ea2a2fbc5103d160485fafb861aa29781557646fe0533428c199b` |
| `tests/testthat/test-results-readiness-propagation.R` | `da8242c7753e2a5ed35da4d32a1141b254772ffd98959e8f9ea936f7d4b290f6` |
| `tests/testthat/test-export-bundles.R` | `329304d2b44dfbc2fb9a5e03f245d6528d907fc6be3582ce765b086fcfe775d1` |
| `tests/testthat/test-mfrm-results.R` | `f04344a2a4b88ad0378a62778f8e7916c6361cd42b7047abfbc7d71e359a4be4` |
| `tests/testthat/test-reporting-checklist.R` | `9fb0cb06061d0571b7f2b56ed558bcb54a4885068eaabf10d75b967af1671c96` |
| `tests/testthat/test-report-functions.R` | `84af6ace12fa894a52d86a770491ba637e93e01f435123bf463f02f0faeeeac0` |
| `tests/testthat/fixtures/mfrm-fit-0.2.2-pcm-jml.rds` | `98e8451d3cfd7d2981619cd406eee116583b259e9f5587ff202e436ef0089cfd` |
| `inst/validation/generate-legacy-0.2.2-fixture.R` | `baff8dc83a9908d33d0d4a1251a3adec354c116bc2fd348995ee01accd967510` |
| `inst/validation/validate-legacy-0.2.2-replay-roundtrip.R` | `662940d5899cae83b67cc6979f8ef4e3aae0298d39e8e51aa9ff995fa4536957` |
| `inst/validation/readiness-contract-0.2.3.R` | `155a3630580d1546b7584d7c02572498e68cbd6a5d1af965533b32bf890d2100` |
| `inst/validation/readiness-contract-fixtures-0.2.3.csv` | `ec921a7912eef4a6509488f50c67a7147437d37709114880044a4a3183bbadfa` |

## Why row 23 remains review

This slice does not satisfy the checklist's full acceptance rule.

- Current parameter readiness is implemented for bounded-GPCM slope rows; a
  complete common parameter/facet/step/interaction readiness schema is not yet
  available for every retained output.
- General GPCM joint-boundary and interaction states still depend on open
  WP1--WP3 mathematics. They cannot inherit RSM/PCM readiness.
- Less central saved/export adapters outside the manifest, results, report,
  checklist, and APA routes have not all been audited for exact field parity.
- The real serialized-0.2.2 and current-development fresh-session round trip
  pass, but they are not bound to the eventual exact 0.2.3 candidate tarball.
- Candidate identity, exact-tarball reproduction, and release confirmation are
  Wave E obligations and remain unauthorized.

Accordingly, row 23 stays `review`. The stable conclusion is narrower: the
retained RSM/PCM fit-level v3 decision and its negative numerical/legacy paths
now have one explicit downstream provenance route through manifest, export,
and replay, without converting optimizer success or source history into
automatic inference readiness.

## Next bounded action

Stop extending this row through lower-priority adapters for now. The central
fit, result, report, checklist, APA, manifest, export, and replay surfaces plus
the real 0.2.2 migration path provide a sufficient retained-core slice. Return
to row 23 only when WP1--WP3 provide a mathematically defined parameter state,
an audited central adapter is discovered to drop the record, or the exact
0.2.3 candidate exists for Wave E replay. Do not start simulation to answer
these identity and propagation questions.
