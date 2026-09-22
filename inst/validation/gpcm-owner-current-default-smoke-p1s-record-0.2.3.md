# Current-default paired-owner GPCM smoke P1s record (0.2.3)

## Decision

P1s completes the bounded current-default owner-identity smoke admitted by
P1r. Two non-unit source-owner datasets were each fitted by Criterion-owned
and Rater-owned GPCM under JML and MML. All eight fits returned objects, all
four route-level identity checks passed on every route, and all 12 required
public evidence surfaces retained the full owner, estimator-scale, category-
support, and runtime identity. The optional external-normalizer surface was
not instantiated and supplies no external claim.

This is a software-identity and paired-attribution result. It is not recovery,
coverage, owner-superiority, external-equivalence, fit-index, DFF, or
inference-readiness evidence. Release-spine row 88 remains `review` because
both claimed owners have not passed frozen statistical rules.

## Frozen execution

The final admitted execution used:

- execution SHA-256:
  `addc9f9f860173fd07cf0474f11fe417ee95218a769c603a168863d27ce24fba`;
- runtime SHA-256:
  `429a3d880d0535704f72a497277ce23175c9e8435a6dda385d9f845dce1ab829`;
- P1s runner SHA-256:
  `b1b096dd137f3f9fdf9f30db24fd3dd6cf3d6fe2acfd59b7d1c218868326800f`;
- P1r contract SHA-256:
  `e029a4cd8b0a42bd593fa4a1d56b539389de20af1c8f766592d7954e1222b75e`;
- manifest SHA-256:
  `c7e51e7e166286dc690593921e661827f049252ec5859ea8928b129ab1e34f4f`;
- stored result-file SHA-256:
  `3bf7eaac632c6a0162e92018c80e7904f931d5b15244fc9c037200192122d7d4`;
- completion-marker SHA-256:
  `765df65a02c26d908ad83c27d71d2f29716436a88fc44e5bf4b85cb27ca36f4e`.

The completion marker contains 20 artifact rows. Every recomputed file hash
matches its inventory row, and the inventory-object hash also reproduces.
Within each source-owner block, all four fit routes use the identical retained
data hash:

| Source owner | Rows | Category counts for scores 1--4 | Data SHA-256 |
| --- | ---: | --- | --- |
| Criterion | 4,320 | 568; 1,250; 1,473; 1,029 | `92ae3471dd893ae35f5e3220c205860de71676566d321fdbd156990f7f9131b4` |
| Rater | 4,320 | 818; 1,472; 1,355; 675 | `334b165a9d525817160577affa8dad2746558ac9d0c87f04d6a57859f283064b` |

Both datasets therefore contain every declared category. This observation is
not a sparse-category or boundary operating-characteristic result.

## Route result

| Route | Objective trace | Population SD | Optimizer code zero | Fit readiness | Inference ready |
| --- | ---: | ---: | --- | --- | --- |
| Criterion source / Criterion fit / JML | 4,461.885 | -- | yes | review | no |
| Criterion source / Criterion fit / MML | 4,687.535 | 0.8401 | yes | review | no |
| Criterion source / Rater fit / JML | 4,490.505 | -- | yes | review | no |
| Criterion source / Rater fit / MML | 4,712.771 | 0.8333 | yes | review | no |
| Rater source / Criterion fit / JML | 4,725.133 | -- | yes | review | no |
| Rater source / Criterion fit / MML | 4,957.313 | 0.8697 | yes | review | no |
| Rater source / Rater fit / JML | 4,712.813 | -- | yes | review | no |
| Rater source / Rater fit / MML | 4,946.758 | 0.8823 | yes | review | no |

The objective values are retained numerical traces only. JML and MML optimize
different statistical objectives, and no objective difference is used to rank
owners or estimators.

Every route matched its fitted config, public manifest, replay script, and
public summary. Every route also returned optimizer code zero. Nevertheless,
zero of eight routes is inference ready. Two routes explicitly retained a
terminal-gradient review: Criterion-source/Criterion-fit MML and Criterion-
source/Rater-fit JML. The other six are still `review`, not `ready`, because
the current readiness contract deliberately leaves free-slope GPCM nonlinear
estimability and boundary completeness unresolved. Code-zero convergence is
therefore not relabelled as inferential convergence.

## Required evidence surfaces

The following 12 required surfaces are complete and retain all 12 identity
fields: declared manifest, generated-data ledger, run result, checkpoint row
manifest, checkpoint result, stratum summary, rate summary, numeric summary,
execution identity by stratum, execution policy by stratum, checkpoint ledger,
and replay call. The thirteenth surface,
`external_normalizer_if_instantiated`, remains
`conditional_not_instantiated_no_external_claim`.

