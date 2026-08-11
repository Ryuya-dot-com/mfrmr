# GPCM MML Person-marginal slope-path prototype record for mfrmr 0.2.3

Status: Draft.72 analytic-oracle prototype verified; broader finite-q mechanism
demonstrated on selected points, but compact-interval and tail remainder proofs
remain incomplete; no half-line certificate, readiness effect, confirmation,
or release authorization

Run date: 2026-08-09 JST

## Identity and implemented formulas

| Field | Value |
| --- | --- |
| Runtime package SHA-256 | `2a6344a815dadee12dc50eeac339e2f5774cf43cce2b86771a24aa8c132aa0e3` |
| Mathematical contract SHA-256 | `fd367ac746c5a57242dfe0e83a372a813e0cc04d21acc5532e6895461a81b514` |
| Prototype SHA-256 | `22bf961ca0037547e6b768f8f745fe7af55ff16a8e7f34d9e61867df9eb22b1b` |
| Test SHA-256 | `f6e57f56370a32204c15605166c44a7fdffc9acb08eb8ba7655dbe7ab27e44dd` |
| Test result | 22 expectations passed |

For every finite distance, the prototype independently rebuilds the exact
finite-q observation log probabilities, Person marginals, posterior node
weights, path value, first derivative, and curvature. For observation utility
mean μ and variance V, it implements

\[
d_i=v_i r_i s_i(u_y-μ),\qquad
d'_i=v_i r_i^2\{s_i(u_y-μ)-s_i^2V\},
\]

then obtains the Person-marginal derivative and curvature through posterior
node averaging and the between-node variance of the conditional derivative.
Both forward and reverse named directions are tested; malformed or non-sum-
zero directions stop.

The boundary prototype no longer requires every node to support the positive
group. Positive-incompatible Person nodes receive zero limiting mass;
surviving nodes use maximizing-category tie probabilities for the positive
group, uniform probabilities for the negative group, and fitted probabilities
for zero-loading groups. It also computes the leading negative-slope tail
coefficient under the surviving-node posterior. Both `HalfLineCertified` and
`TailCertified` remain false by construction.

## Analytic-oracle verification

On the Draft.71 criterion-forward q=31 control, selected distances
0, 0.5, 1, 2, and 4 produced:

- maximum absolute reconstructed-versus-optimizer likelihood difference zero;
- maximum absolute analytic-versus-central first-derivative difference below
  `3e-12`;
- maximum absolute analytic-curvature versus central difference of the
  analytic first derivative below `2e-15`; and
- positive total and Person-marginal derivatives at every selected distance,
  even though 36 Person-node derivative cells were negative at each distance.

The direct profile through t=8 was increasing. Its total derivative declined
from about `9.05420e-9` at t=0 to `3.03735e-12` at t=8, while its curvature was
negative and nearly the opposite magnitude. This demonstrates the mechanism
missing from the Draft.69 individual-response check: adverse conditional nodes
can coexist with a positive Person marginal after posterior weighting.

These are formula and selected-point checks. The small first derivative also
shows why ordinary double finite differences of the likelihood curvature are
unreliable here; differentiating the analytic first derivative was stable, but
neither calculation supplies outward-rounded proof.

## Boundary and leading tail across q

The same fitted positive construction was evaluated at q=5/31/61/91. The
table gives the generalized boundary improvement from t=0, the leading
coefficient A in (F'(t)\sim A\exp(-t)), and the number of surviving positive-
compatible nodes per Person.

| q | Boundary improvement | Tail coefficient A | Compatible nodes per Person |
| ---: | ---: | ---: | ---: |
| 5 | `9.101242e-9` | `9.101250e-9` | 5/5 |
| 31 | `9.054208e-9` | `9.054201e-9` | 31/31 |
| 61 | `9.054201e-9` | `9.054201e-9` | 58/61 |
| 91 | `9.054197e-9` | `9.054201e-9` | 81/91 |

At q=61 and q=91, three and ten positive-incompatible outer nodes per Person
vanish in the path limit instead of invalidating the entire direction. At
t=10, the boundary-likelihood remainder was about `4.1e-13`, and
(F'(10)/\exp(-10)) matched A to the displayed precision. The generalized
boundary likelihood itself was stable across q in this symmetric construction.

This explains both earlier findings without contradiction. Draft.71 correctly
showed that the old all-node sufficient condition does not certify the dense
grids. Draft.72 shows exploratorily that the wider Person-marginal path can
still rise and approach a higher finite-q boundary. The latter does not yet
prove nondecrease between all points or control the infinite tail remainder.

## Remaining proof obligations

No production code or fit object changes in Draft.72. The prototype cannot
promote a slope, uncertainty interval, fit, DFF, owner contrast, estimator
comparison, q rule, or readiness state. The following are blockers:

1. outward-rounded or equivalently bounded evaluation of the softmax,
   posterior weights, derivatives, boundary likelihood, and tail coefficient;
2. a complete compact-interval proof, not a selected grid, with deterministic
   subdivision and typed budget exhaustion;
3. a rigorous tail remainder bound joining the compact interval to infinity;
4. explicit treatment of utility ties, zero boundary marginals, A near zero,
   overflow/underflow, nonunit weights, and more than two owner levels;
5. a genuine derivative-sign counterexample and independent analytic oracle;
   and
6. q=5/31/61/91 challenges for both owners, reverse directions, row order,
   binary/polytomous ladders, and moving-additive non-claim controls.

Only after those obligations are met should a versioned finite-q half-line
result replace the current exploratory prototype. Continuous-normal and
moving-additive theorems remain separate. Stochastic owner classification,
recovery/coverage, fit, DFF, sample size, candidate freeze, and confirmation
remain downstream gates.
