from pathlib import Path
from fractions import Fraction as Q
from decimal import Decimal, localcontext
import json, math, runpy

helper=runpy.run_path('inst/validation/jml-nuisance-region-bounds-20261012.py')
digest,local_path=helper['digest'],helper['local_path']
directory=Path('validation-results/jml-shared-nuisance-review-20261012')
manifest_path=directory/'manifest.json'
manifest=json.loads(manifest_path.read_text()); manifest_hash=digest(manifest_path)
# Direct response-coordinate check; no use of the design or witness functions.
base=runpy.run_path('inst/validation/jml-normal-importance-mc-20261003.py')
samples,unused,inputs=base['read_inputs'](helper['ROOT'])
assert inputs==manifest['Inputs']
proposal_path=helper['BASE']/'proposal-probabilities.json'
proposal=json.loads(proposal_path.read_text());assert proposal['Inputs']==inputs
logq={r['Replicate']:Q(r['LogLower']) for r in proposal['Records']}
summary=json.loads((directory/'summary.json').read_text());assert summary['ManifestSHA256']==manifest_hash
checked=[];sources={str(manifest_path):manifest_hash,str(directory/'summary.json'):digest(directory/'summary.json'),str(proposal_path):digest(proposal_path)}
for name,expected in manifest['Sources'].items():
 assert digest(local_path(name))==expected, name
for target in manifest['Selected']:
 assert target['GroupSize'] in (101,2143,304)
