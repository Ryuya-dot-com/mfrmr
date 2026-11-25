build_mfrm_step_map <- function(declarations, config, prep) {
    required <- c("Level", "From", "To")
    optional <- c("Value", "Group")
    if (!is.data.frame(declarations) || !nrow(declarations) || anyDuplicated(names(declarations)) || 
        !all(required %in% names(declarations)) || !any(optional %in% names(declarations)) || !all(names(declarations) %in% 
        c(required, optional))) {
        stop("`step_constraints` needs a data frame with Level, From, To, and Value or Group.", call. = FALSE)
    }
    spec <- declarations
    owners <- names(config$step_specs)
    categories <- prep$score_map
    if (is.null(categories) || !identical(as.numeric(categories$OriginalScore), as.numeric(categories$InternalScore))) {
        stop("`step_constraints` requires consecutive, unrelabelled score categories.", call. = FALSE)
    }
    from <- seq.int(prep$rating_min, prep$rating_max - 1L)
    n_steps <- length(from)
    owner <- match(spec$Level, owners)
    transition <- match(spec$From, from)
    if (!is.character(spec$Level) || !is.null(dim(spec$Level)) || anyNA(owner) || !is.null(dim(spec$From)) || 
        !is.null(dim(spec$To)) || !is.numeric(spec$From) || is.complex(spec$From) || !is.numeric(spec$To) || 
        is.complex(spec$To) || anyNA(transition) || anyNA(spec$To) || any(spec$To != from[transition] + 
        1L)) {
        stop("`step_constraints` needs a known Level and consecutive From/To scores in the rating range.", 
            call. = FALSE)
    }
    row <- (owner - 1L) * n_steps + transition
    if (anyDuplicated(row)) 
        stop("Declare each Level and transition only once in `step_constraints`.", call. = FALSE)
    value <- spec$Value %||% rep(NA_real_, nrow(spec))
    group <- spec$Group %||% rep(NA_character_, nrow(spec))
    if (is.logical(value) && all(is.na(value))) 
        value <- as.numeric(value)
    if (is.logical(group) && all(is.na(group))) 
        group <- as.character(group)
    if (!is.numeric(value) || is.complex(value) || !is.null(dim(value)) || any(is.nan(value) | is.infinite(value)) || 
        !is.character(group) || !is.null(dim(group)) || any(!is.na(group) & !nzchar(group)) || any(is.na(value) & 
        is.na(group))) {
        stop("Each step declaration needs a finite Value or a nonempty Group (use NA for omissions).", 
            call. = FALSE)
    }
    n_rows <- length(owners) * n_steps
    representatives <- seq_len(n_rows)
    groups <- rep(NA_character_, n_rows)
    groups[row] <- group
    for (member in split(seq_len(nrow(spec)), group)) {
        if (length(member) < 2L || length(unique(transition[member])) != 1L) {
            stop("Each step Group must share the same transition across at least two levels.", call. = FALSE)
        }
        if (length(unique(value[member][!is.na(value[member])])) > 1L) {
            stop("Conflicting fixed Values in a shared step Group.", call. = FALSE)
        }
        representatives[row[member]] <- min(row[member])
    }
    cells <- sort(unique(representatives))
    cell <- match(representatives, cells)
    fixed <- rep(NA_real_, length(cells))
    fixed[cell[row[!is.na(value)]]] <- value[!is.na(value)]
    offset <- replace(fixed, is.na(fixed), 0)
    available <- which(is.na(fixed))
    centering <- matrix(0, length(owners), length(cells))
    centering[cbind(rep(seq_along(owners), each = n_steps), cell)] <- 1
    system <- centering[, rev(available), drop = FALSE]
    q <- qr(system)
    dependent <- rev(available)[q$pivot[seq_len(q$rank)]]
    free <- setdiff(available, dependent)
    basis <- matrix(0, length(cells), length(free))
    basis[cbind(free, seq_along(free))] <- 1
    if (length(dependent)) {
        calculated <- qr.coef(qr(centering[, dependent, drop = FALSE]), -cbind(centering %*% offset, 
            centering[, free, drop = FALSE]))
        offset[dependent] <- calculated[, 1L]
        basis[dependent, ] <- calculated[, -1L, drop = FALSE]
    }
    basis[abs(basis) < 1e-12] <- 0
    lhs <- as.numeric(centering %*% offset)
    scale <- as.numeric(centering %*% abs(offset))
    if (any(!is.finite(lhs)) || any(!is.finite(scale)) || any(abs(lhs) > 1e-12 * pmax(1, scale)) || any(abs(centering %*% 
        basis) > 1e-12)) {
        stop("Fixed or shared steps conflict with within-ladder sum-to-zero constraints.", call. = FALSE)
    }
    list(offset = offset[cell], basis = Matrix::Matrix(basis[cell, , drop = FALSE], sparse = TRUE), free = cells[free], 
        groups = groups, fixed = !is.na(fixed[cell]))
}

