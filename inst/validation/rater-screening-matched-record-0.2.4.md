# Rater-screening performance: matched-budget local evaluation

Date: 2026-09-23. Active roadmap row 2b. This record supports the local
expanded-workflows source. It does not mark the broader accuracy request or
the 0.2.4 roadmap complete, and does not change main or any published release.

## Question and procedure

At a fixed scheduled rating budget, how does the existing Infit/Outfit union
screen behave under different linking patterns, assignment by ability, and
missing assigned scores? The target departure is independent random-category
contamination by one observed fixed rater. Severity differences alone are not
misfit; Rater-by-Group DRF, post-selection inference and training effectiveness
are not evaluated.

The public `mfrm_screening_performance()` accepts the full planned roster and
known truth plus logical flags, retaining omitted/unavailable results. It
reports per-target conditional sensitivity/false flags and per-replication
any-affected/any-unaffected events. A partially observed family is known positive
if any observed member is positive; otherwise missing members leave its event
unknown. Exact binomial Monte Carlo intervals describe independent replications,
not independent raters. All-trial bounds assign unknown outcomes negative or
positive and are not confidence intervals. Plot data and source rows are retained.

The existing signal evaluator also now preserves unavailable bias t/p and
descriptive-only DIF classifications. Its target summaries retain unrounded
values, counts and exact bounds. Earlier non-target averages cannot reconstruct
unavailable cells, so they are withheld rather than silently repaired. Saved
target metrics permit re-summarization without new model fitting. These changes
do not turn screening t/p values into calibrated inferential tests.

## Prespecified design and execution

The protocol was written in `internal-roadmap-0.2.3.md` before new outcomes.
The executed runner is `rater-screening-matched-0.2.4.R`. Outputs are in
`validation-results/screening-performance-20260923/`. `protocol.rds` retains
seeds, conditions, the complete roster, source hashes and the session. Its
hash-matching source files were copied to `executed-source/` before subsequent
documentation, input-validation and plot-layout edits. `replicate-1.rds` through
`replicate-100.rds` retain all results and the original source identity.

- 120 independent normal-ability persons, six fixed raters, three criteria,
  categories 0–3. Rater values (-.8,-.4,-.1,.1,.4,.8), criterion values
  (-.3,0,.3), shared steps (-1,0,1).
- Two raters per person: 720 scheduled ratings, 120 per rater. Rotating pairs
  follow (1,2),(2,3),(3,4),(4,5),(5,6),(6,1). Weak bridges retain the workload
  while placing 60 persons within each of two rater triangles. Two swapped
  assignments form (1,4) and (2,5); only two persons connect the panels.
- Five scenarios: normal null; R6 response replaced by an independent uniform
  category with probability .5; ability-ranked assignment null; MCAR null;
  score-dependent nonresponse null. The last three remain null for rater
  response inconsistency, not necessarily for the fitted analysis assumptions.
- Missingness removes exactly 144 assigned scores, leaving 576 observations.
  MCAR samples uniformly. Selective nonresponse uses exponential-race weighted
  sampling without replacement, weight four for generated zeros and one otherwise.
  A fixed independent random stream pairs scenarios and assignments. Nonassigned
  combinations remain absent. Observed scores alone enter the fits; no MI used.
- MML/RSM with 61 quadrature points, maxit 400 and the original full score ladder.
  Fit readiness and descriptive screen computability are recorded separately.
  The declared screen is Infit OR Outfit outside [0.5,1.5], with three-valued
  logical OR, all six raters, no selection, exclusion or refitting.
- 100 independent replications per cell, seeds 2026092301–2026092400, paired
  across ten cells. No sample, threshold, seed or generator tuning after results.
  Five execution preflights used a seed outside that range and are excluded.
- Reused 200 rotating null/contamination pre-selection screens from the A12
  archive, with unchanged generator/estimation/diagnostic source checks. Their
  target flags are exactly recoverable because every screen was available,
  every unaffected-family event was false, and the affected R6 flag was stored.
  The original files and hashes are retained. Raw Infit/Outfit values were not
  retained in those archives, so their reused metric columns stay NA rather
  than being fabricated. Another 800 datasets were fitted; no prior removal or
  refitting stage was rerun or pooled as extra independent evidence.

