

mfrmr_cml_problem <- function(prep, idx, cfg, sizes) {
    adjacent <- mfrmr_estimability_adjacent_design(prep, idx, cfg, sizes, include_person = FALSE, include_population_beta = FALSE)
    p <- sum(unlist(sizes))
    K <- cfg$n_cat - 1L
    n <- nrow(prep$data)
    if (!p || !setequal(adjacent$map$OptimizerIndex, seq_len(p)))
        stop("CML requires free structural coordinates covered by the native model map.", call. = FALSE)
    order <- order(adjacent$map$OptimizerIndex)
    A <- adjacent$design[, order, drop = FALSE]
    keys <- do.call(paste, c(idx$facets, sep = ":"))
    cells <- unique(keys)
    features <- lapply(match(cells, keys), function(i) {
        increments <- as.matrix(A[i + (seq_len(K) - 1L) * n, , drop = FALSE])
        out <- matrix(0, K + 1L, p)
        for (k in seq_len(K)) out[k + 1L, ] <- out[k, ] + increments[k, ]
        out
    })
    cell <- match(keys, cells)
    persons <- split(seq_len(n), idx$person)
    groups <- list()
    group_index <- new.env(hash = TRUE, parent = emptyenv())
    observed <- numeric(p)
    totals <- vapply(persons, function(at) sum(idx$score_k[at]), numeric(1))
    maximum <- lengths(persons) * K
    extreme <- totals == 0 | totals == maximum
    for (i in which(!extreme)) {
        at <- persons[[i]]
        roster <- sort(cell[at])
        key <- paste(roster, collapse = ":")
        g <- group_index[[key]]
        if (is.null(g)) {
            g <- length(groups) + 1L
            group_index[[key]] <- g
            groups[[g]] <- list(features = features[roster], counts = numeric(length(at) * K + 1L))
        }
        groups[[g]]$counts[totals[i] + 1L] <- groups[[g]]$counts[totals[i] + 1L] + 1L
        for (j in at) observed <- observed + features[[cell[j]]][idx$score_k[j] + 1L, ]
    }
    list(groups = groups, observed = observed, parameters = p, map = adjacent$map[order, , drop = FALSE],
        person_totals = data.frame(Person = prep$levels$Person[as.integer(names(persons))], Total = totals,
            Maximum = maximum, Extreme = extreme, row.names = NULL))
}
.mfrm_cml_design_cache <- function(enc, lay) {
    q <- lay$n_xi
    if (!q) return(NULL)
    keys <- do.call(paste, c(as.list(as.data.frame(enc$facet_mat0)), list(enc$step_group0)))
    cell <- match(keys, unique(keys))
    first <- match(seq_len(max(cell)), cell)
    location <- do.call(cbind, lapply(seq_along(enc$facets), function(f) {
        .mfrm_facet_basis(enc, f)[enc$facet_mat0[first, f] + 1L, , drop = FALSE] *
            enc$facet_signs[f]
    }))
    K <- enc$n_cat - 1L
    step <- .mfrm_step_basis(enc, lay)
    group <- enc$step_group0[first] + 1L
    min_score <- enc$step_cat_min[group]
    max_score <- enc$step_cat_max[group]
    features <- lapply(seq_along(first), function(i) {
        k <- seq.int(0L, max_score[i] - min_score[i])
        out <- outer(k, location[i, ])
        increments <- step[(group[i] - 1L) * K + min_score[i] + k[-1L], , drop = FALSE]
        step_part <- matrix(0, length(k), lay$step_len)
        for (j in seq_len(lay$step_len)) step_part[-1L, j] <- -cumsum(increments[, j])
        cbind(out, step_part)
    })
    people_all <- split(seq_along(cell), factor(enc$person0, levels = seq.int(0L, enc$n_person - 1L)))
    rosters_all <- lapply(people_all, function(i) if (length(i)) sort(cell[i]) else integer(0))
    r_keys <- vapply(rosters_all, paste, "", collapse = ",")
    u_keys <- unique(r_keys[nzchar(r_keys)])
    roster_templates <- stats::setNames(lapply(u_keys, function(rk) {
        p1 <- match(rk, r_keys)
        path <- features[rosters_all[[p1]]]
        capacity <- vapply(path, nrow, integer(1)) - 1L
        reachable <- cumsum(capacity)
        max_tot <- sum(capacity)
        log_count <- c(0, rep(-Inf, max_tot))
        mean_feature <- matrix(0, max_tot + 1L, q)
        for (j in seq_along(path)) {
            next_count <- rep(-Inf, max_tot + 1L)
            next_mean <- matrix(0, max_tot + 1L, q)
            for (s in 0:reachable[j]) {
                k <- seq.int(0L, min(capacity[j], s))
                from <- s - k + 1L
                keep_k <- is.finite(log_count[from])
                if (!any(keep_k)) next
                k <- k[keep_k]; from <- from[keep_k]
                peak <- max(log_count[from])
                w <- exp(log_count[from] - peak)
                next_count[s + 1L] <- peak + log(sum(w))
                w <- w / sum(w)
                next_mean[s + 1L, ] <- drop(crossprod(w,
                    mean_feature[from, , drop = FALSE] + path[[j]][k + 1L, , drop = FALSE]))
            }
            log_count <- next_count
            mean_feature <- next_mean
        }
        list(path = path, capacity = capacity, reachable = reachable, mean_feature = mean_feature)
    }), u_keys)
    list(cell = cell, min_score = min_score, features = features,
         people_all = people_all, roster_keys = r_keys, templates = roster_templates)
}

