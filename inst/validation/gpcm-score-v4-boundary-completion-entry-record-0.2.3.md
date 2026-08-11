# mfrmr 0.2.3 GPCM score v4 boundary-completion entry record

Historical scope: this record freezes the pre-execution entry state. The later
one-time outcome is recorded separately in
`gpcm-score-v4-boundary-completion-result-record-0.2.3.md`.

Status: runner and authorization boundary complete; execution remains NO-GO,
2026-08-11. No fit or finite-difference result has been opened.

The dry-run-by-default runner binds the sealed calibration-only design, v4
classifier, retrospective evaluator, v3 replay machinery, complete development
package payload, and one-row manifest. Its source SHA-256 is
`78e0bcfd14c5c4343e0ff4beeb9c250b324539f1dffe8468bed4ccaf13f8090e`,
its dry-run identity SHA-256 is
`2130e8d859e5cfb120e6f46dc8b692b979f026e1dfd99496f4927d30e24e8387`,
and its manifest SHA-256 is
`88fcdf2706d059ed3ac386ff80d23a4d02f10d7bc1acb747261318cc8da0192b`.

The separate target-bound authorization source SHA-256 is
`41f51a6d3e56b09ec92d67aee2f3ff92b0438a49c4e0d370701071072a95d3a3`.
It defaults to `no_go_not_issued`, opens no fit, and writes nothing. Issuance
requires exact runner, design, v4-rule, retrospective, v3-replay, package-
payload, fixture, manifest, and denominator identities; calibration-only and
development-source states; a fresh-process attestation; an explicit execution
request; an existing output parent; and an absent exact target.

A GO row is valid only for its issuing process and exact output path. The
runner independently verifies the row hash and the authorization source hash,
then requires the target still to be absent. On successful consumption it must
embed the full row after changing its status to `consumed_result_embedded` and
recording `ConsumedAtUTC`. The issued authorization hash is retained and a
separate `ConsumedRowSHA256` makes the mutated saved row directly verifiable.
Post-hoc reconstruction is not permitted.

The completion audit obtains the previously unavailable five-point finite-
difference score at the one v4-classified finite boundary point, while retaining
the analytic score and both transformation-Jacobian checks. Its complete
denominator is fixed at four evidence rows, 24 coordinates, one point, and 30
entrywise Jacobian rows. The result can only complete calibration: it is
permanently confirmation-ineligible and cannot freeze a general score
tolerance, authorize inference, or count as new disjoint confirmation.

Forty-four focused expectations verify dry-run behavior, fail-closed missing
authorization, exact source/process/target binding, tamper rejection, occupied-
target refusal, complete issuance gates, and the empty-denominator negative
decision. They do not run a fit. The next action, if separately continued, is
one fresh-process issuance and immediate consumption at a new fixed target,
with no retry or change to rules, fixture, quadrature, optimizer, or stopping
settings.