## Results and answer

| Scenario | Rotating any false flag | Weak bridge any false flag | R6 detection, rotating / weak bridge |
| --- | ---: | ---: | ---: |
| Normal null | 0/100 | 0/100 | Not applicable |
| Inconsistent R6 | 0/100 | 0/100 | 6/100 / 2/100 |
| Ability-linked null | 0/100 | 0/100 | Not applicable |
| MCAR null | 0/100 | 1/100 | Not applicable |
| Score-dependent null | 0/100 | 0/100 | Not applicable |

Exact pointwise 95% Monte Carlo intervals: 6/100 = 2.23–12.60%; 2/100 =
0.24–7.04%; 1/100 = 0.03–5.45%; 0/100 = 0–3.62%. The paired weak-minus-rotating
detection difference is -4 percentage points, MCSE 2.81 points. The small
comparison does not establish a general ordering of assignments. Zero paired
MCSE when all observed differences are zero likewise does not establish equality.

All 6,000 target flags and all 1,000 complete rater screens were available;
there were no recorded execution errors. 997 fits passed inference readiness.
Three selective-nonresponse fits required category-support review: rotating
seeds 2026092350 and 2026092400; weak-bridge seed 2026092353. Their data, fits and
warnings are retained, with the originally declared descriptive screens. No
eligibility threshold was relaxed and no failed/unready trial was replaced.

The screen rarely warned about unaffected raters in these cells, but missed
94% and 98% of the specified contaminated-rater cases. Therefore its low false
flag frequency is insufficient evidence of useful diagnostic accuracy. No warning
does not certify rater quality. The study does not qualify other thresholds,
effect strengths, target types, rater counts, response models, disconnected
designs, response-imputation procedures, or automatic exclusion.

`by-target.csv`, `by-family.csv`, `target-outcomes.csv`, `run-status.csv`,
`paired-family.csv` and `performance.rds` preserve exact results. Correlated
targets are not counted as additional independent simulation replications.

## Verification and remaining work

Focused checks exercise unavailable and omitted trials, partially observed
families, exact boundary intervals, key matching, malformed inputs, saved
objects, plots and DIF/bias migration. Relevant existing signal-evaluator
regressions and namespace registration are checked separately. The new tutorial
executes the public fitting/diagnostic route and renders its plot; changed
reference pages, NEWS, README and roadmap are rendered locally. Verification
logs record the actual outcomes; no whole-package suite, earlier simulation
campaign, hosted CI or release publication is included in this scope.

Final focused checks: 70 new screening expectations, 184 related existing
signal-evaluation expectations and four namespace expectations passed without
failures, errors, warnings or skips. After the saved-DIF repair, the two core
existing signal tests were rerun (39 expectations, a subset of those 184).
The tutorial's six illustrative null fits returned all 24 target flags and
passed inference readiness. Ten rendered pages and 21 new-topic links were
checked; no internal paths were exposed. The local site is a partial preview,
not a full website build. The public source-truth check and `git diff --check`
passed. See `verification.json`, the test result objects and page audit beside
the study results for the checked source identity and scope.

Row 2b has an implemented evaluation tool and this bounded comparison. General
diagnostic accuracy, DRF qualification and threshold calibration remain open.
The next model deliverable is row 3a's identified random-rater likelihood and
distinct observed-rater versus replacement-rater targets. Do not extend this
study with neighboring simulations simply to avoid that model work.

## User-requested threshold and overfit stress audit, 2026-09-23

The user explicitly requested varied simulation conditions, multiple thresholds,
overfit-warning review, visualizations, help and mathematical scrutiny. This
bounded follow-through concerns ordinary fixed-rater diagnostics (M1/M2/M4).
It does not implement or qualify M3 extended-model posterior diagnostics.

