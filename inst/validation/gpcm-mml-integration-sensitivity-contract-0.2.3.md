# GPCM MML integration-sensitivity contract for mfrmr 0.2.3

Status: Draft.68 calibration protocol; confirmation and threshold use prohibited

## Purpose

This lane measures whether the implemented fixed-standard-normal MML results
for the aligned single-owner GPCM materially depend on the Gaussian--Hermite
quadrature grid. It is separate from the Draft.66 owner-pilot identity. The
q=31 owner results are not silently pooled with denser-node results, and a
denser grid cannot retroactively turn the owner pilot into confirmation.

This is an integration-numerics comparison, not evidence that MML is generally
preferable to JML. JML estimates Person parameters conditionally and has a
different incidental-parameter/boundary problem; MML integrates Person effects
under the declared population distribution. Their likelihoods and Person
estimands are not interchangeable.

## Frozen calibration panel

The pilot panel contains 40 exact datasets:

- slope/step owner: Criterion and Rater;
- design: core, weak bridge, range restriction, and zero common Persons;
- five Draft.66 pilot seeds per owner/design cell; and
- the existing four-category, six-rater, six-criterion, 120-Person generator.

Every dataset is fitted at q=31, q=61, and q=91, yielding 120 fit rows. The
optimizer ceiling is `maxit = 400`; MML engine is direct and optimizer dispatch
remains `auto`. Starting values, retained data, likelihood, slope/step owner,
geometric-mean-one slope identification, and fixed standard-normal population
scale are identical across the three fits.

The q values were chosen before execution. There is no adaptive node addition,
fit-specific retry, or selection of the grid that gives the preferred result.
q=31 is the package's standard comparison starting grid; q=61 and q=91 are
dense sensitivity grids. None is declared an exact integral.

Zero-common-Person MML rows remain prespecified guarded negative controls.
Numerical integration can return a fitted object because the common latent
population links panels, but that population-assumption linkage cannot become
owner evidence or inference readiness merely because q sensitivity is small.

## Estimands and common-grid evaluation

For each q-specific fit, retain:

- fit/convergence/readiness state and all warnings/errors;
- own-grid negative log likelihood and optimizer counts;
- optimizer slope recovery against the generator truth;
- identified owner-slope, non-Person facet, owner-step, Person EAP, and Person
  posterior-SD estimates; and
- the candidate parameter vector evaluated on one common q=91 grid.

Within each exact dataset, q=61 and q=91 are compared with q=31 by:

- maximum absolute identified log-slope difference;
- maximum absolute non-Person facet and step difference;
- Person EAP RMSE and maximum absolute difference;
- Person posterior-SD RMSE and maximum absolute difference; and
- q=91 common-grid negative-log-likelihood regret relative to the best of the
  three fitted candidates.

The common-grid comparison holds the candidate parameters fixed and changes
only numerical integration. It avoids ranking own-grid objectives that were
computed under different approximations. It still does not prove that q=91 is
exact or that the optimizer found the global maximum.

## Execution and identity

- The loaded package content hash, this contract hash, runner hash, owner-runner
  hash, model-identity contract hash, complete manifest hash, maxit, q vector,
  and source Draft.66 execution are one global execution identity.
- Deterministic sharding acts on the 40 dataset rows, never on individual q
  arms, so every checkpoint contains the full three-grid comparison.
- Each atomic dataset checkpoint contains its exact manifest row, three result
  rows, and payload hashes. Resume validates every checkpoint already present,
  including checkpoints assigned to another shard.
- Aggregate publication requires one valid checkpoint for every dataset in
  declared order and a completion marker with a relative-path/SHA-256
  inventory.
- All 40 planned datasets and all 120 fit arms remain in denominators. Failed
  fits and unavailable numeric comparisons are reported, not dropped.

## Decision limits

This calibration run may identify node sensitivity and plan further numerical
work. It may not:

- freeze an integration tolerance from five replicates;
- choose a q grid per outcome or per dataset;
- promote zero-shared-Person evidence;
- compare MML and JML as though they shared one likelihood/Person estimand;
- establish sample-size sufficiency, fit/DFF accuracy, or a finite GPCM slope
  maximum; or
- authorize confirmation or a 0.2.3 release gate.

Any future numeric tolerance must be proposed from this pilot with its finite
denominator and Monte Carlo uncertainty, registered before new confirmation
seeds are inspected, and evaluated on an independently identified run.
