# GPCM MML boundary-path deterministic challenge record for mfrmr 0.2.3

Status: completed Draft.71 concern result; deterministic negative controls
pass, all dense-grid positive expectations fail, and readiness propagation is
blocked; not confirmation, an operating-characteristic estimate, or release
authorization

Run date: 2026-08-09 JST (completion marker: 2026-08-08 22:10:39 UTC)

## Frozen identity and accounting

The contract was frozen before the q=31/61/91 results were opened. It extended
the known criterion-forward q=5 fixture to reversed direction, rater ownership,
mixed negative responses, and zero-versus-`1e-8` discordant response weights.
The ten deterministic datasets produced 30 direct-MML arms under the Draft.69
runtime, with no retry, anchor change, expectation change, or cell removal.

| Field | Value |
| --- | --- |
| Runtime package SHA-256 | `2a6344a815dadee12dc50eeac339e2f5774cf43cce2b86771a24aa8c132aa0e3` |
| Runner SHA-256 | `721af73fa1c8b44c67200779252e6c054fa83767e68dddc368639315035fd5cd` |
| Contract SHA-256 | `289a1cc96a82726fb3aae4a851cba8053f3833f0453704f16b2f71d24f1304d2` |
| Independent completion-validator SHA-256 | `b66532e12873b60337eebdb7e967610cd742d874bccb572b8730eba26d1b7f3b` |
| Manifest SHA-256 | `cd3a554938b540d1f96ea558b9d37c3bd89aabe7f198b95016159c0900cf97ff` |
| Execution SHA-256 | `1b442b29510fa763ebe1277a4c314b3c27dcff9dea3715cda8db7d55811ab11f` |
| Completion inventory SHA-256 | `e29fef305d94e13dcbe187597a33ecd90c65d0ef7368d7624e09434159957316` |
| Completion inventory | 17 files: six aggregate CSVs, one RDS result, and ten atomic dataset checkpoints |
| Local bundle | ignored workspace path `validation-results/gpcm-mml-boundary-challenge-draft71/` |

Selected aggregate hashes are:

| Artifact | SHA-256 |
| --- | --- |
| `gpcm-mml-boundary-challenge.rds` | `7ec3f75ffd0522fcd26cdfb21362d4d89b7565d5e71e735bca233baf40f49d62` |
| `run-complete.rds` | `4bceb4a5596978c2fba4401d41ad6c37a1cb181f4346f513e1b5260941bb0bb7` |
| `dataset-manifest.csv` | `a95b5ab264c4f3b4f89857306313a4a8f2920392c6cf0c1ddc185a5feb48e220` |
| `run-results.csv` | `53597d5d75cccd6df66557cdd62ddc2df77b2161f3a764be36508688808f993b` |
| `dataset-summary.csv` | `4e9a32a132050c44b7bee76313b8a2ad6cfa73e3e82bd24bd33bfc83d4a7b76b` |
| `summary.csv` | `ea6dde30221ffabde9bf9286edb6d35a8ecdb33f2a366f351ba1fc4074efd1d5` |
| `checkpoint-ledger.csv` | `eeeb973709531c8f1be05602ce903395bb37eb27b93368aec42aaa2780ad3c39` |

All 30 fits and all 30 fixed-quadrature calculations completed. Every
likelihood reconstruction difference was zero, retained-data identity was
stable across q in 10/10 datasets, and no arm became evidence-inference-ready.
The independently sourced validator regenerated every deterministic input,
recomputed the 17-file inventory, validated every checkpoint/ledger entry,
reconstructed the 30- and 10-row aggregates, and rechecked all non-promotion
flags.

## Frozen-expectation result

