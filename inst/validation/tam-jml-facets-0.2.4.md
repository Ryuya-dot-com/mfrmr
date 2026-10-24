# TAM JML and FACETS comparison for mfrmr 0.2.4

Executed on Windows with R 4.5.1, TAM 4.3-25 and FACETS 64-bit 4.5.0,
2026-10-24. This is a bounded compatibility investigation, not a coverage
experiment or a general software-equivalence certificate.

## Matched model and question

Does a third JML implementation support the current mfrmr score equations,
including sparse assignment and partial Person anchors? Which differences
come from estimation, category support, uncertainty or fit conventions?

`tam-jml-facets-0.2.4.R` uses 48 Persons, three Raters, three Tasks and scores
0:3. RSM has shared steps; PCM has Task-owned steps. Location and step
contrasts sum to zero. TAM's grand intercept is fixed to zero to match
mfrmr's free Person location and centered Rater/Task effects. The partial
anchor fixes P03 to -0.4. Complete designs have 432 responses; sparse designs
have 324, averaging 6.75 per Person, with connected assignments. Interior
examples deliberately avoid extreme Person totals; they are conditioned
diagnostic examples, not recovery replicates. Two further cases force extremes.

Both `A` and `B` are supplied to TAM and the returned arrays are checked.
Modes use `bias=FALSE, adj=0`, `bias=FALSE, adj=.3`, and `bias=TRUE, adj=.3`.
The last means default *corrections* under common identification, not a call
with every argument left at its default. Errors/warnings remain recorded.

## Numerical attribution

Across the six interior complete/sparse/partial-anchor RSM/PCM comparisons,
maximum Person difference is 1.986e-5 logits and maximum expected-score
difference is 1.909e-5. Independent exponential-polynomial likelihood checks
give free score residuals below 8e-5 and negative-log-likelihood differences
below 7e-9. These support agreement beyond returned optimizer status.

The first probe was not model-matched: one Rater-Task column lacked observed
category 3. With only full-category `A` supplied, TAM generated `B` with
fourth-category score zero in that column, while retaining its intercept.
This is not simply a smaller dataset or an optimization error. Supplying
full-support `B` restored agreement without changing observations or mfrmr,
and removed initial interior PCM raw failures. Initial missing Person
comparisons also used the wrong mfrmr label column; the corrected comparison
uses `Person` with a complete-match assertion. Original evidence is retained.

TAM's classical factor is exactly 8/9 for nine response columns, including
sparse cases with mean exposure 6.75. Corrected free `xsi` equals 8/9 times
the raw value; returned `theta`, `errorP` and `errorWLE` are unchanged.
Loaded source confirms multiplication after ability/SE computation. Hence
these fields are not all recomputed at the corrected item vector. Expected
scores differ from ordinary JML by up to .157 here. This is not mfrmr's
adjusted-likelihood `JML_BC`, and one-seed differences do not rank estimators.

TAM `theta` and `WLE` differ by up to .388 logits in interior cases and .965
with forced extremes. `errorWLE` must not be attached to `theta` as its MLE
SE. Independent conditional-information SEs at MLEs agree with mfrmr
diagnostic ModelSE within 3.75e-6 for free Persons. Primary ordinary-JML
inference SEs remain unavailable. Independent joint-information inversion
gives SEs up to 1.545 times conditional-coordinate SEs across free coordinates;
this does not establish coverage or cure incidental-parameter bias.

For both forced-extreme models, TAM `adj=0` fails. With `adj=.3`, adjusted
score residuals are below 3e-9; original extreme-total residuals are .3.
This changes calibration equations. mfrmr retains infinite primary Person
estimates with a separately labeled reporting correction. These procedures
therefore do not share an estimand. In a separate fixed-item binary case,
TAM `theta`, the mfrmr FACETS reporting route and independent roots agree to
about 1.1e-11; native FACETS agrees within rounding. Person 2 has corrected-
total MLE -3.197019 versus WLE -2.324155.

## Diagnostic and weight differences

At the same calibration, `tam.jml.fit(trim_val=Inf)` matches unweighted
Infit/Outfit and the fourth-moment cube-root transform used by mfrmr's
FACETS/WHexact-YES route before any display cap. A saved-output regression
checks this kernel separately from optimizer tolerances. TAM's ordinary fit
output does not supply all FACETS df, expected correlations, fair averages
or bias-cell reports; those surfaces are not certified here.

