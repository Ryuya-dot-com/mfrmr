"""Independent exact checks of the saved conditional reference's truth coverage.

Enumerates every possible target statistic in each retained conditioning stratum.
No stochastic simulation, fitted ability, estimated SE or JML optimizer is used.
"""
from fractions import Fraction as Q
from pathlib import Path
from decimal import Decimal, localcontext
import hashlib
import json
import math
import sys


def masses(h,z):
    a,b=z.numerator,z.denominator;low,high=min(h),max(h)
    return {t:n*a**(t-low)*b**(high-t) for t,n in h.items()}


def check_interval(record,alpha=Q(1,20)):
    h={int(k):int(v) for k,v in record['OrientationCounts'].items()}
    observed=record['TargetStatistic'];scale=-record['NaturalScale']
    assert observed in h and scale>0 and all(v>0 for v in h.values())
    for key,upper in [('NaturalLowerRootBracket',True),('NaturalUpperRootBracket',False)]:
        bracket=record[key]
        if bracket is None:
            assert observed==(min(h) if upper else max(h))
            continue
        lo,hi=map(Q,bracket)
        signs=[]
        for z in (lo,hi):
            m=masses(h,z);tail=sum(v for t,v in m.items() if (t>=observed if upper else t<=observed))
            signs.append(2*alpha.denominator*tail-alpha.numerator*sum(m.values()))
        assert signs[0]<=0<=signs[1] if upper else signs[0]>=0>=signs[1]
        # Independent high-precision logarithm checks outward decimal endpoints.
        with localcontext() as context:
            context.prec=100
            bound=hi if not upper else lo
            endpoint=-(Decimal(bound.numerator)/Decimal(bound.denominator)).ln()/scale
            saved=Decimal(record['Lower' if not upper else 'Upper'])
            assert saved<=endpoint if not upper else saved>=endpoint
    checks=[]
    # All target outcomes, not just the statistic actually observed.
    for z in map(Q,('1/64','1/8','1/2','1','2','8','64')):
        m=masses(h,z);total=sum(m.values());prefix=0;excluded=0
        for t in sorted(m):
            prefix+=m[t];upper=total-prefix+m[t]
            if 2*alpha.denominator*prefix<alpha.numerator*total or 2*alpha.denominator*upper<alpha.numerator*total:excluded+=m[t]
        assert alpha.denominator*excluded<=alpha.numerator*total
        checks.append(Q(total-excluded,total))
    return min(checks)


def check_projection(record):
    number=lambda s: -math.inf if s=='-Inf' else math.inf if s=='Inf' else Q(s)
    bounds=[(number(c['Lower']),number(c['Upper'])) for c in record['Components']]
    positive=all(b>0 for a,b in bounds);negative=all(a<0 for a,b in bounds)
    zero=all(a<=0<=b for a,b in bounds)
    result=record['ProjectedInterval']
    assert result['Empty']==(not (positive or negative or zero))
    if result['Empty']:return
    lo,hi=map(number,(result['Lower'],result['Upper']));degree=len(bounds)
    if zero:assert lo<=0<=hi
    if positive:
        lower=math.prod(max(a,Q(0)) for a,b in bounds)
        upper=math.prod(b for a,b in bounds)
        assert lo<=0 or lo**degree<=lower
        assert hi==math.inf if upper==math.inf else hi>=0 and hi**degree>=upper
    if negative:
        lower=math.prod(max(-b,Q(0)) for a,b in bounds)
        upper=math.prod(-a for a,b in bounds)
        assert hi>=0 or (-hi)**degree<=lower
        assert lo==-math.inf if upper==math.inf else lo<=0 and (-lo)**degree>=upper


if __name__=='__main__':
    root=Path(sys.argv[1]);paths=sorted(root.glob('result-??.json'))
    assert len(paths)==50
    sources={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    minimum=Q(1);strata=0
    for p in paths:
        d=json.loads(p.read_text())
        index=int(p.stem.split('-')[1]);input_path=root/f'input-{index:02d}.json'
        assert hashlib.sha256(input_path.read_bytes()).hexdigest()==d['InputSHA256']
        assert hashlib.sha256(Path('inst/validation/jml-pcm-conditional-intervals-20261003.py').read_bytes()).hexdigest()==d['SourceSHA256']
        for record in d['Results']:
            minimum=min(minimum,check_interval(record));strata+=1
    gpcm_paths=sorted((root/'gpcm-projection').glob('result-??.json'))
    assert len(gpcm_paths)==50
    for p in gpcm_paths:
        d=json.loads(p.read_text());sources[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
        for name,h in d['Sources'].items():assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==h
        index=int(p.stem.split('-')[1]);input_path=root/f'input-{index:02d}.json'
        assert hashlib.sha256(input_path.read_bytes()).hexdigest()==d['InputSHA256']
        for c in d['Components']:
            record={**c,'TargetStatistic':c['ObservedSufficientStatistics'][0],'NaturalScale':-1}
            minimum=min(minimum,check_interval(record,Q(c['ErrorProbability'])));strata+=1
        check_projection(d)
    result=dict(ConditioningStrata=strata,ExactCoverageChecks=7*strata,
        MinimumGridConditionalCoverage=str(minimum),ProjectedSetsChecked=len(gpcm_paths),AllChecksPassed=True,
        Scope='Exact finite-support tests and numerical bracket/log checks; universal coverage follows from the inclusive-tail theorem, not the finite grid.',
        Sources=sources,CheckSourceSHA256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (root/'qualification-checks.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(Strata=strata,Checks=7*strata,MinimumGridCoverage=float(minimum),Passed=True)))
