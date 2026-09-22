# mfrmr 0.2.3 GPCM score-rule v3 freeze record

Status: frozen for disjoint confirmation, 2026-08-11. This seal freezes the
bounded calibration rule and its complete executable source identity. It does
not freeze a general `NUM-SCORE-TOL`, prove a boundary or finite extreme-slope
maximum, authorize inference, or authorize execution of confirmation data.

## Freeze-review finding

The first corrected v3 replay had numerically complete evidence, but freeze
review found that its execution identity omitted
`numerical-stationarity-pilot-0.2.3.R`. That file supplies the coordinate table,
likelihood bundle, and free-to-expanded GPCM Jacobian used by the replay. The
omission did not change the observed numerical result, but it made the phrase
"exact source identity" too strong. The earlier deterministic artifacts remain
audit history and are not the frozen evidence.

The calibration, attribution, and v3 runners now explicitly reload their
declared validation dependencies once per fresh source load. The numerical
base is a named member of both v2 and v3 identities. This prevents pre-existing
same-named validation helpers from silently supplying the calculation in the
documented fresh-process workflow.

One intermediate v2 source-bound artifact was also rejected because the
dependency was reloaded but its hash column had not yet been emitted into the
v2 identity table. It supplies no freeze evidence.

## Frozen source-bound identities

- package payload:
  `ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a`
- numerical base:
  `68df33bc1c114309f875a0cf8056ac720254740633fe55ca909535d032663344`
- source-bound v2 result:
  `c3bc7cd84ecf930a1b52fdfbd1c9f965aceb9072c7ee675dc4e0e42363f0f5dc`
- v2 execution identity:
  `18b5fc8c6f2c09c420b1be8dd9c2b8ff08d66f4c4b4850815868e3eecd6afa36`
- v2 manifest:
  `8ecca4c04d4f81913172cba880dda154fab60238b0aae8c88483445c2fff758a`
- source-bound analytic attribution:
  `3a98f86bafa44c49d5826e1826162c71314d486545b38481fbe734b746721c7f`
- v3 rule source:
  `caa58301fcb676d22ab60263c23b641dfd6b6559bc5f72fa52391db0ebe61e60`
- v3 replay runner:
  `9a6a8cc73ba1c72fb532b9254389973bfec29cb65da99642db6db9081ae0f0f9`
- source-bound v3 replay identity:
  `5651592f12e2ba5f4c4d394d49516de1d1720e0a1c300feb1af7be4dc753f3a7`
- source-bound v3 manifest:
  `520c6969633d7e41369bbacbaf1d5e66cf20c684c9d2ddbe9b5f82ffbc7a829d`
- source-bound v3 result:
  `a133d1e5aea075d9017637453dc497ba9028d9ad82f3ca5c175bab67c5ba2296`
- freeze validator:
  `de3b3bcf6e78ba99806bc67fafe85e908557e912c9c4212cbe6233c5913074bd`

The freeze validator binds nine validation sources, all package `R/` and
`src/` payload files, and the three retained RDS artifacts. It checks all 128
evidence keys, the 672-coordinate denominator, 32 point summaries, 384
entrywise Jacobian rows, review-only fit status, and every non-promotion flag.

## Mathematical review

The frozen target is the fixed-standard-normal-quadrature MML negative log
likelihood for the declared additive GPCM cells. Positive owner slopes are
represented by free log slopes expanded to a sum-zero log vector, hence their
geometric mean is one. The independent score is independent of the production
gradient, while intentionally sharing the declared additive/step indexing and
quadrature contract; it is not an end-to-end independently indexed estimator.

For each quadrature node, the analytic score uses posterior expectations of
the GPCM sufficient statistics. Additive terms use the signed residual
`a(y - E[Y])`; step terms use cumulative-category indicators; log-slope terms
use the observed-minus-expected category kernel multiplied by the positive
slope. Expanded gradients are mapped to free sum-zero coordinates by the
reference-level contrast. The final sign is that of the negative marginal log
likelihood. The five-point derivative is required only inside
`max(abs(z)) <= 3`; outside it, analytic and transformation checks remain
mandatory but finite differences are explicitly not applicable.

The source-bound replay is numerically identical to the preceding corrected
replay for coordinates, evidence, point summaries, Jacobians, and decision.
Maximum combined ratios remain 0.1716381 (analytic score), 0.001754898
(finite difference), 0.1717086 (expanded-log Jacobian), and 0.2676695
(positive-slope Jacobian). Three retained points remain extreme review
handoffs; no source fit is inference-ready.

## Frozen boundary for the next stage

The four combined rules and the inclusive log-slope envelope are now frozen
unchanged for a future disjoint exact-candidate confirmation. Confirmation
fixtures, their hashes, and an execution authorization contract are still
missing. Until those are specified without viewing their results, checklist
rows `canonical_score_reference` and `gpcm_transformed_score` remain
`review / pilot_required`.

Changing any frozen rule, source, package payload, or artifact invalidates the
seal and requires a new calibration lineage. A later confirmation pass may
support a candidate-specific numerical gate; it cannot by itself validate
recovery, standard errors, DFF, fit indices, sparse designs, or external-engine
equivalence.
