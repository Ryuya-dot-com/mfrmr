"""Exact finite-sample obstruction to a general uncorrected JML truth-Wald CI.

Two binary items, fixed theta=0, centered difficulties +/-log(2).
No data generation, numerical fitting, normal-tail approximation or Monte Carlo.
"""
from fractions import Fraction as Q
from pathlib import Path
from math import comb
import hashlib
import json
import runpy
import sys


def certificate(n=480, minimum_b=40):
    reference = Path(__file__).with_name('jml-pcm-conditional-intervals-20261003.py')
    log_bounds = runpy.run_path(str(reference))['log_bounds']
    # Truth is delta=log(4); exact JML is 2*log(A/B).
    # On A>=3B, B>=40, bias >= log(9/4), and (2 SE)^2 <= 64/(3B).
    # Include the larger N/(N-1) finite-sample covariance normalization.
    lower_log, _ = log_bounds(Q(9, 4))
    radius_squared = Q(64, 3 * minimum_b) * Q(n, n-1)
    assert lower_log > 0 and lower_log**2 > radius_squared
    # P(A=a,B=b) = choose(n,b) choose(n-b,a) 4**(n-b) / 9**n.
    numerator = sum(comb(n, b) * 4**(n-b) *
                    sum(comb(n-b, a) for a in range(3*b, n-b+1))
                    for b in range(minimum_b, n//4+1))
    mass = Q(numerator, 9**n)
    assert mass > Q(1, 20)
    # A compact rigorous decimal bound uses integer floor/ceiling only.
    scale = 10**6
    failure_lower = (mass.numerator * scale) // mass.denominator
    coverage_upper = scale - failure_lower
    return dict(N=n,Items=2,Categories=2,Theta='0',Truth='log(4)',
        ExactJML='2 log(A/B), A=n01, B=n10',
        SandwichVariance='4(1/A+1/B)',
        CertifiedEvent=f'A >= 3 B and B >= {minimum_b}',
        NoncoverageProbability=str(mass),
        NoncoverageLowerBound=f'{failure_lower/scale:.6f}',
        CoverageUpperBound=f'{coverage_upper/scale:.6f}',
        Interval='JML +/- 2 SE, even with covariance multiplied by N/(N-1)',
        Scope='Exact counterexample to a general truth-Wald qualification; not an assessment of every other interval procedure.',
        Sources={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),reference)})


if __name__ == '__main__':
    out=Path(sys.argv[1]);out.parent.mkdir(parents=True,exist_ok=True)
    result=certificate();payload=json.dumps(result,indent=2)+'\n'
    if out.exists():assert out.read_text()==payload
    else:out.write_text(payload)
    print(json.dumps({k:result[k] for k in ('N','NoncoverageLowerBound','CoverageUpperBound','Interval')}))
