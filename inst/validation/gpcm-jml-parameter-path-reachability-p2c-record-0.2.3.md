# GPCM JML forward parameter-path reachability P2c record (0.2.3)

## Decision

P2c implements a forward parameter-space reachability contract for the
declared JML GPCM lexicographic paths introduced in P2b. The caller declares
each additive stage in the retained constrained free-parameter coordinates.
The package maps those coordinates through the exact retained sparse
adjacent-utility operator and accumulates the result into category utilities.
The constructed direction is therefore reachable on the retained response
design by construction.

This forward route is deliberate. A numerical inverse projection of an
arbitrary category-utility matrix would require a tolerance. A residual within
that tolerance could still change an exact equality or ordering used by the
P2b lexicographic tie rule. P2c makes no such inverse claim. P2b is invoked only
on category directions produced by the forward operator itself.

Every applicable fit records the operator scope and coordinate map at
`config$boundary_audit$gpcm_parameter_path_reachability`. The fit-level audit
declares and evaluates zero paths. The internal current-fit wrapper requires
the user to provide coordinate directions and scale exponents explicitly; it
does not infer them from optimizer iterations.

## Forward construction

Let `A` be the retained constrained adjacent-utility design with
`N(K-1)` rows and `p` free additive coordinates. Its rows are ordered first by
transition and then by observation, consistently with the retained response
kernel. For declared stage direction `d_g`, define

```text
delta_g = A d_g,
D_g(i,0) = 0,
D_g(i,k) = sum_{m=1}^k delta_g(i,m),  k = 1,...,K-1.
```

The map `d_g -> delta_g -> D_g` includes the actual Person, constrained facet,
interaction, and step-coordinate expansions used by the JML objective.
Anchors, reference coordinates, signs, and sum-zero restrictions therefore
enter through the existing free-coordinate design rather than through a
separate reconstruction.

Category zero is fixed to utility zero. No rowwise shift is needed because the
forward map already uses the package's cumulative-utility gauge. Each stage
must produce at least one nonzero adjacent-category contrast; a free-coordinate
null direction is rejected rather than represented as a fictitious slower
scale.

## Basis transport

For an invertible free-coordinate change `T`, write

```text
A* = A T,
d* = T^{-1} d.
```

Then

```text
A* d* = A T T^{-1} d = A d.
```

The two-coordinate verification fixture confirms that the adjacent and
cumulative category directions agree to `1e-14` after this transformation.
This is a coordinate-equivalence result for a declared path, not a claim that
an optimizer trace selects either representation.

## Current-fit wrapper

`mfrmr_jml_gpcm_fit_parameter_hierarchy_limit()` performs the following
internal sequence for a current `mfrm_fit`:

1. verifies the GPCM/JML estimator and current P2b contract identity;
2. rebuilds indices, free-parameter sizes, the constrained adjacent design,
   expanded parameters, and the retained response kernel;
3. maps caller-declared additive coordinate directions forward;
4. reconstructs base cumulative utilities, observed scores, weights, slope
   indices, and expanded sum-zero base log slopes; and
5. calls the P2b oracle with the declared additive and slope power scales.

The returned P2b object is marked with the P2c reachability contract only after
the forward construction succeeds. Additive reachability and completion of the
whole P2b input contract remain separate: for example, an invalid exponent
vector does not erase an already completed forward reachability certificate.

`mfrmr_jml_gpcm_parameter_hierarchy_loglik_at()` evaluates finite distances on
the same constructed path. It accepts only a completed P2c result and cannot
be used to attach reachability to an arbitrary P2b utility path.

## Production states

The applicable fit-level state is
`retained_additive_parameter_operator_available_no_path_declared`. It records
the sparse operator dimensions, nonzero count, and optimizer-coordinate map,
while the following remain false:

- production parameter-path reachability checked;
- production path limit classified;
- optimizer-trace direction or scale extraction;
- inverse projection;
- path search, monotonicity, or competitiveness;
- common-subsequence or arbitrary-path classification;
- global boundary, finite-maximum, or boundary-absence certification; and
- uncertainty, readiness, or external-comparison eligibility.

The direct forward mapper has typed states for malformed dimensions or sparse
designs, nonfinite or dimension-mismatched coordinate directions, excessive
stages, null utility stages, invalid parameter maps, workload limits, and
controls. The current-fit wrapper separately types invalid/legacy fits,
non-GPCM, MML, unit-slope reduction, P2b source mismatch, retained-design
failure, forward-path failure, and P2b contract failure.

## Verification

Ten focused JML GPCM boundary files pass 932 expectations with zero failures,
skips, warnings, or errors:

| Test surface | Expectations |
| --- | ---: |
| P2c forward parameter-path reachability | 125 |
| P2b declared lexicographic limit | 136 |
| P2a finite-depth rate hierarchy | 135 |
| P1z boundary compactification | 107 |
| P1y asymptotically-affine transport | 60 |
| P1x general constant-rate boundary | 54 |
| JML GPCM joint boundary | 74 |
| P1v/v2 fixed-objective classifier | 60 |
| P1w terminal-gradient stability | 83 |
| JML GPCM slope-only boundary | 98 |

