mfrm_extended_fit <- function(x) inherits(x, c("mfrm_testlet", "mfrm_random_rater"))

mfrm_extended_prediction_source <- function(fit) {
    list(class = class(fit), columns = fit$input$columns, levels = fit$input$levels, basis = fit$input$basis, 
        score_levels = fit$input$score_levels, calibration = fit$calibration, parameters = fit$parameters, 
        settings = fit$settings, checks = fit$checks, rater_mode = fit$rater_mode, conditional_rater_covariance = fit$conditional_rater_covariance)
}