mfrm_step_affine_subspace <- function(fit, n_owners = NULL, tol = 1e-10) {
    cfg <- fit$config
    n_steps <- as.integer(cfg$n_cat) - 1L
    if (!is.null(cfg$step_constraint_map)) {
        offset <- as.numeric(cfg$step_constraint_map$offset)
        basis <- as.matrix(cfg$step_constraint_map$basis)
    }
    else {
        specs <- mfrmr_step_specs(cfg)
        n_free <- sum(vapply(specs, function(s) as.integer(s$n_params), integer(1)))
        offset <- as.vector(t(expand_step_constraints(numeric(n_free), specs)))
        basis <- if (n_free == 0L) {
            matrix(0, length(offset), 0L)
        }
        else {
            cols <- vapply(seq_len(n_free), function(j) {
                e <- numeric(n_free)
                e[j] <- 1
                as.vector(t(expand_step_constraints(e, specs))) - offset
            }, numeric(length(offset)))
            if (!is.matrix(cols)) 
                matrix(cols, nrow = length(offset))
            else cols
        }
    }
    if (identical(toupper(as.character(cfg$model)), "RSM") && !is.null(n_owners) && n_owners > 1L) {
        lift <- kronecker(rep(1, n_owners), diag(n_steps))
        offset <- as.numeric(lift %*% offset)
        basis <- lift %*% basis
    }
    if (ncol(basis) == 0L || all(abs(basis) == 0)) {
        Q <- matrix(0, length(offset), 0L)
    }
    else {
        sv <- svd(basis)
        keep <- sv$d > tol * max(1, sv$d[1L])
        Q <- sv$u[, keep, drop = FALSE]
    }
    list(offset = offset, basis = basis, Q = Q, rank = ncol(Q), n_cols = ncol(basis))
}

mfrm_affine_subspace_contained <- function(sub, sup, tol = 1e-10) {
    if (length(sub$offset) != length(sup$offset)) 
        return(FALSE)
    delta_c <- sub$offset - sup$offset
    res_c <- if (sup$rank == 0L) {
        delta_c
    }
    else {
        delta_c - drop(sup$Q %*% crossprod(sup$Q, delta_c))
    }
    scale_c <- max(1, max(abs(sub$offset)), max(abs(sup$offset)))
    if (!all(is.finite(res_c)) || max(abs(res_c)) > tol * scale_c) 
        return(FALSE)
    if (sub$rank == 0L) 
        return(TRUE)
    if (sup$rank < sub$rank) 
        return(FALSE)
    res_B <- sub$Q - sup$Q %*% crossprod(sup$Q, sub$Q)
    all(is.finite(res_B)) && max(abs(res_B)) <= tol
}