The P2c file covers two-stage forward mapping, exact cumulative construction,
coordinate metadata, invertible basis transport, empty additive paths, null
directions, malformed designs/directions/maps/controls, workload limits,
current-fit reconstruction, P2b handoff, finite-distance evaluation,
reachability-versus-limit failure separation, production attachment, legacy
source mismatch, unit-slope reduction, and non-reuse for MML or PCM.

The existing release/readiness/scope/documentation guards pass 1,084
expectations. Their three expected skips remain: two require the uninstalled
optional `diffobj` package and one is the separately opt-in P1p stored-result
pilot. The checklist remains 106 rows; line 83, the JML-GPCM joint-boundary
row, stays `review` with `pilot_required` criteria. The local warning that
`testthat` was built under R 4.5.3 while checks run under R 4.5.1 is unchanged.

A source tarball built successfully and passed `R CMD check` with zero errors
and zero warnings under the offline development setting
`_R_CHECK_FORCE_SUGGESTS_=false` and without manuals or vignettes. The single
NOTE reports Rd cross-references to the unavailable optional Suggests
`lme4`, `eRm`, `mirt`, and `TAM`; package installation, static code analysis,
Rd validation, examples, and the complete test suite were OK.

No external executable, recovery run, broad simulation, or confirmation run
is part of P2c.

## FACETS and claim consequence

P2c changes no FACETS comparison role. FACETS PCM/JMLE versus mfrmr PCM/JML
remains the only possible future direct common-estimand lane. Non-unit
GPCM/JML remains truth-first, FACETS PCM remains a deliberately misspecified
control, and FACETS Table 7 discrimination remains diagnostic-only. A forward
map inside mfrmr's constrained GPCM free coordinates cannot create shared
model, estimator, conditioning, or parameter identity with FACETS.

## Machine-readable disposition

```text
ParameterPathReachabilityImplemented = TRUE
ParameterPathReachabilityContract = mfrmr-jml-gpcm-parameter-path-reachability-0.2.3-v1
ReachabilityBasis = forward_map_from_retained_constrained_free_additive_coordinates
MaximumAdditiveStages = 2
CategoryZeroGauge = first_category_utility_fixed_to_zero
InverseProjectionUsed = FALSE
InverseToleranceReachabilityClaim = FALSE
ArbitraryUtilityDirectionReachabilityClassified = FALSE
ExactTieContractPreservedByForwardConstruction = TRUE
CurrentFitBaseReconstructionAvailable = TRUE
DirectFiniteDistanceEvaluatorAvailable = TRUE
ProductionPathsDeclared = 0
ProductionParameterPathReachabilityChecked = FALSE
ProductionPathLimitClassified = FALSE
PathInferredFromOptimizerTrace = FALSE
ScaleExponentsInferred = FALSE
PathSearchPerformed = FALSE
RemainderStableTiesCertified = FALSE
MonotoneTailCertified = FALSE
CompetitiveBoundaryCertified = FALSE
CommonSubsequenceLimitCertified = FALSE
ArbitraryPathLimitClassified = FALSE
GlobalBoundaryClassified = FALSE
GlobalFiniteMaximumCertified = FALSE
GlobalBoundaryAbsenceCertified = FALSE
ReadinessEffect = none_diagnostic_only
ExternalComparisonAuthorized = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

## Identity and verification

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-parameter-path-reachability.R` | `7074fdc6b864637993be5c3596fbd759bdf66f59d55a82c0e07eddfd2393ab9f` |
| `R/core-estimability.R` | `a2d13aaa3b4f53e530751d3c8312dbf8f4f5f2ac8d1455a006d18b7c2295710f` |
| `R/core-jml-gpcm-lexicographic-limit.R` | `2701ca0e97a75d40e368414452d0c18da8a1888194ac0615b69558ac8e08178d` |
| `R/mfrm_core.R` | `470e8a625b75507dc35811053a2179852d03c2f600083ad86630296f5c83b905` |
| `R/api-estimation.R` | `b3824533d142af8a1dad91dcf3c6208c28ea973928a3f58ad7281600d56db70c` |
| `man/fit_mfrm.Rd` | `aecce001d705b822bb975152c85e1db15c6b883f31ecd4ab76c3746d9d9eebcd` |
| `tests/testthat/test-jml-gpcm-parameter-path-reachability.R` | `c071a39a6cb6572b74506bfae62d007a78a1bf367f40cb45251a61fd7392d5de` |
| `NEWS.md` | `e200167b0864420afb446a4928879c33b55e06664c21cc2d42ecf5e67c518265` |
| `ROADMAP.md` | `b317db0c1744fa429f764ce707c19c02d8b38c02a253e879845333dce497a992` |
| `inst/validation/README.md` | `d4462a78ae506f4de69cca9d3710d2005ec467c3af830f1acc9245eb319072e9` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `3a4baf65c26ee848c6fb730c0bfa9e05a02ee59f35716ea5366b76b4b12c99ba` |
