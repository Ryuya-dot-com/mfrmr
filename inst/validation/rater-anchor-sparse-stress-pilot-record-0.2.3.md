# Rater-anchor proportion by sparse-link stress record for 0.2.3

Status: **completed three-seed calibration; no anchor rate selected**

Run date: 2026-08-13

Specification: `0.2.3-draft.1`

Contract: `mfrmr_rater_anchor_sparse_stress_pilot_v1`

## Question and scope

This repository-only pilot asks whether a useful direct-Rater-anchor
percentage can be inferred independently of sparse rating design. It uses the
direct FACETS-adjacent model lane only:

- PCM response model;
- unpenalized mfrmr JML;
- 80 Persons, eight Raters, four Criteria, and four ordered categories;
- three deterministic generating seeds;
- seven direct-anchor configurations; and
- seven complete or sparse assignment designs.

There were 147 declared PCM/JML fits. The same complete generated truth and
responses were reused within each seed. Sparse designs were deterministic
subsets of those responses, and every anchor configuration within a design
used the identical retained data. No FACETS executable was run, no GPCM slope
was fitted, and three seeds cannot estimate an operational failure rate.

Two percentages must not be conflated:

1. **direct Rater-anchor rate**: the fraction of Rater severity parameters
   fixed to externally supplied logits; and
2. **common-link Person rate**: the fraction of Persons rated by every Rater
   in an otherwise incomplete assignment.

## Fixed stress factors

Direct Rater anchors used 0%, 12.5%, 25%, 50%, or 75% of eight Raters. Exact
anchors were fixed at generating values. The 25% condition also included:

- two central-severity rather than range-spanning Raters; and
- two range-spanning Raters whose supplied logits were each shifted upward by
  0.25.

Sparse assignments included:

| Design | Raters per ordinary Person | All-Rater link Persons | Density | Minimum direct pair overlap |
|---|---:|---:|---:|---:|
| complete | 8 | 80 | 1.000 | 80 |
| single-Rater, no link | 1 | 0 | 0.125 | 0 |
| single-Rater, weak link | 1 | 2 | 0.147 | 2 |
| single-Rater, representative link | 1 | 10 | 0.234 | 10 |
| single-Rater, central link | 1 | 10 | 0.234 | 10 |
| two-Rater cycle | 2 | 0 universal | 0.250 | 0; graph still connected |
| two-Rater cycle plus link | 2 | 10 | 0.344 | 10 |

The two-Rater cycle has 20 Rater pairs with no direct common Person, but its
eight adjacent-pair connections form one network. This distinguishes minimum
pairwise overlap from graph connectivity.

## Execution accounting

All anchor tables passed the anchor-table observation/category review. That
review alone did not certify structural identification or inference readiness.

| Design | Planned | Fit returned | Inference ready | Principal retained state |
|---|---:|---:|---:|---|
| complete | 21 | 21 | 14 | seven terminal-gradient reviews |
| single-Rater, no link | 21 | 0 | 0 | structural rank failure before optimization |
| single-Rater, link 2 | 21 | 21 | 0 | extreme-Person exclusions |
| single-Rater, link 10 representative | 21 | 21 | 0 | extreme-Person exclusions |
| single-Rater, link 10 central | 21 | 21 | 0 | extreme-Person exclusions |
| two-Rater cycle | 21 | 21 | 14 | one seed had extreme-Person exclusions |
| two-Rater cycle plus link 10 | 21 | 21 | 13 | extremes plus one terminal-gradient review |

With one Rater per ordinary Person and no common link, every fit was
structurally unidentified. Increasing exact direct anchors reduced the
free-coordinate nullity from seven at 0% to one at 75%, but did not remove it.
Direct anchors therefore did not substitute for an observed connection to the
remaining free Raters.

With two or ten all-Rater linking Persons, the single-Rater designs returned
fits, but every returned row remained non-ready because four ratings per
ordinary Person produced low or high extreme response profiles in these
seeds. Moving to two Raters per Person restored 14/21 ready fits even without
a universal linking set. Adding ten universal link Persons did not improve
that small-sample ready count.

## Anchor-rate recovery traces

The primary Rater metric excludes the fixed Raters. This avoids giving a high
anchor percentage automatic credit merely because most values were supplied
as truth. Selected three-seed means are:

| Design | Anchor condition | Ready | Free-Rater absolute RMSE | Person absolute RMSE |
|---|---|---:|---:|---:|
| complete | none | 2/3 | 0.207 | 0.341 |
| complete | exact 25%, range-spanning | 3/3 | 0.182 | 0.333 |
| complete | exact 50%, range-spanning | 2/3 | 0.198 | 0.316 |
| complete | exact 75%, range-spanning | 1/3 | 0.137 | 0.302 |
| two-Rater cycle | none | 2/3 | 0.302 | 0.586 |
| two-Rater cycle | exact 25%, range-spanning | 2/3 | 0.276 | 0.588 |
| two-Rater cycle | exact 50%, range-spanning | 2/3 | 0.278 | 0.577 |
| two-Rater cycle | exact 75%, range-spanning | 2/3 | 0.154 | 0.532 |
| two-Rater cycle + link 10 | none | 2/3 | 0.287 | 0.536 |
| two-Rater cycle + link 10 | exact 25%, range-spanning | 1/3 | 0.272 | 0.534 |

