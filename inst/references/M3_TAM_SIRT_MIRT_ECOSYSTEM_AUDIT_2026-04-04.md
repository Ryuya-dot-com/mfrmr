# M3 Ecosystem Audit: TAM / sirt / mirt

Date: 2026-04-04  
Package baseline: `mfrmr` 0.1.5

## 1. Purpose

This note fixes the strategic meaning of the user's new requirement:

> "`mfrmr` should cover what TAM, sirt, and mirt implement, while also
> strengthening the parts that are genuinely `mfrmr`'s own strengths."

Taken literally, "cover all of TAM / sirt / mirt" would pull the project off
axis, because those packages span much more than the current many-facet Rasch
mission. This audit therefore defines the relevant comparator envelope and the
correct product reading.

## 2. Source base

Primary official package documentation used in this audit:

- TAM `tam.mml`: <https://search.r-project.org/CRAN/refmans/TAM/html/tam.mml.html>
- TAM `tam.latreg`: <https://search.r-project.org/CRAN/refmans/TAM/html/tam.latreg.html>
- TAM `tam.pv`: <https://search.r-project.org/CRAN/refmans/TAM/html/tam.pv.html>
- mirt `mirt`: <https://search.r-project.org/CRAN/refmans/mirt/html/mirt.html>
- mirt `mixedmirt`: <https://search.r-project.org/CRAN/refmans/mirt/html/mixedmirt.html>
- mirt `fscores`: <https://search.r-project.org/CRAN/refmans/mirt/html/fscores.html>
- sirt `rm.facets`: <https://rdrr.io/cran/sirt/man/rm.facets.html>

## 3. What the current comparator packages actually cover

### 3.1 TAM

From the official `tam.mml` documentation, TAM already covers:

- `MML` and `JML`;
- uni- and multidimensional IRT;
- Rasch, 2PL, generalized partial credit, rating scale, multi-facets, and
  nominal response models;
- fit statistics and standard errors;
- plausible values and weighted likelihood estimation.

The same documentation also shows that `tam.mml.mfr()` accepts latent
regression inputs through `formulaY` / `dataY`, including a worked
multi-facet latent-regression example.

The `tam.latreg` and `tam.pv` pages confirm that TAM also has:

- a dedicated latent-regression layer,
- plausible values tied to that population model,
- and optional handling of regression-parameter uncertainty.

Strategic reading:
TAM is the strongest open-source comparator for the combined space of
many-facet modeling, latent regression, generalized item families, and
plausible-values workflows.

### 3.2 mirt

The official `mirt` documentation shows a very broad model family:

- dichotomous and polytomous models under EM, stochastic EM, or MHRM;
- multidimensional modeling as the default framing;
- latent regression through the `formula` interface;
- nominal response and generalized partial credit models;
- rating-scale and generalized rating-scale forms;
- multiple-group analysis.

The `mixedmirt` page extends that further to:

- fixed and random person-level predictors,
- item-level predictors,
- explanatory IRT,
- and mixed / multilevel IRT.

The `fscores` page shows that mirt also provides:

- MAP, EAP, ML, WLE, and plausible values;
- multiple-imputation style score draws;
- scoring that conditions on latent-regression predictors when present.

Strategic reading:
mirt is the strongest open-source comparator for generalized item families,
multidimensionality, explanatory predictors, and posterior scoring.
It is not many-facet-first, but it is very broad in model-family coverage.

### 3.3 sirt

The most relevant official sirt page for the present roadmap is `rm.facets`.
It documents:

- a unidimensional rater-facets model;
- `MML` estimation by EM;
- optional item slopes and rater slopes;
- optional rater-item interactions;
- factor scores, posterior output, likelihood extraction, and model-fit tools.

Strategic reading:
sirt is narrower than TAM or mirt in general model-family breadth, but it is a
real comparator for targeted rater-facets extensions, especially slope and
interaction variants that go beyond the plain many-facet Rasch core.

## 4. What "cover TAM / sirt / mirt" must mean for `mfrmr`

It should **not** mean:

