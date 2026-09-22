# D-SIM-0 v4 package-capability contract record

Status: specification complete; D-SIM-1/2 and D-SIM-3 coverage, execution contract, and qualification audit subsequently completed
Date: 2026-08-30
Contract: `MFRMR-GTHEORY-MV-DSIM0-CAPABILITY-V4`
Contract hash: `9b68d194e13625ec73992f314a9494e29c36f77838e0da19a15020f2af74a214`
Implementation identity hash: `76c20091fecd225149dd8fa9e11fc9a16dc52cfcacba15fee09bddaebc388416`

## Correction of responsibility scale

V1--v3 treated a named operational use, action consequence, and practical
owner as prerequisites for deciding whether `ABS-PHI` or `REL-G` could enter
the development study. That is the wrong responsibility scale for a general R
package. A package can compute and validate both coefficients without owning
the user's eventual decision. Users remain responsible for interpreting
relative versus absolute error, choosing any substantive target, and deciding
what action follows.

V4 therefore supersedes the **activation path** of the v3 owner-admission
contract. It does not rewrite or delete v1--v3. Their hashes, candidate packets,
blank responses, and tests remain historical evidence of an unexecuted design
proposal. None of those owner artifacts blocks package development, D-SIM-1,
or inclusion of either coefficient in the validation multiverse.

## Package responsibility

The active package-level responsibility is limited to:

- mathematical estimand and error-partition definitions;
- a machine-checkable design grammar and honest support boundary;
- deterministic, Monte Carlo, negative-control, and reference checks;
- convergence, boundary, nonidentification, and attempt-accounting behavior;
- evidence-bounded maturity and public-support claims.

Analysis-design declaration, coefficient interpretation, substantive targets,
and action consequences remain user responsibilities. Project preregistration
is optional protocol for a particular study, not a package admission gate.

## D-SIM-0 content

Both `ABS-PHI` and `REL-G` are mandatory, separate, nonvoting validation
estimands. The contract registers 14 axes and 44 levels spanning estimand,
stratum count, condition and observation-event sharing, crossing, balance,
missingness, sample and allocation size, variance and covariance regimes,
response distribution, and analysis route. Full anchors, targeted structural
cases, pairwise stress, boundaries, closure cases, and a deliberately invalid
pooling control have distinct coverage roles. Outcome-adaptive scenario
selection is prohibited.

Ten acceptance criteria cover deterministic algebra, one-stratum closure,
label invariance, PSD validity, coefficient recovery, interval coverage,
matched-route parity, structural negative controls, complete attempt
accounting, and resource reporting. No criterion requires an operational
consequence or allows post-outcome revision.

Feature maturity is now classified as:

`specified -> implemented -> simulation_validated -> reference_validated -> stable`

Only `specified` is current. Consequently:

- `Dsim0Satisfied = TRUE`;
- `Dsim1Allowed = TRUE`;
- exploratory and confirmation response generation remain false;
- planned seed access remains false; and
- public support and stable maturity remain false.

## D-SIM-1 completion update

The companion D-SIM-1 record now closes deterministic algebra, one-stratum
reduction, PSD, incidence, observation-event, and backend-eligibility oracles
over five canonical design anchors and seven criteria. D-SIM-2 may therefore
run one nonreserved generator-to-fit smoke. That smoke subsequently completed
one shared-rater/distinct-event fixture through lme4 REML, nonvoting G/Phi
metric plumbing, terminal-state accounting, and exact replay. It is not truth
recovery or simulation validation. D-SIM-3 subsequently froze 21 outcome-blind
design cells covering all 44 levels and 603 feasible dataset-axis pairs, with
zero generated datasets. Its separate execution contract subsequently froze
42 dataset attempts, 210 route units, 420 nonvoting coordinates, and the 855
seed band without opening any stream. Full-profile generator, adapter, receipt,
and resource-enforcement qualification subsequently completed as a no-go:
18/37 legacy generator primitives are reusable, but 0/21 complete profiles,
0/50 candidate routes, 0/13 terminal states, and 0/5 resource scopes have exact
D-SIM-3 bindings. One shared semantic execution substrate is next; multiverse
response generation, confirmatory freezing, and support promotion remain
closed. Its first typed design-compiler layer subsequently qualified 21/21
profiles across nine axes with no scenario-specific branch. The second shared
layer then bound the remaining three variance/covariance/distribution axes
through 84/84 PSD component factors and 21/21 response-kernel contracts, also
without scenario-specific patches. Complete stochastic generator semantics
then qualified for 21/21 profiles on nonreserved shadow fixtures, including
84/84 unit-to-effective covariance identities and nine randomized fixed-count
MCAR masks. Generic route/receipt and resource layers were next; reserved 855
execution remains closed. A fourth shared layer has since qualified 50/50
route admissions and all 13 terminal semantics, with 181 currently terminal
units at exactly one receipt and 92 open units at zero. The resource-controller
layer is next; reserved 855 execution remains closed.
