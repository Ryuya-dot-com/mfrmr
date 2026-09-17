# Local-testlet evaluator speed qualification, 2026-09-17

## Question and prespecified scope

Can the existing research evaluator avoid recomputing item probabilities for
every person without changing its likelihood, scores, or posterior moments?
The N = 120 evaluation in the information experiment took 12.635 seconds at
GH181. That single timing motivates this experiment; it is not a benchmark.

Only person-independent calculations will move outside the person loop. The
normal quadrature, tail weights, log-scale integration, person-by-rater latent
ownership, optimizer settings, and qualification tolerances remain unchanged.
There is no cache across evaluations or pooling of responses across persons.

Before editing, the three old evaluator function bodies were saved from commit
`90917aa` in `validation-results/local-testlet-speed-20260917/baseline.R`, with
source hashes and parent commit in `baseline-provenance.rds`. The baseline and
new implementation will use the same unchanged quadrature helpers. This is an
implementation-equivalence check, not a new independent likelihood validation.
The previous TAM comparisons supply that separate evidence.

## Checks specified before execution

- Compare old and new results at the three saved fitted points (original,
  clustered, and zero-variance boundary), at GH181.
- Compare the 24 previously specified numerical stress fixtures at GH241,
  including tiny variance, variance 16, alpha +/-40, and missing observations.
  These are comparisons at the same quadrature nodes, not repeat searches for
  quadrature convergence or new TAM fits.
- Compare N = 1, 7, 17, and 120 repeated fixtures at GH181 against the saved
  information experiment, and a deterministic, heterogeneous N = 120 fixture
  against the frozen evaluator. The heterogeneous fixture selects 120 distinct
  complete rows evenly from all 729 six-item response patterns; a second copy
  has every thirteenth matrix entry missing.
- Require absolute differences <= 1e-9 in total/person log likelihood and
  posterior moments; structural/log-variance scores <= 1e-9. Direct variance
  scores use <= 1e-6, including division by tiny positive variance. Check names,
  dimensions, and row order as well. The exact right derivative at zero must
  match within 1e-9. Record errors and warnings without hiding failed cases.
- After numerical comparisons, time both evaluators in alternating order for
  three repetitions on repeated, heterogeneous, and heterogeneous-with-missing
  N = 120 at GH181. Report medians and all raw times. A median speedup of at
  least 2 on each fixture is the practical target, not a statistical claim.
- Exercise the unchanged bounded optimizer on one original fixture from the
  original initial parameters, and from the saved clustered/boundary solutions.
  Require no capture error, native convergence 0, projected score <= 1e-5,
  fitted parameter difference <= 1e-4, log likelihood <= 1e-7, and moments
  <= 1e-5 against the saved solutions. Do not rerun their earlier multistart,
  information, TAM, full-package, or FairZ experiments.

## Interpretation limits

This is repository-only code for two raters, three criteria, and categories
0/1/2. Faster evaluation does not establish recovery, coverage, identification,
new-person prediction, or a crossed random-rater model. No public API, interval
eligibility, or production estimator changes are included.

## Implementation

`stress_reference()` now builds the six item probability tables and their
structural derivatives once per call. The three-category logit maximum uses
base R `pmax()` instead of invoking `max()` separately for each row. The
person loop still forms each person's conditional likelihood and score from
their observed responses, integrates each of their two independent local
effects, and then integrates their shared ability. The zero-variance right
derivative similarly reuses item probabilities while retaining the same
per-person curvature calculation.

This removes repeated work without a response-pattern cache, a persistent
cache, new dependencies, or a change to quadrature accuracy. The six retained
probability tables require storage proportional to the square of quadrature
order, independent of person count; this experiment does not benchmark memory.

## Results

All **238 planned checks passed**. All 33 fixed-point comparisons had exactly
zero reported numerical difference in total/person likelihood, structural and
variance scores, and posterior moments. Names, dimensions and row order also
matched. This includes the exact right derivative at zero, the tiny positive
variance cases, the extreme tails and the missing-response cases. No warnings
or captured errors occurred in these comparisons, timings, or fit bridges.

