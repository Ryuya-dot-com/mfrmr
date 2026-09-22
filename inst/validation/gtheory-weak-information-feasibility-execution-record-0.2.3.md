# Draft.83d2b2b1d replacement feasibility execution record

Date: 2026-08-10
Scope: untouched replicates 101--125, atomic full/reduced checkpoints,
threshold-free descriptive resolution feasibility, and exact resume
Result: all 3,000 method routes and 750 datasets are accounted for; the
descriptive evidence ledger is ready, but numerical and few-level weaknesses
keep calibration, thresholds, inference, and D-study decisions closed

## Frozen identities

The run used the exact Draft.83d2b2b1c upstream identities:

- feasibility contract:
  `3a005d424d6121d0feda96ac4455e230cb7f4c93d0f152659b27f3ea647d406b`;
- untouched feasibility manifest:
  `bc14c65fb6ccc26c22d60487f4225493cd58735a48a44758d19cbaf739b17242`;
- viewed-runtime execution:
  `9099eec3ae54485162b18e3fee14aae4b1d888fe32e2bc0b897fbb1d8105e7eb`;
  and
- descriptive-feasibility authorization:
  `e36e82198763e7a785a840cbd9bc029b658b919f58e14377a24e6ced1ca64e1a`.

The new identities are:

- atomic runner contract:
  `c97b5d08c29e7a7537fe4669f938de9e978b4bb651596007af0b7ea7b9378df7`;
  and
- timing- and reuse-excluded scientific execution:
  `04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b`.

The immediate full resume validated all route and dataset hashes, performed
zero new route computations, reused all 3,000 route checkpoints, and
reproduced the scientific execution hash exactly. A further independent test
invocation repeated the same full-resume result.

## Exact accounting

| Quantity | Result |
| --- | ---: |
| planned and recorded method rows | 3,000 / 3,000 |
| independent scenario-replicate datasets | 750 / 750 |
| valid route checkpoint files | 3,000 |
| valid dataset completion markers | 750 |
| planned full/reduced backend fits | 6,000 |
| returned full/reduced pairs | 3,000 / 3,000 |
| typed route failures | 0 |
| common-score-available rows | 2,804 / 3,000 |
| likelihood/optimizer-identity unavailable rows | 79 |
| finite materially negative raw likelihood differences below -1e-6 | 126 |
| non-finite raw likelihood differences | 7 |
| overlap: likelihood/optimizer unavailable and finite material negative | 9 |
| non-finite differences within the likelihood/optimizer-unavailable set | 7 |
| union unavailable | 79 + 126 - 9 = 196 |
| available small negative differences retained | 759 |
| target-boundary rows | 913 |
| nuisance-boundary rows | 381 |

All 3,000 pairs returned from the backend wrapper. That return rate is not an
availability rate. Seventy-nine returned pairs fail the registered optimizer
or likelihood-identity condition, 126 have a finite raw nested-likelihood
difference below the numerical tolerance, and seven have a non-finite raw
difference. The finite material-negative overlap is nine; all seven non-finite
rows are already in the 79-row failure set. This leaves 196 unavailable
common-score rows and 2,804 available rows.

The raw likelihood difference is never truncated to zero. Among negative
values, the minimum is approximately -5.13e-5, the median is -2.53e-7, and
the first percentile is approximately -7.06e-6. The 759 negative values
within tolerance remain available numerical observations; the 126 finite
material values do not become evidence that the scientifically reduced model
fits better. An earlier draft of this record called all 133 false tolerance
flags material-negative; Draft.83d2b2b1e identified and corrected that
classification because the seven non-finite values are not signed differences.
For hash reproducibility, the immutable Draft.83d2b2b1d execution object still
retains its legacy `MaterialNegativeDropCount=133` field; that field must now
be read as `NegativeDropWithinTolerance is not TRUE`, not as a finite signed
count. Draft.83d2b2b1e adds an explicit finite `MaterialNegativeDrop` field.

The sum of the 3,000 stored pair elapsed times is 1,878.702 seconds; the
median pair time is 0.257 seconds and the maximum is 3.109 seconds. Generation
and pre-fit time is not included in that sum. Timing is retained only as local
planning telemetry and is absent from the scientific execution identity.

