# ConQuest 5.47.5 additive native-runtime probe record for 0.2.3

Status: runtime available outside the Codex filesystem sandbox, superseding the
preliminary crash NO-GO, 2026-08-11. This record retains the failed sandboxed
probes as execution-environment evidence; it no longer treats them as a
ConQuest product failure. The completed four-arm numerical review is recorded
separately in `conquest-additive-native-four-arm-record-0.2.3.md`.

## Bound identities

| Artifact | SHA-256 |
| --- | --- |
| `ConQuest_5_47_5.dmg` | `8526b086aa33ee4a7b30b3dc86399f1f287f2667ea86c0cf3016d673e4f6e329` |
| `/Applications/ConQuest/ConQuest` | `61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48` |
| corrected RSM q31 command | `4b702d767116f139c27aca209b5b137bfc279e7a2c4eefcb728b8062d841517c` |
| RSM q31 wide input | `391687fd8eb4e9a857950fcf232014833b0259a6ac7b483c7b1f898fdf03cf91` |

The host is arm64 macOS and the executable is a signed thin x86_64 Mach-O run
through Rosetta with `/usr/bin/arch -x86_64`. ConQuest identifies itself as
version 5.47.5 Demonstration Version and reports expiry on 1 September 2026.

## Correction of the preliminary diagnosis

Restricted launches originally produced macOS crash reports with
`EXC_BAD_ACCESS` in `RegistryCheck -> CRegistry::WriteInt -> XMLFile::Put ->
... -> fwrite` before a command was observed. Re-expanding the application did
not change its SHA-256, so the same result initially appeared to implicate the
runtime.

The user then demonstrated successful interactive execution from Terminal.
The same executable was consequently run outside the Codex filesystem sandbox:

1. a command containing only `quit;` printed the version, echoed the command,
   printed `End of Program`, and returned status 0;
2. RSM q31 and q61 completed 96 iterations and wrote every requested export;
3. PCM q31 and q61 completed 95 iterations and wrote every requested export;
4. all four authoritative arms retain console transcripts ending in
   `End of Program`; the initially untranscribed RSM q31 run is archived, and
   its transcript-completion repeat reproduced all six core numeric exports
   byte-for-byte.

The combined evidence shows that the earlier failure was specific to the
restricted launch context, most plausibly the blocked registry/settings write,
and was not evidence that `/Applications/ConQuest/ConQuest` was generally
unusable. The historical crash reports remain valid observations about
sandbox compatibility only.

## Command grammar correction

The first generated command encoded two implicit facets as
`facets=criterion(2),rater(2)`. ConQuest parsed the comma as the separator for
outer `datafile` options and rejected `rater(2)`. Manual page 340 documents
space-separated implicit variables in the corresponding `format` syntax. A
schema probe established that this build accepts
`facets=criterion(2) rater(2)`. The generator and its test now use that form;
quotes and the comma form are rejected.

## Current decision

The controlling runtime state is `runtime_available_unsandboxed`, not
`no_go_external_runtime_crash`:

- `ExecutionComplete = TRUE` for the four sealed arms;
- `NativeDesignMatrixObserved = TRUE`;
- `RawTokenAuditPossible = TRUE`;
- `ArithmeticEligible = TRUE` for descriptive review;
- `ComparisonReady = FALSE` because no acceptance threshold or release
  candidate is bound; and
- `ScientificEquivalenceInferred = FALSE`.

Future automated ConQuest work in this environment must run outside the
filesystem sandbox and must preserve its console transcript. A sandboxed crash
must not be generalized to the native runtime without an ordinary-Terminal or
equivalent unsandboxed control.