Default `trim_val=10` clips large squared standardized residuals relative
to their across-response SD. A fixed-calibration stress gives Person Outfit
1171.517 versus 1409.165 untrimmed; independent arithmetic matches the latter.
This modified diagnostic object is not described as a refitted model.

TAM normalizes `pweights` to sum to Person count. Doubling every weight leaves
estimates, item SEs and returned weights identical in execution; this is not
raw observation-frequency replication. Also, the checked `tam.jml.fit()`
item Outfit divides its weighted residual sum by unweighted observed count.
With assignment-dependent weights it differs from normalization by observed
weight sum: one cell gives .690445 versus 1.208280. A first balanced-weight
probe had equal denominators; a second correlates weights with assignment
patterns to distinguish them. Do not flatten arbitrary response weights
into `pweights` or copy this denominator into mfrmr.

## Native FACETS and anchor limits

Four additional native FACETS processes used the same generated data.
Complete unanchored RSM/PCM finish and agree with TAM Person measures to
4.48e-5 and 1.64e-5 logits. Partial-anchor RSM reports `Over-constrained?
Noncenter= not in effect`, differs by up to 1.413 logits and retains large
score residuals. It is not a qualified matched maximum. The analogous PCM
run cycles with large residuals and is terminated at the declared 45-second
timeout. Extending runtime does not resolve this constraint problem.

In the earlier all-item-fixed binary case, a Person anchor automatically
routes TAM 4.3-25 through version 1. With no free item coefficients it stops
at `rep(0,max(est.xsi.index))`, because the index is empty. No patched TAM
output replaces this failure. The version-3 fixed-item case without a Person
anchor succeeds. mfrmr's anchored result satisfies conditional equations,
but three-way parity for the failing case cannot be claimed. Broader FACETS
constraint/anchor behavior remains open; no empirical shift is added to mfrmr.

## Evidence and implementation decision

Local evidence: `tmp/native-compatibility-20261024/tam-jml/`. The
`explicit-support/` directory holds matched inputs, fits, source/function
hashes, session and call states. `matched/`, `attribution.*` and `support.*`
retain the first mismatched probe and diagnosis. Independent checks and
native comparisons are in `score-information-audit.csv`, `bias-identities.csv`,
`anchor-probe.*`, `diagnostic-kernel.*`, `weights.rds`, `three-engine.csv`
and native directories. Successful runs retain executable/input/output hashes
and UTC starts. The PCM timeout receipt preserves its missing start timestamp
as missing rather than inventing a successful execution record.

The `tam-jml-0.2.4-*` CSV fixtures export executed TAM results. Response
moments use a separate scalar evaluation of its returned parameters; Person
measures and fit statistics retain native TAM output. Tests exercise sparse
RSM and partially anchored PCM through public mfrmr fitting/diagnostics,
including an unobserved highest category in a response column. They do not
require TAM or FACETS at test time.

The initial matched results did not justify changing the likelihood. Migration guidance
now distinguishes support, corrections, anchors, MLE/WLE, conditional
information and weights. Broader valid FACETS anchor/exclusion handling,
calibration-inclusive fair-average/bias inference and the four original PCM
Outfit-df discrepancies remain open. Coverage and release qualification are
not established.