# Exact full DP-network LP fallback (used only if outer approximation does not terminate)
.mfrm_cml_boundary_network_lp <- function(q, n_people, observed, direction_gain, groups, verify_gap) {
    edge_chunks <- list()
    n_chunks <- 0L
    node <- 0L
    terminals <- frequencies <- numeric()
    for (g in groups) {
        path <- g$path
        targets <- g$targets
        counts <- g$counts
        last <- g$last
        capacity <- g$capacity
        reachable <- g$reachable
        remaining <- rev(cumsum(rev(capacity))) - capacity
        previous <- rep(NA_integer_, last + 1L)
        previous[1L] <- 0L
        for (j in seq_along(path)) {
            next_node <- rep(NA_integer_, last + 1L)
            for (s in 0:min(reachable[j], last)) {
                if (!any(targets >= s & targets <= s + remaining[j])) next
                k <- seq.int(0L, min(capacity[j], s))
                k <- k[!is.na(previous[s - k + 1L])]
                if (!length(k)) next
                from <- s - k + 1L
                node <- node + 1L
                next_node[s + 1L] <- node
                rows_j <- vector("list", length(k))
                for (i in seq_along(k)) {
                    prior <- previous[from[i]]
                    cols <- c(seq_len(q), q + node, if (prior > 0L) q + prior)
                    vals <- c(-path[[j]][k[i] + 1L, ], 1, if (prior > 0L) -1)
                    use <- vals != 0
                    rows_j[[i]] <- cbind(cols[use], vals[use])
                }
                n_chunks <- n_chunks + 1L
                edge_chunks[[n_chunks]] <- rows_j
            }
            previous <- next_node
        }
        terminals <- c(terminals, previous[targets + 1L])
        frequencies <- c(frequencies, counts)
    }
    constraints <- unlist(edge_chunks, recursive = FALSE)
    term_cols <- c(seq_len(q), q + terminals)
    term_vals <- c(observed, -frequencies)
    use_t <- term_vals != 0
    constraints[[length(constraints) + 1L]] <- cbind(term_cols[use_t], term_vals[use_t])
    width <- q + node
    triplets <- lapply(seq_along(constraints), function(i) {
        a <- constraints[[i]]
        cbind(rep.int(i, 2L * nrow(a)), c(a[, 1L], a[, 1L] + width), c(a[, 2L], -a[, 2L]))
    })
    lp <- lpSolve::lp("max", c(direction_gain, rep(0, node), -direction_gain, rep(0, node)),
        dense.const = rbind(do.call(rbind, triplets),
            cbind(length(triplets) + 1L, c(seq_len(q), width + seq_len(q)), 1)),
        const.dir = c(rep(">=", length(triplets)), "<="), const.rhs = c(rep(0, length(triplets)), 1))
    unavailable <- list(detected = FALSE, status = "solver_unavailable", solver_status = lp$status)
    if (lp$status != 0L || !is.finite(lp$objval)) return(unavailable)
    gain <- lp$objval / n_people
    if (gain <= 1e-9) return(list(detected = FALSE, status = "no_conditional_recession_detected"))
    direction <- lp$solution[seq_len(q)] - lp$solution[width + seq_len(q)]
    gap <- verify_gap(direction)
    if (abs(gap / n_people) > 1e-7 || sum(abs(direction)) > 1 + 1e-7)
        return(unavailable)
    list(detected = TRUE, status = "no_finite_conditional_mle", direction = direction,
         support_gap = gap, gain = gain)
}

