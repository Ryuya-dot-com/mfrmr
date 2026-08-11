# GPCM MML slope-boundary instrumentation contract for mfrmr 0.2.3

Status: Draft.69 implemented mathematical instrumentation; calibration,
readiness propagation, finite-maximum claims, and confirmation prohibited

## Purpose

This contract adds an estimator-specific boundary-path audit for the aligned
single-owner GPCM under the implemented finite Gaussian--Hermite MML objective.
It replaces the absence of MML instrumentation; it does not reuse the
conditional JML audit and does not complete global marginal identification.

The audit is deliberately narrower than a profile-likelihood rule or a proof
that finite optimizer slopes are finite maximum-likelihood estimates. Its
immediate role is to detect a class of sufficient monotone boundary paths,
retain exact provenance, and supply a calibration target for later expanded
owner/estimator replication.

## Mathematical scope

For retained Person pattern \(p\), the numerical marginal likelihood used by
the package is

\[
L_p(t)=\sum_q w_{pq}\exp\{\ell_{pq}(t)\},
\]

where \(q\) indexes the declared finite quadrature nodes. Along an expanded
sum-zero log-slope ray \(\log\alpha_g(t)=\log\alpha_g+t r_g\),

\[
\frac{d}{dt}\log L_p(t)
=\sum_q \pi_{pq}(t)\frac{d}{dt}\ell_{pq}(t),
\]

with strictly nonnegative posterior node weights \(\pi_{pq}(t)\) at finite
coordinates. For an observation assigned to slope group \(g\), its
conditional contribution is

\[
r_g\alpha_g(t)\{u_{iyq}-E_t(u_{iKq})\},
\]

where \(u_{ikq}\) is the unscaled cumulative category utility. Consequently,
the following is a sufficient fixed-quadrature certificate:

- every positive-loading response is a utility maximizer at every retained
  node;
- every negative-loading response is a utility minimizer at every retained
  node; and
- at least one effective response has a nonzero utility span.

Under the package's geometric-mean-one identification, enumeration of every
ordered pair with loadings \(+1,-1\) is complete for this constant two-group
ray family. The positive slope tends to infinity and the negative slope tends
to zero. The boundary likelihood is reconstructed independently: a positive
group assigns equal probability over utility-maximizing categories, a negative
group tends to the uniform category distribution, unchanged groups retain
their fitted probabilities, and Person patterns are reintegrated with the
same quadrature basis.

## Implemented checks

`audit_mfrm_mml_gpcm_slope_boundary()` records:

- estimator, model, quadrature nodes, dimensions, execution limits, and
  retained-versus-optimizer likelihood reconstruction;
- nodewise maximum/minimum compatibility and strict-support counts for every
  slope level;
- every ordered two-level direction, boundary likelihood, improvement, and
  certification result;
- expanded and optimizer-coordinate direction loadings; and
- explicit flags that the result is a fixed-quadrature certificate, is not a
  continuous-integral certificate, and has no readiness effect.

Malformed retained coordinates, nonfinite utilities, likelihood mismatch,
invalid controls, no effective observations, and bounded execution-limit
exceedance all fail closed with typed audit states. The direct optimizer's
separate typed numeric-proposal rejection remains unchanged.

## Non-claims

A certified path establishes nondecrease only for the declared finite-node
MML objective while additive, step, interaction, and population coordinates
remain fixed. It does not establish:

- a corresponding path for the exact continuous-normal integral;
- completeness over paths where other coordinates move;
- a global finite or infinite maximum;
- structural identification or weak-information classification;
- valid standard errors, confidence intervals, recovery, or coverage;
- owner or estimator superiority; or
- fit, DFF, sample-size, release, or confirmation conclusions.

A negative result is also scoped: it means no path was certified in the
enumerated sufficient family, not that finite optimizer slopes are primary
estimates. Therefore free MML GPCM slopes retain `ParameterStatus =
"not_evaluated"`, optimizer values remain numerical traces, and fit readiness
remains review-only.

## Verification and next evidence

Unit controls must include a constructed certified boundary path, an explicit
fixed-quadrature likelihood-path oracle, row-order invariance, a normal
none-certified case, execution-limit failure, and proof that neither positive
nor negative audit results promote inference readiness.

The next calibration lane must run this audit on independently identified
owner-specific MML datasets at q=31/61/91, compare certificate stability across
nodes, and retain all failures. Direct q61-to-q91 parameter contrasts and
prospective tolerances belong to expanded replication. Readiness propagation
requires a separately versioned contract and evidence; this Draft.69
instrumentation alone cannot supply it.

## Source boundary

Muraki (1992, doi:10.1177/014662169201600206; ETS report
doi:10.1002/j.2333-8504.1992.tb01436.x) supplies the GPCM and its EM
estimation basis. Bock and Aitkin (1981, doi:10.1007/BF02293801) supplies the
marginal-likelihood/EM foundation in which ability is integrated out. Neither
source is cited as a theorem for the facet-owner or fixed-quadrature boundary
certificate above. That sufficient-path derivation is package-specific and is
therefore kept narrower than a general MML identification claim.