- reproducing every auxiliary utility in those packages;
- reproducing every estimation engine they use;
- or turning `mfrmr` into a generic all-of-IRT package.

For this project, the only defensible meaning is:

> Cover the subset of TAM / sirt / mirt that materially belongs to a
> many-facet-first, non-Bayesian, native-R measurement workflow.

That relevant envelope consists of:

1. ordered many-facet Rasch estimation and scoring;
2. population models and latent regression;
3. plausible values / multiple-imputation style scoring;
4. generalized ordered models such as `GPCM`;
5. unordered nominal response models;
6. multidimensional extensions;
7. constrained or explanatory design layers;
8. selected rater-slope / interaction extensions;
9. operational workflow tooling around diagnostics, planning, QC, linking,
   and reporting.

## 5. Current ecosystem position of `mfrmr`

### 5.1 Areas where `mfrmr` is already credible

- Long-format many-facet API with arbitrary facet vectors.
- Ordered `RSM` / `PCM` many-facet estimation in native R.
- First-version latent regression for the current ordered-response scope.
- Design simulation, planning, and signal-screening workflow.
- FACETS / ConQuest-oriented reporting, crosswalk, and audit infrastructure.
- QC, anchor/linking, dashboard, and report-building layers.

### 5.2 Areas where `mfrmr` is still behind the open-source ecosystem

- `GPCM`;
- nominal response modeling;
- multidimensional estimation;
- design-matrix / explanatory generalization on the item side;
- richer plausible-values workflows with parameter uncertainty and
  multiple-imputation framing;
- rater-slope and rater-item interaction extensions comparable to the
  documented `sirt::rm.facets()` space.

### 5.3 The main strategic threat

If `mfrmr` is positioned only as "open ConQuest/FACETS in R", TAM and mirt
already weaken that claim because they cover much of the estimation territory
in official CRAN packages.

Therefore `mfrmr` should be positioned instead as:

- many-facet-first,
- long-data-native,
- workflow-complete,
- explicit about overlap boundaries,
- and stronger than the comparator packages in operational measurement
  workflow, not only in estimation.

## 6. Distinctive strengths `mfrmr` should deliberately amplify

The package has a real chance to be strongest in the following combined space:

### 6.1 Many-facet workflow coherence

- one long-data API across fit, diagnosis, bias, planning, reporting, and
  export;
- shared object contracts;
- explicit facet-role metadata.

### 6.2 Operational QC and reporting

- dashboards;
- report bundles;
- FACETS-aligned tables and visual summaries;
- anchor drift and linking support;
- design-screening workflow.

### 6.3 External auditability

- conservative ConQuest overlap bundle / normalize / audit path;
- reproducibility bundles and replay scripts;
- clear written claim boundaries.

### 6.4 Planning and deployment support

- simulation specifications;
- design evaluation;
- signal-detection screening;
- public naming and descriptor layers for practical multi-facet planning.

These are not just "extra helpers". They are the product thesis that keeps
`mfrmr` from collapsing into a weaker clone of TAM or mirt.

## 7. Priority implications for the roadmap

Given the ecosystem evidence, the correct post-M2 order is:

1. `GPCM`;
2. stronger plausible-values workflow under latent regression;
3. nominal response model;
4. between-item multidimensional extension;
5. explanatory / design-matrix generalization;
6. selected sirt-style rater-slope and interaction extensions;
7. parallel strengthening of `mfrmr`'s operational workflow advantages.

This order is justified because:

- `GPCM` is the nearest extension from the current ordered `PCM` core;
- plausible-values strengthening is already expected by the TAM / mirt
  comparator set;
- nominal and multidimensional work are ecosystem necessities but require
  clearer interface separation;
- explanatory design and rater-slope generalization should follow only after
  the model-family layer is stable.

## 8. Immediate conclusion

There is no blocking question that must stop work.

The correct working assumption is:

> "`mfrmr` should cover the relevant TAM / sirt / mirt feature envelope for a
> many-facet-first package, not literally every function those packages ship."

That assumption keeps the roadmap ambitious without making it incoherent.
