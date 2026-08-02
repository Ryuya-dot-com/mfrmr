# FACETS JML stress-validation plan for mfrmr 0.2.3

Status: `0.2.3-draft.17` planning artifact; confirmation is not authorized.

This plan is subordinate to the repository-root `ROADMAP.md` and the frozen
release-gate specification. It defines how the locally available proprietary
FACETS installation will be used as an external JML implementation without
treating FACETS as ground truth or making it a package/runtime dependency.

## Critical premise

The purpose of this lane is not to show that mfrmr reproduces every FACETS
number. The purpose is to separate four questions that are otherwise easily
confounded:

1. Does each implementation recover the known generating values under its
   stated estimator and finite-sample behavior?
2. When both programs fit the same JML RSM/PCM estimand, do transformed common
   parameters agree within a pilot-frozen tolerance?
3. When they differ, can the difference be assigned to parameterization,
   identification, extreme-score treatment, fit/SE definition, stopping rule,
   or an unresolved implementation discrepancy?
4. Does mfrmr classify unsupported, disconnected, or weakly identified cases
   conservatively rather than turning optimizer completion into a support
   claim?

FACETS JMLE is therefore the primary external comparator for matched mfrmr JML
RSM/PCM rows. It is not an external target for mfrmr MML EAP Person summaries.
MML RSM/PCM comparison remains a TAM/ConQuest lane. Bounded GPCM remains a
truth/reduction and genuinely matched-GPCM lane; FACETS evidence must not be
used to imply general GPCM equivalence.

Passing this synthetic lane establishes only the declared computational and
statistical operating characteristics. It does not establish construct
validity, fairness, consequential validity, population transportability, or
suitability for an operational high-stakes decision; those require separate
domain evidence.

## External-tool qualification

The 2026-08-03 environment audit found three different identities:

| Evidence | Observed identity | Status |
| --- | --- | --- |
| Official FACETS page | FACETS 4.5.1, July 2026 | Current upstream reference; not yet locally qualified |
| Local `Facets.exe` file metadata | File version 4.5.0; SHA-256 `dfb0afb0faa18f026d1b3b4175f22e42cc3764430eb83cbd368c7a572b3593a1` | Available, but no fresh report-header qualification run is yet bound to 0.2.3 |
| Retained 2026-05-07 RSM/PCM reports | Report header FACETS 4.4.5 | Historical workflow evidence only; not 0.2.3 release evidence |

The confirmation default is a locally installed and qualified copy of the
current upstream FACETS release. If that version is unavailable, the frozen
gate must name the older version, explain the limitation, and narrow the
claim. No pilot or confirmation result may combine output from different
FACETS versions under one external-program identity.

`EXT-FACETS-QUALIFY` must complete before simulation pilots:

- run deterministic binary, RSM, and PCM microcases in batch mode;
- capture the executable SHA-256, file metadata, report-header version, command
  schema, control/data/output hashes, run date, locale, and parser version;
- verify that the echoed model, facet count, category support, observations,
  anchors, output tables, and element counts match the generated specification;
- treat a zero process return code without the expected report and score-file
  structure as failure;
- retain raw proprietary-program output outside the package and public source
  tarball, with normalized synthetic aggregates and hashes in repository
  evidence; and
- repeat qualification after any binary, parser, control-template, locale, or
  operating-system change.

File-version metadata alone is insufficient: the report header is the runtime
identity. Existing reports containing local absolute paths or identifiers must
not be copied into public package evidence.

## Scenario registry

