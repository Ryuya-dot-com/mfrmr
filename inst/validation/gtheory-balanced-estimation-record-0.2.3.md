# Draft.82 balanced univariate G-study estimation record

Status: completed repository-only balanced estimator prototype, 2026-08-09.

## Decision

Draft.82 passes its narrow balanced-estimation structural gate. The new
prototype recovers the frozen p x i and p x r x i raw components through an
independently coded orthogonal expected-mean-square inversion, agrees with a
saturated base-R `lm` ANOVA decomposition, and reduces to local `lme4` REML on
interior balanced fixtures. ML remains separately identified and numerically
different. A negative raw MoM component and a constrained lme4 boundary zero
are both reproduced without relabelling one as a correction of the other.

The exact current main-effects/collapsed-residual lme4 identity also reproduces
the current public `mfrm_generalizability()` component values on the same rows.
It is not allowed to enter the typed interaction-specific D-study path.

This is point-estimation and reduction evidence only. Every inference and
decision-ready field remains false. No public function or package dependency
changed.

## Environment and execution

- R 4.6.1
- lme4 2.0.6
- reformulas 0.4.4
- digest 0.6.39
- Draft.81 design/algebra contract `gtheory_design_algebra_draft81_v1`
- Draft.82 estimation contract `gtheory_balanced_estimation_draft82_v1`

The dedicated command was:

```sh
Rscript -e 'devtools::load_all(quiet=TRUE); testthat::test_file("tests/testthat/test-gtheory-balanced-estimation-prototype.R", reporter="summary")'
```

Result: seven tests and 71 expectations passed without failure, warning, skip,
or error.

## p x i interior fixture

The complete 18-Person x 6-Item fixture has one observation per cell. Its MoM
components are exactly:

| Component | MoM | lme4 REML | lme4 ML |
| --- | ---: | ---: | ---: |
| Person | 1.0000000 | 1.0000047 | .9570665 |
| Item | .2000000 | .2000019 | .1812493 |
| Residual p:i,e | .8000000 | .7999990 | .8007693 |

The largest MoM--REML difference is below `4.8e-6`. Both REML and ML are
interior, but ML differs from REML by about `.043` on at least one component;
they are not pooled.

At `n_i=4`, the typed MoM D-study returns `G=5/6` and `Phi=4/5` with
`AlgebraReady=TRUE`, `InferenceReady=FALSE`, and `DecisionReady=FALSE`.

Identity hashes:

- data: `ca2b9cd70b864432cb4c9560f5cb5c1490d61eeee1622d0c41e4d117124a3f58`
- MoM: `1a0233f910aefbeceb7c4238f889b52481a33cd366c2c1debe40efe84ebc4207`
- REML: `cad58ff627b710c9250f204b2766f967b29aee89cb2a8014c516705177c08b25`
- ML: `107563d1161b3b1918a740aa47b26421a3811917bab47a1a91f3da7aa18dcfdb`
- estimator-bound D-study:
  `c2318bf4d16b030379a6be454d5100e02b337eacfb0bc41771f02ca07b7db0f5`

## p x r x i interior fixture

The complete 16-Person x 4-Rater x 5-Item fixture has one observation per cell.
The raw MoM vector exactly reproduces:

```text
p=1, r=.12, i=.18, p:r=.24, p:i=.30, r:i=.08, p:r:i,e=.48
```

The lme4 REML vector is respectively `1.00001171`, `.11999643`, `.18000012`,
`.23999733`, `.30000256`, `.07999942`, and `.47999994`. The maximum
MoM--REML difference is below `1.2e-5`; the fit is nonsingular with optimizer
code zero. ML differs from REML by about `.039` on at least one component.

For the Person mean square, the retained EMS equation is:

```text
MS_p = 1 * sigma2_pri,e
     + 5 * sigma2_pr
     + 4 * sigma2_pi
     + 20 * sigma2_p
     = 22.88
```

The independently reconstructed effect sums of squares and mean squares match
the saturated `lm(Score ~ Person * Rater * Item)` ANOVA terms. The orthogonal
effect sums close to the corrected total (`722.72`) within `1.2e-13`, well
inside the stored `7.23e-8` audit tolerance.

At `n_r=2`, `n_i=3`, the MoM D-study gives relative error `.30`, absolute
error `13/30`, `G=10/13`, and `Phi=30/43`.

Identity hashes:

- data: `b4bbd6625e3035661dc75ca139e95a1a156c7232cf312cf837748809ef600f74`
- MoM: `1462cbe88aad24f39621cade31e45205181480a97f6b2c7a48effb3eec5bd677`
- REML: `c974b85f669c89d7da6d2f9b2c9d67a6fedd88258d665c8f21586003efc5bde6`
- ML: `b4a8ffa6f9cf7b440dafe58d0197ffb3c9527229d271fdf2f7b8f7a48b32b605`
- estimator-bound D-study:
  `09fe5acda1291c2b18596530b2e59dd9a19452908bf9966e69d2b97b945eea26`

## Raw-negative versus constrained-boundary fixture

The complete p x i negative control produces:

| Component | Raw MoM | MoM state | lme4 REML | REML state |
| --- | ---: | --- | ---: | --- |
| Person | .86666667 | `interior_raw` | 1.096262 | `interior_constrained` |
| Item | -.04444444 | `negative_raw` | 1.78e-33 | `constrained_zero_boundary` |
| Residual | .80000000 | `interior_raw` | .730841 | `interior_constrained` |

The lme4 optimizer code is zero, while `isSingular()` is true and the fit state
is `boundary_or_singular`. Its nonnegative point is a constrained REML result,
not the raw MoM solution and not a post-hoc modification that could still be
called an unconstrained maximum. Conversely, the raw MoM vector maximizes no
likelihood. Its D-study transformation remains inspectable but is
`raw_negative_component`, `AlgebraReady=FALSE`, and decision-ineligible.

Identity hashes:

- data: `290f0b5512830e433c638cbb320c82eeb86bbf21c4e16af167db7d4d320a235d`
- MoM: `2bc6d40c875b2dfd62b884dd40639414748f739008458c59531635dbf7ff3058`
- REML: `e7e18d679d961ad139b713ec647da9c7a79a1717d98f051d1048db133c049dca`

## Compatibility result

On the p x r x i interior data, the internal
`main_effects_collapsed_residual_v1` fit gives:

```text
Person=1.0961869, Rater=.1450534, Item=.2113210, Residual=.9559596
```

After the public helper's documented six-decimal rounding, all four values
equal `mfrm_generalizability()` on the same data and REML choice. The collapsed
result hash is
`bae68afb29f581eb09a4c09b349a18b7fbbe83bf3bd59c97511f082b826d6ba5`.
The typed model retains seven components and a different identity; numerical
output from one model cannot silently authorize the other's D-study algebra.

## Remaining gates

Draft.82 is not a recovery study: the fixtures were constructed to have known
orthogonal mean-square solutions. It supplies no bias, RMSE, coverage,
false-ready rate, sample-size recommendation, estimator preference, or
uncertainty method.

Draft.83 must now introduce nesting and incidence/rank semantics, partially
crossed and disconnected controls, unequal replication/allocation operators,
missingness identities, workload imbalance, and component-specific failure
accounting. Draft.84 remains responsible for joint full-refit uncertainty.
