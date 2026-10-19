"""Truth-interval decisions retaining each original JML point and failed fit.

Conditional reference intervals are explicitly distinct from JML Wald/bootstrap.
No estimator is relabelled or replaced by a conditional MLE.
"""
from pathlib import Path
import csv
import hashlib
import json
import math
import runpy
import sys


def number(s):
    return float('nan') if s in ('NA',None) else float(s)


def run(root):
    ref=root/'conditional-reference';out=ref/'gpcm-projection';out.mkdir(exist_ok=True)
    script=Path('inst/validation/jml-gpcm-conditional-projection-20261003.py')
    projection=runpy.run_path(str(script));projection['check']()
    inputs={};gpcm={};pcm={}
    for i in range(1,51):
        path=ref/f'input-{i:02d}.json';saved=out/f'result-{i:02d}.json'
        inputs[str(path)]=hashlib.sha256(path.read_bytes()).hexdigest()
        if saved.exists():
            value=json.loads(saved.read_text())
            assert value['InputSHA256']==inputs[str(path)]
            for p,h in value['Sources'].items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h
        else:
            value=projection['run'](path)
            saved.write_text(json.dumps(value,indent=2)+'\n')
        gpcm[i]=value['ProjectedInterval']
        pcm[i]={r['Contrast'].split()[0]:r for r in json.loads((ref/f'result-{i:02d}.json').read_text())['Results']}
    point_path=root/'accuracy-review/contrasts.csv'
    records=[]
    for p in csv.DictReader(point_path.open()):
        if 'JML' not in p['Arm']:continue
        i=int(p['Replicate']);facet=p['Target'].split(':')[1]
        fixed=p['Arm']=='PCM-JML';supported=fixed or facet=='Rater'
        r=pcm[i][facet] if fixed else gpcm[i] if supported else None
        empty=bool(r.get('Empty',False)) if r is not None else False
        lo=number(r['Lower']) if r is not None and not empty else float('nan')
        hi=number(r['Upper']) if r is not None and not empty else float('nan')
        estimate=number(p['Estimate']);truth=number(p['Truth'])
        records.append(dict(Arm=p['Arm'],Replicate=i,Facet=facet,JMLEstimate=estimate,
            PointAvailable=math.isfinite(estimate),PointNumericalPass=p['NumericalPass']=='TRUE',
            Truth=truth,Lower=lo,Upper=hi,Empty=empty,
            FiniteInterval=supported and not empty and math.isfinite(lo) and math.isfinite(hi),
            ContainsTruth=supported and not empty and lo<=truth<=hi,
            ContainsJMLPoint=supported and not empty and lo<=estimate<=hi,
            Width=hi-lo,Method='exact_conditional_pcm' if fixed else
                'conditional_projection_all_positive_slopes' if supported else 'unsupported',
            ConditionalProcedureSupported=supported,JMLWaldQualified=False,JMLBootstrapQualified=False,
            Scope='Two facet, three levels each, four categories, two assigned raters and three criteria; conditional independence, unit weights, centered owner steps; GPCM positive geometric-mean-one criterion slopes.'))
    assert len(records)==400
    with (ref/'jml-points-and-conditional-intervals.csv').open('w',newline='') as stream:
        writer=csv.DictWriter(stream,fieldnames=list(records[0]));writer.writeheader();writer.writerows(records)
    summary=[]
    for arm in sorted({r['Arm'] for r in records}):
        for facet in ('Rater','Criterion'):
            rows=[r for r in records if r['Arm']==arm and r['Facet']==facet]
            assert len(rows)==50
            supported=all(r['ConditionalProcedureSupported'] for r in rows)
            mean_width=sum(r['Width'] for r in rows)/50 if supported and not any(r['Empty'] for r in rows) else None
            finite=[r for r in rows if r['FiniteInterval']]
            summary.append(dict(Arm=arm,Facet=facet,Planned=50,Points=sum(r['PointAvailable'] for r in rows),
                ConditionalProcedureSupported=supported,FiniteIntervals=sum(r['FiniteInterval'] for r in rows),
                Covered=sum(r['ContainsTruth'] for r in rows),PointInside=sum(r['ContainsJMLPoint'] for r in rows),
                FiniteCovered=sum(r['ContainsTruth'] for r in finite),
                MeanFiniteWidth=sum(r['Width'] for r in finite)/len(finite) if finite else None,
                MeanWidth='Inf' if mean_width==math.inf else mean_width))
    sources=[Path(__file__),script,Path('inst/validation/jml-pcm-conditional-intervals-20261003.py'),point_path]
    result=dict(Summary=summary,Inputs=inputs,Sources={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},
        NewFits=0,NewDatasets=0,
        Decision='Supported conditional procedures give pointwise finite-sample coverage under the stated response/design law. Original JML points are retained separately. Current JML Wald and plug-in bootstrap are not thereby qualified. GPCM Criterion truth intervals remain unsupported by this conditioning.')
    (ref/'truth-interval-decision.json').write_text(json.dumps(result,indent=2,allow_nan=False)+'\n')
    print(json.dumps(summary,indent=2,allow_nan=False))


if __name__=='__main__':run(Path(sys.argv[1]))
