# Draft.81 typed G-theory parser and algebra record

Status: completed repository-only structural prototype, 2026-08-09.

## Decision

Draft.81 passes its narrow structural gate. The internal parser constructs a
deterministic typed effect map, and its component-wise balanced algebra exactly
reproduces the frozen p x i and p x r x i hand calculations. Unresolved,
aliased, nested-without-operator, and malformed inputs fail before coefficient
output. This result moves `gtheory_typed_design_algebra` from `not_run` to
`review`; it does not make that roadmap guard `ok` and does not promote a
public design family.

No variance component was estimated in this slice. Consequently this record
is evidence for parsing and transformation correctness only, not component
recovery, standard errors, coverage, convergence, missing-data robustness, or
decision use.

## Executed environment and artifacts

- R 4.6.1
- reformulas 0.4.4 (`findbars()` / `nobars()` parser backend)
- digest 0.6.39 (SHA-256 serialized identities)
- `gtheory-design-algebra-prototype-0.2.3.R`
- `gtheory-design-algebra-contract-0.2.3.md`
- `test-gtheory-design-algebra-prototype.R`

The dedicated test command was:

```sh
Rscript -e 'testthat::test_file("tests/testthat/test-gtheory-design-algebra-prototype.R", reporter="summary")'
```

Result: eight tests and 46 expectations passed, with no failure, warning, skip,
or error.

## Positive oracle results

### p x i

The component vector was `p=1`, `i=.2`, `p:i,e=.8`, with `n_i=4`.

| Quantity | Result |
| --- | ---: |
| Universe variance | 1 |
| Relative error | .2 |
| Absolute error | .25 |
| G | .8333333333333333 |
| Phi | .8 |

The component divisors were 1 for p and 4 for both i and the collapsed
p:i,e residual. The design hash was
`77f41208ecab2ef64f4dba952cdfebf673acc11eac71654cd76bd7dc08fa7764`;
the result hash was
`46d649f5a99984001459d833ed3835fd2048327db6254d6669ce68df815e0c31`.

### p x r x i

The component vector was `p=1`, `r=.12`, `i=.18`, `p:r=.24`, `p:i=.30`,
`r:i=.08`, and `p:r:i,e=.48`, with `n_r=2` and `n_i=3`.

| Quantity | Result |
| --- | ---: |
| Universe variance | 1 |
| Relative error | .3 |
| Absolute error | .4333333333333333 |
| G | .7692307692307693 |
| Phi | .6976744186046512 |

The relative contributions were `.24/2=.12`, `.30/3=.10`, and `.48/6=.08`.
Absolute error additionally used `.12/2=.06`, `.18/3=.06`, and
`.08/6=.0133333333333333`. Their independent column sums equal the returned
relative and absolute denominators. Increasing `n_r` from 1 to 2 to 4 at fixed
`n_i=3` increased both coefficients monotonically, with `Phi <= G` in every
scenario. In exact fractions, `G=10/13` and `Phi=30/43`.

The design hash was
`899fd433b74e967d3ff0ffe299378cc260280250bf173c54604836b58f10faf6`;
the result hash was
`70a3ab50818eb0bc36d328ed58bf10310dbeb139a0c63ac6572e078c01e042bb`.

## Formula and semantic checks

- Reordered terms, reversed interaction spelling such as `Item:Person`, and
  random-intercept `||` normalize to the same declared-order effect map and
  design hash.
- Reordered named component vectors and nonsemantic design-grid row names
  produce the same canonical result hash.
- `Site/Rater` is retained as an original nesting edge even though the backend
  expands it to Site and Site:Rater. Without `Site > Rater` metadata the design
  records `unresolved_nesting_metadata`; with that metadata it records
  `nested_scaling_not_supported` until Draft.83 supplies conditional operators.
- Missing lower-order crossed components, an unspecified residual divisor,
  a residual assigned outside both relative and absolute error, random slopes,
  omitted fixed intercepts, fixed predictors, invalid balanced counts,
  nonnumeric estimates, and component-name mismatches are rejected or marked
  algebra-ineligible.
- A fitted highest-order interaction plus Residual without cell replication
  marks both components `aliased` and produces no coefficient table.
- Negative raw components are preserved. They produce an inspectable raw
  transformation with `raw_negative_component` and `AlgebraReady=FALSE`, not
  truncation or an assertion that a likelihood estimator returned a negative
  variance.

Even the positive hand fixtures have `DecisionReady=FALSE` and
`DecisionStatus=prototype_no_estimation_or_uncertainty`. Their
`AlgebraReady=TRUE` state certifies only the declared deterministic
transformation; it cannot stand in for fitted-component recovery or uncertainty.

## Interpretation boundary and next step

The hashes include the parser backend/version because parser identity is part
of reproducibility. They are fixture identities, not cross-version constants;
semantic equivalence across parser versions must be tested through the
canonical fields as well as recorded hashes.

Draft.82 is next: implement a balanced ANOVA/method-of-moments oracle and
matched `lme4` REML/ML extraction under this effect map, retain raw negative
MoM estimates separately from likelihood boundary zeros, and verify exact
reduction to the current main-effects/collapsed-residual helper where that
collapse is intentionally declared. Nested, unbalanced, missing, interval,
and multivariate claims remain later gates.
