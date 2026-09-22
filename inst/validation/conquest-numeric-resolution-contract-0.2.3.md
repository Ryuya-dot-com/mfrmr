# ConQuest numeric-resolution contract for 0.2.3

Status: repository-only Wave C prerequisite, 2026-08-11. This contract performs
no fit, launches no external program, freezes no tolerance, and authorizes no
confirmation or cross-engine equivalence claim.

## Source boundary

The local reference is ConQuest 5.47.5:

| Artifact | SHA-256 |
| --- | --- |
| `ConQuest_5_47_5.dmg` | `8526b086aa33ee4a7b30b3dc86399f1f287f2667ea86c0cf3016d673e4f6e329` |
| bundled `conquestManual.pdf` | `60bce1a39f5430fd304178356fb943721f9f72c0ddee70a9866c28c87017459f` |

Manual pp. 328--331 define native export roles for parameters, regression
coefficients, covariance, and iteration history. Page 394 states that the
`decimals` option controls screen display and is ignored for file output. The
manual does not establish the number of significant digits, a rounding mode,
or unlimited precision for every CSV export. Consequently, neither screen
precision nor a token such as `424.738979` proves that the underlying value was
rounded to nearest at `1e-6`.

## Contract

`conquest-numeric-resolution-contract-0.2.3.R` reads audited CSV columns as
character data before numeric conversion and retains, for every numeric cell:

- decoded lexical token and row/column identity;
- file role, filename, and complete-file SHA-256;
- finite decimal/scientific-notation grammar status;
- decimal places, exponent, significant digits, and trailing zeroes;
- the lexical unit suggested by the written token; and
- a separately declared rounding rule.

The lexical unit is descriptive. It becomes an uncertainty interval only when
the rule is independently declared as `nearest`. `exact` declares that the
token itself is the value. The default is `unknown`, which retains the token
but produces no interval.

For an external value `y`, reference value `x`, and independently established
round-to-nearest unit `u`, the compatible absolute-difference range is

`max(0, abs(x - y) - u / 2)` through `abs(x - y) + u / 2`.

Without an established rule, the comparison is
`reported_resolution_limited`. Exact lexical equality, numeric equality,
compatibility at established resolution, tolerance passage, and scientific
equivalence are distinct fields. The helper always leaves scientific
equivalence unknown and never derives a tolerance from observed differences.

## Wave C admission effect

The existing binary and RSM/PCM ladders remain same-platform calibration.
Their approximate `4.14e-7` and `1.25e-6` deviance differences cannot be
described as more precise than the retained external tokens. A future
independent or candidate-linked run must:

1. retain the five native CSV files byte-for-byte and record SHA-256;
2. run this raw-token audit before the ordinary numeric adapter;
3. record the engine/version, executable hash, input/command hashes, objective
   interpretation, likelihood, constraints, nodes, bounds, stopping reason,
   and final-history/export agreement;
4. label rounding as `unknown` unless the rule is independently established;
5. report exact-token, resolution, prespecified-tolerance, and scientific
   decisions separately; and
6. keep the result `review` until candidate identity and every model-specific
   Wave C gate pass.

This contract is reusable for the future additive Person/Rater/Criterion
RSM/PCM microcases. It does not broaden the current public item-only ConQuest
adapter.
