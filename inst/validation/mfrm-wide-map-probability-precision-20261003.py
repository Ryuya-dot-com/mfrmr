"""Independent high-precision adjacent-odds check of saved binary64 parameters.

No simulation, estimation, parameter rounding or model-selection claims.
"""
import csv
import hashlib
import json
import math
from pathlib import Path
import sys

import mpmath as mp


def probabilities(row, digits=80):
    with mp.workdps(digits):
        theta = float.fromhex(row['Theta'])
        if math.isinf(theta):
            return [mp.mpf(int(k == (0 if theta < 0 else 3))) for k in range(4)]
        value = lambda name: mp.mpf(float.fromhex(row[name]))
        eta = value('Theta') - value('Rater') - value('Criterion')
        slope = mp.exp(value('LogSlope'))
        logits = [mp.mpf(0)]
        for k in range(1, 4):
            logits.append(logits[-1] + slope * (eta - value(f'Step{k}')))
        mass = [mp.exp(z - max(logits)) for z in logits]
        total = mp.fsum(mass)
        return [p / total for p in mass]


def main(source, destination):
    mp.mp.dps = 80
    groups = {}
    worst = None
    worst_error = mp.mpf(-1)
    rows = 0
    with source.open(newline='') as stream:
        for row in csv.DictReader(stream):
            ref = probabilities(row)
            actual = [mp.mpf(float.fromhex(row[f'P{k}'])) for k in range(4)]
            assert all(mp.isfinite(p) and p >= 0 for p in actual)
            total = mp.fsum(actual)
            assert total > 0 and abs(total - 1) < mp.mpf('1e-12')
            error = [abs(a - b) for a, b in zip(actual, ref)]
            # A product-law TV bound requires probability measures of equal mass.
            # Interpret the stored binary64 vector as normalized sampling weights.
            tv = mp.fsum(abs(a / total - b) for a, b in zip(actual, ref)) / 2
            maximum = max(error)
            key = (row['JobId'], row['Phase'], row['Kind'])
            if key not in groups:
                groups[key] = dict(JobId=row['JobId'], Arm=row['Arm'], Replicate=int(row['Replicate']),
                    Phase=row['Phase'], Kind=row['Kind'], Rows=0,
                    MaximumAbsoluteError=mp.mpf(0), MaximumRowTV=mp.mpf(0),
                    SumRowTV=mp.mpf(0), MaximumRowSumError=mp.mpf(0),
                    RoundedZeroCategories=0, RoundedZeroMass=mp.mpf(0))
            z = groups[key]
            z['Rows'] += 1
            z['MaximumAbsoluteError'] = max(z['MaximumAbsoluteError'], maximum)
            z['MaximumRowTV'] = max(z['MaximumRowTV'], tv)
            z['SumRowTV'] += tv
            z['MaximumRowSumError'] = max(z['MaximumRowSumError'], abs(total - 1))
            for a, b in zip(actual, ref):
                if a == 0 and b > 0:
                    z['RoundedZeroCategories'] += 1
                    z['RoundedZeroMass'] += b
            if maximum > worst_error:
                worst_error, worst = maximum, row
            rows += 1
    assert rows and worst is not None
    higher = probabilities(worst, 120)
    lower = probabilities(worst, 80)
    precision_difference = max(abs(a-b) for a, b in zip(higher, lower))
    assert precision_difference < mp.mpf('1e-60')
    records = []
    for z in groups.values():
        z['JointTVArithmeticBound'] = min(mp.mpf(1), z['SumRowTV']) if z['Kind']=='profile_generator' else None
        records.append({k: mp.nstr(v, 18) if isinstance(v, mp.mpf) else v for k, v in z.items()})
    with destination.open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(records[0]))
        writer.writeheader()
        writer.writerows(records)
    metadata = dict(rows=rows,groups=len(groups),digits=80,mpmath=mp.__version__,
        input_md5=hashlib.md5(source.read_bytes()).hexdigest(),
        source_md5=hashlib.md5(Path(__file__).read_bytes()).hexdigest(),
        maximum_absolute_error=mp.nstr(worst_error,18),worst_row=worst,
        worst_row_80_vs_120=mp.nstr(precision_difference,18),
        interpretation='Raw probability errors and normalized-weight total variation at identical stored parameters; not root/global/truth accuracy or PRNG certification.')
    destination.with_suffix('.json').write_text(json.dumps(metadata, indent=2)+'\n')
    print(json.dumps({k: metadata[k] for k in ('rows','groups','digits','maximum_absolute_error','worst_row_80_vs_120')}))


if __name__ == '__main__':
    assert len(sys.argv)==3
    main(Path(sys.argv[1]),Path(sys.argv[2]))
