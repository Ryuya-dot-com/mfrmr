# mfrmr 0.2.3 GPCM score v4 confirmation entry record

Status at entry: dry-run runner and separate authorization contract sealed
without fitting, 2026-08-11. The default authorization decision was
`no_go_not_issued`. This is the historical pre-execution record; the subsequent
single negative execution is documented in
`gpcm-score-v4-confirmation-result-record-0.2.3.md`.

## Bound identities

| Component | SHA-256 |
|---|---|
| Confirmation runner | `53de91632f368bc404ff064b7819d820ee7f592db74b286071a70b8f88715c1a` |
| Authorization source | `677a21bd6d6c8fe6a735c137e6e7acfa8f43dce343594283ca5ec6c39d6402e2` |
| Independent validator | `7646c8cfb042942c5bbc00454410e3f5528a370e057478e1c8e16a96acadcaf9` |
| Confirmation design | `31b495b46aef7706835030efe3b41d2888242a4a8f7724ead435c2c7648fb11a` |
| Bounded-v4 freeze | `3baab8bfabf5b05600a2a12057cfcb6b79c7c3c665824675afb6cafa9c56744b` |
| Bounded-v4 rule | `c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126` |
| V3 replay runner | `9a6a8cc73ba1c72fb532b9254389973bfec29cb65da99642db6db9081ae0f0f9` |
| Package payload | `ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a` |
| Runner identity row | `14bccb69494f98798abf3dd23dbf51ea18107d19d251e9df2dad29011400be2f` |
| Six-scenario manifest | `04efdbcb857f6bd99ee4295e560594e6e1fd005a7623864e40bd857b34cf5b33` |

The runner also binds the numerical base, calibration design, independent
non-unit-score oracle, and v3 score rule. The three fixture identities remain
those in the sealed design record. The exact future denominator is 96 evidence
rows, 888 coordinate rows, 24 point rows, and 688 entrywise Jacobian rows.

## Fail-closed execution boundary

The runner defaults to `dry_run = TRUE`. A non-dry invocation requires all of
the following in one fresh R process:

- an explicit execution request and `authorize = TRUE`;
- exact runner, identity, payload, design, freeze, rule, replay, fixture, and
  manifest identities;
- the unchanged complete denominator and structurally disjoint design flags;
- an output path supplied in absolute form, with an existing parent and no
  existing target;
- the exact unconsumed authorization row issued in that same process; and
- reproducible authorization-source, issued-row, and consumed-row hashes.

The input-path check occurs before normalization. A relative path therefore
cannot become eligible merely because `normalizePath()` represents it as an
absolute path. The authorization row does not open a fit or create its target.
The issued-row hash is necessarily issuance-specific because process, time,
and target are part of the row; it is embedded and rechecked if consumed.

Seventy-four no-fit expectations cover default NO-GO behavior, exact denominator and
class counts, relative-path refusal, missing/stale/tampered authorization,
occupied-target refusal, same-process validation, consumed-row hashing, and an
empty-evidence rejection. They also verify the independent validator's closed
96/888/24/688 denominator and refusal of absent or incomplete results.
Synthetic GO issuance was used only to test the contract and created no fit or
result.

## Decision boundary

The implementation is now ready for a deliberate pre-execution review, not
automatically ready to execute. The next permissible state-changing action is
one fresh-process issue-and-consume operation to one new absolute target, only
after rechecking runner, validator, authorization, and default NO-GO hashes.
There is no retry
permission and no rule adjustment permission. Even a complete numerical pass
would confirm only this bounded v4 implementation rule over the sealed design;
it would not freeze a general `NUM-SCORE-TOL`, prove the global GPCM boundary,
authorize inference, or promote the 0.2.3 capability claim.
