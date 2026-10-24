# Literal TAM 4.3-25 output, with explicit full category support and bias=FALSE.
# See inst/validation/tam-jml-facets-0.2.4.md for execution and conditioning.
test_that("ordinary JML preserves declared support in matched sparse TAM cases", {
  response <- read.csv(test_path("fixtures", "tam-jml-0.2.4-response.csv"))
  person <- read.csv(test_path("fixtures", "tam-jml-0.2.4-person.csv"))
  for (case in unique(response$Case)) {
    z <- response[response$Case == case, ]; ref <- person[person$Case == case, ]
    model <- sub("_.*", "", case)
    anchors <- if (grepl("partial", case)) {
      data.frame(Facet="Person", Level="P03", Anchor=-.4)
    } else NULL
    fit <- fit_mfrm(z, "Person", c("Rater", "Task"), "Score",
      model=model, method="JML", step_facet=if (model=="PCM") "Task" else NULL,
      rating_min=0, rating_max=3, anchors=anchors,
      optimizer="BFGS", maxit=500, reltol=1e-11)
    dx <- diagnose_mfrm(fit, residual_pca="none", diagnostic_mode="legacy")
    oi <- match(paste(z$Person,z$Rater,z$Task),
                paste(dx$obs$Person,dx$obs$Rater,dx$obs$Task))
    expect_false(anyNA(oi))
    # TAM's independently stopped iterations and mfrmr's optimizer leave
    # small score residuals. This bound detects the >= .26 support mismatch.
    expect_lt(max(abs(dx$obs$Expected[oi]-z$Expected)), 5e-5)
    expect_lt(max(abs(dx$obs$Var[oi]-z$Variance)), 3e-5)
    p <- fit$facets$person
    expect_lt(max(abs(p$Estimate[match(ref$Person,p$Person)]-ref$Measure)), 5e-5)
    m <- dx$measures[dx$measures$Facet=="Person", ]
    mi <- match(ref$Person,m$Level)
    free <- if (is.null(anchors)) rep(TRUE,nrow(ref)) else ref$Person != "P03"
    expect_lt(max(abs(m$ModelSE[mi][free]-ref$ConditionalSE[free])), 2e-5)
    # Conditional diagnostic information is not a validated joint-inference SE.
    expect_true(all(is.na(p$SE)))
    if (!is.null(anchors)) expect_equal(p$Estimate[p$Person=="P03"], -.4)
  }
})

test_that("untrimmed unit-weight TAM fit uses the same fourth-moment transform", {
  response <- read.csv(test_path("fixtures", "tam-jml-0.2.4-response.csv"))
  person <- read.csv(test_path("fixtures", "tam-jml-0.2.4-person.csv"))
  for (case in unique(response$Case)) {
    z <- response[response$Case==case, ]; ref <- person[person$Case==case, ]
    obs <- data.frame(Person=z$Person, Weight=1, Var=z$Variance,
      StdSq=(z$Score-z$Expected)^2/z$Variance, FourthCentralMoment=z$Fourth)
    fit <- mfrmr:::calc_facet_fit(obs, facet_cols="Person", fit_df_method="facets", whexact=FALSE)
    fit <- fit[match(ref$Person,fit$Level), ]
    expect_equal(fit$Infit,ref$Infit,tolerance=1e-11)
    expect_equal(fit$Outfit,ref$Outfit,tolerance=1e-11)
    expect_equal(fit$InfitZSTD,ref$InfitZ,tolerance=1e-10)
    expect_equal(fit$OutfitZSTD,ref$OutfitZ,tolerance=1e-10)
  }
})