for region in range(1,4):
 for path in sorted(directory.glob(f'region-{region}-reference-*.json')):
  row=json.loads(path.read_text());assert row['ManifestSHA256']==manifest_hash
  sources[str(path)]=digest(path)
  cert=row.get('JointCertificate')
  if not cert or 'JointLogWeightUpper' not in row:
   checked.append({'Region':region,'Replicate':row['Replicate'],'Available':False});continue
  a=list(map(Q,cert['Slopes']));assert min(a)>0 and math.prod(a)==1
  w=cert['Witness'];v=list(map(Q,w['ProjectionMultiplier']));den=int(w['ProbabilityDenominator'])
  raw=samples[0]+samples[row['Replicate']-1]
  balance=[Q(0)]*9;g=[Q(0)]*60;h=Q(0);probabilities=[];ys=[];groups=[[Q(0)]*9 for _ in range(2)]
  cursor=0
  for person,(roster,ratings) in enumerate(raw):
   for rater_index,rater in enumerate(roster):
    for criterion in range(3):
     y=ratings[rater_index*3+criterion];slope=a[criterion]
     d=[]
     for k in range(4):
      feature=[Q(0)]*9
      feature[0]=-slope*k*{1:1,2:0,3:-1}[rater]
      feature[1]=-slope*k*{1:0,2:1,3:-1}[rater]
      feature[2]=-slope*k*(Q(-1,2) if criterion<2 else 1)
      for category in (1,2):feature[3+2*criterion+category-1]=-slope*(k==category)
      d.append(feature)
     q0=[Q(n,den) for n in w['ProbabilityNumerators'][cursor]]
     mu=[sum(q0[k]*d[k][j] for k in range(4)) for j in range(9)]
     q=[q0[k]*(1+sum((d[k][j]-mu[j])*v[j] for j in range(9))) for k in range(4)]
     assert min(q)>0 and sum(q)==1
     for j in range(9):
      delta=d[y][j]-sum(q[k]*d[k][j] for k in range(4))
      balance[j]+=delta;groups[person//30][j]+=delta
     residual=y-sum(k*q[k] for k in range(4))
     g[person]+=slope*residual
     h+=(-slope/2 if criterion==0 else slope/2 if criterion==1 else 0)*residual
     probabilities.append(q);ys.append(y);cursor+=1
  assert cursor==len(w['ProbabilityNumerators'])==360
  assert balance==[0]*9 and h==Q(cert['AffineUpperSlope'])<0
  assert all(x+y==0 for x,y in zip(*groups))
  block_independent=sum(x*x for x in g)
  incorrectly_shared=sum((x+y)**2 for x,y in zip(g[:30],g[30:]))
  # Independent directed evaluation at the anchor; the producer evaluates
  # the whole rectangle with a second outward-arithmetic implementation.
  with localcontext() as c:
   c.prec=80
   lo=Decimal(0);hi=Decimal(0)
   from decimal import ROUND_FLOOR,ROUND_CEILING
   for q in probabilities:
    for p in q:
     c.rounding=ROUND_FLOOR;pl=Decimal(p.numerator)/Decimal(p.denominator)
     c.rounding=ROUND_CEILING;pu=Decimal(p.numerator)/Decimal(p.denominator)
     l=pl.ln().next_minus();u=pu.ln().next_plus()
     c.rounding=ROUND_FLOOR;lo+=pu*l
     c.rounding=ROUND_CEILING;hi+=pl*u
   exact=block_independent/2+h*Q(21,4)
   c.rounding=ROUND_FLOOR;lo+=Decimal(exact.numerator)/Decimal(exact.denominator)
   c.rounding=ROUND_CEILING;hi+=Decimal(exact.numerator)/Decimal(exact.denominator)
   stored=Q(cert['GlobalMarginalLogLikelihoodUpper'])
   assert Q(lo)<=stored
   assert float(abs(stored-Q(hi)))<1e-40
   beta_lower=Q((Decimal(1)/Decimal(200)).ln().next_minus())
  transfer_lo,transfer_hi=map(Q,row['JointTransfer']['DecimalEnclosure'])
  assert transfer_lo<=transfer_hi
  reconstructed=Q(row['JointLogWeightUpper'])+logq[1]+logq[row['Replicate']]+beta_lower
  assert float(reconstructed-transfer_hi)>-1e-40
  assert Q(row['CombinedLogWeightUpper'])==min(Q(row['BaselineLogWeightUpper']),Q(row['JointLogWeightUpper']))
  checked.append({'Region':region,'Replicate':row['Replicate'],'Available':True,
                  'RawStructuralBalanceExact':True,'BlocksHaveNonzeroIndividualBalance':any(groups[0]),
                  'IndependentLatentQuadraticDiffersFromShared':block_independent!=incorrectly_shared,
                  'AnchorDecimalCheck':True})
assert len(checked)==90
base['IV'].dps=60
for region,record in enumerate(summary['Regions'],1):
 rows=[json.loads(p.read_text()) for p in sorted(directory.glob(f'region-{region}-reference-*.json'))]
 for key,out in [('BaselineLogWeightUpper','BaselinePValueUpper'),('CombinedLogWeightUpper','CombinedPValueUpper')]:
  value=base['ends'](sum(base['IV'].exp(base['iv'](Q(r[key]))) for r in rows)/50)[1]
  assert value==Q(record[out])
 assert record['ExclusionCertified']==(Q(record['CombinedPValueUpper'])<=Q(9,200))
result={'ChecksPassed':True,'Sources':sources,'ManifestSourcesVerified':len(manifest['Sources']),
        'Rows':checked,'RawJointCertificatesChecked':sum(r['Available'] for r in checked),
        'NonzeroSeparateBalanceCases':sum(r.get('BlocksHaveNonzeroIndividualBalance',False) for r in checked),
        'LatentBlockDistinctionCases':sum(r.get('IndependentLatentQuadraticDiffersFromShared',False) for r in checked),
        'CompleteNumeratorsReproduced':3,'NoNewOptimizationDuringChecks':True,
        'Scope':'Independent response-coordinate reconstruction and Decimal anchor enclosures, all completed auxiliary certificates; saved complete MC sums and source identity. No coverage qualification.'}
output=directory/'checks.json';payload=json.dumps(result,indent=2)+'\n'
if output.exists():assert output.read_text()==payload
else:output.write_text(payload)
print(json.dumps({k:v for k,v in result.items() if k not in ('Sources','Rows')},indent=2))