**Protocol and reuse.** `rater-threshold-stress-0.2.4.R` fixes nine conditions,
100 independent seeds (823001--823100), five bands ([.4,1.2], [.5,1.5],
[.6,1.4], [.7,1.3], [.8,1.2]), three directions (upper, lower, either) and
Infit/Outfit separately or jointly. It compares MnSq alone with MnSq OR
directional ZSTD at +/-2, for engine and fourth-moment conventions. The
protocol and selected fitting/diagnostic source hashes were saved before the
900 production fits; computational preflights used seed 823000 and are not
included. No threshold, generator, seed or sample-size tuning followed outcomes.
No rater exclusion or refitting is part of the screen.

The conditions are 60-person complete crossing; 60- and 600-person rotating
assignments; 120 persons/12 raters; 120 persons/6 raters with exactly 60% MCAR
assigned-score omissions; 50% uniform-category replacement for R6; 75%
model-modal replacement for R6; Person-by-rater normal local effects with SD 1;
and two rater panels without shared Persons. Apart from crossing, Persons have
two raters and three criteria. Abilities follow the known standard normal;
severities are equally spaced over [-.8,.8], criteria (-.3,0,.3), shared steps
(-1,0,1), and scores 0--3. The analysis is ordinary RSM MML with 61 quadrature
points, maxit 400. Local dependence is a departure for all raters, not evidence
of one bad rater. Disconnected rater panels still share the fixed criteria and
common ability-population assumption: the package's full facet graph can report
one component, while the free-Person identification warning remains relevant.

The earlier matched-budget study supplied another 800 raw-statistic fits for
reanalysis, without fitting. The 200 legacy trials lacking raw statistics
remain in the roster as unavailable for changed thresholds; their old binary
flags cannot be reused as if they implied full statistics. They are not extra
independent replications. A reused weak-bridge null gives low-side family flags
in 57/100 trials at lower=.7 and 99/100 at lower=.8.

**Outcome and decision.** At [.5,1.5], any-unaffected-rater low-side flags were:

| Null condition | MnSq only | MnSq or engine ZSTD | MnSq or fourth-moment ZSTD |
| --- | ---: | ---: | ---: |
| Small crossed | 0/100 | 44/100 | 48/100 |
| Short sparse | 1/100 | 59/100 | 71/100 |
| Large sparse | 0/100 | 100/100 | 100/100 |
| Twelve raters | 1/100 | 88/100 | 96/100 |
| Heavy MCAR | 24/100 | 92/100 | 96/100 |
| Disconnected panels | 0/100 | 93/100 | 96/100 |

Exact pointwise 95% Monte Carlo intervals include [0,.0362] for 0/100,
[.1602,.3357] for 24/100, and [.9638,1] for 100/100. They describe independent
replications, not independent raters or simultaneous error control across
profiles. Paired engine-minus-MnSq differences at [.5,1.5] are .44 (MCSE .0499)
for small crossing and .68 (.0469) for heavy MCAR. Large sparse has all 100
discordant pairs, difference 1 and observed MCSE 0; that boundary value does
not mean the population difference is known without uncertainty.

R6 random-category detection with MnSq-only was 2/100, 11/100, 39/100 and 65/100
for [.5,1.5], [.6,1.4], [.7,1.3] and [.8,1.2]. Predictable-R6 detection was
65/100, 96/100, 100/100 and 100/100. The asymmetric [.4,1.2] band gives 65/100
random-category detection but only 18/100 predictable-R6 detection. The tighter
lower bounds also greatly increase null low-side flags. No best band was chosen.
The full directional and per-target results include local-dependence responses
and wrong-direction warnings; union sensitivity must not hide those directions.

All 900 fits passed numerical readiness, with zero execution errors and 6,000
finite Infit/Outfit pairs. Only 741 passed broader inference readiness: 100
disconnected-panel, 26 heavy-MCAR, 13 twelve-rater, 12 short-sparse and eight
predictable-R6 fits require review. Their descriptive screens remain under the
prespecified computability rule. The runner retains warnings and readiness
booleans for all runs, full fits/diagnostics for the first replicate of each
condition and execution failures; it does not retain every fit's full readiness
detail. No failed or unready trial was replaced or silently removed.