Primary reference: [TAM documentation](https://alexanderrobitzsch.github.io/TAM/reference/tam.jml.html).
Loaded source governs the version-specific observations above.

## Anchor-origin follow-up: implementation and separate engine failures

The [FACETS centering specification](https://www.winsteps.com/facetman64/centerfacet.htm)
states that an anchored facet obtains its origin from its anchors; Center and
Noncenter no longer act on that facet. Thus the previous P03=-0.4 inputs with
Noncenter=Person left both Rater and Task centered. In mfrmr this is a valid
extra constraint on the likelihood, but the FACETS iterations and warning do
not demonstrate that it optimized that same restricted likelihood. This
supersedes treating the interior discrepancy as an unexplained engine shift.

Two additional native FACETS 4.5.0 runs kept the sparse data and P03 anchor,
changed Noncenter to Rater and used a bounded 500-iteration limit. Task stayed
centered. Both exited normally without the overconstraint warning, in 1.243
and 1.053 seconds respectively. If the unanchored solution has Person theta,
Rater r and Task t, define delta=-0.4-theta[P03]. Replacing theta by theta+delta
and r by r+delta leaves theta-r-t and every category probability unchanged.
This supplies an independent reference from the earlier unanchored fits.

| Model | Largest native minus translated TAM Person difference | Largest native minus translated mfrmr location difference |
|---|---:|---:|
| RSM | 8.62e-6 | 5.99e-6 |
| PCM | 7.61e-6 | 1.93e-5 |

The new public `centering_scope="anchor_origin"` implements this constraint
choice for ordinary additive RSM/PCM JML. Direct anchors replace centering
on their facet; the selected noncenter facet must be unanchored and active.
Other facets remain centered. Group anchors, interactions, other estimators
and comparison-only fits reject the option. Existing `facet`/`remainder`
defaults and saved constraints are unchanged. Individual affine constraint
maps retain their established representation, while configuration, anchor
review (`Centered`, `OriginBasis`), summaries and replay retain the selected
convention. New native-fixture regressions check fitted locations within
1e-4 and independent free-Person/Rater score residuals below 1e-4. Rater-anchor
tests additionally preserve the likelihood under an independent translation
and allow fully fixed nonzero facet totals.

An identified origin need not give a finite maximum. A 3-Person, 2-Rater,
2-Task binary example anchors the only all-zero Person. Increasing all free
Persons and both Raters together leaves their responses unchanged and improves
the anchored Person's likelihood indefinitely. The existing joint additive
audit certifies this direction. The new option now stops when that audit
detects recession affecting structural calibration, instead of returning the
finite stopping values near 15.2 as a solution. Ordinary defaults are unchanged.
This test does not establish general extreme-score exclusion parity.

Two direct TAM probes distinguish a software convention from convergence:

- With a free grand intercept and `theta.fixed=(3,-0.4)`, TAM 4.3-25's
  version-1 implementation still subtracts mean(theta) whenever
  `xsi.fixed` is NULL. The returned anchored theta was -2.960700 rather than
  -0.4, its overall Person mean was approximately zero, and 800 iterations
  were exhausted. Loaded source and execution agree on this branch.
- A zero-row `xsi.fixed` matrix fixes no item parameters and bypasses that
  NULL check without modifying TAM. It retained theta[P03]=-0.4, but at 800
  iterations the largest location difference was .018147, maximum expected-
  score difference .004793, maximum free gradient .001118 and NLL difference
  .0001381. It is an unqualified numerical solution even though the anchor
  is now retained. This diagnostic probe is not a general workaround or an
  invitation to copy finite-iteration differences into mfrmr.

Both direct probes stopped after their RSM mismatch; no direct free-intercept
PCM success is claimed. The tight TAM agreement in the table above instead
uses an independently fitted unanchored solution and an exact invariant
translation. Do not substitute it for evidence that TAM's direct anchored
iteration converged. The failed native inputs and both failed TAM probes
are retained rather than overwritten by the corrected FACETS reference.

Follow-up evidence is in `tmp/native-compatibility-20261024/anchor-origin/`:
`RSM/` and `PCM/` retain full native input/output, executable/input SHA256,
UTC start, exit and output hashes. `check.R`, `comparison.csv`, `reference.csv`
and `tests/testthat/fixtures/facets-anchor-origin.csv` preserve the independent
translation and native fixture export. `matched/` and `empty-fixed-xsi/`
retain failed direct TAM objects and metrics; `tam-version1.R.txt` retains
the loaded implementation. `run_tam_jml_anchor_origin_check()` in the adjacent
runner reproduces that comparison and intentionally fails its match assertions
on an unqualified result; its `xsi_fixed` argument exposes the diagnostic
NULL/zero-row distinction.

Fresh-session RDS consumers, specifications, fair-average plotting, actual
public replay refitting and the bundled-data vignette example pass. Focused
tests cover new constraints and boundary rejection, existing centering, old
saved fits, anchored diagnostics, identification, TAM fixtures and FACETS
extreme reporting. `tests-final.csv` combines unaffected passing files with
the final focused rerun. The initial scalar test failure concerned the retained
Rater name, and was corrected by comparing its numeric value explicitly.
Help was generated in an isolated stage with source/namespace identity checks.
These checks are not a full package check or a publication.

Calibration-inclusive fair-average/bias inference, estimated-anchor error,
the four original PCM Outfit-df discrepancies and broader extreme/exclusion
equivalence remain open. No new coverage or fairness guarantee follows.
