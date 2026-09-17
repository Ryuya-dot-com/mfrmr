# Bounded optimizer-control follow-up

2026-09-17. This plan is written before the new fits. The original 40-dataset
calibration pilot and its numerical sources remain unchanged.

## Question and comparisons

Do objective scaling and a gradient-focused stopping policy resolve the
observed early stops and distant-trial integration errors without disturbing
successful solutions? This is numerical diagnosis on selected existing data,
not a new recovery or coverage sample.

Use all 17 non-ready pilot datasets and six successful controls. Controls are
the first ready dataset in each cell (01-02, 02-01, 03-01, 04-01), plus 03-03
(the largest returned local variance, 4.31) and 03-05 (true positive variance
estimated at exact zero). IDs below use the full `cell-XX-rep-YY` format.
All use the original start, bounds, quadrature orders and tolerances.

Compare three new settings with the saved original setting:

| Setting | `fnscale` | `factr` | `pgtol` |
|---|---|---|---|
| Original, saved | 1 | 1000 | 1e-6 |
| Scaled | N | 1000 | 1e-6/N |
| Gradient | 1 | 0 | 5e-6 |
| Scaled + gradient | N | 0 | 5e-6/N |

The installed R 4.6.1 help and [R's optim documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html)
specify that `fnscale` scales both the objective and gradient. Adjusting
`pgtol` by the same factor keeps its total-gradient target unchanged across
the scaling comparison. The gradient-focused policy is a combined stopping
change: remove the positive function-reduction tolerance and set a total-score
target of 5e-6, above the checked quadrature score difference of 1e-6 but below
the unchanged final readiness threshold of 1e-5. A zero/nonpositive function
reduction can still trigger a native function-reduction stop at `factr=0`.
Do not interpret this as a gradient-only stopping guarantee.

There are 23 selected datasets x three new settings = 69 new fits. Before
these comparisons, run two unchanged-control bridges with the new search
driver, on 02-01 (ready exact zero) and 04-06 (trial integration error).
Require identical numerical histories, returned results and captured error/
warning identities to the originals, excluding elapsed time. This gives 71
planned optimizer calls; original results for all other comparisons are reused.

The new search driver retains the original orchestration with only its
`optim` control list supplied as an argument. It reuses the existing evaluator,
boundary derivative, input check and projected-score helper. Keeping the
short driver separate preserves the executable source identities of the
completed pilot. No namespace patch, new optimizer or dependency is introduced.

## Qualification and failure retention

Keep native code 0, total projected score <=1e-5, no artificial-bound solution,
and no captured errors/warnings as the fit-ready requirements. Exact local
variance zero remains allowed. Every returned new point, including non-ready
ones, gets one fixed evaluation at a higher GH order than its terminal fit
evaluation (121->181, 181->241, 241->301). Require likelihood/moment changes
<=1e-7, gradient change <=1e-6, and reference projected score <=1e-5 for final
readiness. This final check does not replace a nonzero native code.

Report all failures, full trial histories, stop messages, first-trial locations,
evaluation counts, elapsed time and reference discrepancies. No automatic retry
or fit-specific control tuning. Compare successful controls with their saved
solutions: likelihood difference <=1e-7, maximum parameter difference <=1e-4,
moment difference <=1e-5 and unchanged exact-zero/interior status. For any
returned original point, record the new minus original likelihood; decreases
larger than 1e-7 require review. Do not apply a closeness requirement to the
three originals that returned no fitted point.

A candidate merits the next independent pilot only if it resolves all 17
selected failures, preserves all six controls within these tolerances, and
satisfies the higher-order checks. That decision is restricted to these
selected data and this starting point; no global optimum or general success
probability is established. If no candidate meets it, retain the result and
diagnose the remaining stops before expanding the study. Do not recompute
person intervals, aggregate a repaired coverage denominator, or rerun FairZ,
TAM or the full package suite during this optimizer experiment.

Freeze this plan, selected IDs, sources and input evidence hash before fitting.
Checkpoint every fit before its higher-order evaluation, keep failed results,
and reuse completed checkpoints only with matching identities. Store portable
evidence with all selected generated data, old and new results and audits.

## Recorded results, 2026-09-17

**The combined scaled + gradient setting resolves all 17 saved failures and
preserves all six successful controls.** All 23 final points also satisfy the
higher-order reference criteria. This completes the bounded numerical repair
and makes that setting a candidate for an independent pilot. The selection was
deliberately enriched for failures; these proportions are not estimates of
general fitting reliability or interval coverage.

### What each change contributes

| Setting | Ready / selected | Original failures resolved / 17 | Successful controls preserved / 6 | Captured fit errors |
|---|---|---|---|---|
| Original, saved | 6/23 | 0/17 | 6/6 | 3 |
| Scaled | 13/23 | 8/17 | 5/6 | 0 |
| Gradient | 20/23 | 14/17 | 6/6 | 3 |
| Scaled + gradient | 23/23 | 17/17 | 6/6 | 0 |

Scaling alone removes the three trial-integration errors but retains ten
projected-score failures. It also changes successful control `cell-02-rep-01`
from score 6.079e-6 to 2.616e-5, so it cannot be adopted alone. All 23 scaled
fits use the function-reduction stopping message. The point can be close to
the old solution while failing the unchanged score requirement.

The gradient-focused policy resolves all 14 original score failures. Its
three integration errors are the same `cell-04-rep-06`, `cell-04-rep-08` and
`cell-04-rep-10` cases, with numerical trial histories **identical** to the
original failures. Changing a stopping rule cannot help a first distant trial
whose likelihood evaluation already fails. This policy changes `factr` and
the total projected-gradient target together; their individual contributions
are not separately identified by this comparison.

The scale comparison explains the other obstacle. For `cell-04-rep-06`, the
original first trial is `(8,-8,-8,-8,8,16)`, whereas scaling by N moves it to
approximately `(.184,-.508,-.150,-.408,-.317,.413)` in the same coordinates.
All 23 unscaled gradient runs touch an artificial search bound somewhere in
their trajectory; neither scaled setting does. Touching a bound is a trajectory
diagnostic, not itself a fit failure: only three of those unscaled paths have
unresolved integration. The three originally problematic datasets now reach
qualified solutions under the combined setting without a new initial value,
larger quadrature cap, or relaxed final criterion.

The combined setting has 22 projected-gradient stops and one function-reduction
stop (`cell-04-rep-01`). The latter has total projected score 5.365186e-6,
slightly above the requested 5e-6 optimizer target but below the prespecified
1e-5 readiness threshold. Its higher-order score agrees. This is the declared
`factr=0` caveat in operation: the [R native stopping condition](https://github.com/r-devel/r-svn/blob/main/src/appl/lbfgsb.c)
can still stop on a zero/nonpositive improvement. Keep the separate final
score and reference checks; a native code or control value alone does not
establish their satisfaction.

### Successful solutions and integration accuracy

For the six controls under the combined setting, the largest absolute
likelihood change is 3.638e-12, maximum coordinate change is 6.322e-7, and
maximum posterior-moment change is 7.837e-7. Both exact-zero controls remain
at zero; the positive-variance controls remain positive, including the
approximately 4.31 variance example. All six satisfy the prespecified
likelihood, coordinate, moment and boundary tolerances.

Across the 20 selected originals that returned a fitted point, the combined
new-minus-old log-likelihood changes range from -3.638e-12 to +1.766e-10.
There is no decrease exceeding the 1e-7 review threshold. This preserves the
previous numerical solutions within tolerance; the controls do not establish
global optimality or performance at other starts.

Every returned new fit uses GH121 at termination and gets a GH181 reference:
66 references in total, with three gradient-setting fits returning no point.
All 66 likelihood/moment/gradient discrepancies satisfy their tolerances.
The combined setting has:

| Quantity | Maximum | Required bound |
|---|---|---|
| Terminal total projected score | 5.366e-6 | 1e-5 |
| Higher-order total projected score | 5.366e-6 | 1e-5 |
| GH121--181 log-likelihood difference | 3.411e-13 | 1e-7 |
| GH121--181 posterior-moment difference | 1.111e-14 | 1e-7 |
| GH121--181 gradient difference | 6.096e-13 | 1e-6 |

Both unchanged-control bridges match the saved numerical histories, returned
values and error/warning identities exactly. The failed bridge remains a
failed bridge with the same error; elapsed times are excluded from equality.
Nine read-only audits pass for the 69 comparison outcomes, two bridge records,
input/source identities, selection, starts, gradient scaling and final gates.
All 69 new-setting attempts have no captured warnings or nonzero returned
native codes; the three captured errors remain explicitly unavailable.

Median fitting times are 5.180 seconds for scaled, 4.561 for gradient and
5.190 for combined. These are descriptive times for different search paths,
including early failures, not a controlled performance benchmark. The complete
run, including both bridges and higher-order evaluations, spans
18:51:18--19:00:15 JST.

### Reuse and next step

For the next independent study, use the checked driver with the following
explicit controls, and retain the same final qualification:

```r
n <- nrow(fixture$response)
fit <- testlet_controlled_fit(fixture, start,
  control = list(maxit = 250L, fnscale = n, factr = 0, pgtol = 5e-6 / n))
```

The separate driver in the [runner](local-testlet-optimizer-controls-0.2.4.R)
keeps the original evaluator and its source identity available for the
completed pilot. The native `fnscale` mechanism scales both likelihood and
gradient internally; reported likelihoods, scores and readiness thresholds
remain on the original total-likelihood scale. No custom optimizer or change
to the probability model is needed.

Move next to new independent datasets generated under a frozen version of
this setting, comparing known and estimated calibration with failures retained.
Do not pool the repaired fitting subset into the old coverage results: these
datasets helped select the optimizer controls, and no intervals were computed
in this follow-up. Stop adding numerical variants to the same examples unless
a new discrepancy justifies one. Shared random-rater estimation, calibration-
uncertainty corrections and equal-budget rating-design comparisons continue
to require their own research designs.

### Files and source identities

- [Selected datasets](local-testlet-optimizer-controls-0.2.4-selection.csv),
  [all comparison rows](local-testlet-optimizer-controls-0.2.4-rows.csv),
  [counts and decision](local-testlet-optimizer-controls-0.2.4-counts.csv),
  and [read-only audits](local-testlet-optimizer-controls-0.2.4-audit.csv).
- [Portable evidence](local-testlet-optimizer-controls-0.2.4-evidence.rds),
  approximately .887 MB, includes the frozen plan, all selected generated data,
  the original fit records, both bridges, all 69 new fits and 66 higher-order
  evaluations, and aggregate results. All failed histories are retained.
- [Aggregator](local-testlet-optimizer-controls-0.2.4-summary.R): from the
  development repository root, run
  `Rscript inst/validation/local-testlet-optimizer-controls-0.2.4-summary.R`
  to read the raw checkpoints in
  `validation-results/local-testlet-optimizer-controls-20260917/` without
  refitting or reevaluation. The evidence RDS is independently inspectable.

The runner MD5 is `bf874cec3c9fd7538e531eba3544a69a`; the input pilot evidence
MD5 is `217d865d64e122ad22165cd14124bd85`. The plan stores all six numerical
source hashes and its pre-run text. The aggregator records its own MD5 in
the evidence. Parent commit is `0dc2c75`; execution uses R 4.6.1 on
`aarch64-apple-darwin23`. The original pilot source/data/evidence hashes are
unchanged. No full-package suite, TAM comparison, FairZ experiment or person
coverage calculation was rerun, and no production API or dependency changed.