The older `gpcm-model-identity-contract-0.2.3.csv` is not rewritten. It is part
of the hashed Draft.66 historical execution lineage and records that run's
fixed-standard-normal MML scale. P1r/P1s form the prospective current-default
overlay: JML records `not_applicable_jml` with jointly estimated fixed-effect
Person coordinates, while MML records `free_population` with an estimated
intercept-only normal population scale.

## Defects found before the admitted run

P1s did not tune the model to obtain a preferred result. Its failed and
superseded attempts are retained as diagnostic history:

1. The first runner stopped after one JML fit because an absent optional
   objective field produced `numeric(0)` in reporting. It wrote no evidence
   bundle. Scalar extraction was made type safe.
2. v1 completed all eight fits, but the harness incorrectly expected the MML
   input argument `free_population` to remain the effective JML scale label.
   The production model and P1r correctly record `not_applicable_jml` for JML.
   The harness was corrected; the model was not changed.
3. v2 passed the identity contract but exposed
   `longer object length is not a multiple of shorter object length` on all
   four MML routes. Warning-as-error reproduction localized this to nonlinear-
   block selection in `audit_mfrm_estimability()`: the code combined a full
   parameter-name vector with a candidate-only logical vector. The selector
   now intersects candidate names first and then tests their sizes. The full
   estimability audit test file passes, and v3 has zero instances of this
   warning.
4. The P1s objective trace now reads the retained `fit$opt$value` and falls
   back to `-LogLik`; the earlier absent trace did not affect fitting or the
   identity gate.

These corrections changed evidence interpretation and a readiness audit, so
only v3 is admitted. v1 and v2 do not enter any aggregate or claim.

## Machine-readable disposition

```text
PairedDatasets = 2
PlannedRoutes = 8
ExecutedRoutes = 8
FitSucceededRoutes = 8
RequiredSmokeSurfacesComplete = TRUE
AllRouteIdentityChecksPass = TRUE
CurrentDefaultOwnerEvidenceComplete = TRUE
OptimizerCodeZeroRoutes = 8
InferenceReadyRoutes = 0
RecoveryClaimAuthorized = FALSE
OwnerSuperiorityClaimAuthorized = FALSE
ExternalComparisonAuthorized = FALSE
AdditionalReplicationAuthorized = FALSE
BroadSimulationAuthorized = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
OwnerEvidenceGatePass = FALSE
GPCMCorePromotionAuthorized = FALSE
```

## Portfolio consequence

The current-default identity gap is closed; repeating this eight-route smoke
would add little information. The next high-leverage GPCM work is not broad
simulation. It is to complete the mathematical and numerical basis for
free-slope inference readiness, separately for JML and marginal MML:

1. define when the retained nonlinear response-kernel or marginal-pattern
   information establishes local estimability without claiming global
   identification;
2. complete estimator-specific slope and joint-boundary classification;
3. resolve the two terminal-gradient review paths under fixed objectives and
   prespecified stability checks; and only then
4. freeze owner-specific recovery, uncertainty, support, and false-ready rules
   before deciding whether replication is needed.

Fit indices and DFF remain descriptive/screening-only until their own
operating-characteristic contracts pass. This ordering avoids spending a
large simulation budget on fits that the current contract already declares
non-inference-ready.

## Reproduction

- runner:
  `inst/validation/gpcm-owner-current-default-smoke-p1s-0.2.3.R`;
- record:
  `inst/validation/gpcm-owner-current-default-smoke-p1s-record-0.2.3.md`;
- P1s test:
  `tests/testthat/test-gpcm-owner-current-default-smoke-p1s.R`;
- nonlinear estimability regression test:
  `tests/testthat/test-estimability-audit.R`;
- local admitted result:
  `/tmp/mfrmr-p1s-current-default-owner-smoke-v3/p1s-result.rds`;
- P1s test SHA-256:
  `6a4a98a4f68301da135b18642695a4377bb2930b20f5eee99cc97bbcb5eda20f`;
- nonlinear estimability test SHA-256:
  `456acd1c5eadc5bfe77290795d464c38cf8df5ad1c3d4c18c5958b73e1f60a7a`;
- corrected estimability source SHA-256:
  `76df99aa3227368bb59da75852ff4fc327df9d854840bd959a4c854de099a3aa`.

Routine tests cover dry runtime binding, paired data hashes, checkpoint
mutation rejection, complete synthetic surface propagation, scalar and
objective extraction, and atomic-save refusal. The stored execution test is
opt-in through `MFRMR_RUN_P1S_SMOKE=true` and `MFRMR_P1S_RESULT=<result.rds>`.