**Mathematical audit.** At unit weights, reconstruction from observed-minus-
expected residuals reproduced the returned Infit/Outfit with maximum absolute
difference 2.553513e-15 (prespecified tolerance 1e-10). With fixed correct
probabilities, E[(Y-mu)^2]=V and the nominal mean-square expectation is one.
Estimated EAP plug-in residuals do not inherit that reference distribution.
In the large sparse null the fitted mean Infit/Outfit was .831944/.806094,
while generating-parameter references were 1.001095/1.000602. Heavy MCAR gave
.704066/.689479 versus 1.002247/1.003995. Per-replication averages and MCSEs are
retained. This isolates a discrepancy between the two procedures, not every
individual mechanism behind it. Correct arithmetic does not calibrate a ZSTD
test or a threshold, and changing df conventions did not remove the problem.
Extended-model moments still require their own joint latent integration and
both total-variance terms; none of these ordinary cutoffs is transferred.

**Implementation and user contract.** `fit_measures_table()` now defaults to
MnSq-only directional labels, retaining ZSTD/df columns and an explicit
`ZSTDOnly` indicator. `flag_basis="mnsq_or_zstd"` requests the earlier combined
rule. Unknown indices no longer establish a negative screen; `ScreenComplete`
remains visible, and negative/nonfinite mean squares are unavailable. Main and
profile tables use the same classifier. Summary guidance prioritizes upper-side
MnSq departures, and low residual variability is not equated with poor rater
quality, misconduct or a need for exclusion. Saved ordinary reports record the
actual flag basis; older saved bundles without this field retain the earlier
combined-rule interpretation rather than being relabeled as MnSq-only.

`mfrm_screening_sensitivity()` reuses the planned-roster performance evaluator
for every declared band and direction. Three-valued flags preserve unavailable
results and partially known family events. Its tile/curve figures expose counts,
pointwise Monte Carlo intervals, exact source tables, alternative text and
display controls, with ggplot and monochrome options. Positive small rates are
not rounded to a displayed zero. Tile text chooses black/white by relative
luminance; sampled colour/monochrome backgrounds meet 4.5:1 for text, following
the W3C contrast definition. This is not a full accessibility-conformance audit.

**Verification.** Focused comparison/formula/threshold/report/namespace tests
passed (667 expectations before final display-boundary additions). The final
53 targeted expectations cover small rates, unavailable cells, contrast, hidden
annotations and replay. A complete six-fit tutorial ran once; later rendering
reuses that saved demonstration. Seven help topics render, with new-topic link
warnings resolved after first generation. Actual null/detection figures were
visually inspected. Saved ordinary reports and legacy flag-basis provenance
were replayed without refitting. Validation harness errors (an initial helper
filename and a summary-script parenthesis) were corrected before the affected
checks executed; no simulation replication was rerun because of them. A final
CSV check initially inferred the all-empty error column as logical NA;
declaring its character type corrected the check, without repeating the tests
or simulation. Actual ggplot tile/text contrasts were also checked (sampled
minima 5.33:1 colour and 4.70:1 monochrome), and saved-diagnostic console
follow-up correctly prioritized upper-side mean squares.

Evidence is `validation-results/rater-threshold-stress-20260923/`: frozen
protocol/source, all 100 replication files, raw measures/status, nine rule/index
summaries, paired comparisons, generating-parameter references, reused evidence,
help/tutorial rendering, plots, replay, focused logs and source hashes/diff.
Public tutorial figures are in `vignettes/figures/screening-*-stress.png`.
Published context is Linacre (2003), https://www.rasch.org/rmt/rmt171n.htm,
and Wright & Linacre (1994), https://www.rasch.org/rmt/rmt83b.htm; neither
provides a universal rater threshold. Mean-square calculation is checked against
Wright & Masters' definition, https://www.rasch.org/rmt/rmt34e.htm.

This audit changes a misleading default classification and documents serious
remaining diagnostic limitations; it does not qualify universal accuracy,
extended-model fit bands, capacity ceilings or interval coverage. Return to
M3's joint posterior response moments and descriptive diagnostics without adding
another adjacent simulation grid. M2's interval/MI qualification and M5 local
integration remain open. No full package suite, commit, push, CI or publication
was performed.
