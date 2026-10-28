adaptive_api_fixture <- local({
  cache <- list()
  function(model = "RSM") {
    if (!is.null(cache[[model]])) return(cache[[model]])
    data <- load_mfrmr_data("example_operational")
    fit <- fit_mfrm(data, "Person", c("Rater", "Criterion"), "Score",
      model = model, step_facet = if (model != "RSM") "Criterion" else NULL,
      slope_facet = if (model == "GPCM") "Criterion" else NULL,
      mml_integration = "adaptive", quad_points = 31L, maxit = 200L, reltol = 1e-10)
    cache[[model]] <<- list(data = data, fit = fit)
    cache[[model]]
  }
})

adaptive_sensitivity_fixture <- local({
  cache <- list()
  function(model = "RSM") {
    if (is.null(cache[[model]])) {
      fixture <- adaptive_api_fixture(model)
      expect_no_warning(cache[[model]] <<- mml_quadrature_sensitivity(
        fixture$fit, fixture$data, quad_points = c(31L, 41L)))
    }
    cache[[model]]
  }
})

