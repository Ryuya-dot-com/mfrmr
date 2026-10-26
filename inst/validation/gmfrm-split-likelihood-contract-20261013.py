"""Deterministic checks for a proposed split-likelihood contract, not GMFRM coverage.

Run from the development root. No responses, model fits or random numbers.
Exact finite-state sums check the inferential logic before any fitting allocation.
"""
from fractions import Fraction as F
from math import comb, exp, log, sqrt, isclose
from pathlib import Path
import hashlib
import json

alpha = F(1, 20)
m = 6


def likelihood(p, k, n):
    return p ** k * (1 - p) ** (n - k)


exact = []
for j in range(1, 10):
    p = F(j, 10)
    mean = F(0)
    rejection = F(0)
    conservative = F(0)
    for a in range(m + 1):
        for b in range(m + 1):
            prob = (comb(m, a) * likelihood(p, a, m)
                    * comb(m, b) * likelihood(p, b, m))
            q_a, q_b = F(a + 1, m + 2), F(b + 1, m + 2)
            e_b = likelihood(q_a, b, m) / likelihood(p, b, m)
            e_a = likelihood(q_b, a, m) / likelihood(p, a, m)
            e = (e_a + e_b) / 2
            mean += prob * e
            rejection += prob * (e > 1 / alpha)
            # A lower numerator and upper denominator enlarge the retained set.
            conservative += prob * (F(9, 20) * e > 1 / alpha)
    assert mean == 1 and 0 <= conservative <= rejection <= alpha
    exact.append(dict(p=str(p), expected_e=str(mean), rejection=str(rejection),
                      bounded_rejection=str(conservative)))

# A candidate likelihood below the null supremum can be anti-conservative.
# H0: p in [.1,.9], true p=.9, q=.9, but denominator is evaluated at p=.1.
bad_rejection = sum(comb(2, k) * likelihood(F(9, 10), k, 2)
                    for k in range(3)
                    if likelihood(F(9, 10), k, 2) / likelihood(F(1, 10), k, 2) > 20)
assert bad_rejection == F(81, 100)
for k in range(3):
    null_mle = max(F(1, 10), min(F(9, 10), F(k, 2)))
    assert likelihood(F(9, 10), k, 2) / likelihood(null_mle, k, 2) <= 1

# Twenty-one valid e-values on a uniform 21-state experiment. Choosing the
# maximum after observing the state rejects surely; their fixed mean is one.
for observed in range(21):
    es = [F(21 if candidate == observed else 0) for candidate in range(21)]
    assert max(es) > 20 and sum(es) / 21 == 1

# Five independent Persons each have two identical Bernoulli(.5) ratings.
# Putting one rating per Person in each fold and copying the training rating
# makes the wrongly factorized held-out likelihood ratio 2^5 on every outcome.
for state in range(32):
    ratings = tuple((state >> i) & 1 for i in range(5))
    copied_prediction = F(1)
    marginal_denominator = F(1, 2) ** len(ratings)
    assert copied_prediction / marginal_denominator == 32

# Separate fold profiling is a conservative outer projection, not necessarily
# the exact projection of the averaged full-parameter e-value.
q = F(1, 2)
L_a, L_b = (F(1, 10), F(9, 10)), (F(9, 10), F(1, 10))
separate = (q / max(L_a) + q / max(L_b)) / 2
common = min((q / L_a[i] + q / L_b[i]) / 2 for i in range(2))
assert separate == F(5, 9) and common == F(25, 9) and separate < common

# Normal location, known unit variance: an exact information-cost identity.
# Single split, training/test sizes N/2: radius^2 = (mean_A-mean_B)^2
# + 4 log(1/alpha)/N. E[(mean_A-mean_B)^2] = 4/N.
normal = []
z975 = 1.959963984540054
for n in (20, 60, 240):
    rms_radius = sqrt((4 + 4 * log(20)) / n)
    usual_radius = z975 / sqrt(n)
    normal.append(dict(N=n, split_rms_radius=rms_radius,
                       full_normal_radius=usual_radius, ratio=rms_radius/usual_radius))
# Check the expanded radius against a direct log likelihood ratio.
for a, b, theta in ((1., 1., 0.), (-.3, .2, 1.), (.4, -.2, -.7)):
    n_test = 10
    direct = sum(-.5 * ((b-a)**2 - (b-theta)**2) for _ in range(n_test))
    expanded = n_test / 2 * ((theta-b)**2 - (a-b)**2)
    assert isclose(direct, expanded, abs_tol=1e-13)
assert exp(5) > 20  # A learned predictor can exclude the old fixed anchor 0.

paper = Path("tmp/universal-inference-20261013/universal-inference-v4.pdf")
source = Path(__file__)
answer = dict(
    scope="Exact logic checks and normal-model identities, not GMFRM performance",
    alpha=str(alpha), independent_binomial_checks=exact,
    bad_denominator_rejection=str(bad_rejection),
    post_selection_max_rejection="1", dependent_row_split_rejection="1",
    separate_profile_e=str(separate), common_nuisance_projection_e=str(common),
    normal_information_cost=normal,
    source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
    paper_sha256=hashlib.sha256(paper.read_bytes()).hexdigest())
path = Path("validation-results/gmfrm-split-likelihood-contract-20261013/checks.json")
path.parent.mkdir(parents=True, exist_ok=True)
if path.exists():
    assert json.loads(path.read_text()) == answer, "Existing evidence differs; do not overwrite."
else:
    path.write_text(json.dumps(answer, indent=2) + "\n")
print("Exact split/crossfit, bound-direction and failure-mode checks passed.")
print("Maximum rejection in the nine complete-null controls:",
      max(float(F(row["rejection"])) for row in exact))
print("Normal single-split RMS-radius / full-normal radius:", normal[0]["ratio"])