# A conditional sufficient statistic lies on a likelihood boundary if a
# direction maximizes the observed statistic with a strict gain over some
# other rating pattern having the same person total.
.mfrm_cml_boundary <- function(fit) {
    enc <- fit$encoding
    lay <- fit$xi_layout
    q <- lay$n_xi
    if (!q) return(list(detected = FALSE, status = "no_free_structural_parameters"))
    if (!isTRUE(fit$converged)) return(list(detected = FALSE, status = "not_converged"))
    V <- fit$xi_covariance_model
    if (nrow(V) != q || any(!is.finite(V)))
        return(list(detected = FALSE, status = "information_unavailable"))

    cache <- enc$cml_cache
    if (!is.null(cache)) {
        cell <- cache$cell
        min_score <- cache$min_score
        features <- cache$features
        keep_p <- which(fit$person$ObsCount > 0 & fit$person$ExtremeFlag == 0L)
        if (!length(keep_p)) return(list(detected = FALSE, status = "information_unavailable"))
        people <- cache$people_all[keep_p]
        r_keys_sub <- cache$roster_keys[keep_p]
    } else {
        keys <- do.call(paste, c(as.list(as.data.frame(enc$facet_mat0)), list(enc$step_group0)))
        cell <- match(keys, unique(keys))
        first <- match(seq_len(max(cell)), cell)
        location <- do.call(cbind, lapply(seq_along(enc$facets), function(f) {
            .mfrm_facet_basis(enc, f)[enc$facet_mat0[first, f] + 1L, , drop = FALSE] *
                enc$facet_signs[f]
        }))
        K <- enc$n_cat - 1L
        step <- .mfrm_step_basis(enc, lay)
        group <- enc$step_group0[first] + 1L
        min_score <- enc$step_cat_min[group]
        max_score <- enc$step_cat_max[group]
        features <- lapply(seq_along(first), function(i) {
            k <- seq.int(0L, max_score[i] - min_score[i])
            out <- outer(k, location[i, ])
            increments <- step[(group[i] - 1L) * K + min_score[i] + k[-1L], , drop = FALSE]
            step_part <- matrix(0, length(k), lay$step_len)
            for (j in seq_len(lay$step_len)) step_part[-1L, j] <- -cumsum(increments[, j])
            cbind(out, step_part)
        })
        people <- split(seq_along(cell), factor(enc$person0))
        people <- people[vapply(people, function(rows)
            fit$person$ExtremeFlag[enc$person0[rows[1L]] + 1L] == 0L, logical(1))]
        if (!length(people)) return(list(detected = FALSE, status = "information_unavailable"))
        rosters <- lapply(people, function(i) sort(cell[i]))
        r_keys_sub <- vapply(rosters, paste, "", collapse = ",")
    }

    n_people <- length(people)
    obs_person <- t(vapply(people, function(rows) {
        s <- numeric(q)
        for (i in rows) {
            k <- enc$score0[i] - min_score[cell[i]]
            s <- s + features[[cell[i]]][k + 1L, ]
        }
        s
    }, numeric(q)))
    if (q == 1L) obs_person <- matrix(obs_person, ncol = 1L)
    observed <- colSums(obs_person)
    by_roster <- split(seq_len(n_people), r_keys_sub)
    totals <- vapply(people, function(i) sum(enc$score0[i] - min_score[cell[i]]), integer(1))

    groups <- vector("list", length(by_roster))
    direction_gain <- observed
    r_names <- names(by_roster)
    for (r in seq_along(by_roster)) {
        members <- by_roster[[r]]
        targets <- sort(unique(totals[members]))
        t_match <- match(totals[members], targets)
        counts <- tabulate(t_match, length(targets))
        obs_mean <- rowsum(obs_person[members, , drop = FALSE], t_match, reorder = TRUE) / counts
        last <- max(targets)
        if (!is.null(cache)) {
            tpl <- cache$templates[[r_names[r]]]
            path <- tpl$path
            capacity <- tpl$capacity
            reachable <- tpl$reachable
            mean_sub <- tpl$mean_feature[targets + 1L, , drop = FALSE]
        } else {
            path <- features[sort(cell[people[[members[1L]]]])]
            capacity <- vapply(path, nrow, integer(1)) - 1L
            reachable <- cumsum(capacity)
            remaining <- rev(cumsum(rev(capacity))) - capacity
            log_count <- c(0, rep(-Inf, last))
            mean_feature <- matrix(0, last + 1L, q)
            for (j in seq_along(path)) {
                next_count <- rep(-Inf, last + 1L)
                next_mean <- matrix(0, last + 1L, q)
                for (s in 0:min(reachable[j], last)) {
                    if (!any(targets >= s & targets <= s + remaining[j])) next
                    k <- seq.int(0L, min(capacity[j], s))
                    from <- s - k + 1L
                    keep_k <- is.finite(log_count[from])
                    if (!any(keep_k)) next
                    k <- k[keep_k]; from <- from[keep_k]
                    peak <- max(log_count[from])
                    weight <- exp(log_count[from] - peak)
                    next_count[s + 1L] <- peak + log(sum(weight))
                    weight <- weight / sum(weight)
                    next_mean[s + 1L, ] <- drop(crossprod(weight,
                        mean_feature[from, , drop = FALSE] + path[[j]][k + 1L, , drop = FALSE]))
                }
                log_count <- next_count
                mean_feature <- next_mean
            }
            mean_sub <- mean_feature[targets + 1L, , drop = FALSE]
        }
        direction_gain <- direction_gain - drop(crossprod(counts, mean_sub))
        groups[[r]] <- list(path = path, targets = targets, counts = counts, obs_mean = obs_mean,
                            last = last, capacity = capacity, reachable = reachable)
    }

    # Recompute path maxima without LP potentials before accepting any certificate.
    verify_gap <- function(direction) {
        gap <- -sum(observed * direction)
        for (g in groups) {
            values <- 0
            for (x in g$path) {
                scores <- drop(x %*% direction)
                next_values <- rep(-Inf, length(values) + nrow(x) - 1L)
                for (k in seq_along(scores)) {
                    i <- seq_along(values) + k - 1L
                    next_values[i] <- pmax(next_values[i], values + scores[k])
                }
                values <- next_values
            }
            gap <- gap + sum(g$counts * values[g$targets + 1L])
        }
        gap
    }

    # Multi-cut outer approximation on d in R^q (2q LP variables instead of full DP node space).
    eval_cuts <- function(d) {
        cuts_list <- vector("list", length(groups) + 1L)
        n_c <- 0L
        total_gap <- 0
        agg_cut <- numeric(q)
        for (g in groups) {
            L <- length(g$path)
            last <- g$last
            vals <- c(0, rep(-Inf, last))
            choice <- matrix(NA_integer_, L, last + 1L)
            for (j in seq_len(L)) {
                sc <- drop(g$path[[j]] %*% d)
                nv <- rep(-Inf, last + 1L)
                s_hi <- min(g$reachable[j], last)
                for (k in seq_along(sc)) {
                    kk <- k - 1L
                    if (kk > s_hi) break
                    s_seq <- kk:s_hi
                    cand <- vals[s_seq - kk + 1L] + sc[k]
                    better <- cand > nv[s_seq + 1L]
                    if (any(better)) {
                        idx <- s_seq[better] + 1L
                        nv[idx] <- cand[better]
                        choice[j, idx] <- kk
                    }
                }
                vals <- nv
            }
            diffs <- vals[g$targets + 1L] - drop(g$obs_mean %*% d)
            pos <- which(diffs > 0)
            if (length(pos)) {
                total_gap <- total_gap + sum(g$counts[pos] * diffs[pos])
                mat <- matrix(0, length(pos), q)
                for (vi in seq_along(pos)) {
                    m <- pos[vi]
                    s_cur <- g$targets[m]
                    feat <- numeric(q)
                    for (j in L:1L) {
                        kk <- choice[j, s_cur + 1L]
                        feat <- feat + g$path[[j]][kk + 1L, ]
                        s_cur <- s_cur - kk
                    }
                    diff_vec <- feat - g$obs_mean[m, ]
                    mat[vi, ] <- diff_vec
                    agg_cut <- agg_cut + g$counts[m] * diff_vec
                }
                viol <- diffs[pos] > 1e-12
                if (any(viol)) {
                    n_c <- n_c + 1L
                    cuts_list[[n_c]] <- mat[viol, , drop = FALSE]
                }
            }
        }
        if (total_gap > 0 && any(agg_cut != 0)) {
            n_c <- n_c + 1L
            cuts_list[[n_c]] <- matrix(agg_cut, nrow = 1L)
        }
        cuts <- if (n_c > 0L) do.call(rbind, cuts_list[seq_len(n_c)]) else matrix(0, 0L, q)
        list(gap = total_gap, cuts = cuts)
    }

    C_mat <- matrix(0, 0L, q)
    g_l1 <- sum(abs(direction_gain))
    if (g_l1 <= 1e-15) {
        return(list(detected = FALSE, status = "no_conditional_recession_detected"))
    }
    d0 <- direction_gain / g_l1
    ev0 <- eval_cuts(d0)
    if (ev0$gap / n_people <= 1e-9 && sum(direction_gain * d0) / n_people > 1e-9) {
        gap0 <- verify_gap(d0)
        if (abs(gap0 / n_people) <= 1e-7 && sum(abs(d0)) <= 1 + 1e-7) {
            return(list(detected = TRUE, status = "no_finite_conditional_mle",
                        direction = d0, support_gap = gap0, gain = sum(direction_gain * d0) / n_people))
        }
    }
    if (nrow(ev0$cuts)) C_mat <- unique(ev0$cuts)

    obj <- c(direction_gain, -direction_gain)
    norm_row <- matrix(1, 1L, 2L * q)
    for (it in seq_len(80L)) {
        lhs <- if (nrow(C_mat)) rbind(cbind(C_mat, -C_mat), norm_row) else norm_row
        lp <- lpSolve::lp("max", obj, lhs, rep("<=", nrow(lhs)), c(rep(0, nrow(C_mat)), 1))
        if (lp$status != 0L || !is.finite(lp$objval)) {
            return(list(detected = FALSE, status = "solver_unavailable", solver_status = lp$status))
        }
        gain <- lp$objval / n_people
        if (gain <= 1e-9) {
            return(list(detected = FALSE, status = "no_conditional_recession_detected"))
        }
        direction <- lp$solution[seq_len(q)] - lp$solution[q + seq_len(q)]
        ev <- eval_cuts(direction)
        if (ev$gap / n_people <= 1e-9) {
            gap <- verify_gap(direction)
            if (abs(gap / n_people) <= 1e-7 && sum(abs(direction)) <= 1 + 1e-7) {
                return(list(detected = TRUE, status = "no_finite_conditional_mle",
                            direction = direction, support_gap = gap, gain = gain))
            }
        }
        if (!nrow(ev$cuts)) break
        prev_n <- nrow(C_mat)
        C_mat <- unique(rbind(C_mat, ev$cuts))
        if (nrow(C_mat) == prev_n) break
    }
    .mfrm_cml_boundary_network_lp(q, n_people, observed, direction_gain, groups, verify_gap)
}
