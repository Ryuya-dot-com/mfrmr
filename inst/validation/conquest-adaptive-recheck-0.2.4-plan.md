# Current adaptive fitter against the retained ConQuest microcase

Bound before execution, 2026-09-14: rerun the four existing ConQuest 5.47.5
RSM/PCM × Q31/Q61 commands on their byte-identical 96-Person, two-Rater,
two-Criterion input with `~ X` population regression. Copy only input/command
files to a new temporary directory; historical outputs remain unchanged.
Check the executable hash, completion transcript and exported A matrix.

Runtime observation before fitting: the sandboxed launch could not load a
bundled SPSS library under macOS policy. The historical ordinary execution
route (`arch -x86_64`, outside the filesystem sandbox) completed a data-free
`quit;` probe and reported ConQuest 5.47.5 **Standard Version**. The executable
hash is unchanged; the current licensed edition supersedes the historical
demonstration-edition assumption. No signature, quarantine flag, licence or
system policy was modified. Native runs use this verified route and stdin
commands, with a 600-second per-arm limit.

Fit the same long data through current public mfrmr at Q31/Q61 with both fixed
and adaptive integration (eight fits), preserving the original constraints,
maxit=2000 and reltol=1e-12. Compare native constrained coordinates, population
coefficients/variance, deviance, EAP and posterior SD. Validate adaptive-fit
likelihood and moments with the independent continuous-integral reference.

This is a descriptive extension of an existing microcase, not a new ConQuest
equivalence lane. Retain raw output tokens. The uncertainty in native CSV
rounding and the `stderr=quick` convention are not resolved by small point
differences: do not infer a scientific pass threshold, SE equivalence, or
formal-inference readiness. The generic ConQuest export restriction on
adaptive fits is unchanged; the native commands describe ConQuest's own
calculation and are not exported from a relabelled adaptive fit.

Post-hoc scoring diagnostic (declared after observing EAP differences up to
0.00884, before executing the following settings): the official ConQuest manual
distinguishes estimation nodes from `p_nodes` for posterior approximation and
notes stochastic EAP output. For each model at estimation Q61, retain the
original fitting commands and produce all nine posterior runs from
`p_nodes = 2000, 20000, 200000` crossed with seeds `2, 73, 20260914`. Reset the
seed before each `show cases` call so latent draws are rebuilt. Keep every row;
do not select the seed with the smallest discrepancy. Confirm that native
calibration exports remain identical. Compare scores with continuous integration
at the exported native parameters, retaining the native rounding limitation.
This diagnoses Monte Carlo sensitivity, without changing the original four-arm
results or establishing posterior-SE equivalence.

Source: [ACER ConQuest command reference, `set` and `show`](https://conquestmanual.acer.org/s4-00.html),
accessed 2026-09-14; bundled manual pp. 411, 424 describes the same controls.
