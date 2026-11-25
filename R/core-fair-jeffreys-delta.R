mfrm_fair_jeffreys_jacobian <- function(fit, design, probs, anchors, anchor_map) {
    d <- mfrm_fair_jeffreys_design(fit)
    z <- mfrm_fair_jeffreys_objective(d$category, d$offset, d$y)$evaluate(fit$opt$par)
    p <- length(fit$opt$par)
    n <- nrow(probs)
    K <- ncol(probs)
    O <- mfrm_fair_delta_anchor_design(fit, design$idx, anchors, anchor_map)
    Z <- lapply(z$centered, as.matrix)
    W <- lapply(seq_len(K), function(k) cbind(Z[[k]], as.matrix(O[[k]])))
    W <- lapply(mfrm_fair_delta_center(W, probs), as.matrix)
    V <- vector("list", K)
    q <- matrix(0, n, K)
    residual <- 0
    for (k in seq_len(K)) {
        V[[k]] <- matrix(0, n, p)
        if (p) 
            for (first in seq.int(1L, n, by = 256L)) {
                rows <- seq.int(first, min(n, first + 255L))
                rhs <- z$D %*% t(Z[[k]][rows, , drop = FALSE])
                solved <- Matrix::solve(z$factor, rhs, system = "A")
                error <- max(abs(z$H %*% solved - rhs))/max(1, max(abs(rhs)))
                if (!is.finite(error) || error > 1e-08 || any(!is.finite(solved))) 
                  stop("Jeffreys derivative information solve failed its residual check.", call. = FALSE)
                residual <- max(residual, error)
                V[[k]][rows, ] <- t(as.matrix(z$D %*% solved))
            }
        q[, k] <- rowSums(V[[k]] * Z[[k]])
    }
    ordinary <- as.matrix(mfrm_fair_delta_information(Z, probs, W))
    adjustment <- matrix(0, p, p + nrow(anchors))
    if (p) 
        for (j in seq_len(ncol(adjustment))) {
            rows <- which(Reduce(`|`, lapply(W, function(w) w[, j] != 0)))
            active <- which(Reduce(`+`, lapply(Z, function(z) colSums(abs(z[rows, , drop = FALSE])))) != 
                0)
            m <- matrix(0, n, length(active))
            dI <- matrix(0, length(active), length(active))
            for (k in seq_len(K)) {
                pw <- probs[, k] * W[[k]][, j]
                m <- m + pw * Z[[k]][, active, drop = FALSE]
                small <- Z[[k]][rows, active, drop = FALSE]
                dI <- dI + crossprod(small, pw[rows] * small)
            }
            for (k in seq_len(K)) {
                v <- V[[k]][, active, drop = FALSE]
                dq <- -2 * rowSums(v * m) - rowSums((v %*% dI) * v)
                adjustment[, j] <- adjustment[, j] + 0.5 * (drop(crossprod(Z[[k]], probs[, k] * (W[[k]][, 
                  j] * q[, k] + dq))))
                adjustment[active, j] <- adjustment[active, j] - 0.5 * colSums(probs[, k] * q[, k] * 
                  m)
            }
        }
    jacobian <- ordinary - adjustment
    H <- jacobian[, seq_len(p), drop = FALSE]
    asymmetry <- if (p) 
        max(abs(H - t(H)))/max(1, max(abs(H)))
    else 0
    if (any(!is.finite(jacobian)) || asymmetry > 1e-08) 
        stop("Jeffreys score Jacobian is nonfinite or fails symmetry.", call. = FALSE)
    H <- (H + t(H))/2
    reciprocal_condition <- 1
    if (p) {
        diagonal <- diag(H)
        if (any(diagonal <= 0)) 
            stop("Jeffreys score Jacobian has a nonpositive diagonal.", call. = FALSE)
        scaled <- H/sqrt(outer(diagonal, diagonal))
        reciprocal_condition <- rcond(scaled)
        if (!is.finite(reciprocal_condition) || reciprocal_condition < sqrt(.Machine$double.eps)) 
            stop("Jeffreys score Jacobian is ill-conditioned; no regularization was applied.", call. = FALSE)
    }
    list(information = Matrix::Matrix(H, sparse = TRUE), anchors = jacobian[, p + seq_len(nrow(anchors)), 
        drop = FALSE], diagnostics = list(equation = "jeffreys_penalized_score", analytic = TRUE, symmetry_residual = asymmetry, 
        information_solve_residual = residual, scaled_reciprocal_condition = reciprocal_condition))
}