Each timing below is the median of three measured evaluations at GH181, on
R 4.6.1, aarch64-apple-darwin23. Warmups were excluded and execution order
alternated. The parameters are the saved original positive-variance solution.

| N = 120 response table | Distinct rows | Old seconds | New seconds | Speedup |
|---|---:|---:|---:|---:|
| Original six rows repeated | 6 | 12.722 | 1.098 | 11.59 |
| Heterogeneous complete rows | 120 | 13.516 | 1.170 | 11.55 |
| Heterogeneous rows with missing entries | 120 | 12.561 | 1.088 | 11.55 |

Thus the improvement does not depend on repeating identical responses. These
are local measurements, not a guarantee for other machines, quadrature orders,
or all inputs. In the single warmup comparison, the N=6 zero-variance case took
0.022 versus 0.024 seconds, and the all-missing reference took 0.037 versus
0.057 seconds: precomputing unused tables can add small overhead. All-missing
data remain rejected by the estimator and unsupported by the tested TAM path.

| Optimizer bridge | Start | Evaluations | Code | Projected score | Max parameter difference | Seconds |
|---|---|---:|---:|---:|---:|---:|
| Original | Original initial parameters, v=.49 | 21 | 0 | 6.50e-6 | 8.08e-7 | .820 |
| Clustered | Saved solution | 1 | 0 | 3.33e-7 | 0 | .041 |
| Zero boundary | Saved solution | 1 | 0 | 1.67e-7 | 0 | .019 |

The largest fitted log-likelihood difference was 4.74e-12 and posterior-moment
difference 6.69e-7. The original bridge takes a new path from its starting
parameters; the other two check stopping and evaluation at saved solutions.
They are not additional multistart searches. No old TAM, information-matrix,
full-package, or FairZ experiments were repeated. The old evidence, including
the boundary line-search failure, remains intact.

The bounded implementation objective is met. Further caching is unnecessary
for this step. The next research decisions concern propagation of population
parameter uncertainty into person estimates, appropriate inference at variance
zero, and a declared recovery study. Faster computation alone resolves none of
those questions, and this experiment did not fit a new N=120 dataset.

## Evidence and reproduction

- [Checks](local-testlet-speed-0.2.4-checks.csv),
  [all timings](local-testlet-speed-0.2.4-timings.csv), and
  [timing summary](local-testlet-speed-0.2.4-summary.csv).
- [Portable evidence](local-testlet-speed-0.2.4-evidence.rds) contains the
  pre-execution plan, old function bodies and hashes, all comparison inputs and
  outputs, individual timings, optimizer histories, and final checks.
- Raw checkpoints and console output are retained in
  `validation-results/local-testlet-speed-20260917/`.
- Evaluated source MD5: stress `812999e7da7ecbbdbb654974529058aa`,
  estimation `e599de0ca8fed081da0b3f519505d690`,
  runner `60609a956a7036caf85595ef257c40c0`.
  The original TAM reference remains `6bacb70c9d4c0fba27bef70a508f0f88`.
  Sources were unchanged throughout the run.

From `development/`, run
`Rscript inst/validation/local-testlet-speed-0.2.4.R` when the retained raw
inputs are present. A fresh checkout can restore missing inputs from portable
evidence with the following R code before running the experiment:

```r
x <- readRDS('inst/validation/local-testlet-speed-0.2.4-evidence.rds')
out <- 'validation-results/local-testlet-speed-20260917'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
if (!file.exists(file.path(out, 'baseline.R')))
  writeLines(x$plan$baseline_source, file.path(out, 'baseline.R'))
if (!file.exists(file.path(out, 'baseline-provenance.rds')))
  saveRDS(x$plan$baseline_provenance, file.path(out, 'baseline-provenance.rds'))
prior <- 'validation-results/local-testlet-information-20260917'
dir.create(prior, recursive = TRUE, showWarnings = FALSE)
for (id in paste0('N', c(1, 7, 17, 120))) {
  path <- file.path(prior, paste0(id, '.rds'))
  if (!file.exists(path)) saveRDS(list(fixture = x$comparisons[[id]]$fixture,
    evaluated = x$comparisons[[id]]$old), path)
}
```
