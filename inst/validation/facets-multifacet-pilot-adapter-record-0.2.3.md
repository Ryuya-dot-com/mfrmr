# FACETS multifacet pilot execution-adapter record for mfrmr 0.2.3

## Question

Can the completed fixed-information pilot machinery produce the semantic
manifest expected by the frozen confirmation reviewer without opening any
confirmation response, and without treating a machine-specific file identity
as scientific evidence?

## Implemented boundary

`facets-multifacet-pilot-adapter-0.2.3.R` accepts only the already-open base
seeds 451001, 452001, 452101, 452201, 452301, and 452401. Any other seed,
including every registered 460001--462901 confirmation seed, fails before
response generation. Dry-run preflight does not create the requested work
directory.

For an executed pilot case the adapter retains:

- the complete Element and Step coordinate identities and both estimates;
- FACETS return code, reported convergence criteria, final iteration, score
  residual, and logit change;
- mfrmr fit-returned state, optimizer convergence code, `Converged` state,
  terminal gradient sup norm, and gradient review tolerance; and
- FACETS executable path, size, modification time, report path, and report-
  header version as descriptive provenance.

Eligibility requires all numerical and coordinate gates. The FACETS version is
read from the report header and must be 4.5.0 for this pilot stratum. No SHA,
file-byte equality, serialization identity, exact floating-point equality,
confirmation claim, or FACETS-replacement claim is used.

## Verification

Focused tests covered dry-run non-creation, the explicit seed allowlist,
confirmation-seed rejection, semantic manifest conversion, 48 Element and
three RSM Step identities, report-version mismatch, finite coordinate
arithmetic, and absence of cryptographic identity operations. The companion
precision runner now retains full Element coordinates and requires mfrmr code
zero, `Converged=TRUE`, and a terminal gradient no larger than its recorded
review tolerance before a case can contribute comparisons.

## Local launcher diagnosis

Directly spawning the Windows GUI executable from R `system2()` or processx
returned status `0xC0000005` (access violation), including for FACETS' bundled
`Dives.txt` example. FACETS' documented native `START /WAIT`-style route,
implemented with PowerShell `Start-Process -Wait`, returned code zero for the
same bundled example and for the mfrmr control. The repository runner therefore
uses that native wait route on Windows and supplies case-local relative file
names. This is an execution-layer correction, not a model or tolerance change.

## Live pilot audit

On 2026-08-14 the adapter locally executed the already-open RSM and PCM
three-facet cases at base seed 451001 with `C:/Facets/Facets.exe`. Both report
headers identified version 4.5.0, both FACETS runs met their displayed stopping
criteria, both mfrmr fits returned code zero with terminal gradients below
`1e-4`, and both complete coordinate contracts passed.

| Model | FACETS iterations | FACETS final score residual | mfrmr terminal gradient | Element rows | Maximum Element difference | Step rows | Maximum Step difference |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| RSM | 30 | 0.0065 | 0.00002300044 | 48 | 0.0003081470 | 3 | 0.0001725604 |
| PCM | 34 | 0.0078 | 0.000008098199 | 48 | 0.0004236722 | 12 | 0.0002679638 |

These use pilot responses already examined in the earlier qualification and
therefore validate the adapter but are not independent confirmation evidence.
Confirmation responses remain unopened, and the confirmation execution adapter
remains unimplemented and unauthorized.

## Complete already-open sweep

The same local route then executed all six allowed base seeds across RSM/PCM
and three, four, and five total facets: 36 planned cases. All 36 FACETS
processes returned code zero, all 36 report headers identified version 4.5.0,
and all 36 echoed the requested convergence criteria. There were no recorded
warnings. The previously observed `MFX-PILOT-RSM-F5-B452401` case again stopped
at iteration 75 with final Element score residual 0.0825. It remained in the
36-case denominator as `convergence_failure`, did not launch mfrmr, and
contributed no coordinate rows.

The other 35 cases passed both numerical gates and both coordinate contracts.
The largest mfrmr terminal gradient was 0.00009925830 against the unchanged
0.0001 review tolerance (`MFX-PILOT-RSM-F3-B452201`). No criterion was adjusted
after observing this value.

| Model | Total facets | Planned | Eligible | Maximum mfrmr terminal gradient | Maximum Element difference | Maximum Step difference |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| RSM | 3 | 6 | 6 | 0.00009925830 | 0.0004385272 | 0.0003044221 |
| PCM | 3 | 6 | 6 | 0.00009615037 | 0.0004236722 | 0.0002679638 |
| RSM | 4 | 6 | 6 | 0.00006608758 | 0.0006329638 | 0.0003591656 |
| PCM | 4 | 6 | 6 | 0.00008721265 | 0.0006315225 | 0.0003632125 |
| RSM | 5 | 6 | 5 | 0.00009578918 | 0.0004843736 | 0.0003074616 |
| PCM | 5 | 6 | 6 | 0.00007656920 | 0.0002138938 | 0.0000770561 |

Across the 35 eligible cases, 1,771 Element and 267 Step coordinates were
retained. Every coordinate passed the independently frozen 0.005-logit rule.
The global Element maximum was 0.0006329638 in
`MFX-PILOT-RSM-F4-B452201`; the global Step maximum was 0.0003632125 in
`MFX-PILOT-PCM-F4-B452401`. Neither value changes the rule, opens confirmation,
or supports exact equality or FACETS replacement.