| Scenario family | Required role | Scope |
| --- | --- | --- |
| `EXT-FACETS-QUALIFY` | structural blocker | Binary/RSM and PCM microcases; binary/report/parser identity |
| `EXT-FACETS-RSM-CORE` | pilot then confirmation blocker | Connected matched JML RSM recovery and common-parameter comparison |
| `EXT-FACETS-PCM-CORE` | pilot then confirmation blocker | Connected matched JML PCM recovery, criterion/item-specific steps, and common-parameter comparison |
| `EXT-FACETS-ANCHOR` | pilot then confirmation blocker | Matched element and group-anchor cases already supported by 0.2.2; no threshold anchors |
| `EXT-FACETS-SPARSE` | pilot then confirmation blocker | Connected sparse, weak-bridge, articulation, and deliberately disconnected controls |
| `EXT-FACETS-EDGE` | pilot then confirmation blocker | Extreme scores, rare/unused categories, severity dispersion, nesting/confounding, and nonrandom missingness |
| `EXT-FACETS-DFF` | pilot/sensitivity; blocker only for a promoted row | Null and non-null matched interaction cases where the parameterization is demonstrably common |

Every cell receives an ADEMP record: aim, data-generating mechanism, estimand,
fitted method, and performance measure. Scenario and replicate IDs, seeds,
category maps, missingness maps, topology fingerprints, parameter transforms,
and expected support states are immutable after candidate freeze.

## Design architecture

An indiscriminate Cartesian product would spend large compute budgets while
leaving each interaction poorly replicated. The design therefore uses:

1. deterministic reduction and negative-control microcases;
2. a balanced reference cell for each RSM/PCM and three-/four-facet structure;
3. one-factor stress contrasts around the reference cell;
4. prespecified two-factor interactions where confounding is scientifically
   plausible, especially sparsity by severity dispersion, category support by
   sample size, and DFF by assignment structure; and
5. extended sensitivity cells that cannot compensate for a failed core cell.

Pilot starting values below are planning values, not frozen criteria:

| Axis | Pilot levels or structures |
| --- | --- |
| Persons | 100, 300, 1000 |
| Raters | 5, 20, 50 |
| Tasks | 3, 8 |
| Criteria/items | 4, 10 |
| Score categories | 2, 4, 7 with balanced, skewed, rare-boundary, and unused-category support |
| Assignment density | complete, approximately 30%, approximately 10% with topology recorded separately |
| Graph topology | well connected, weak bridge, articulation, zero-common-Person pair, disconnected |
| Severity SD | approximately 0.25, 0.75, 1.50 logits |
| Anchor pattern | none, approximately 20%, approximately 50%; individual and group anchors remain separate |
| Extreme-score prevalence | none, moderate, high, with each program's adjustment/exclusion policy recorded |
| DFF magnitude | null, approximately 0.5, approximately 1.0 logit where a common interaction is available |
| Missingness | planned-by-design, conditionally nonrandom, and confounded/nested stress |

The M2 pilot may change these values only through a new draft revision. The
frozen specification must select the core cells and the replication count by
a Monte Carlo standard-error target, not by runtime convenience or by stopping
when a desired conclusion appears.

## Estimands and transformations

Before any numeric comparison, each scenario record must define:

- Person, rater, task, criterion/item, and step orientation;
- centering/noncentering and positive-direction rules;
- category numbering and threshold parameterization;
- element and group-anchor values and the scale on which they are supplied;
- extreme-score and unused-category handling;
- the free and expanded parameter vectors and the transformation between
  engine-native and common coordinates; and
- which SE, fit, fair-average, or interaction statistic is genuinely common.

RSM/PCM element and estimated-step parameters enter the mandatory common
coordinate comparison. Person measures enter only matched JML rows and are
reported separately from mfrmr's recommended MML/EAP workflow. Fit statistics,
ZSTD, fair averages, and DFF enter numeric gates only after their formulas,
degrees-of-freedom conventions, and conditioning units are shown to match;
otherwise they remain convention-aware descriptive comparisons.

## Performance measures

Each engine is evaluated against simulation truth before engines are compared
with one another. Minimum per-cell output is:

- signed bias, absolute bias, RMSE, and empirical SD by parameter class;
- mean reported SE, SE availability, and interval coverage where the interval
  definition is supported;
- numerical success, inference-ready rate, boundary/extreme adjustment rate,
  warning class, and false-ready rate;