## Availability and boundary structure

Across methods, the design-level results are:

| Design | Available / 600 | Likelihood available | Material negative | Target boundary | Nuisance boundary |
| --- | ---: | ---: | ---: | ---: | ---: |
| baseline complete | 586 | 590 | 5 | 211 | 34 |
| few levels complete | 576 | 587 | 11 | 266 | 283 |
| high information | 457 | 554 | 101 | 89 | 11 |
| imbalanced hub | 595 | 597 | 3 | 181 | 39 |
| sparse connected | 590 | 593 | 6 | 166 | 14 |

The corresponding common-score availability rates are 97.7%, 96.0%, 76.2%,
99.2%, and 98.3%. High information therefore does not guarantee a numerically
valid nested comparison. Its 101 materially negative rows dominate the
overall material-negative count.

Across designs, the method-level results are:

| Method | Available / 750 | Likelihood available | Material negative | Target boundary | Nuisance boundary |
| --- | ---: | ---: | ---: | ---: | ---: |
| glmmTMB ML | 702 | 749 | 47 | 181 | 89 |
| glmmTMB REML | 699 | 744 | 45 | 160 | 69 |
| lme4 ML | 704 | 719 | 20 | 293 | 121 |
| lme4 REML | 699 | 709 | 14 | 279 | 102 |

These are route-feasibility descriptions, not estimator rankings. The
dominant problems differ: high-information glmmTMB routes contribute many
materially negative likelihood differences, while lme4 routes contribute
more optimizer/likelihood-unavailable states and more target-boundary states.
No alternate optimizer or tolerance was selected after viewing these data.

Within high information, each glmmTMB route has 13/25 material negatives at
exact zero, 10/25 at numerical near zero, 12/25 at 0.0025, 6--7/25 at 0.01,
and 2/25 at 0.04. The problem is therefore not confined to the exact boundary.
This requires a separately frozen numerical-reproducibility sensitivity
before any likelihood-drop rule is eligible for calibration.

The target-boundary counts by generating variance are:

| Generating Rater variance | Available / 500 | Target boundary / 500 | Material negative / 500 |
| ---: | ---: | ---: | ---: |
| 0 | 448 | 202 | 38 |
| 1e-10 | 454 | 225 | 31 |
| 0.0025 | 465 | 228 | 29 |
| 0.01 | 467 | 161 | 19 |
| 0.04 | 485 | 61 | 6 |
| 0.12 | 485 | 36 | 3 |

The 0.0025 transition has more target-boundary results than the exact-zero
condition. This is compatible with weak finite-sample resolution and directly
rejects any attempt to turn boundary attainment alone into a monotone binary
classifier. Transition cells retain their registered no-binary-requirement
role.

## Threshold-free ordering summaries

Spearman correlations use only finite common-score rows and are descriptive.
Every design x method x score result retains its available N and all six
generating truth levels. Across the 20 design-method strata:

| Score | Minimum rho | Median rho | Maximum rho |
| --- | ---: | ---: | ---: |
| target fraction of fitted total variance | 0.151 | 0.614 | 0.652 |
| target-to-residual variance ratio | 0.151 | 0.610 | 0.657 |
| raw likelihood difference | 0.143 | 0.559 | 0.606 |

The two component-ratio scores have stronger median ordering than the raw
likelihood difference, but none is close to deterministic recovery. The
few-level design is the limiting stratum: its correlations range from about
0.151 to 0.259 for the component scores and from 0.143 to 0.194 for the raw
likelihood difference, while 283/600 routes also contain a nuisance boundary.
High availability alone therefore does not establish useful resolution.

Only baseline-complete and high-information designs had prospectively
registered positive and negative controls. Their common-available empirical
rank probabilities are:

