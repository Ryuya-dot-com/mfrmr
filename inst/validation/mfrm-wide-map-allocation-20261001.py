"""Enumerate the roadmap's first R=50 mapping allocation; no data or fits.

Run from the package root with one new output directory argument. These are
allocation records, not executable generator specifications or input hashes.
Detailed truths, assignments, scales and output gates remain in the roadmap.
"""
import csv
import itertools
import json
import math
import pathlib
import sys

FULL_N = (20, 30, 40, 60, 120, 240, 480)
ANCHORS = (20, 60, 240, 480)
TRUTHS = ("S-RSM", "S-PCM", "S-GPCM")
REPETITIONS = 50
records = []


def identity(block, design, n, sd, truth):
    return f"{block}:{design}:N{n}:SD{sd}:{truth}"


def arms(truth, corrected=True):
    out = []
    models = {"S-RSM": ("RSM",), "S-PCM": ("PCM", "GPCM"),
              "S-GPCM": ("GPCM",)}[truth]
    for model in models:
        out.extend((f"{model}-MML-free-population", f"{model}-JML"))
        if model == "GPCM" and corrected:
            out.extend(("GPCM-JML-order2", "GPCM-JML-order4"))
    return out


def add(block, design, n, sd, truth, priority, configurations, *, alias=None,
        raters=3, criteria=3, tasks=0, categories=4, excluded=""):
    key = identity(block, design, n, sd, truth)
    records.append(dict(ConditionId=key, InputId=alias or key, Block=block,
        Design=design, N=n, SD=sd, Truth=truth, Priority=priority,
        RaterLevels=raters, CriterionLevels=criteria, TaskLevels=tasks,
        Categories=categories, InputAlias=bool(alias), PlannedReplicates=REPETITIONS,
        InitialConfigurations=len(configurations), Arms=";".join(configurations),
        CorrectedExclusion=excluded, InputStatus="allocation_only",
        SavedInputCandidate=(block == "D" and design.startswith("historical-full-")
                             and n in (120, 240, 480))))


for n, sd, roster, truth in itertools.product(FULL_N, (.5, 1), ("full-L1", "paired-L1"), TRUTHS):
    add("AB", roster, n, sd, truth, "P1", arms(truth))
for n, sd, truth in itertools.product(ANCHORS, (.5, 1), TRUTHS):
    add("AB", "paired-L2", n, sd, truth, "P1", arms(truth))

# Fixed-normal assumptions use exactly the A/B input, not another dataset.
for row in records:
    row["FixedPopulationConfigurations"] = 2 if row["Truth"] == "S-PCM" else 1

c_designs = (
    ("six-raters-paired", "P1", 6, 3, 0, 4, True),
    ("six-raters-full", "P2", 6, 3, 0, 4, False),
    ("null-task", "P1", 3, 3, 2, 4, True),
    ("two-tasks-same-pair", "P1", 3, 3, 2, 4, True),
    ("two-tasks-changing-pair", "P1", 3, 3, 2, 4, True),
    ("four-tasks-all-same-pair", "P2", 3, 3, 4, 4, False),
    ("four-tasks-all-changing-pair", "P2", 3, 3, 4, 4, False),
    ("four-tasks-two-observed", "P2", 3, 3, 4, 4, True),
    ("five-criteria-two-tasks-changing-pair", "P2", 3, 5, 2, 4, False),
    ("three-categories", "P2", 3, 3, 0, 3, True),
    ("five-categories", "P2", 3, 3, 0, 5, True),
)
for (design, priority, raters, criteria, tasks, cats, correction), n, truth in itertools.product(c_designs, ANCHORS, TRUTHS):
    add("C", design, n, 1, truth, priority, arms(truth, correction),
        alias=identity("AB", "paired-L2", n, 1, truth) if design == "null-task" else None,
        raters=raters, criteria=criteria, tasks=tasks, categories=cats,
        excluded="owner-total state cap" if not correction and truth != "S-RSM" else "")

d_arms = ("PCM-MML-free-population", "GPCM-first-owner-MML-free-population",
          "GPCM-second-owner-MML-free-population", "two-family-MML-fixed-normal")
for n, sd, roster in itertools.product(FULL_N, (.5, 1), ("common", "rotating-pair")):
    add("D", "historical-full-"+roster, n, sd, "H-both", "P1", d_arms,
        raters=6, criteria=0, tasks=3, categories=3)
for n, sd, roster, truth in itertools.product(ANCHORS, (.5, 1), ("common", "rotating-pair"), ("H-equal", "H-first-only", "H-second-only")):
    add("D", "historical-reduced-"+roster, n, sd, truth, "P2", d_arms,
        raters=6, criteria=0, tasks=3, categories=3)
for n, sd, roster, truth in itertools.product(FULL_N, (.5, 1), ("full-L1", "paired-L1"), ("S-PCM", "S-GPCM")):
    extra = (d_arms[1], d_arms[3]) if truth == "S-PCM" else (d_arms[0], d_arms[1], d_arms[3])
    add("D", "rubric-alias-"+roster, n, sd, truth, "P1", extra,
        alias=identity("AB", roster, n, sd, truth))
