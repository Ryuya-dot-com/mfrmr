# Draft.83a G-theory observed-design incidence audit record

Status: completed repository-only structural audit prototype, 2026-08-09.

## Decision

Draft.83a passes its narrow observed-design audit gate. The prototype now
canonicalizes retained and omitted rows, applies conditional identities to
nested child levels, measures global and pairwise incidence connectivity,
records workload and full-cell replication, and computes component-specific
fixed-effect-equivalent rank increments.

The gate deliberately does not fit a variance-component model. Its strongest
positive state is `IncidenceScreenPassed`, while estimation remains
`not_adjudicated_draft83a` and coefficient and decision readiness remain
false. This prevents a connected graph or a finite rank calculation from being
used as a substitute for covariance-parameter identifiability, recovery, an
allocation operator, or missingness justification.

## Environment and execution

- R 4.6.1
- reformulas 0.4.4
- digest 0.6.39
- Draft.81 design contract `gtheory_design_algebra_draft81_v1`
- Draft.83a incidence contract
  `gtheory_design_incidence_audit_draft83a_v1`

The dedicated command was:

```sh
Rscript -e 'testthat::test_file("tests/testthat/test-gtheory-design-incidence-audit.R", reporter="summary")'
```

Result: seven tests and 69 expectations passed without failure, warning, skip,
or error.

## Complete crossed control

The 4-Person x 3-Rater x 2-Item control has 24 rows and one observation in
every full cell. All three bipartite projections have density 1 and one
connected component. Factor workloads are exactly 6, 8, and 12 rows per
Person, Rater, and Item level, with zero within-factor load CV.

The six modeled crossed components have their full sum-contrast rank
increments. The fixed-equivalent model rank is 18, leaving six residual
degrees of freedom. The audit passes its incidence screen but remains
coefficient- and decision-ineligible.

Audit hash:
`01c1b91aea3ea220d1d016e2b35dd9d0ccc675809e356acc19fb29c4e902c0ce`.

## Sparse connected and disconnected controls

The connected p x i cycle observes 8 of 16 edges, for density .5. Every Person
and Item has degree 2, the graph has one component, and the additive
fixed-equivalent model leaves one residual degree of freedom. This passes the
narrow incidence screen. It does not establish stable variance estimation or
define a D-study for the observed sparse allocation.

Audit hash:
`1fd28f19353c4449fffe91fff477553d01b93b8979053b66dffe72bb4bd52c24`.

The matched disconnected control contains two Person-Item islands. It reports
two bipartite components and partial rank increments for both Person and Item,
with explicit issues:

```text
non_nested_object_facet_disconnected:Item
fixed_equivalent_rank_deficiency:Person,Item
```

It is not incidence-screen eligible. Audit hash:
`8a360d1db455df8706ae4dcf20d6d98b92e7f1e20772aacb498ec7e7b80f8d30`.

## Nested conditional-identity control

The Site/Rater control uses two raw Rater labels in each of two Sites. The
audit retains two raw labels but four conditional Site:Rater levels and marks
both raw labels as shared across parents. The effective Site-Rater graph has
two components, as a nested design should, while Person links to all four
conditional Rater levels.

The fixed-equivalent ranks are:

| Component | Expected increment | Block rank | Increment | State |
| --- | ---: | ---: | ---: | --- |
| Person | 2 | 2 | 2 | full increment |
| Site | 1 | 1 | 0 | nested hierarchy absorbed |
| Site:Rater | 2 | 3 | 2 | full conditional increment |

The zero increment for the Site dummy after retaining Site:Rater dummies is
not called random-variance nonidentifiability. Nested structural potential
cells and coverage remain unresolved until Draft.83b supplies an allocation
contract. The incidence screen passes, but the Draft.81 nested D-study remains
unsupported and decision readiness remains false.

Audit hash:
`84b8d73878abf0bc34fc09eded8591c2cdcdeef52759deba9b961063d01ce254`.

## Replication and missingness controls

The replicated 3-Person x 3-Item saturated control has two observations in
all nine cells. Its Person, Item, and Person:Item contrast increments are
2, 2, and 4, and nine residual degrees of freedom remain. The audit detects
full within-cell replication. It also detects a metadata mismatch when the
same rows are paired with a `cell_replication=FALSE` specification.

Replicated saturated audit hash:
`2151a6f71cf8e4ad6e08ba85a2a0d0ffef20146247fbd534ec6a939b41fa1a3e`.

The missing-row control separately counts a missing score and a missing facet
identity. Declaring the data complete produces a typed conflict; declaring
covariate-dependent MAR records that declaration without claiming it is true.
Reversing every input row preserves canonical-input, retained-data,
omission-pattern, and full-audit hashes.

A separate control retains four declared Person factor levels although only
two have usable rows: one appears only on an omitted-score row and one is an
unused factor level. Both are counted as zero-retained and produce
`declared_levels_without_retained_rows:Person`; refactoring cannot silently
erase them.

## Metacognitive boundary and remaining work

This result closes a structural pre-fit gap, not the whole Draft.83 gate. The
audit can disprove some overly broad claims but cannot prove the intended
variance components are stably identified. In particular:

- graph connectivity is necessary but not sufficient;
- fixed-effect-equivalent rank is not covariance-parameter information rank;
- observed workload is not a future allocation operator;
- nested observed combinations do not define structural population cells;
- a declared MAR mechanism is not verified MAR; and
- replication permits separation in principle but does not ensure recovery or
  acceptable interval coverage.

Draft.83b therefore comes next: component-specific balanced-count and
allocation-operator transformations, including conditional nested allocation
and unequal object-specific loads. Draft.83c then binds these identities to
unbalanced lme4/glmmTMB fits and covariance/information diagnostics. Draft.83d
must challenge all positive states with recovery and deliberately broken
designs before any checklist promotion beyond review.
