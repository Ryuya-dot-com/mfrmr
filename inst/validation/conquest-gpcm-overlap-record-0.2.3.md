# ConQuest 5.47.5 bounded-GPCM overlap record for mfrmr 0.2.3

Current status, 2026-10-23: a retained current-source comparison supports
item-only GPCM calibration and observed-information agreement, including latent
regression and incomplete observations. The numerical checks below pass; formal
inference, many-facet equivalence and the public ConQuest bridge are not promoted.
The August 11 record is retained below as historical evidence, not evidence for
the current working source or current raw-output retention.

## October 23 current-source comparison for 0.2.4

**Question.** Does the improved direct MML route reach the same item-only GPCM
solution as ConQuest after matching models, identification and integration
accuracy? Does agreement extend to full parameter covariance, and do differences
in reported Person summaries imply a calibration error?

**Design.** One seeded response sample has 240 Persons, six items and four
categories, with heterogeneous positive slopes and item-specific steps. The
three analyses use no covariate, a continuous latent-regression covariate, and
that regression with planned 15% independent missing responses (207 of 1,440
responses absent, 14.4%). These are related analyses of one sample, not three
independent replications or a recovery/coverage study. Every Person retains an
observation and every item/category is observed.

mfrmr uses the existing `free_population` identification and
`mml_integration="auto"`, starting at Q31. Each case selects adaptive Q31; a
separate Q63 refit checks movement. ConQuest 5.47.5 uses fixed latent intercept
zero and residual variance one, `model item + item*step ! type=scoresfree,
positivescores=yes`, and quadrature at 31/61/121 nodes with ranges ±6/±6/±8.
The parameter-change/deviance-change settings are 1e-8/1e-10. All runs terminate
on the deviance criterion. Estimated Tau remains between 0.821 and 2.316,
strictly inside the requested 0-to-20 range. This checks an interior positive
solution; ConQuest's zero-boundary behavior is not mfrmr's positive-log-slope
parameterization. An identical number of nodes would not imply identical
integration rules.

The exported A and C matrices verify the actual response law and free-parameter
ordering. Scale conversion uses the exact map below, including the regression
coefficient and residual SD. Conditional probabilities calculated directly from
the mfrmr formula agree with the converted exported design within 8.89e-16 on
161 ability values from −4 to 4 on the ConQuest scale. All free coordinates
round-trip within 1e-11. This is a response-law check, not merely label matching.

**Calibration and uncertainty.** The following differences use the final
121-node ConQuest result and the mfrmr adaptive result on the same scale.

| Analysis | Absolute reported deviance difference | Maximum free-coordinate difference | Maximum category-probability difference | Maximum SE relative difference |
| --- | ---: | ---: | ---: | ---: |
| No covariate | 8.08e-8 | 1.33e-5 | 2.40e-6 | 0.00462% |
| Latent regression | 2.19e-7 | 1.30e-5 | 1.56e-6 | 0.00545% |
| Regression with missing responses | 2.83e-7 | 1.27e-5 | 1.62e-6 | 0.00577% |

The independently expressed continuous integral agrees with the *retained
public mfrmr objective* within 4.16e-10 in total negative log likelihood. Its
Person EAP and posterior SD agree within 9.82e-10 and 3.97e-9, respectively.
The finer adaptive Q63 evaluator agrees with the continuous reference at both
programs' mapped estimates within 2.28e-13. The absolute continuous deviance
gap between programs is at most 8.23e-10; small signed negative gaps are not
evidence of one optimizer's superiority. Q63 refitting moves mfrmr free
coordinates by at most 8.57e-7. Native terminal NLL gradient sup norms are
4.01e-5–6.08e-5; those evaluated at rounded ConQuest exports are
1.98e-4–2.30e-4. These are local numerical checks, not a global-maximum proof.