| Design | Method | Positive N | Negative N | Target fraction | Target/residual | Raw likelihood drop |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| baseline | glmmTMB ML | 25 | 50 | 0.9480 | 0.9464 | 0.9248 |
| baseline | glmmTMB REML | 25 | 50 | 0.9480 | 0.9472 | 0.9192 |
| baseline | lme4 ML | 24 | 46 | 0.9375 | 0.9366 | 0.9094 |
| baseline | lme4 REML | 24 | 47 | 0.9725 | 0.9716 | 0.9397 |
| high information | glmmTMB ML | 48 | 27 | 0.8665 | 0.8673 | 0.8202 |
| high information | glmmTMB REML | 48 | 27 | 0.8727 | 0.8688 | 0.8210 |
| high information | lme4 ML | 43 | 39 | 0.8915 | 0.8951 | 0.8623 |
| high information | lme4 REML | 42 | 39 | 0.8944 | 0.8932 | 0.8797 |

The estimand counts a tie as one half and retains the exact
`PositiveN * NegativeN` denominator. These values show ordering signal, not a
threshold or a calibrated test. The high-information negative-control
denominators are especially reduced by unavailable comparisons, so their
conditional rank probabilities cannot be read without the availability
table. Pairwise comparisons also share observations and are not treated as
independent Bernoulli trials. No p-value, interval, ROC cutpoint, or binary
classification accuracy is attached.

## Mathematical interpretation

This slice supports four narrow conclusions.

1. The exact descriptive execution is operationally reproducible: every
   planned route is represented by one self-hashed success or typed failure,
   and a no-refit resume reproduces the complete scientific identity.
2. Target-fraction and target-to-residual scores contain useful but imperfect
   monotone information. Their behavior is design dependent and is weakest
   with few facet levels.
3. Raw full/reduced likelihood differences are not currently a portable
   application-time score. The high-information material-negative pattern
   first requires frozen optimizer/control and likelihood-identity
   sensitivity work; negative values cannot be repaired by post hoc
   truncation.
4. Boundary attainment is not a resolution rule. The nonmonotone boundary
   frequency near zero and the high few-level nuisance-boundary frequency
   require explicit indeterminate/not-evaluable states.

These conclusions do not establish bias, RMSE, confidence-interval coverage,
finite-sample test size or power, a minimum sample size, a production
bootstrap replication count, or D-study coefficient stability.

## Readiness and next gate

`FeasibilityEvidenceReady = TRUE` now means exact completion of this
descriptive ledger only. The following remain false:

- `BootstrapOperatingCharacteristicsReady`;
- `CalibrationEvidenceReady`;
- `ThresholdFrozen`;
- `ConfirmationAuthorized`;
- `InferenceReady`;
- `CoefficientEligible`; and
- `DecisionReady`.

The next contract must be frozen before generating calibration replicates
201--300. It should contain two noninterchangeable lanes:

1. a numerical-likelihood sensitivity on already viewed feasibility data,
   with fixed alternative optimizer/control profiles and exact full/reduced
   likelihood reproduction, used only to define eligible routes; and
2. an untouched outer operating-characteristic calibration comparing a plain
   fitted-reduced bootstrap with a prespecified nuisance-boundary treatment.

The second lane must retain scenario x method denominators, failures, size,
power, Monte Carlo uncertainty, positive-component bias/RMSE/coverage, and
D-study stability separately. The few-level stratum cannot be pooled away,
and no threshold can be selected from replicates 101--125.

## Test and artifact evidence

Five focused tests and 65 expectations pass with the explicit full tier. They
cover upstream authorization replay, route/dataset hash corruption and stale-
identity rejection, atomic overwrite, tie-aware rank probability, exact
threshold-free stratification, all 3,000 route results, all 750 dataset
markers, and zero-computation full resume.

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-weak-information-feasibility-runner-contract-0.2.3.md` | `5c4336ad4e9ddfb2dc0bbf8a880236d64fb7bbb43f942b0e4fe3215cc4df8241` |
| `gtheory-weak-information-feasibility-runner-0.2.3.R` | `9eba5781d28554c4353287946962bcb61564dd729a01482a22d9ce9bd93349f8` |
| `test-gtheory-weak-information-feasibility-runner.R` | `9b0b79f4d4bcd5c5859d022ec05d49108bd3a1690b7528eb7070bf7ade389b2c` |

The record's own hash is omitted because recording it would change the file.
