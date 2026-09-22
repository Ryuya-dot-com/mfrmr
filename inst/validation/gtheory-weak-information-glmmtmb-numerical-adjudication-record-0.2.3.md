# Draft.83d2b2b1g3 glmmTMB numerical adjudication record

Date: 2026-08-10
Scope: exact no-refit re-adjudication of the b1g2 120-pair scalar/hash ledger
Decision: objective/likelihood separation and adjudication schema ready;
stationarity criterion and full execution remain false

## Frozen identities

- b1g2 alignment runner contract:
  `7632a74709576c78d4e89b9fd015952dbde5be98313b99ed380af7c5436e1177`
- b1g2 execution:
  `e2716a4ae71784e218d15f2509ed8c15326c1b7c6bc9acf78826a81822581482`
- b1g1--b1g2 comparison:
  `651b6f07cb7977b7d1245b1048e0b7b905c4999f8da43bfbcd30180d9581d435`
- b1g3 adjudication contract:
  `934f96be6e23cd728576cfedbb44d48b68137fbbc74e84d19d7200b8ad52ccc0`
- b1g3 result:
  `c7c35d5b961c578b6234a1f29f628f13dac357bc1b046e012832d28ca7f3d4de`
- installed glmmTMB 1.1.14 `logLik.glmmTMB` body/formals:
  `c3f49676ea6fd8b6e2f4f70e775fd62387b808fd6a93388e17b280c45c4efbfd`

The adjudicator recomputes the b1g2 execution and comparison hashes before
reading any row. It calls no generator or fitting backend, accesses no fit
object, and retains all 120 pair and 20 base-route denominators.

## Backend return and optimizer termination

All 120 full/reduced pairs returned. Optimizer codes are an independent axis:
119 pairs have code zero on both sides, while one has full code 1 and reduced
code 0. The latter is the REML, `high_information/reference_1200`,
`glmmTMB_warm_nlminb_from_bfgs` row. Its primary b1g2 state was already
`nonfinite_objective_or_likelihood`, so the earlier precedence-based summary
did not display the nonzero optimizer code. b1g3 retains both facts.

R's definition of code zero as successful completion is used only as optimizer
termination metadata. It is not promoted to stationarity, curvature, global-
maximum, or inference readiness.

## Raw objective versus reported log likelihood

Raw full and reduced objectives are finite in all 120 pairs. Reported full log
likelihood is available in 113 fits and reported reduced log likelihood in 111
fits. Wherever reported, all 224 values are exactly the negative raw objective.
All 106 pairwise reported differences are exactly equal to their objective-
derived differences.

The pairwise reported-likelihood states are:

- 106 both reported;
- 5 full curvature-masked;
- 7 reduced curvature-masked;
- 2 both curvature-masked; and
- 0 unexplained non-finite.

Thus the 14 b1g2 nonfinite objective/likelihood states did not contain a
nonfinite stored objective. They were exactly explained by glmmTMB's installed
rule that returns `NA` from `logLik()` when the corresponding `sdr$pdHess` is
false. This explanation does not rehabilitate the fits: the mask communicates
adverse curvature, and the raw objective is retained only as numerical trace
evidence.

## Curvature and gradient axes

Sdreport and the independently recomputed Richardson sign classification agree
for all 120 full and all 120 reduced fits. Pair curvature states are:

- 106 both PD;
- 7 full-only PD;
- 5 reduced-only PD; and
- 2 neither PD.

There are no Richardson-unavailable or diagnostic-disagreement rows. PD
agreement is treated as a necessary curvature condition, not a sufficient
numerical rule.

Both outer and sdreport gradient summaries are available for all 240 fits.
Their hashes agree in 119/120 full and 119/120 reduced fits. The one full and
one reduced mismatch occur at the same two fits whose raw/aligned fixed states
differed in b1g2. Their maximum-gradient summaries differ slightly, so the two
surfaces are not silently pooled. The maximum observed outer-gradient absolute
values remain approximately 0.02798 full and 0.01722 reduced. Because raw
gradient vectors, parameter scales, and a prospective scale-aware rule are not
present in this ledger, every stationarity state is `not_calibrated`.

## Finite nested trace ordering

Using all finite stored objectives rather than only curvature-eligible reported
log likelihoods exposes the complete 120-row signed trace partition:

- 75 positive;
- 22 small negative under the inherited descriptive `1e-6` partition; and
- 23 material negative.

All 60 `reference_1200` rows are positive. Among `exact_zero`, 15 are positive,
22 are small negative, and 23 are material negative. Two material-negative and
12 positive trace differences had previously been hidden by the reported-
likelihood curvature mask.

This is not an LRT ledger. The zero-variance reduced point lies in the closure,
not at a finite full log-SD coordinate. Negative finite differences therefore
record finite-trace non-attainment or insufficient observed maximization
relative to the closed comparison; the inherited `1e-6` value remains a
descriptive partition only.

## Six-profile best-observed envelopes

Each of the 20 base routes has exactly six profiles. Independently selecting
the smallest observed full and reduced objective yields 12 positive and 8
small-negative envelopes, with zero material-negative envelope. All 10
`reference_1200` routes and 2/10 `exact_zero` routes are positive; the remaining
8 `exact_zero` routes are small negative. Restricting candidates to fits with
both sdreport and Richardson PD curvature produces the same source profiles
and envelope values in all 20 routes.

This shows that the material-negative individual-profile traces are not stable
under the frozen six-profile search. It does not show that the envelopes are
global maxima, that one optimizer is preferable, or that small-negative
boundary traces are numerically adequate.

## Fail-closed adjudication

The following narrow claims are true:

- `AdjudicationSchemaReady=TRUE`;
- `NoRefitLedgerReady=TRUE`;
- `ObjectiveLikelihoodSeparationReady=TRUE`; and
- `CurvatureNecessaryConditionSpecified=TRUE`.

The following remain false:

- `StationarityCriterionReady`;
- `NumericalEligibilitySufficientRuleFrozen`;
- `FullExecutionAuthorized`;
- `NumericalStabilizationReady` and
  `NumericalSensitivityEvidenceReady`;
- calibration, threshold, bootstrap, and confirmation readiness; and
- inference, coefficient, and D-study decision readiness.

The next prospective slice must instrument raw fixed-coordinate gradients and
parameter/objective scales before fitting, define scale-aware stationarity
summaries without using these observed magnitudes as cutoffs, and verify their
behavior across restarts and optimizers. Only then can full-manifest execution
authorization be reconsidered separately from numerical adequacy.

## Artifact hashes

- contract Markdown:
  `11503561426192b6ce5f6fd9f70bffae7ca609d027a86b929a7991a276db6d22`
- adjudicator source:
  `bfad0ecbdd2aeb4fce63cdcbf28ac650f0bb61ec5188db409f3dd68fe3d5ef65`
- test source:
  `83a0a99ba5d5d1b1860bf09377f4995110a9261cabd7a3085deec75dcb797d8f`
- retained result RDS:
  `0c0a19c68cf599b34ef60f90baa065b314f75f90c464d9b40d20717eb63184f8`