audit_mfrm_step_constraints_nesting <- function(fits, sigs, labels, interaction_sets) {
    lbls <- as.character(labels)
    model_pair <- toupper(c(sigs[[1]]$model, sigs[[2]]$model))
    methods <- toupper(vapply(fits, function(f) as.character(f$config$method %||% ""), character(1)))
    if (!all(model_pair %in% c("RSM", "PCM")) || !all(methods == "MML")) {
        return(list(eligible = FALSE, reason = "Automatic likelihood-ratio tests review fixed or shared step_constraints only across MML RSM/PCM models.", 
            simpler = NA_character_, complex = NA_character_, relation = "step_constraints_unreviewed"))
    }
    if (identical(model_pair[1], "PCM") && identical(model_pair[2], "PCM") && !same_signature_component(sigs[[1]]$step_facet, 
        sigs[[2]]$step_facet)) {
        return(list(eligible = FALSE, reason = "Same-family fits differ in structural model settings: step_facet.", 
            simpler = NA_character_, complex = NA_character_, relation = "same_model"))
    }
    if (setequal(model_pair, c("RSM", "PCM"))) {
        idx_rsm <- which(model_pair == "RSM")[1L]
        idx_pcm <- which(model_pair == "PCM")[1L]
        missing_int <- setdiff(interaction_sets[[idx_rsm]], interaction_sets[[idx_pcm]])
        if (length(missing_int)) {
            return(list(eligible = FALSE, reason = paste0("RSM interaction terms are absent from the PCM: ", 
                paste(missing_int, collapse = ", "), ". Freeing category steps does not preserve these interaction effects."), 
                simpler = NA_character_, complex = NA_character_, relation = "RSM_PCM_interactions_not_nested"))
        }
    }
    n_owners <- if (any(model_pair == "PCM")) {
        idx_pcm <- which(model_pair == "PCM")[1L]
        step_f <- sigs[[idx_pcm]]$step_facet
        if (is.na(step_f) || !nzchar(step_f)) {
            return(list(eligible = FALSE, reason = "PCM fit is missing a valid step_facet for step-subspace review.", 
                simpler = NA_character_, complex = NA_character_, relation = "step_constraints_unreviewed"))
        }
        length(fits[[idx_pcm]]$prep$levels[[step_f]])
    }
    else {
        1L
    }
    spaces <- lapply(fits, mfrm_step_affine_subspace, n_owners = n_owners)
    if (any(vapply(spaces, function(sp) sp$rank != sp$n_cols, logical(1)))) {
        return(list(eligible = FALSE, reason = "Step-constraint basis columns are rank-deficient; restriction count could not be verified.", 
            simpler = NA_character_, complex = NA_character_, relation = "step_constraints_unreviewed"))
    }
    step_1_in_2 <- mfrm_affine_subspace_contained(spaces[[1]], spaces[[2]])
    step_2_in_1 <- mfrm_affine_subspace_contained(spaces[[2]], spaces[[1]])
    int_1_in_2 <- all(interaction_sets[[1]] %in% interaction_sets[[2]])
    int_2_in_1 <- all(interaction_sets[[2]] %in% interaction_sets[[1]])
    sub_1_in_2 <- step_1_in_2 && int_1_in_2
    sub_2_in_1 <- step_2_in_1 && int_2_in_1
    if (sub_1_in_2 && sub_2_in_1) {
        return(list(eligible = FALSE, reason = "Both fits span the same affine step-parameter subspace and interaction set, so there are zero net restrictions to test.", 
            simpler = lbls[1], complex = lbls[2], relation = "step_constraints_equivalent"))
    }
    if (!sub_1_in_2 && !sub_2_in_1) {
        return(list(eligible = FALSE, reason = "The affine step-parameter subspaces (or fixed facet-interaction sets) of the two fits are not nested.", 
            simpler = NA_character_, complex = NA_character_, relation = "step_constraints_not_nested"))
    }
    idx_simple <- if (sub_1_in_2) 
        1L
    else 2L
    idx_complex <- 3L - idx_simple
    sizes <- lapply(fits, function(f) build_param_sizes(f$config))
    nonstep_simple <- sum(unlist(sizes[[idx_simple]][names(sizes[[idx_simple]]) != "steps"]))
    nonstep_complex <- sum(unlist(sizes[[idx_complex]][names(sizes[[idx_complex]]) != "steps"]))
    step_df <- spaces[[idx_complex]]$rank - spaces[[idx_simple]]$rank
    int_df <- as.integer(sizes[[idx_complex]][["interactions"]] %||% 0L) - as.integer(sizes[[idx_simple]][["interactions"]] %||% 
        0L)
    total_df <- step_df + int_df
    if (step_df < 0L || int_df < 0L || total_df < 1L || (nonstep_complex - nonstep_simple) != int_df) {
        return(list(eligible = FALSE, reason = "Free-parameter blocks outside step constraints and declared interactions did not align.", 
            simpler = NA_character_, complex = NA_character_, relation = "step_constraints_unreviewed"))
    }
    list(eligible = TRUE, reason = paste0("Supported affine step-subspace nesting review passed (", step_df, 
        " interior step restriction(s)", if (int_df > 0L) paste0(" plus ", int_df, " interaction parameter(s)") else "", 
        "; total df = ", total_df, ")."), simpler = lbls[idx_simple], complex = lbls[idx_complex], simpler_index = idx_simple, 
        complex_index = idx_complex, df = total_df, relation = "step_constraints_nested")
}
