# Draft.85c4n planned-adapter capability-isolation contract

Status: internal preflight contract  
Scope: exact Draft.85c4m non-attempt adapter and three opaque lane requests  
Public support: none

## Purpose

Draft.85c4n converts the c4m payload-separation claim into live macOS
process-capability evidence. It reruns the exact c4m adapter with the canonical
pilot, confirmation, and negative-control requests in separate fresh
default-deny processes. It then proves six attempted accesses unavailable.

This is deliberately not the full c3 truth-blind process boundary. The c4m
worker receives topology only, cannot receive candidate response data, and
cannot invoke a backend. Qualifying this surface therefore cannot qualify a
future fit-capable worker by implication.

## Required ancestry

The controller must reconstruct and validate:

- the canonical c1 plan and c2 generator manifest;
- the c3 admission manifest;
- the c4e environment and c4f four-route policy;
- the c4i ABI-repair receipt;
- the c4j full-object qualification receipt;
- the c4k full-object capability evidence;
- the c4l backend-qualification integration receipt; and
- the c4m planned-adapter manifest.

The c4m adapter source hash must equal the source hash recorded by c4m. The
three requests must be reconstructed from c1 handoff previews and the exact
c4l receipt and route-registry hashes. Retained request objects are not trusted
as roots.

## Runtime identity

Live execution is macOS-only and binds:

- OS, release, version, and machine;
- R version, R home, direct R executable, and executable hash;
- `/usr/bin/sandbox-exec`, `/usr/bin/env`, and `system.sb` hashes;
- `C.UTF-8` and UTC runtime settings;
- exact c4m and c4n worker source hashes;
- digest version, DESCRIPTION hash, and native-binary hashes; and
- required path-traversal literals.

The staged non-base library contains a verified physical copy of digest, not a
symlink. This avoids granting a package-directory symlink-resolution ability
whose macOS `realpath` behavior is wider and less stable than the adapter needs.
The copy's DESCRIPTION and every native binary are compared with the bound
origin before execution.

## Staging topology

The exact topology is:

```text
<root>/
  allowed/
    input/
    worker/
    runtime-library/
    output/
    scratch/
  denied/
    protected-vault/
    forbidden-output/
```

Only the allowed subtree is readable as data. Only output and scratch are
writable. Exact metadata traversal is granted for `/`, `/private`,
`/private/tmp`, the staging root, allowed root, and runtime-library root so R
can canonicalize its staged library. Neither denied child is named in the
profile.

The protected vault contains synthetic tokens and explicit false markers for
scenario identity, planned seed, reference identity, truth, accuracy
threshold, and candidate data. No real protected study material is staged.

## Process policy

The profile must:

- start with version 1, default deny, and `system.sb`;
- contain no allow-default or allow-network rule;
- allow execution only of the sanitized environment launcher, direct R
  executable, and the shell helpers already required by validated R startup;
- allow the R framework and system dynamic-library closure to load;
- allow read access to the allowed subtree only;
- allow writes only to output and scratch;
- omit the repository, denied root, protected vault, and forbidden-output
  paths; and
- pass all 21 static policy-audit rows.

The worker is launched through `env -i`. Only R home, the staged library,
scratch directory, path, locale, and timezone are supplied. A synthetic secret
present in the controller environment must be absent in every child.

## Normal controls

Three normal modes are mandatory:

1. `normal_pilot`;
2. `normal_confirmation`;
3. `normal_negative_control`.

Each mode runs in its own fresh process. Its adapter receipt must be identical,
not merely hash-compatible, to the canonical c4m receipt reconstructed by the
controller. Expected and observed denominators remain 960, 19,200, and 8.

The receipts remain non-attempt receipts. They do not contain responses, fits,
parameter estimates, backend output, or success claims about future study
execution.

## Negative controls

Six negative modes are mandatory:

1. protected-vault read;
2. repository-source read;
3. write outside the allowed subtree;
4. controller-environment secret discovery;
5. execution of an unlisted executable; and
6. external-network connection.

The first three and last two must be classified as sandbox operation denials.
The environment probe must report that the variable is absent. Every wrapper
process must itself exit successfully and write a typed result so denial is
distinguished from worker crash.

The worker's own readiness booleans are always false and are never trusted.
The controller derives the qualification only after validating the complete
result, action message class, canonical receipt, source hashes, and profile.

## Evidence object

The evidence binds full runtime, staged-runtime, policy-audit, control-result,
normal-receipt, prerequisite-projection, worker-identity, and implementation
objects plus their hashes. Rehashing a modified readiness flag is insufficient:
the assertion reconstructs the canonical ancestors and all derived registries.

The evidence may set both of the following true, with the scope constrained by
this contract:

- `PlannedAdapterProcessCapabilityIsolationReady`;
- `ProcessCapabilityIsolationReady`.

It must keep all of the following false:

- `TruthBlindProcessBoundaryReady`;
- `PlannedExecutionIsolationReady`;
- pilot, confirmation, and negative-control authorization;
- backend and candidate execution;
- candidate completion and truth release;
- denominator accounting for executed candidates;
- recovery, estimation, inference, decision, and public support.

## c3 projection

c4n starts from c4m's 2-of-8 state. It records narrow process evidence on the
truth-blind row but does not transition that row. A fit-capable worker will have
a materially wider capability surface because it must read blinded candidate
data and invoke a qualified backend. That exact surface requires its own
default-deny run.

Accordingly:

- exactly zero c3 prerequisites transition in c4n;
- the satisfied count remains 2 of 8; and
- partial execution remains prohibited.

## Dispatch

The dispatch guard recognizes candidate, lane, recovery, and public action
names only to reject them after full evidence validation. `authorize=TRUE`
cannot open any action. The callback must never run.

## Successor boundary

The next slice should define a sealed fit-capable candidate-data envelope and
worker contract. It must preserve the c1 denominator topology while separating
the data-generation authority from the candidate-fitting authority. A later
capability run must exercise that exact fit-capable worker before the c3
truth-blind prerequisite can transition.
