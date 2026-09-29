# Fixed GPCM calibration: TAM scoring comparison

## Question and scope

Can the existing mfrmr fitted-object scorer and TAM compute the same new-Person
EAP and posterior SD when the *entire* GPCM calibration and normal scoring prior
are held fixed, including separate slope/step owners?

This is preparatory evidence for the roadmap's portable-scoring work, not a
portable calibration implementation, an inference qualification or a release
decision. It does not establish agreement between freely estimated many-facet
models. No training responses were reused and no calibration was reestimated.

The [runner](gpcm-fixed-scoring-tam-20260926.R) uses two retained synthetic fits:
the shared-Rater-owner `refit-788.rds` and the separate Criterion-slope/Rater-step
`n120-complete-01.rds`. The first has nine rating contexts and scores coded 1–3;
the second has six contexts and scores coded 0–2. Their fitted estimates and
population parameters are fixed numerical inputs, not new truth/recovery data.
Both fixtures have an intercept-only estimated normal population, positive
slopes, additive negatively signed facet locations and three categories. The
comparison admits no interactions, weights or new facet levels. It does not
override either source fit's uncertainty/readiness decision.

## Coordinate and input contract

For rating context j, slope a_j, summed facet location d_j and steps t_jh,
the native cumulative category predictor is

    a_j * [k * (theta - d_j) - sum(h=1..k, t_jh)].

Write theta = mu + sigma*z, z ~ N(0,1). Supply TAM with

    AXsi[j,k] = a_j * [k * (mu - d_j) - sum(h=1..k, t_jh)]
    B[j,k]    = k * sigma * a_j.

The zero category has AXsi = B = 0. A separate fixed intercept is supplied for
each nonzero category/context using an explicit A design. All xsi parameters,
category scores B, population regression and variance are held fixed and their
returned values checked. `tam.mml()` evaluates this fixed generalized-item
model; it is not a free many-facet slope fit through `tam.mml.mfr()`.

Four newly constructed response patterns per fixture cover all-low, all-high,
mixed complete and incomplete known-context responses. Missing contexts are
omitted identically in both inputs. The native score map restores the original
response codes before `predict_mfrm_units()`; TAM uses category indices 0–2.
The existing scorer is called with `readiness_policy = "review"` and no draws;
this numerical comparison does not authorize a source calibration for freezing.

Transform TAM EAP by mu + sigma*EAP and its posterior SD by sigma*SD.
Those are conditional posterior summaries, not JML estimates, calibration SEs
or intervals carrying calibration-estimation uncertainty. Each program uses
its own probability/scoring implementation. A third scalar adjacent-logit
calculation checks TAM category probabilities over every evaluated grid node.

## Numerical criteria and results

Before execution, the runner set maximum probability difference 1e-11,
EAP/SD difference 1e-6 native units and within-engine grid change 1e-7.
These are engineering agreement criteria for double-precision stored inputs,
not empirical calibration-accuracy or statistical coverage thresholds.
The exact fixed-parameter probability map is checked more tightly; different
integration rules additionally need the stricter within-engine stability check.

TAM 4.3-25 used 121 and 181 equally spaced nodes over [-9,9]. The initial
mfrmr 61/101-node comparison gave a maximum EAP/SD grid change of 5.45e-7 for
the separate-owner fixture, failing the declared 1e-7 criterion even though
cross-engine agreement at 101 nodes was close. That failure and its manifest
are preserved in `initial-61-101/`. The subsequent 101/141-node comparison
passed the *same* criteria; neither the tolerances nor fixtures were changed.

| Owner arrangement | Maximum probability difference | Maximum EAP difference | Maximum posterior SD difference | mfrmr 101/141 change |
| --- | ---: | ---: | ---: | ---: |
| Shared Rater owner | 4.44e-16 | 8.04e-14 | 1.98e-13 | 8.27e-11 |
| Criterion slopes, Rater steps | 3.33e-16 | 1.19e-12 | 2.56e-13 | 4.15e-10 |

TAM's maximum within-engine changes were below 4.6e-15. All four response
patterns in both fixtures enter the maxima. This checks eight conditional
scores, not eight independently fitted calibrations or repeated-sample accuracy.
The result demonstrates a useful fixed-model representation even though the
standard freely estimated additive-intercept comparison is a different model.
It does not choose a universal quadrature order or alter the public default.

## Remaining work and retained evidence

The corresponding local ConQuest anchor/scoring comparison remains open.
So do cross-engine posterior interval endpoints, a standalone artifact schema,
save/load and fresh-session artifact-only scoring, unknown-level/input refusal,
and end-to-end user documentation for a new portable GPCM API. The existing
fitted-object scoring route is what was checked here. Profile intervals and
calibration-aware Person uncertainty are independent tasks.

Outputs are in `validation-results/gpcm-fixed-scoring-tam-20260926/`:
`manifest.rds`, `results.rds`, `summary.csv`, and the initial grid-review record.
The adjacent `.log` retains the final execution output. The manifest records
R-source/runner and fixture hashes, source commit, TAM version and session.
Package R code is unchanged from main `08a5ee9b`; only the roadmap and
repository-only comparison files change. No full package suite or simulation
grid was rerun. Existing scripts remain runnable without a new public API.
