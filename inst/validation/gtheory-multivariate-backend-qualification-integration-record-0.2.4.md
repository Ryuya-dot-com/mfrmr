# Draft.85c4l multivariate G-theory backend-qualification integration record

Date: 2026-08-25  
Scope: non-executing c4k-to-c4e/c3 qualification projection  
Result: backend qualification admission passes; study and public lanes remain closed

## Outcome

The final c4l implementation revalidated the complete c3-through-c4k parent
chain, constructed a six-row repair-completion registry, materialized four
trusted route and two trusted matched-pair rows, and projected the result into
the eight-row c3 prerequisite audit. The historical c3 and c4e objects were
inputs and were not modified.

Exactly one prerequisite changed:
`all_four_matched_backends_qualified` moved from false to true.
`no_diagnostic_override` remained true. The projected count is 2 of 8; the
other six prerequisites and all partial-execution flags remain false.

Ten focused tests and 64 expectations pass without failure, warning, error, or
skip. The final public-surface audit reads textual R, Rd, Rmd, NEWS, and public
roadmap sources and finds no c4l contract or function name.

## Repair completion

| Step | Evidence source | Ready | Original library mutated |
| --- | --- | --- | --- |
| isolated library created | c4i | yes | no |
| package sources pinned | c4i | yes | no |
| selected TMB installed | c4i | yes | no |
| glmmTMB rebuilt against selected TMB | c4i | yes | no |
| fresh-process identity reobserved | c4i | yes | no |
| four route receipts completed | c4j + c4k | yes | no |

The c4e environment identity remains explicitly labelled as the historical
template identity. The repaired environment is represented separately by the
c4i fresh-process receipt; c4l does not rewrite c4e history.

## Qualification projection

All four admitted route rows are fresh-process, ABI-matched, fit-warning-free,
diagnostic-override-free, complete-object revalidated, and capability-isolated:

```text
lme4_ml
lme4_reml
glmmTMB_ml
glmmTMB_reml
```

The matched pairs retain these observed numerical differences:

| Pair | Max covariance absolute | Max covariance relative | Max fixed absolute | LogLik absolute |
| --- | ---: | ---: | ---: | ---: |
| `matched_ml` | 7.021595e-05 | 1.005769e-04 | 3.806434e-05 | 2.744036e-08 |
| `matched_reml` | 8.762925e-05 | 1.040517e-04 | 1.793843e-13 | 7.106848e-08 |

These values are carried for audit visibility. Qualification still depends on
the complete c4j/c4k receipt and object hashes, not on these summaries alone.

## c3 prerequisite state

| Prerequisite | Prior | Projected |
| --- | --- | --- |
| external freeze receipt | false | false |
| clean source identity | false | false |
| all four matched backends qualified | false | true |
| truth-blind process boundary | false | false |
| lane-specific authority | false | false |
| candidate completion before truth release | false | false |
| accuracy threshold before confirmation | false | false |
| no diagnostic override | true | true |

No row allows partial execution. The state therefore supports backend
qualification admission only, not a pilot or any other planned-study lane.

## Receipt identities

