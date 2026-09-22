# mfrmr 0.2.4 public-language/schema numerical-parity record

Status: `rsm_pcm_exact_numerical_parity_complete_hosted_pending`, 2026-08-26.

## Result

The source tarball from the pre-amendment recovery payload and the source
tarball from exact amended commit
`96068c9a16d48e7011a321f40ef125d8ab621418` were installed into separate R
libraries. Each installed package independently fitted the same synthetic
training data, extracted and froze a calibration with fixed timestamps, and
scored the same new response rows.

The comparison was run separately for RSM/MML and PCM/MML. For each model, the
following result object was byte-for-byte identical between installations:

- fitted optimizer parameter vector;
- complete calibration coordinate and anchor tables;
- identification constraints;
- scoring quadrature nodes and weights;
- scored-Person estimates;
- row review and row dispositions; and
- Person dispositions.

The maximum absolute difference was zero for fitted parameters, calibration
coordinate values, and Person estimates in both models. The serialized result
SHA-256 was also identical within each old/new pair. Artifact schema and
display labels were intentionally not placed in the numerical comparison
object because those fields are the amendment being tested; their exact new
contract is covered by the lifecycle and mutation tests.

## Interpretation

This closes the direct falsifier that a terminology-only review might miss a
numerical change. It does not by itself reissue the complete statistical G4
evidence or authorize G6. The hosted five-platform denominator and an explicit
delta decision remain required.

## Exact fields

- `ParityContract=mfrmr_public_language_schema_numerical_parity_v1`
- `OldCheckedCommitSHA40=76b4d65722cf82cc082717750ea14340571918a1`
- `OldSourceTarballSHA256=ff7ea0878cef0d6ee4a6ada10db95ea43d7265452070a05be57b61005e6c9dfe`
- `NewCheckedCommitSHA40=96068c9a16d48e7011a321f40ef125d8ab621418`
- `NewSourceTarballSHA256=ad901c65751ffc9974f1ea2ab2739058d8e9f5c672833e3792a85932784c5956`
- `SeparateInstalledLibraries=TRUE`
- `ComparedModels=RSM,PCM`
- `Estimator=MML`
- `ScoringQuadratureOrder=31`
- `RngUsed=FALSE`
- `RsmResultSHA256=d0dbbb2b8b2a531f595afe4eca3825b8e214e4bd12a03cfd2462792f315ebb7d`
- `PcmResultSHA256=bd3c80b90a037ec3e678148f93e5f55d635787f5174f72dba0917ef20a9d462f`
- `RsmOldNewObjectIdentical=TRUE`
- `PcmOldNewObjectIdentical=TRUE`
- `MaxFitParameterDifference=0`
- `MaxCalibrationCoordinateDifference=0`
- `MaxPersonEstimateDifference=0`
- `NumericalScoringAlgorithmChanged=FALSE`
- `StatisticalModelChanged=FALSE`
- `G4Reissued=FALSE`
- `G6Revalidated=FALSE`
- `CandidateMetadataApplied=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=complete-public-language-schema-five-platform-matrix`
