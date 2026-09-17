"""Independent 100-digit reference. Usage: python3 SCRIPT nodes-weights.csv out.csv."""
import csv
import sys

import mpmath as mp

mp.mp.dps = 100
with open(sys.argv[1]) as source:
    rows = list(csv.DictReader(source))
results = []
for row in rows:
    n = int(row["q"])
    # The supplied double root is only a starting value. Refine at 100 digits;
    # use physicists' H and its derivative, not R's eigenvector/Christoffel sum.
    x = mp.mpf(row["node"]) / mp.sqrt(2)
    for _ in range(5):
        x -= mp.hermite(n, x) / (2 * n * mp.hermite(n - 1, x))
    assert abs(mp.hermite(n, x) / (2 * n * mp.hermite(n - 1, x))) < mp.mpf("1e-90")
    node = x * mp.sqrt(2)
    weight = mp.power(2, n - 1) * mp.factorial(n - 1) / (n * mp.hermite(n - 1, x)**2)
    results.append(dict(q=n, node=mp.nstr(node, 45), weight=mp.nstr(weight, 45),
                        node_error=float(abs(mp.mpf(row["node"]) - node)),
                        relative_weight_error=float(abs(mp.mpf(row["weight"]) / weight - 1))))
with open(sys.argv[2], "w") as output:
    writer = csv.DictWriter(output, fieldnames=results[0].keys())
    writer.writeheader()
    writer.writerows(results)
print("mpmath", mp.__version__, "digits", mp.mp.dps)
for n in sorted(set(row["q"] for row in results)):
    case = [row for row in results if row["q"] == n]
    print(n, "maximum node error", max(row["node_error"] for row in case),
          "maximum relative weight error", max(row["relative_weight_error"] for row in case))
