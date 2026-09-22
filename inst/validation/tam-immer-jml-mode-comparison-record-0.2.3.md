# TAM/immer/mfrmr matched JML mode smoke record for mfrmr 0.2.3

Status: Draft.75 repository-only calibration record, 2026-08-09.

## Runtime identity

The smoke used R 4.6.1, development mfrmr 0.2.3, TAM 4.3-25, and immer
1.5-13. Loaded function identities were:

| Engine/function | SHA-256 of loaded formals/body |
| --- | --- |
| `mfrmr::fit_mfrm` | `ffa3802190772b30c04f2d1afe3e6a58968248e2c0981a32da5185b75a98582e` |
| `TAM::tam.jml` | `7b131ddd1d333673cc3103e7d24178afb8e86781d95e2947c4c00a877c725386` |
| `immer::immer_jml` | `31163e6eedba375989dbd14f7d4b270a9379839fddde25be43c5ee997a09692b` |

The package help and loaded source confirmed the exact adjustment and bias
identities before results were interpreted.

## Execution accounting

Four paired datasets crossed RSM/PCM with forced extreme fractions 0 and
0.125. Each had 64 Persons, 3 Raters, 3 Criteria, 9 responses per Person, and
27 cumulative-difficulty coordinates. Thirty-six mode rows were planned.

All required modes returned finite surfaces. As expected, TAM `adj=0` with
and without its classical bias factor failed on both forced-extreme datasets
with `missing value where TRUE/FALSE needed`; those four rows and errors remain
retained and ineligible. The other 32 fits produced 864 retained recovery
rows. Both mfrmr extreme datasets had a verified extended profile limit; both
no-extreme profiles were explicit no-ops.

## Matched implementation results

| Check | RSM | PCM |
| --- | ---: | ---: |
| mfrmr raw vs TAM raw, location-aligned maximum difference, no extremes | 2.4880e-6 | 3.8795e-6 |
| TAM raw vs immer `jml`, maximum difference, no extremes | 8.6709e-6 | 1.2502e-5 |
| TAM `adj=.3` vs immer `jml, eps=.3`, maximum difference, forced extremes | 5.5485e-8 | 8.0530e-8 |
| mfrmr profile vs TAM adjusted, location-aligned descriptive difference, forced extremes | 0.06181 | 0.08053 |

TAM adjustment changed nothing in the no-extreme cells. Every TAM and immer
classical-factor identity reproduced to at most `8.88e-16`; with nine
pseudoitems the factor was exactly `8/9` up to floating-point arithmetic.
The mfrmr/TAM/immer raw agreement in the no-extreme cells verifies the common
RSM/PCM kernel, design expansion, signs, and location normalization on these
microcases.

The forced-extreme mfrmr/TAM differences are not a parity failure: mfrmr
retains an unadjusted finite trace and separately computes the boundary
profile, while TAM and immer replace extreme scores by 0.3 before estimating
the displayed surface. The observed difference quantifies a method-convention
change that must not be hidden by a generic `JML` label.

The largest raw-surface difference between immer `eps_adj` and immer `jml`
ranged from about 0.168 to 0.188 across the four cells. This confirms in
execution that `eps_adj` changes item as well as Person sufficient statistics;
it is not simply another extreme-Person display.

## One-seed recovery traces

| Model | Extreme fraction | mfrmr raw/profile RMSE | TAM adjusted / immer `jml` RMSE | immer `eps_adj` RMSE | Classical-factor RMSE |
| --- | ---: | ---: | ---: | ---: | ---: |
| RSM | 0 | 0.28676 | 0.28676 | 0.30532 | 0.33134 |
| RSM | 0.125 | 0.33013 | 0.33115 | 0.34140 | 0.36319 |
| PCM | 0 | 0.51200 | 0.51200 | 0.50935 | 0.51196 |
| PCM | 0.125 | 0.56727 | 0.55165 | 0.54418 | 0.54366 |

These are descriptive one-seed values, not rankings. In particular, the
classical factor worsens RSM RMSE here while appearing slightly favorable in
the forced-extreme PCM cell. Selecting or rejecting a correction from those
opposing microcase results would be outcome-adaptive and invalid.

## Interpretation and next gate

Draft.75 closes the first executable normalization gap: the local TAM and
immer versions can be compared with mfrmr on an explicit common RSM/PCM
cumulative-difficulty estimand, and the major adjustment/bias modes behave as
their help and source specify.

It does not establish general recovery, Person agreement, SE/coverage parity,
fit-index equivalence, an effective-item definition under missingness, or a
preferred JML correction. The result has no checklist, public API, default,
candidate, readiness, or confirmation effect.

The next pilot must retain all 60 declared datasets and focus on the two
questions this smoke cannot answer: whether any correction improves replicated
structural bias/RMSE without stability cost, and how TAM's fixed pseudoitem
count diverges from immer's mean observed exposure under missing and unequal
panels. Person-state and supported uncertainty comparisons follow as separate
contracts.
