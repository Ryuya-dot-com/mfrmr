# Draft.83d1 G-theory ADEMP registry and denominator record

Date: 2026-08-09
Scope: repository-only pre-simulation registry and denominator audit
Result: Draft.83d1 schema gate passed; no simulation or recovery gate run

## Outcome

Draft.83d1 converts the requested broad G-theory stress portfolio into a
machine-checkable pre-simulation contract. It registers 24 scenarios, 20
metrics, 480 scenario-metric routes, and an 89-unit one-replicate smoke
manifest. The registry hash is:

`9961558027b79fcc755696b7b7d15ecd629a91e6ac7380386e2f5a69a9f5ff8e`.

Nine focused tests and 77 expectations pass with no warning, skip, failure, or
error. These tests validate registry semantics and denominator mechanics only.
No dataset was generated and no model was fitted by Draft.83d1.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| digest | 0.6.39 |

Draft.83d1 uses the Draft.81 SHA-256 identity helper. It does not add a package
dependency or change the public API.

## Frozen registry counts

| Object | Count |
| --- | ---: |
| Requested/design factors | 13 |
| Scenarios | 24 |
| Metrics | 20 |
| Scenario-metric routes | 480 |
| Executable smoke fit units | 89 |
| Blocked anchor scenarios | 2 |
| Smoke replicates per executable scenario | 1 |
| Frozen pilot or confirmation replicates | 0 |

The 24 scenarios are a semantically constrained covering design, not a full
factorial. They contain nine exact-Gaussian cells, four missingness-sensitivity
cells, three bounded observed-score projection cells, two local-dependence
reference cells, two boundary cells, two identification-negative cells, and
two blocked anchor cells.

## Important adjudications

### Category count and endpoint concentration

Three-, five-, and seven-category cells use a complete finite-potential-table
observed-score projection. They do not compare fitted observed-score
components to latent Gaussian generating variances. Endpoint concentration is
therefore a bounded-score sensitivity factor, not a hidden change to the exact
Gaussian recovery target.

### Local dependence

Residual correlations 0.25 and 0.50 are registered as independence-model
reference deviations. They cannot contribute ordinary component bias/RMSE
under the exact-recovery label because the fitted covariance family is then
misspecified.

### Anchor rate

Nonzero anchor-rate cells are registered but blocked. The current Gaussian
random-intercept G-study has no anchor operation, latent scale, or transport
uncertainty contract. `MethodSet=none` prevents these rows from entering the
89-unit execution manifest.

### Facet separation

The requested facet-separation evaluation is split into facet-level rank
correlation, centered level-effect RMSE, and a G-theory effect-recovery ratio.
The last is explicitly labelled as not Rasch/FACETS separation.

### Coverage

All component, G, and Phi coverage routes remain unavailable before Draft.84.
Draft.83c1/c2 point fits do not supply a validated interval. The registry
therefore cannot manufacture coverage from a backend standard error.

## Denominator fixture

The frozen four-unit negative-control fixture contains one deliberately false-
ready result, one pre-fit failure, one backend-return failure, and one boundary
failure. The denominator audit reports:

| Quantity | Result |
| --- | ---: |
| Planned units | 4 |
| Recorded results | 4 |
| Fit attempted | 3 |
| Fit returned | 2 |
| Optimizer converged | 2 |
| Point-estimation gate passed | 1 |
| Typed failed cells | 3 |
| Fit-return rate | 2/3 |
| Optimizer-convergence rate | 2/3 |
| Estimation-gate rate | 1/4 |
| False-ready rate | 1/4 |
| Exact accounting | TRUE |

This fixture is not a substantive result. It proves that the accounting code
detects rather than hides false readiness. Removing the fourth row produces
`UnrecordedCount=1` and `ExactAccountingPassed=FALSE`; an unrecorded row is not
silently relabelled as a typed failure. Invalid stage ordering and changed
registry hashes are rejected before aggregation.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-ademp-registry-prototype-0.2.3.R` | `a7d9dde6882d5207d9b6f1646ebce9c405e4aac0d34839a8a034e202fd9ac4cc` |
| `gtheory-ademp-registry-contract-0.2.3.md` | `31c8335bb31bb390bfc1693ba918be9c3754875ce56a385f06f6c26fb676c828` |
| `test-gtheory-ademp-registry-prototype.R` | `ceb25ad36329048454c13e0184a08869004912247907e44941423919b2825c62` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

`SimulationExecuted`, `RecoveryEvidenceReady`, `InferenceReady`,
`CoefficientEligible`, and `DecisionReady` are all false. Checklist status
remains `review`; no formula family, estimator, sample-size rule, coefficient,
interval, or public claim is promoted.

Draft.83d2 should implement generator and assignment identities, full-
potential projection truth, missingness and local-dependence mechanisms,
backend adapters, conditional-effect extraction, and atomic result rows for
the one-replicate smoke manifest. A subsequent feasibility pilot must set
replication counts from precision criteria without using its own results as
confirmation. Draft.84 remains responsible for interval coverage.
