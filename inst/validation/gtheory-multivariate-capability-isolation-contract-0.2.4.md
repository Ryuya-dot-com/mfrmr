# Draft.85c4b multivariate G-theory capability-isolation contract

Date: 2026-08-24  
Scope: one nonreserved fixture under a runtime-bound macOS sandbox  
Public status: unsupported

## Purpose and claim boundary

Draft.85c4b is the operating-system successor to the c4a namespace and payload
preflight. It demonstrates that one exact candidate envelope can reach the c4a
receipt worker while selected filesystem, environment, and process capabilities
remain unavailable to that worker process.

The claim is deliberately local. It applies only to the runtime identity hashed
in the evidence object: the observed Darwin release and machine, the exact
`sandbox-exec`, `env`, direct R executable, imported Apple `system.sb`, digest
installation, c4a worker, and c4b worker. It is not a portable Linux, container,
Docker, or future-macOS isolation certificate.

c4b does not alter the historical c3 admission manifest. Its live evidence is
an input for a later successor that may answer c3's isolation prerequisite. It
does not create an external freeze receipt, clean-source receipt, backend
qualification, accuracy rule, or lane authority.

## Default-deny profile

The generated profile starts with:

```text
(deny default)
(import "system.sb")
```

It then allowlists only the process and file capabilities required by the
fixture receipt path:

- execution of `/usr/bin/env`, the exact direct R binary, and the shell helpers
  required by R process handling;
- executable/runtime reads from the exact R framework and standard system
  binary locations;
- reads from the staged candidate input, staged c4a/c4b workers, receipt output,
  and scratch directories; and
- writes to only the receipt-output and scratch directories.

The repository validation directory, staged reference vault, and a separate
forbidden-output directory do not occur in an allow rule. The process is
started through `env -i` with only `R_HOME`, `TMPDIR`, `PATH`, `LANG`, `LC_ALL`,
and `TZ` supplied. A synthetic parent secret must therefore be absent.

The imported Apple profile is a private, version-dependent system interface;
its exact bytes are part of the runtime identity. It permits standard operating
system facilities, including local syslog and selected IPC. Consequently,
`ExternalNetworkPolicyClosed=TRUE` means that c4b adds no general external
network allowance and does not invoke `system-network`; it does not mean that
all local system IPC is absent.

## Six live controls

The live preflight runs exactly one c2 nonreserved fixture through six fresh
sandbox invocations:

| Mode | Required result |
| --- | --- |
| normal | candidate receipt succeeds |
| probe_vault_read | staged reference-vault read is denied |
| probe_source_read | repository source read is denied |
| probe_outside_write | write outside output/scratch is denied |
| probe_parent_environment | parent secret is absent |
| probe_unlisted_exec | `/bin/cat` execution is denied |

Each process must exit normally after writing a typed control result. The
normal action alone succeeds; every negative action must fail for the registered
denial class. A missing result, unexpected exit, successful negative action,
visible parent secret, created outside file, changed denial class, or altered
hash/readiness field fails closed.

The deterministic staging path must be initially absent. Readiness evidence is
valid only when the staging content is removed after the run. Retained staging
is diagnostic material and cannot pass the evidence assertion.

## Data and execution boundary

The controller generates only fixture ordinal 1 from the c2 nonreserved band.
The staged candidate input contains the c4a seven-column candidate data and no
truth-side field. Fixture, scenario, reference, seed, and truth information is
placed in a separate staged vault solely for the denied-read control. It is not
included in the worker result or final evidence payload. Its SHA-256 identity,
but not its content, is retained in the final evidence so a successor can bind
the exact object whose read was denied.

No c1 pilot, confirmation, or negative-control seed is opened. Neither the
capability worker nor the c4a receipt worker contains an estimator. No lme4,
glmmTMB, TMB optimization, or ConQuest process is invoked.

## Disposition

```text
DefaultDenyProfileReady          = TRUE
SanitizedEnvironmentReady        = TRUE
CandidateInputReadReady          = TRUE
CandidateReceiptWriteReady       = TRUE
ReferenceVaultReadDenied         = TRUE
SourceTreeReadDenied             = TRUE
OutsideWriteDenied               = TRUE
ParentEnvironmentSecretAbsent    = TRUE
UnlistedExecutableDenied         = TRUE
ExternalNetworkPolicyClosed      = TRUE
ProcessCapabilityIsolationReady  = TRUE
TruthBlindProcessBoundaryReady   = TRUE
BackendQualificationReady        = FALSE
PilotExecutionAuthorized         = FALSE
ConfirmationExecutionAuthorized  = FALSE
BackendExecutionOccurred         = FALSE
PlannedResponseGenerated         = FALSE
RecoveryExecuted                 = FALSE
RecoveryEvidenceReady            = FALSE
EstimationReady                   = FALSE
InferenceReady                    = FALSE
DecisionReady                     = FALSE
PublicSupportReady                = FALSE
```

These two promoted isolation states are scoped to the exact c4b fixture path
and runtime. They are necessary but not sufficient for any planned execution.