```text
ReceiptFileSHA256                       8b9e65be7a8f8d2c4b99e9860e2dc7da64706d75a55d9c7a654e598b0dfbf26d
ReceiptHash                             b616611ad7455ae79f948a10c71eefaa27e9fd2e92de277a64b477a560022c6e
C3ManifestHash                          e1c7285018d814ac5332adb94f780e73410f70120cd079ca282d889935ea3b02
C3PolicyHash                            4d5f9a3481bdef0c935970bd65df9f65f86a76cfa70f197b6c1a4fcc39db0443
C3PrerequisiteAuditHash                 f23c5c9f8df0bb15b64a5051334c8fbf55e7c65f22ac2a2d9b424f1f5ecf29d2
C4EManifestHash                         cb8214df9c468858ca3e4e267e815eab99918f880fb99ed6a336a2b053ef80ce
C4ERepairPlanHash                       0dcb71afc2b1fbad463d22105ab9c76157f50cd376bc8be1537c077e90450742
C4EQualificationReceiptTemplateHash     baf6fe4454aea4fba0a57eeaa95ee38e78a5e5dc60e67bb057c3ae2f968c50e2
C4FManifestHash                         89044060c10c55321e61d2214fc85484aca30c4eafc413f67fc26f00edc6d1fb
C4FPolicyHash                           83947af1c57e62f281c54a4216bc4c384c483a83b482e07be013b31fb86e985a
C4IRepairReceiptHash                    4a7c4ac0eca775e6efef8fa2713fa343c9bec4db3eec9464f0d3c7767058e3af
C4JQualificationReceiptHash             ee5e69982e3833a7fe80d83f170bff3685de7ba45e4dee5cbf8eef742c18a233
C4KEvidenceHash                         daa30f29b2b0291ac2abad9dd8d6c111f840d63ea3e1cc94317fc243235bf73d
C4KTrustedRouteRegistryHash             e2a0fa60a49fc1dae4127afeed970dba41f1df6d39026a5a3564063d9d79adc9
C4KTrustedPairRegistryHash              e340d45062a2d4600ed5f2dfe353cd8108e02b2bba0f37393777ab90cb90be61
RepairCompletionRegistryHash            29a112bb3209c9f8d46f63239fd48ee0600c5e61158689989d71f20febfa7472
QualificationRouteRegistryHash          1fbdc0796133d159b105438834eea3528c6377122cb50f8b65a368e6d0bc6677
QualifiedPairRegistryHash               4925d61aaf7c936cd16b7549ed65c072c380ba7df21609e25ba4af6645ac7d90
PrerequisiteProjectionHash              e65731a882ecafa4656480f16b8b9df0824eeebe20c8692a35f99121ebc4bfdc
ImplementationIdentityHash              0a065278c4c5d67c2820f6947e0c6f14c62e8e9bfdec658e096dd63438b9e562
```

The retained receipt is
`/private/tmp/mfrmr-c4l-integration-receipt-0.2.4.rds`. It is ephemeral,
platform-specific validation evidence and is not a package input.

## Metacognitive boundary audit

- Statistical: c4l changes only the qualification prerequisite. It creates no
  G-study/D-study result, coefficient, standard error, or recovery conclusion.
- Numerical: route and pair identities descend from complete c4j/c4k objects;
  displayed differences are audit aids and cannot independently pass a gate.
- Historical: c3 and c4e remain false-state historical manifests. A successor
  registry records later evidence rather than backdating readiness.
- Reproducibility: all parent, registry, implementation, and receipt hashes are
  bound. A final receipt was regenerated after the implementation was fixed.
- Software: c4l adds a separate 13-function controller and no worker or
  backend dispatcher.
- Security: no protected seed, planned response, reference truth, or accuracy
  threshold is present. The c4k capability result is consumed, not widened.
- External validity: ConQuest was not invoked and remains outside these four
  backend-qualification routes.
- Release: no exported function, help topic, vignette, NEWS entry, or public
  roadmap claim was added. Multivariate G-theory remains unsupported.

## Disposition and next gate

`RepairPlanCompleted`, `AllRouteReceiptsReady`,
`AllPairReceiptsReady`, `BackendQualificationAdmissionReady`,
`BackendQualificationReady`, and `IntegrationReceiptReady` are true.

`AllExecutionPrerequisitesReady`, `StudyOperationallyAdmissible`, every lane
authority, recovery evidence, estimation, inference, decision, and public
support remain false. The dispatch guard rejects every in-scope callback even
with caller authorization.

The next ordered slice is a non-executing truth-blind planned-study adapter
preflight. It may bind opaque c1 stage/unit identities and define candidate
request/receipt transport, but it must not expose scenario identity, seed,
reference identity, truth, or thresholds, and it cannot self-issue any of the
six remaining c3 prerequisites.