for n, sd, roster, truth in itertools.product(ANCHORS, (.5, 1), ("full-L1", "paired-L1"), ("rubric-first-only", "rubric-both")):
    add("D", roster, n, sd, truth, "P1", d_arms)

profiles = (
    ("E0", "P1"), ("E1-right-skew", "P2"), ("E1-left-skew", "P2"), ("E1-mixture", "P2"),
    ("E2-minus2.5", "P2"), ("E2-plus2.5", "P2"), ("E3-rare-category", "P2"),
    ("E4-unequal", "P1"), ("E5-ability-allocation", "P2"),
    ("E6-missing0.15", "P1"), ("E6-missing0.30", "P1"), ("E7-rater-missing", "P2"),
    ("E8-score-missing", "P2"), ("E8-matched-independent", "P2"),
    ("E9-rho0", "P2"), ("E9-rho0.25", "P2"), ("E9-rho0.5", "P2"),
    ("E10-link0.6", "P1"), ("E10-link0.2", "P1"), ("E10-link0.05", "P1"),
)
for (design, priority), n, truth in itertools.product(profiles, ANCHORS, TRUTHS):
    add("E", design, n, 1, truth, priority, arms(truth),
        raters=6 if design.startswith("E10") else 3,
        tasks=2 if design.startswith("E9") else 0)
for n, truth, mechanism in itertools.product((20, 480), TRUTHS, ("score-missing", "matched-independent")):
    # The normal controls are E8 inputs, not additional generated records.
    add("E", "shape-missing-right-skew-"+mechanism, n, 1, truth, "P3", arms(truth))
for n, truth, link, rho in itertools.product((20, 480), TRUTHS, (.6, .05), (0, .5)):
    add("E", f"links-dependence-b{link}-rho{rho}", n, 1, truth, "P3", arms(truth), raters=6, tasks=2)

for row in records:
    row.setdefault("FixedPopulationConfigurations", 0)
inputs = {row["ConditionId"] for row in records if not row["InputAlias"]}
assert len(records) == 680 and len(inputs) == 612
assert len({row["ConditionId"] for row in records}) == len(records)
assert all(row["InputId"] in inputs for row in records)
assert sum(row["SavedInputCandidate"] for row in records) == 12
assert all("JML" not in row["Arms"] for row in records if row["Block"] == "D")
assert {row["N"] for row in records if row["Block"] == "AB"} == set(FULL_N)
assert {row["N"] for row in records if row["Block"] == "C"} == set(ANCHORS)
assert sum(row["InitialConfigurations"] for row in records) == 2572
assert sum(row["FixedPopulationConfigurations"] for row in records) == 144

def totals(rows):
    unique = sum(not row["InputAlias"] for row in rows)
    saved = sum(row["SavedInputCandidate"] for row in rows)
    slots = sum(row["InitialConfigurations"] + row["FixedPopulationConfigurations"] for row in rows)
    return dict(ConditionTemplates=unique, InputAliases=sum(row["InputAlias"] for row in rows),
        PlannedRecords=unique*REPETITIONS, SavedInputCandidates=saved*REPETITIONS,
        NewRecords=(unique-saved)*REPETITIONS, InitialSlots=slots*REPETITIONS)

summary = dict(repetitions=REPETITIONS, total=totals(records),
    blocks={b: totals([r for r in records if r["Block"] == b]) for b in ("AB","C","D","E")},
    priorities={p: totals([r for r in records if r["Priority"] == p]) for p in ("P1","P2","P3")},
    precision=dict(max_rate_mcse=math.sqrt(.25/REPETITIONS),
        coverage95_mcse_at_full_delivery=math.sqrt(.95*.05/REPETITIONS),
        zero_failures_one_sided95_upper=1-.05**(1/REPETITIONS)),
    notes=["Allocation only: no response datasets, RNG states or fits generated.",
        "Input aliases and paired cohorts are not independent replications.",
        "Saved candidates use fixed original replicate IDs 1--50, subject to input/source checks.",
        "All original 100-replicate evidence remains retained; compatible extra results retain their actual denominator.",
        "F reuses calibration records; supported scoring panels and checks add work, not calibration datasets."])
assert summary["total"]["PlannedRecords"] == 30600
assert summary["total"]["NewRecords"] == 30000
assert summary["total"]["InitialSlots"] == 135800
assert summary["priorities"]["P1"]["InitialSlots"] == 74200
assert summary["priorities"]["P2"]["InitialSlots"] == 54400
assert summary["priorities"]["P3"]["InitialSlots"] == 7200

out = pathlib.Path(sys.argv[1])
out.mkdir(parents=True, exist_ok=False)
with (out/"conditions.csv").open("w", newline="") as handle:
    writer = csv.DictWriter(handle, fieldnames=records[0].keys())
    writer.writeheader(); writer.writerows(records)
(out/"allocation.json").write_text(json.dumps(summary, indent=2)+"\n")
print(json.dumps(summary, indent=2))