The 75% condition often has the smallest recovery error because only two
Raters remain to be estimated; it does not demonstrate that 75% is an
efficient or defensible operational policy. Its complete-design ready count
was lower, and it supplies most of the target rather than estimating it.

One central exact anchor at 12.5% increased the mean free-Rater RMSE relative
to no anchors in every design where fits returned. At 25%, central-severity
anchors were generally worse for free-Rater recovery and rank than
range-spanning anchors. Thus anchor composition mattered separately from
anchor percentage.

The 0.25-logit misspecified 25% anchors produced worse Person RMSE than the
corresponding exact 25% anchors in every fitted design. For example, complete
Person RMSE rose from 0.333 to 0.375, and the two-Rater-cycle-plus-link design
rose from 0.534 to 0.560. More anchors are beneficial only to the extent that
their transported values are trustworthy.

## Interpretation against external evidence

FACETS can export estimated elements as anchors and reuse edited subsets in a
later frame of reference; that mechanism does not prescribe a universal
percentage ([FACETS Anchorfile help](https://www.winsteps.com/facetman64/anchorfile.htm)).

DeMars, Shapovalov, and Hathcoat report that when most examinees receive a
single rating, having all Raters score a common linking set gave the smallest
standard errors among the sparse alternatives they studied. Their results
also favor repeated ratings more generally over the single-rating sparse
case ([2023 NCME paper record](https://commons.lib.jmu.edu/gradpsych/63/)).

Earlier sparse-network work likewise did not identify one universal minimum
link size, while finding Rater severity more sensitive than Person and task
estimates to reduced links
([Wind and Jones, 2018](https://pmc.ncbi.nlm.nih.gov/articles/PMC6096472/)).
Myford's operational study used six common
benchmark performances and found all studied benchmark subsets sufficient for
minimal connectivity, with stability depending on benchmark characteristics
([ETS RR-00-09](https://www.ets.org/research/policy_research_reports/publications/report/2000/hsdy.html)).

The retained pilot is consistent with these sources in treating connectivity,
ratings per Person, link composition, and anchor accuracy as primary design
variables rather than deriving a percentage-only rule.

## Decision

This pilot supports the following bounded planning conclusion:

- do not attempt to repair a disconnected single-Rater-per-Person design by
  raising the direct-anchor percentage;
- establish a connected assignment first, preferably with repeated ratings or
  an all-Rater common set when most Persons receive one rating;
- carry **25% exact range-spanning Rater anchors** forward as the primary
  feasibility candidate, with 12.5% and 50% sensitivity arms;
- retain 0% as the within-seed reference and a shifted-anchor arm as a required
  negative control; and
- do not carry 75% forward as a default, because its apparent recovery gain is
  mechanically coupled to leaving only two free Raters.

The 25% value is a candidate for a prospectively replicated comparison, not a
recommended operational percentage. The next study needs more Raters, more
seeds, separately generated external anchor error, and explicit cost per
anchor and repeated rating.

That next design is now prospectively frozen in
`rater-anchor-sparse-prospective-contract-record-0.2.3.md`. It expands to 16
Raters and 10 feasibility seeds, separates external calibration error from
response-data seeds, and reports direct anchors and repeated ratings as
different resource axes. The contract runs no fit and does not strengthen the
present conclusion.

## Post-run maintenance note

The repository-only runner now retains warnings raised before an anchor-review
error is returned. Every anchor review in the retained 147-fit calibration
passed, so this fail-closed maintenance path does not revise any retained
estimate, readiness decision, evidence identity, or authority state. The runner
and focused tests in version control bind the maintained implementation.

## Reproduction policy

Hashes emitted by the repository-only runner are within-run pairing and
provenance fingerprints. They are not a cross-machine scientific acceptance
criterion. Reproduction is evaluated from the registered design, explicit
failure denominators, numerical tolerances, recovery metrics, and the retained
decision and authority states. The original calibration run accumulated 130.51
seconds of fit time; timing is descriptive only.

## Authority state

`CalibrationOnly = TRUE`

`AppropriateAnchorRateSelected = FALSE`

`BroadSimulationAuthorized = FALSE`

`ConfirmationAuthorized = FALSE`

The result changes no public default, readiness rule, anchor-review threshold,
FACETS comparison claim, PCM/GPCM selection rule, or release gate.
