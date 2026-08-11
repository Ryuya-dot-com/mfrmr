# mfrmr 0.2.3 GPCM score v4 boundary-completion result

Historical scope: this record states the result-review status before the later
no-fit seal. The bounded rule is subsequently frozen in
`gpcm-score-v4-freeze-record-0.2.3.md`; all broader non-promotion limits remain.

Status: independently validated calibration-only numerical pass, 2026-08-11.
V4 is ready for a separate freeze review but is not frozen. No retry was run.

The one target-bound authorization was issued and immediately consumed in one
fresh R process. The saved artifact is
`validation-results/gpcm-score-v4-boundary-completion-source-bound/gpcm-score-v4-boundary-completion.rds`
with SHA-256
`5998c6c5f01a9436af0af152d30315655291275d72c169649e048f0d5647400e`.
The runner source SHA-256 is
`78e0bcfd14c5c4343e0ff4beeb9c250b324539f1dffe8468bed4ccaf13f8090e`,
the authorization source SHA-256 is
`41f51a6d3e56b09ec92d67aee2f3ff92b0438a49c4e0d370701071072a95d3a3`,
and the independent no-fit validator source SHA-256 is
`ff2b8e55316251411076480751f1ed39459d5a2be8675c0bce8a99482631b9e7`.

The fit completed with optimizer code zero in 2.07 elapsed seconds, but its
package readiness is `review` and `InferenceReady = FALSE`. The complete fixed
denominator is present: four parameter-class evidence rows, 24 identified-free
coordinates, one point summary, and 30 entrywise Jacobian rows. The class
counts are 5 owner-additive, 2 other-additive, 12 step, and 5 log-slope
coordinates.

All four numerical components pass the unchanged rule. Their maxima are:

- analytic-score combined ratio: `5.04726284250545e-05`;
- five-point finite-difference combined ratio: `0.0006326413`;
- free-log to sum-zero-log Jacobian combined ratio: `0.2028742`;
- sum-zero-log to positive-slope Jacobian combined ratio: `0.2822680`.

The constructed six-level point has raw excess `8.881784197001252e-16`
against its error-derived allowance `6.905587213168476e-15`; it is therefore
in the finite constructed-point region. This does not rescue an estimated
retained extreme, prove a finite global slope maximum, or freeze a general
optimizer/score tolerance.

The embedded authorization retains issued-row SHA-256
`cde0633dead58cab7bed93986511a45f6863ae9e7b9e8a70cab3a1055e1ab58e`
and consumed-row SHA-256
`045c011ff47420d520b340a9c1d3b822dc32f3fc2c3685c8f097e07a29e9d519`.
Both independently reproduce. Its target is recorded in repository-relative
form rather than as an absolute path; the validator records
`AbsoluteTargetRecorded = FALSE` and verifies that the path resolves exactly
to the hashed artifact from the repository root. This is disclosed for freeze
review and is not silently upgraded into an absolute-path claim.

The independent validator reports
`validated_calibration_only_numerical_pass`: artifact/source/authorization
integrity, target resolution, denominators, coordinate rules, and aggregation
all pass. It also records `FitReadiness = review`,
`V4FreezeReviewReady = TRUE`, `V4Frozen = FALSE`,
`GeneralNUMSCORETOLFrozen = FALSE`, and `InferenceAuthorized = FALSE`.
Nineteen validator expectations include numerical and authorization tamper
rejection and do not refit the model.

The completion fixture remains permanently confirmation-ineligible. The next
step is a no-execution review/freeze decision over the complete v4 calibration
lineage. Only after that decision may a new structurally disjoint confirmation
family be designed. This artifact cannot be rerun, relabelled as confirmation,
or used to authorize inference or release promotion.
