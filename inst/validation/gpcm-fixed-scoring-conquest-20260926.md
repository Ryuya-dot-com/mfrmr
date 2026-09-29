# Fixed GPCM scoring: local ConQuest comparison

## Question and current conclusion

Can ConQuest represent, save and reload the same fixed GPCM response functions
and score new response patterns on the same scale? The local ConQuest 5.47.5
comparison verifies the fixed model for both shared and separate slope/step
owners. Stochastic EAP and posterior-SD differences remain and are reported
below. This is not free-estimation equivalence, a coverage study, or an
implemented portable mfrmr artifact.

Use the two retained fixed calibrations and eight target response patterns in
the [TAM comparison](gpcm-fixed-scoring-tam-20260926.md). Each fixture has four
new patterns: lower extreme, upper extreme, mixed categories and incomplete
known contexts. Calibration and population parameters are all fixed. The
[runner](gpcm-fixed-scoring-conquest-20260926.R) supplies generalized-item A
matrices, fixed category scores and category-intercept anchors. It transforms
the original population to mean zero and variance one, then transforms EAP and
posterior SD back to the original scale. There is no prior reestimation.

ConQuest drops some category parameters if the category is absent from the
supplied responses. One declared all-middle-category support row per fixture
preserves those parameters. This row is excluded from the target comparisons;
with every calibration and population parameter fixed, it cannot recalibrate
the model. This workaround belongs to the external fixture, not the proposed
mfrmr scoring API.

## Model identity before accepting scores

The serialized numerical inputs reproduce the retained TAM probabilities to
4.44e-16 (shared owners) and 3.33e-16 (separate owners). Native execution is then
checked separately: exported A, parameter indices and estimates, category
scores and population must reproduce the intended fixed model before scoring.
The installed version accepts a text design file with the parameter count on
the first line, followed by matrix rows. The working representation uses
negative category indicators and correspondingly negated coefficients.
Its mean anchor is `1 1 0`, as confirmed by the native export.

The model is saved with `put`, then reloaded with `get` in a new native process.
All fixed numerical parameters, category scores, population and A remain
unchanged. Human-readable parameter labels change on reload, so labels alone
are not a valid identity check; indices and the numerical design are checked.
Reconstructed probabilities from the printed native parameters differ from
full-precision TAM probabilities by at most 2.65e-7 (shared) and 2.12e-7
(separate). The largest deterministic EAP/SD effect of that print precision is
5.08e-7 and 2.00e-7, respectively.

The file layout is documented in the official
[imported-design example, Figure 2.74](https://conquestmanual.acer.org/graphics/2.10-ImportingDesignMatrices_Fig11.02.PNG).
The [command reference](https://conquestmanual.acer.org/s4-00.html) describes
`score`, `import`, `put`, `get`, `set p_nodes`, `set seed` and `show cases`.
Sources checked 2026-09-26; the installed-version exports resolve actual input
and indexing behavior rather than assuming that every manual example applies.

## Scoring results and limits

Posterior scoring uses stochastic `p_nodes`, separately from estimation
quadrature. Before execution, two budgets (20,000 and 200,000) and three seeds
(2, 73, 20260926) were selected for each fixture. All 12 settings and 48 target
rows are retained. The table gives maximum absolute differences from mfrmr
across the four target patterns and three seeds, on the original ability scale.

| Owners | Posterior budget | EAP difference | Posterior SD difference |
| --- | ---: | ---: | ---: |
| Shared | 20,000 | 0.006094192 | 0.002529552 |
| Shared | 200,000 | 0.002031886 | 0.001376215 |
| Separate | 20,000 | 0.007120928 | 0.003249104 |
| Separate | 200,000 | 0.002420771 | 0.001651768 |

These differences exceed the measured printed-parameter effect. Their
seed/budget dependence with an unchanged fixed model is consistent with
Monte Carlo approximation. Three seeds do not characterize its full error
distribution, and the smaller observed maxima do not guarantee monotonic
improvement. No favorable seed is selected and TAM's deterministic 1e-6
criterion is not applied to ConQuest's stochastic EAP. The result establishes
the fixed-model representation and records score agreement at the observed
precision; it does not establish deterministic score equality. Posterior SD
is conditional on the fixed calibration and prior, not a calibration-parameter
standard error or evidence of frequentist coverage.

## Runtime recovery and retained failures

The first ordinary local launch outside the filesystem sandbox failed before
reading any input with `Bad CPU type in executable`. The user subsequently
accepted Apple's license and reported successful Rosetta installation. Native
execution then succeeded using
`/usr/bin/arch -x86_64 /Applications/ConQuest/ConQuest`.
The executable SHA256 is
`61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48`;
the observed host is arm64 macOS 27.0 build 26A428.

Earlier input attempts are preserved separately. They include an incorrect
matrix format, a rejected mean-anchor index, category removal, a record-length
failure and a positive-indicator identification failure. One rejected matrix
import allowed ConQuest to continue with its default design: its scores are
excluded. This is why process completion alone is insufficient and native
model exports must be checked. None of those attempts supplies comparison
evidence or indicates an mfrmr estimation defect.

## Evidence and remaining work

Accepted outputs are under
`validation-results/gpcm-fixed-scoring-conquest-20260926-v6/`:

* `fixed-model-check.csv`: fixed-model and reload checks, printed precision.
* `score-comparison.csv`: every target pattern, seed and budget.
* `summary.csv`: maxima reported above.
* Each owner directory: actual command files, native console/error logs,
  exported model, `fixed.sys` and score files.
* `manifest.rds`: preparation inputs, executable hash and planned settings.
* `analysis-manifest.rds`: final analysis-script and retained-file hashes.

The final analyzer adds checks beyond the runner used for the accepted native
execution. A separate read-only reload exported A after persistence; its actual
`reload-design-check.cqc` and logs are retained. The final runner incorporates
that export and the additional pre-scoring category-score check. The original
manifest and executed command files are not rewritten to imply that the final
script was used unchanged throughout.

The initial runtime attempt and subsequent rejected interface attempts remain
in the sibling original, `-restored`, and `-v2` through `-v5` directories.
No full package suite or TAM repeat was needed for runtime recovery. The next
implementation task is the existing calibration lifecycle's GPCM schema and
scoring extension, preserving RSM/PCM compatibility. That artifact still needs
its own fresh-session and external comparisons; this fixture does not complete
the future public workflow or release gate.