- signed and absolute mfrmr-minus-FACETS differences after the frozen
  transformation, including median, high quantile, and maximum rather than a
  pooled correlation alone;
- category/anchor/topology classification accuracy;
- null false-positive and non-null detection behavior for any promoted DFF
  row; and
- elapsed time and peak-memory context as descriptive evidence, not a feature
  race with FACETS.

Correlation is descriptive only. A high correlation cannot pass a row with a
material location/scale error, a hidden failed cell, or incorrect readiness.
FACETS finite-sample JMLE bias is not treated as mfrmr's target: known truth
and the matched estimand decide how a disagreement is interpreted.

## Batch execution and evidence contract

FACETS runs outside CRAN tests and outside the installed package. The runner
must:

- use synthetic or explicitly public inputs for retained evidence;
- isolate every scenario/replicate in its own output and temporary directory;
- default to one FACETS process unless the license and executable behavior
  explicitly permit more;
- impose and record a timeout without killing unrelated FACETS sessions;
- retain the exact generated control and data hashes, stdout/stderr, report,
  score files, warnings, return code, parser diagnostics, and expected-versus-
  observed schema checks;
- refuse mixed RSM/PCM output directories and stale output reuse;
- distinguish program failure, parser failure, model nonconvergence,
  unidentified design, and mfrmr/FACETS disagreement; and
- aggregate only after verifying the full expected replicate registry so that
  failed or missing runs cannot disappear from summaries.

The existing workspace batch runner is useful scaffolding but is not itself a
0.2.3 gate. It currently centers on FACETS-only truth summaries and legacy
case outputs; it must be adapted or replaced with a repository-owned,
candidate-bound scenario generator, mfrmr paired runner, strict parser, and
manifest before confirmation.

## Promotion and support-envelope rules

The final 0.2.3 result is a machine-readable support envelope, not a blanket
accuracy statement. At minimum it records model, estimator, parameter class,
design envelope, recovery status, external comparator, external-tool identity,
operational status, caveat, and evidence hash.

A row may be labelled `validated_within_envelope` only when internal recovery,
negative controls, and applicable matched external evidence all pass for the
same candidate. Otherwise it remains one of `supported_with_caveat`,
`exploratory`, `blocked`, `deferred`, or `unsupported`. The evidence registry
may feed documentation, but it does not require a new exported API in 0.2.3.

The expected boundary before confirmation is deliberately conservative:

- RSM/PCM MML: validation candidate through recovery plus TAM/ConQuest;
- RSM/PCM JML: validation candidate through recovery plus FACETS;
- bounded GPCM: provisional until its own recovery and genuinely matched
  external contract pass;
- DFF: screening/exploratory unless null and non-null operating
  characteristics pass for a named design envelope; and
- frozen calibration, threshold anchors, multiple scales, and native
  multidimensional estimation: unsupported in 0.2.3.

## M2 implementation order

1. Qualify one pinned FACETS version and freeze the parser/report schema.
2. Extract a deterministic RSM/PCM microcase suite and verify parameter
   orientation, constraints, score files, and error classification.
3. Build the shared simulation specification and paired mfrmr/FACETS runner.
4. Pilot connected core, anchor, sparse/topology, edge, and DFF-sensitivity
   families without release decisions.
5. Use pilot-only results to freeze scenario values, replication/MCSE rules,
   transformation maps, tolerances, and failed-run policy in a new frozen gate
   identity.
6. Run confirmation once on disjoint seeds and one exact package candidate.

Any change to the FACETS binary, report parser, data/control generator,
parameter transformation, scenario grid, tolerance, or failed-replicate rule
after freeze invalidates the corresponding confirmation evidence.

## Sources used for scope

- CRAN mfrmr page: <https://cran.r-project.org/web/packages/mfrmr/index.html>
- FACETS official product/features page: <https://www.winsteps.com/facets.htm>
- CRAN TAM page: <https://cran.r-project.org/web/packages/TAM/index.html>

These sources establish current distribution and advertised software scope;
they do not substitute for candidate-linked empirical validation.