ConQuest's `stderr=empirical` and `matrixout` provide the **full joint parameter
covariance**: 24 dimensions without regression and 25 with it. This is distinct
from `export covariance`, which provides the latent variance. The native
observed-information inverse is transformed with the full Jacobian, including
location, step, slope and population cross terms. Parameter labels, rank,
symmetry and positive definiteness are checked. The largest covariance-element
difference, standardized by the product of native SEs, is 1.16e-4. Jacobian step
halving changes entries by at most 1.78e-10; refining native information from
Q31 to Q63 changes standardized covariance by at most 2.53e-9. ConQuest CSVs
retain six decimal places; this resolution and its empirical differentiation
limit finer equality claims. Full covariance agreement does not establish
finite-sample interval coverage. See the [official command reference](https://conquestmanual.acer.org/s4-00.html)
for `estimate`, `matrixout`, `export` and posterior-reporting controls.

Before fitting, numerical review thresholds were set to 1e-4 for coordinates,
1e-5 for probabilities and continuous deviance, 1e-3 for the total NLL gradient
at rounded external coordinates, and 1e-3 for standardized covariance-element
differences. All final cases meet these scoped criteria. These thresholds do
not override `InferenceReady=FALSE`, certify public bridge compatibility or
establish scientific equivalence for every design.

**Person posterior reporting.** Continuous posterior summaries at the two
calibrations differ by at most 2.77e-6 in EAP and 7.44e-7 in posterior SD after
scale conversion. ConQuest's reported summaries with `p_nodes=2000` differ from
its own continuous reference by up to 0.0231 and 0.0189. Changing only the
reporting seed from 2 to 3 changes EAP by up to 0.0325 and SD by up to 0.0262.
Together with the manual's separate Monte Carlo posterior calculation, this
supports reporting approximation as the source of these much larger
differences. Two seeds characterize this example, not a general Monte Carlo
error guarantee. Replacing mfrmr's accurate posterior moments with these
stochastic values would not improve numerical accuracy.

**Algorithm consequence.** At the initial native fixed Q31 solutions, maximum
individual log-marginal discrepancies are 0.00107–0.00244, and finer-rule NLL
gradient sup norms are 0.088–0.103. Adaptive refitting changes free coordinates
by 0.00141–0.00242 and removes these discrepancies in this sample. ConQuest
itself also benefits from refinement: its Q31 reported deviance differs from
the continuous evaluation at its own estimates by as much as 1.79e-4, versus
at most 2.83e-7 at Q121. Thus these results support accuracy-controlled MML;
they do not identify EM as the cause of agreement or establish that switching
mfrmr to EM would be more accurate or faster. No matched-work runtime comparison
was performed. Default adoption and downstream inference eligibility remain
separate decisions.

**Many-facet boundary.** The ordinary native model has adjacent-category log
odds `a_i * (theta - d_i - r_j - t_ik)`. The ordinary additive ConQuest
`scoresfree` model has `Tau_i * z - xi_i - xi_j - xi_ik` after tying the item
scores. The native rater contrast is multiplied by `a_i`; a single additive
ConQuest rater contrast is common to all items. For example, slopes 0.5 and 2
with a rater difference 0.6 give native log-odds contrasts 0.3 and 1.2, which
one common rater coefficient cannot reproduce. ConQuest 4+ allows linear C
matrix constraints on scores ([official Note 8](https://www.acer.org/files/Note_8--The_ConQuest_4_Model.pdf));
tying those scores alone does not impose the additional unknown products
`a_i*r_j`. Freely adding item-by-rater interactions would enlarge the model,
not prove identical estimation. This does not assert that every custom
ConQuest representation is impossible. An exact response-law and constraint
map is needed before a many-facet or two-family comparison can be interpreted
as a comparison of estimators.

**Reproducibility and limits.** `conquest-gpcm-mml-20261023.R` prepares the
inputs/commands, fits native models, checks raw exports, compares continuous
integration and information, and replays the results in a fresh R session.
Raw commands, inputs, output matrices, saved native fits and executable/source
hashes are retained with locations recorded in the internal roadmap. The
August raw outputs were not found at their old temporary location, so the
current conclusions use newly retained runs. Early harness errors concerned a
mixed shorthand ConQuest command and CSV integer/whitespace parsing; their
logs remain retained, and no failed run is treated as a fitted result. All 211
R source files are unchanged from the validated auto-integration implementation.
No estimator, default, public bridge, inference eligibility or release status
was changed for this comparison. Weak identification, extreme sparsity,
larger designs, anchors, many-facet joint estimation and interval coverage are
not certified by this one-sample comparison.

## Historical August 11 record

## Decision

ConQuest does implement a GPCM. In the current manual the canonical command is

```text
set lconstraints=cases, sconstraint=cases;
model item + item*step!scoresfree;
estimate ! method=quadrature, nodes=31;
```

`scoresfree` estimates one Tau per item. For category `k`, the exported item
score is `k * Tau`; the zero category is the reference. The same behavior was
observed in the installed 5.47.5 executable. This makes ConQuest a useful
external MML comparator, but only after separating four different strata:

1. An **item-only GPCM with an active free population model**, either
   intercept-only or with prespecified covariates, has an exact statistical
   likelihood and coordinate map to the current bounded mfrmr GPCM.
2. The default **intercept-only free-population MML** is the no-covariate case
   of that same exact map. Its structural map is established, although the
   retained native microcase includes `X` and is not a separate unconditional
   candidate.
3. The former **fixed-standard-normal mfrmr MML** fixed the latent distribution
   and the slope geometric mean to one. ConQuest's standard `scoresfree` run
   fixes latent variance to one but freely estimates the common discrimination
   scale. These are different finite-dimensional models, not merely
   differently labelled output. That narrower mfrmr likelihood is now the
   explicit `gpcm_mml_identification = "fixed_standard_normal"` compatibility
   mode rather than the default.
4. A standard **multifacet ConQuest `scoresfree`** model estimates scores for
   generalized items, which are combinations of all active facets. It does not
   automatically reproduce mfrmr's single Criterion- or Rater-owned slope that
   multiplies every term in the adjacent-category predictor. The item-only map
   therefore cannot validate the current many-facet owner claims.

ConQuest JML is not a GPCM slope comparator. The current manual's estimate
command note 11 states that JML cannot estimate item scores. The local negative
control using `scoresfree` and `method=JML` terminated abnormally with status
139 after design-matrix formation and produced no Tau. Because the requested
combination is documented as unsupported, that run is retained only as a
fail-closed negative control; it is not interpreted as a numerical result or a
general product-failure claim.

## Exact item-only map

For owner item `i`, mfrmr uses

```text
log P(Y=k | theta, i) = constant
  + a_i { k(theta - delta_i) - sum_{h=1}^k tau_ih }.
```

Under active latent regression,

```text
theta = beta_0 + X beta + sigma epsilon,
epsilon ~ N(0, 1),
geometric_mean(a_i) = 1.
```

ConQuest fixes its latent variance to one and, with `lconstraints=cases`, fixes
the latent intercept to zero while freeing all item locations and score Taux.
Define

```text
z                    = (theta - beta_0) / sigma
beta_ConQuest         = beta_mfrmr / sigma
Tau_i,ConQuest        = sigma a_i
delta_i,ConQuest      = a_i (delta_i,mfrmr - beta_0)
tau_ih,ConQuest       = a_i tau_ih,mfrmr.
```

Substitution gives the same adjacent-category log odds category by category.
It also gives

```text
geometric_mean(Tau_ConQuest) = sigma_mfrmr.
```

The free dimensions agree. With `I` items, `K+1` categories, and `p`
non-intercept regressors, mfrmr uses an intercept, `p` regression coefficients,
one residual variance, `I-1` item contrasts, `I-1` log-slope contrasts, and
the item-step contrasts. ConQuest instead fixes the intercept and variance but
estimates `I` item locations and `I` Taux. The two totals are identical.

`conquest-gpcm-overlap-contract-0.2.3.R` implements this transformation and an
independent conditional-probability audit. Its deterministic test spans three
non-unit slopes, three four-category step ladders, and five ability values;
the maximum probability difference is below `1e-14`.

## Native MML microcase

The microcase reused the fixed 120-Person, five-item, four-category synthetic
input generator from the existing ConQuest RSM/PCM pilot. It is a single
structural probe, not a Monte Carlo study. All item/category cells were
observed. ConQuest used quadrature MML with 31 nodes, the constraints above,
and native parameter, Tau, item-score, A-matrix, C-matrix, covariance,
regression, case-EAP, and iteration-history exports.

| Result | Observed value |
| --- | ---: |
| ConQuest completion | `End of Program`, status 0 |
| ConQuest iterations | 150 |
| ConQuest deviance | 1385.310197 |
| ConQuest latent variance | 1.000000 |
| ConQuest regression coefficient for `X` | 0.848977 |
| ConQuest Taux | 0.785204, 0.754345, 0.558053, 1.461882, 0.541181 |
| geometric mean of ConQuest Taux | 0.7647096404 |
| mfrmr residual SD | 0.7647105008 |
| mfrmr deviance | 1385.3102092 |
| mfrmr terminal gradient sup norm | `6.137551e-5` |
| mfrmr inference readiness | `FALSE` |

The native C matrix contains coefficients `0, 1, 2, 3` for the four categories
of each item, and the item-score export is exactly `k * Tau` at its retained
six-decimal resolution. After applying the map above, maximum absolute
differences were:

| Coordinate | Maximum absolute difference |
| --- | ---: |
| deviance | `1.22e-5` |
| regression coefficient | `5.09e-8` |
| Tau/slope scale | `2.10e-5` |
| item location | `2.50e-6` |
| free step coordinate | `1.83e-5` |
| Person EAP | `2.13e-2` |
| Person posterior SD | `1.03e-2` |

The structural coordinates and objective support the derived map. Person
posterior summaries are less close because the programs use different
posterior integration/reporting routes; they are not part of this structural
claim. The mfrmr fit also remained review-only under its current terminal-
gradient rule. No cross-engine tolerance was prespecified, the ConQuest CSV
rounding rule remains unestablished, and the run was not candidate-bound.
Consequently no numerical row is marked eligible and these differences are
descriptive, not acceptance results.

## Package identification correction

The package default now uses
`gpcm_mml_identification = "free_population"`. When a GPCM MML call omits
`population_formula`, mfrmr constructs the intercept-only population model

```text
theta = beta_0 + sigma epsilon, epsilon ~ N(0, 1), GM(a) = 1.
```

This is the left side of the exact map above and therefore restores the common
discrimination degree of freedom. The fixed-latent-SD optimizer slope reported
for comparison is `sigma * a`; its geometric mean is `sigma`. Automatic and
explicit `population_formula = ~ 1` calls are tested to produce the same
objective and optimizer coordinates. JML is unchanged because GM-one slopes
remain necessary for its joint person/slope scale identification.

This correction establishes likelihood identity, not external acceptance.
The native ConQuest microcase remains rounded, non-candidate-bound review
evidence, and the many-facet score-owner mismatch remains open.

## Identity and retention

| Artifact | SHA-256 |
| --- | --- |
| mfrmr source commit used for the live probe | `bf71579cba787dfddfa668b9b60cfb6c9277ecf2` |
| `/Applications/ConQuest/ConQuest` | `61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48` |
| `/Applications/ConQuest/conquestManual.pdf` | `60bce1a39f5430fd304178356fb943721f9f72c0ddee70a9866c28c87017459f` |
| fixed wide input | `875106ce5fc501c76229eda00aa37b4a0556d352233c2990347d263d59cce3ce` |
| corrected MML control | `4ab4379e57df34da6e769eb891e38e4317e929765c5d58bf26320ef07b34737a` |
| ConQuest console transcript | `a25ced994436a629d6d594d4f88afc13bca69d3ca9caef7f66df74a3b53f0e74` |
| ConQuest Tau export | `84da21440045bd9ce1b430e534f33a6c2b59fde3ac406c498e0b32a5b94e8d29` |
| ConQuest parameter export | `3f9b60e698c4d68bf2e0170b5fe343281549079ee9336c1396c5f11aa6aab541` |
| ConQuest history export | `f5bf78c94f88145a5cc10ce0c67a30b3259a33a2b31096db6c9c48d1b7fa3785` |
| coordinate contract | `8ed505578b1baed4a6b24756bef4f80f2f4b4e3994c02d787ffe07d7316d52f2` |
| overlap registry | `e4e5822514d1814113fe21f21dea07a7bdab9c273ad0dd36fd542c77e0971584` |
| deterministic test | `79846227982d66cb2cccfa1523ea4859007e302fe40993926fad3bd9530e6ab0` |

Raw external outputs remain in the restricted temporary probe directory and
are not added to the package or source tree. Only data-free formulas,
aggregate values, source identities, and the machine-readable scope registry
are retained here.

## Roadmap consequence

Checklist row 67 remains `review`; the mathematical map now corrects the
package default but does not pass the external comparison row. The next
bounded external step is one newly generated item-only candidate with a
predeclared integration ladder, raw-token contract, and external tolerance.
It remains lower priority than the retained RSM/PCM release spine.

Criterion-owned and Rater-owned many-facet GPCM comparisons remain separate.
Before either can use ConQuest, a design must prove that generalized-item score
ownership, every slope-scaled non-owner facet term, step dimension, constraints,
and sparse observation set are the same. A C-matrix label alone is not that
proof. Broad simulation cannot substitute for the missing model identity.

## Official sources

- ACER ConQuest Manual, current web tutorial, “Modelling Polytomous Items with
  the Generalised Partial Credit and Bock Nominal Response Models”:
  <https://conquestmanual.acer.org/s2-00.html>
- ACER ConQuest command reference for `estimate`, `export`, `model`, `set`,
  `scoresfree`, `tau`, `itemscores`, `cmatrix`, and `sconstraint`:
  <https://conquestmanual.acer.org/s4-00.html>
- ACER ConQuest Note 6, *Score Estimation and Generalised Partial Credit
  Models*:
  <https://www.acer.org/files/Conquest-Notes-6-ScoreEstimationAndGeneralisedPartialCreditModels.pdf>
- ACER ConQuest product scope:
  <https://www.acer.org/ae/conquest>

The product page establishes broad feature availability. The current command
manual, not the product-level feature list, controls the estimator-by-model
cross-product used in this contract.
