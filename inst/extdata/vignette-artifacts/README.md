These CSV files are lightweight vignette artifacts generated from the public
`mfrmr-workflow` route. During CRAN-style vignette builds, heavy fitting and
simulation chunks stay unevaluated, and the vignette reads these small tables
to show representative output. Maintainers can regenerate the files with:

```r
source(system.file("validation", "generate-vignette-artifacts.R", package = "mfrmr"))
mfrmr_generate_vignette_artifacts(".")
```

For a source checkout, source `inst/validation/generate-vignette-artifacts.R`
from the package root.