| Challenge class | Planned arms | Passed frozen expectation | Observed certified arms |
| --- | ---: | ---: | ---: |
| criterion/rater `mixed_negative` | 6 | 6 | 0 |
| criterion/rater `epsilon_weight_discordant` | 6 | 6 | 0 |
| criterion/rater forward/reverse positive | 12 | 0 | 0 |
| criterion/rater `zero_weight_discordant` | 6 | 0 | 0 |
| **Total** | **30** | **12** | **0** |

The four negative datasets behaved exactly as frozen at all three q values.
The zero-weight contradictory row was removed as declared, while the otherwise
identical `1e-8` row remained effective; nevertheless, neither zero-weight
positive construction was certified on the dense grids. Owner reversal did
not change the pattern: criterion and rater results were symmetric.

This is a concern result, not an invitation to relabel the positive controls.
They were positive with respect to the q=5 behavior frozen from Draft.69 and
were deliberately expected to extend to q=31/61/91. That prospective
expectation failed in all 18 applicable arms.

## Mathematical diagnosis

The all-node condition is sufficient because it forces every conditional-node
derivative to have the desired sign before posterior-node averaging. Its cost
is that it depends on the most extreme retained node. The standard-normal
Gaussian--Hermite node ranges used here are:

| q | Minimum node | Maximum node |
| ---: | ---: | ---: |
| 5 | -2.85697 | 2.85697 |
| 31 | -9.89339 | 9.89339 |
| 61 | -14.4985 | 14.4985 |
| 91 | -18.0233 | 18.0233 |

For the criterion-forward reference, q=5 still certifies `C1>C2`: C1 is a
utility maximum and C2 is a utility minimum at every node. At q=31 C1 remains
maximum-compatible, but C2 is no longer minimum-compatible. At q=61 and q=91
neither group is compatible at every node. The q=31 minimum support margin for
C2 is about -2.44; by q=91 the corresponding incompatible margins reach about
-10.57 for C2 and -5.48 for C1. The reverse and rater-owned constructions show
the same geometry.

For a binary item with finite additive coordinates, the category-utility order
reverses somewhere as the latent node ranges toward both tails. Because the
extreme Gaussian--Hermite nodes move outward with q, an individual-response
condition that demands the same category extremum at every node cannot be
expected to preserve ordinary positive cases as q increases. In the
continuous standard-normal integral, latent support is unbounded in both
directions; this particular all-node argument therefore does not become a
continuous-integral certificate merely by increasing q.

The failure does not show that the marginal likelihood has a finite maximum.
It shows that the current sufficient condition is too restrictive to certify
the frozen dense-grid constructions. Negative results remain silent about
other slope-only paths, paths with moving additive coordinates, and global
geometry.

## Gate consequence and corrective mathematics

Draft.71 blocks the planned readiness-propagation step. The q=5 positive
fixture remains a valid certificate for that exact five-node numerical
objective, but it cannot support a general marginal-MML slope claim or a
dense-grid detection rule. No checklist row, tolerance, q default, sample-size
rule, recovery claim, candidate, or confirmation state is promoted.

The next mathematical slice should not tune anchors until the current test
passes. It should derive and verify a broader Person-marginal path condition
that allows conditionally adverse outer nodes to lose posterior mass. Candidate
routes, in increasing order of proof burden, are:

1. retain the exact boundary likelihood with incompatible-node limits made
   explicit, and derive Person-pattern rather than individual-response
   sufficient inequalities;
2. characterize the derivative of each finite-q Person marginal along the
   one-dimensional pair ray, including its limits at zero and infinity;
3. use certified interval bounds or an analytic transformation to establish
   nonnegativity over the entire half-line rather than checking a selected t
   grid; and
4. keep continuous-normal and moving-additive paths as separate theorems, not
   extrapolations from a finite-node result.

A future deterministic challenge must include q=5/31/61/91 and cases where
outer nodes are conditionally adverse but the Person marginal is still
provably monotone. Only after that proof and challenge pass should untouched
owner simulations estimate classification behavior. Fit, DFF, recovery,
coverage, and estimator comparisons remain separate gates.
