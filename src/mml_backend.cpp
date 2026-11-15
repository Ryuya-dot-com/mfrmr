#define R_NO_REMAP
#include <cpp11.hpp>
#include <Rmath.h>

#include <algorithm>
#include <cmath>
#include <cstring>
#include <string>
#include <unordered_map>
#include <limits>
#include <vector>

using namespace cpp11;

namespace {

// Share only bit-identical finite inputs on a common quadrature grid. The
// mapping is local to this call, so no parameter-dependent cache survives it.
struct ProbabilityRows {
  std::vector<int> group;
  std::vector<int> first;
};

ProbabilityRows probability_representatives(doubles base_eta,
                                             doubles_matrix<> person_nodes,
                                             const double* steps,
                                             int k_cat,
                                             bool observation_steps) {
  const int n = base_eta.size();
  if (n < 32 || person_nodes.ncol() < 2 || k_cat < 2 ||
      person_nodes.nrow() == 0) {
    return {};
  }
  for (int q = 0; q < person_nodes.ncol(); ++q) {
    const double first = person_nodes(0, q);
    if (!std::isfinite(first)) return {};
    for (int p = 1; p < person_nodes.nrow(); ++p) {
      const double node = person_nodes(p, q);
      if (std::memcmp(&first, &node, sizeof(double)) != 0) return {};
    }
  }
  if (!observation_steps) {
    for (int k = 0; k < k_cat; ++k) {
      if (!std::isfinite(steps[k])) return {};
    }
  }

  std::unordered_map<std::string, int> first_rows;
  ProbabilityRows rows;
  rows.group.resize(static_cast<size_t>(n));
  std::string key;
  key.reserve(sizeof(double) * static_cast<size_t>(observation_steps ? k_cat + 1 : 1));
  for (int i = 0; i < n; ++i) {
    const double eta = base_eta[i];
    if (!std::isfinite(eta)) return {};
    key.assign(reinterpret_cast<const char*>(&eta), sizeof(double));
    if (observation_steps) {
      for (int k = 0; k < k_cat; ++k) {
        const double step = steps[static_cast<size_t>(i) + static_cast<size_t>(n) * k];
        if (!std::isfinite(step)) return {};
        key.append(reinterpret_cast<const char*>(&step), sizeof(double));
      }
    }
    const auto inserted = first_rows.emplace(key, static_cast<int>(rows.first.size()));
    if (inserted.second) rows.first.push_back(i);
    rows.group[static_cast<size_t>(i)] = inserted.first->second;
    // With few repetitions, retain the original loop and its smaller workspace.
    if (first_rows.size() > static_cast<size_t>(n / 8)) return {};
  }
  // Bound the extra category cache by the already allocated log-probability matrix.
  if (rows.first.size() * static_cast<size_t>(k_cat) >
      static_cast<size_t>(n) * person_nodes.ncol()) return {};
  return rows;
}

ProbabilityRows probability_representatives_indexed(int model_code,
                                                    doubles base_eta,
                                                    doubles_matrix<> person_nodes,
                                                    const double* step_rsm,
                                                    const std::vector<double>& step_rm,
                                                    int n_criteria,
                                                    const int* step_idx_ptr,
                                                    const double* slopes_ptr,
                                                    int n_slopes,
                                                    const int* slope_idx_ptr,
                                                    int k_cat) {
  const int n = base_eta.size();
  if (n < 32 || person_nodes.ncol() < 2 || k_cat < 2 ||
      person_nodes.nrow() == 0) {
    return {};
  }
  for (int q = 0; q < person_nodes.ncol(); ++q) {
    const double first = person_nodes(0, q);
    if (!std::isfinite(first)) return {};
    for (int p = 1; p < person_nodes.nrow(); ++p) {
      const double node = person_nodes(p, q);
      if (std::memcmp(&first, &node, sizeof(double)) != 0) return {};
    }
  }
  if (model_code == 0) {
    for (int k = 0; k < k_cat; ++k) {
      if (!std::isfinite(step_rsm[k])) return {};
    }
  } else {
    for (size_t idx = 0; idx < step_rm.size(); ++idx) {
      if (!std::isfinite(step_rm[idx])) return {};
    }
    if (model_code == 2) {
      for (int s = 0; s < n_slopes; ++s) {
        if (!std::isfinite(slopes_ptr[s])) return {};
      }
    }
  }

  std::unordered_map<std::string, int> first_rows;
  ProbabilityRows rows;
  rows.group.resize(static_cast<size_t>(n));
  std::string key;
  const size_t key_doubles = 1 + (model_code == 2 ? 1 : 0) +
                             (model_code != 0 ? static_cast<size_t>(k_cat) : 0);
  key.reserve(sizeof(double) * key_doubles);
  for (int i = 0; i < n; ++i) {
    const double eta = base_eta[i];
    if (!std::isfinite(eta)) return {};
    key.assign(reinterpret_cast<const char*>(&eta), sizeof(double));
    if (model_code == 2) {
      const int sl_i = slope_idx_ptr[i] - 1;
      if (sl_i < 0 || sl_i >= n_slopes) return {};
      const double sl = slopes_ptr[sl_i];
      key.append(reinterpret_cast<const char*>(&sl), sizeof(double));
    }
    if (model_code != 0) {
      const int st_i = step_idx_ptr[i] - 1;
      if (st_i < 0 || st_i >= n_criteria) return {};
      const double* st_row = step_rm.data() + static_cast<size_t>(st_i) * k_cat;
      key.append(reinterpret_cast<const char*>(st_row), sizeof(double) * static_cast<size_t>(k_cat));
    }
    const auto inserted = first_rows.emplace(key, static_cast<int>(rows.first.size()));
    if (inserted.second) rows.first.push_back(i);
    rows.group[static_cast<size_t>(i)] = inserted.first->second;
    if (first_rows.size() > static_cast<size_t>(n / 8)) return {};
  }
  if (rows.first.size() * static_cast<size_t>(k_cat) >
      static_cast<size_t>(n) * person_nodes.ncol()) return {};
  return rows;
}

inline writable::doubles_matrix<> build_p_geq(const writable::doubles_matrix<>& probs) {
  const int n = probs.nrow();
  const int k_cat = probs.ncol();
  const int n_steps = k_cat - 1;
  writable::doubles_matrix<> out(n, std::max(n_steps, 0));
  if (n == 0 || n_steps <= 0) {
    return out;
  }

  for (int i = 0; i < n; ++i) {
    out(i, n_steps - 1) = probs(i, k_cat - 1);
  }
  for (int s = n_steps - 2; s >= 0; --s) {
    for (int i = 0; i < n; ++i) {
      out(i, s) = out(i, s + 1) + probs(i, s + 1);
    }
  }

  return out;
}

// Helper for 1-person standardized adaptive posterior evaluation at scalar z.
struct AdaptivePointMoments {
  double log_likelihood = 0.0;
  double score = 0.0;
  double information = 1.0;
  bool finite_ok = true;
};

inline AdaptivePointMoments eval_adaptive_point_moments(
    double z,
    double mu_p,
    double sigma,
    int m_obs,
    int k_cat,
    int model_code,
    const double* base_eta_sub,
    const int* score_sub,
    const double* weight_sub,
    const double* slope_sub,
    const double* step_rsm,
    const double* step_rm,
    const int* step_idx_sub,
    std::vector<double>& log_num_buf,
    std::vector<double>& prob_buf) {
  AdaptivePointMoments res;
  const double theta = mu_p + sigma * z;
  double score_sum = 0.0;
  double info_sum = 0.0;
  double ll_sum = 0.0;

  for (int r = 0; r < m_obs; ++r) {
    const double eta = base_eta_sub[r] + theta;
    const double sl = (model_code == 2) ? slope_sub[r] : 1.0;
    const double* st_ptr = (model_code == 0)
      ? step_rsm
      : (step_rm + static_cast<size_t>(step_idx_sub[r] - 1) * k_cat);

    double row_max = -std::numeric_limits<double>::infinity();
    for (int k = 0; k < k_cat; ++k) {
      const double lin = eta * static_cast<double>(k) - st_ptr[k];
      const double val = (model_code == 2) ? (lin * sl) : lin;
      log_num_buf[static_cast<size_t>(k)] = val;
      if (val > row_max) row_max = val;
    }

    double denom = 0.0;
    for (int k = 0; k < k_cat; ++k) {
      const double e = std::exp(log_num_buf[static_cast<size_t>(k)] - row_max);
      prob_buf[static_cast<size_t>(k)] = e;
      denom += e;
    }
    const double log_denom = std::log(denom);
    const int y = score_sub[r];
    const double w = weight_sub[r];
    ll_sum += w * ((log_num_buf[static_cast<size_t>(y)] - row_max) - log_denom);

    double expected = 0.0;
    for (int k = 0; k < k_cat; ++k) {
      prob_buf[static_cast<size_t>(k)] /= denom;
      expected += prob_buf[static_cast<size_t>(k)] * static_cast<double>(k);
    }
    double variance = 0.0;
    for (int k = 0; k < k_cat; ++k) {
      const double centered = static_cast<double>(k) - expected;
      variance += prob_buf[static_cast<size_t>(k)] * centered * centered;
    }
    score_sum += (w * sl) * (static_cast<double>(y) - expected);
    info_sum += (w * sl * sl) * variance;
  }

  const double m1 = sigma * score_sum;
  const double m2 = sigma * sigma * info_sum;
  if (!std::isfinite(m1) || !std::isfinite(m2)) {
    res.finite_ok = false;
    return res;
  }
  res.log_likelihood = ll_sum;
  res.score = m1 - z;
  res.information = m2 + 1.0;
  return res;
}

struct AdaptiveModeResult {
  double mode = 0.0;
  double scale = 1.0;
  double information = 1.0;
  int error_code = 0;
  std::string error_message;
};

// Safeguarded Newton-Raphson with bracketed bisection fallback on the strictly
// decreasing standardized posterior score S(z), matching uniroot(tol = 1e-12)
// while reaching machine-precision stationarity in ~4-6 evaluations.
inline AdaptiveModeResult find_adaptive_posterior_mode(
    double mu_p,
    double sigma,
    int m_obs,
    int k_cat,
    int model_code,
    const double* base_eta_sub,
    const int* score_sub,
    const double* weight_sub,
    const double* slope_sub,
    const double* step_rsm,
    const double* step_rm,
    const int* step_idx_sub,
    std::vector<double>& log_num_buf,
    std::vector<double>& prob_buf) {
  AdaptiveModeResult out;
  auto eval_z = [&](double z) {
    return eval_adaptive_point_moments(
      z, mu_p, sigma, m_obs, k_cat, model_code,
      base_eta_sub, score_sub, weight_sub, slope_sub,
      step_rsm, step_rm, step_idx_sub, log_num_buf, prob_buf);
  };

  AdaptivePointMoments m0 = eval_z(0.0);
  if (!m0.finite_ok) {
    out.error_code = 1;
    out.error_message = "Non-finite adaptive posterior score or information.";
    return out;
  }
  if (std::abs(m0.score) <= 1e-15) {
    const double sc = 1.0 / std::sqrt(m0.information);
    if (!std::isfinite(sc) || sc <= 0.0) {
      out.error_code = 2;
      out.error_message = "Invalid local posterior scale.";
      return out;
    }
    out.mode = 0.0;
    out.scale = sc;
    out.information = m0.information;
    return out;
  }

  double low = -1.0;
  double high = 1.0;
  double z = 0.0;
  AdaptivePointMoments cur = m0;
  bool bracketed = false;

  if (m0.score > 0.0) {
    low = 0.0;
    double step = 1.0;
    high = 1.0;
    for (int expand = 0; expand < 64; ++expand) {
      AdaptivePointMoments mh = eval_z(high);
      if (!mh.finite_ok) {
        out.error_code = 1;
        out.error_message = "Non-finite adaptive posterior score or information.";
        return out;
      }
      if (mh.score <= 0.0) { bracketed = true; break; }
      low = high;
      step *= 2.0;
      high += step;
    }
  } else {
    high = 0.0;
    double step = 1.0;
    low = -1.0;
    for (int expand = 0; expand < 64; ++expand) {
      AdaptivePointMoments ml = eval_z(low);
      if (!ml.finite_ok) {
        out.error_code = 1;
        out.error_message = "Non-finite adaptive posterior score or information.";
        return out;
      }
      if (ml.score >= 0.0) { bracketed = true; break; }
      high = low;
      step *= 2.0;
      low -= step;
    }
  }

  // Preserve the R solver as a fallback when the native search cannot certify
  // a bracket or termination; a finite endpoint is not a posterior mode.
  if (!bracketed) {
    out.error_code = 5;
    out.error_message = "Unable to bracket adaptive posterior mode.";
    return out;
  }

  // Start Newton from the initial step at z = 0, safeguarded inside (low, high)
  double z_next = z + cur.score / cur.information;
  if (!std::isfinite(z_next) || z_next <= low || z_next >= high) {
    z_next = 0.5 * (low + high);
  }
  z = z_next;

  bool converged = false;
  for (int iter = 0; iter < 80; ++iter) {
    cur = eval_z(z);
    if (!cur.finite_ok) {
      out.error_code = 1;
      out.error_message = "Non-finite adaptive posterior score or information.";
      return out;
    }
    if (std::abs(cur.score) <= 1e-14) {
      converged = true;
      break;
    }
    if (cur.score > 0.0) {
      low = z;
    } else {
      high = z;
    }
    const double scale_z = std::max(1.0, std::abs(z));
    if ((high - low) <= 4.0 * std::numeric_limits<double>::epsilon() * scale_z) {
      converged = true;
      break;
    }
    double cand = z + cur.score / cur.information;
    if (!std::isfinite(cand) || cand <= low || cand >= high) {
      cand = 0.5 * (low + high);
    }
    const double dz = std::abs(cand - z);
    z = cand;
    if (dz <= 1e-14 * scale_z && std::abs(cur.score) <= 1e-12) {
      cur = eval_z(z);
      if (!cur.finite_ok) {
        out.error_code = 1;
        out.error_message = "Non-finite adaptive posterior score or information.";
        return out;
      }
      converged = true;
      break;
    }
  }

  if (!converged) {
    out.error_code = 5;
    out.error_message = "Adaptive posterior mode did not converge.";
    return out;
  }

  const double sc = 1.0 / std::sqrt(cur.information);
  if (!std::isfinite(sc) || sc <= 0.0) {
    out.error_code = 2;
    out.error_message = "Invalid local posterior scale.";
    return out;
  }
  out.mode = z;
  out.scale = sc;
  out.information = cur.information;
  return out;
}

inline void sparse_crossprod_add(int pat,
                                 const int* pat_col_starts,
                                 const int* active_col,
                                 const int* col_val_starts,
                                 const int* row_i,
                                 const double* val_x,
                                 const double* vec,
                                 double alpha,
                                 std::vector<double>& target) {
  const int c_begin = pat_col_starts[pat];
  const int c_end = pat_col_starts[pat + 1];
  for (int c_pos = c_begin; c_pos < c_end; ++c_pos) {
    const int col = active_col[c_pos];
    const int v_begin = col_val_starts[c_pos];
    const int v_end = col_val_starts[c_pos + 1];
    double acc = 0.0;
    for (int idx = v_begin; idx < v_end; ++idx) {
      acc += val_x[idx] * vec[row_i[idx]];
    }
    target[static_cast<size_t>(col)] += alpha * acc;
  }
}


}  // namespace

[[cpp11::register]]
writable::doubles_matrix<> mfrm_cpp_compute_p_geq(doubles_matrix<> probs) {
  const int n = probs.nrow();
  const int k_cat = probs.ncol();
  const int n_steps = k_cat - 1;
  writable::doubles_matrix<> out(n, std::max(n_steps, 0));
  if (n == 0 || n_steps <= 0) {
    return out;
  }

  for (int i = 0; i < n; ++i) {
    out(i, n_steps - 1) = probs(i, k_cat - 1);
  }
  for (int s = n_steps - 2; s >= 0; --s) {
    for (int i = 0; i < n; ++i) {
      out(i, s) = out(i, s + 1) + probs(i, s + 1);
    }
  }

  return out;
}

[[cpp11::register]]
writable::list mfrm_cpp_rsm_logprob_bundle(integers score_k,
                                           integers person_int,
                                           doubles base_eta,
                                           doubles_matrix<> person_nodes,
                                           doubles step_cum,
                                           sexp weight,
                                           bool include_probs) {
  const int n = base_eta.size();
  const int n_nodes = person_nodes.ncol();
  const int k_cat = step_cum.size();
  const bool has_weight = !Rf_isNull(weight);
  doubles weight_vec;
  if (has_weight) {
    weight_vec = as_doubles(weight);
  }

  writable::doubles_matrix<> log_prob_mat(n, n_nodes);
  writable::list prob_list;
  if (include_probs) {
    prob_list = writable::list(n_nodes);
  }

  std::vector<double> log_num(static_cast<size_t>(k_cat));
  std::vector<double> prob_row(static_cast<size_t>(k_cat));
  const ProbabilityRows probability_rows = probability_representatives(
    base_eta, person_nodes, REAL(step_cum), k_cat, false);
  const bool reuse_probabilities = !probability_rows.group.empty();
  std::vector<double> cached_log_num(probability_rows.first.size() * static_cast<size_t>(k_cat));
  std::vector<double> cached_row_max(probability_rows.first.size());
  std::vector<double> cached_log_denom(probability_rows.first.size());

  for (int q = 0; q < n_nodes; ++q) {
    if (include_probs) {
      writable::doubles_matrix<> probs_q(n, k_cat);
      for (int i = 0; i < n; ++i) {
        const int person_row = person_int[i] - 1;
        const int obs_col = score_k[i];
        const int group = reuse_probabilities ? probability_rows.group[i] : 0;
        const int source_row = reuse_probabilities ? probability_rows.first[group] : i;
        if (source_row != i) {
          double lp = (cached_log_num[static_cast<size_t>(group) * k_cat + obs_col] -
                       cached_row_max[group]) - cached_log_denom[group];
          if (has_weight) lp *= weight_vec[i];
          log_prob_mat(i, q) = lp;
          for (int k = 0; k < k_cat; ++k) {
            probs_q(i, k) = probs_q(source_row, k);
          }
          continue;
        }
        const double eta_q = base_eta[i] + person_nodes(person_row, q);
        double row_max = -std::numeric_limits<double>::infinity();

        for (int k = 0; k < k_cat; ++k) {
          const double value = eta_q * static_cast<double>(k) - step_cum[k];
          log_num[static_cast<size_t>(k)] = value;
          if (value > row_max) {
            row_max = value;
          }
        }

        double denom_sum = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double prob = std::exp(log_num[static_cast<size_t>(k)] - row_max);
          prob_row[static_cast<size_t>(k)] = prob;
          denom_sum += prob;
        }
        const double log_denom = std::log(denom_sum);
        if (reuse_probabilities) {
          for (int k = 0; k < k_cat; ++k) {
            cached_log_num[static_cast<size_t>(group) * k_cat + k] = log_num[static_cast<size_t>(k)];
          }
          cached_row_max[group] = row_max;
          cached_log_denom[group] = log_denom;
        }

        double lp = (log_num[static_cast<size_t>(obs_col)] - row_max) - log_denom;
        if (has_weight) {
          lp *= weight_vec[i];
        }
        log_prob_mat(i, q) = lp;
        for (int k = 0; k < k_cat; ++k) {
          probs_q(i, k) = prob_row[static_cast<size_t>(k)] / denom_sum;
        }
      }
      prob_list[q] = probs_q;
    } else {
      for (int i = 0; i < n; ++i) {
        const int person_row = person_int[i] - 1;
        const int obs_col = score_k[i];
        const int group = reuse_probabilities ? probability_rows.group[i] : 0;
        const int source_row = reuse_probabilities ? probability_rows.first[group] : i;
        if (source_row != i) {
          double lp = (cached_log_num[static_cast<size_t>(group) * k_cat + obs_col] -
                       cached_row_max[group]) - cached_log_denom[group];
          if (has_weight) lp *= weight_vec[i];
          log_prob_mat(i, q) = lp;
          continue;
        }
        const double eta_q = base_eta[i] + person_nodes(person_row, q);
        double row_max = -std::numeric_limits<double>::infinity();

        for (int k = 0; k < k_cat; ++k) {
          const double value = eta_q * static_cast<double>(k) - step_cum[k];
          log_num[static_cast<size_t>(k)] = value;
          if (value > row_max) {
            row_max = value;
          }
        }

        double denom_sum = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          denom_sum += std::exp(log_num[static_cast<size_t>(k)] - row_max);
        }
        const double log_denom = std::log(denom_sum);
        if (reuse_probabilities) {
          for (int k = 0; k < k_cat; ++k) {
            cached_log_num[static_cast<size_t>(group) * k_cat + k] = log_num[static_cast<size_t>(k)];
          }
          cached_row_max[group] = row_max;
          cached_log_denom[group] = log_denom;
        }

        double lp = (log_num[static_cast<size_t>(obs_col)] - row_max) - log_denom;
        if (has_weight) {
          lp *= weight_vec[i];
        }
        log_prob_mat(i, q) = lp;
      }
    }
  }

  if (include_probs) {
    return writable::list({
      "log_prob_mat"_nm = log_prob_mat,
      "prob_list"_nm = prob_list
    });
  }

  return writable::list({
    "log_prob_mat"_nm = log_prob_mat
  });
}

[[cpp11::register]]
writable::list mfrm_cpp_pcm_logprob_bundle(integers score_k,
                                           integers person_int,
                                           doubles base_eta,
                                           doubles_matrix<> person_nodes,
                                           doubles_matrix<> step_cum_obs,
                                           sexp weight,
                                           bool include_probs) {
  const int n = base_eta.size();
  const int n_nodes = person_nodes.ncol();
  const int k_cat = step_cum_obs.ncol();
  const bool has_weight = !Rf_isNull(weight);
  doubles weight_vec;
  if (has_weight) {
    weight_vec = as_doubles(weight);
  }

  writable::doubles_matrix<> log_prob_mat(n, n_nodes);
  writable::list prob_list;
  if (include_probs) {
    prob_list = writable::list(n_nodes);
  }

  std::vector<double> log_num(static_cast<size_t>(k_cat));
  std::vector<double> prob_row(static_cast<size_t>(k_cat));
  const ProbabilityRows probability_rows = probability_representatives(
    base_eta, person_nodes, REAL(step_cum_obs), k_cat, true);
  const bool reuse_probabilities = !probability_rows.group.empty();
  std::vector<double> cached_log_num(probability_rows.first.size() * static_cast<size_t>(k_cat));
  std::vector<double> cached_row_max(probability_rows.first.size());
  std::vector<double> cached_log_denom(probability_rows.first.size());

  for (int q = 0; q < n_nodes; ++q) {
    if (include_probs) {
      writable::doubles_matrix<> probs_q(n, k_cat);
      for (int i = 0; i < n; ++i) {
        const int person_row = person_int[i] - 1;
        const int obs_col = score_k[i];
        const int group = reuse_probabilities ? probability_rows.group[i] : 0;
        const int source_row = reuse_probabilities ? probability_rows.first[group] : i;
        if (source_row != i) {
          double lp = (cached_log_num[static_cast<size_t>(group) * k_cat + obs_col] -
                       cached_row_max[group]) - cached_log_denom[group];
          if (has_weight) lp *= weight_vec[i];
          log_prob_mat(i, q) = lp;
          for (int k = 0; k < k_cat; ++k) {
            probs_q(i, k) = probs_q(source_row, k);
          }
          continue;
        }
        const double eta_q = base_eta[i] + person_nodes(person_row, q);
        double row_max = -std::numeric_limits<double>::infinity();

        for (int k = 0; k < k_cat; ++k) {
          const double value = eta_q * static_cast<double>(k) - step_cum_obs(i, k);
          log_num[static_cast<size_t>(k)] = value;
          if (value > row_max) {
            row_max = value;
          }
        }

        double denom_sum = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double prob = std::exp(log_num[static_cast<size_t>(k)] - row_max);
          prob_row[static_cast<size_t>(k)] = prob;
          denom_sum += prob;
        }
        const double log_denom = std::log(denom_sum);
        if (reuse_probabilities) {
          for (int k = 0; k < k_cat; ++k) {
            cached_log_num[static_cast<size_t>(group) * k_cat + k] = log_num[static_cast<size_t>(k)];
          }
          cached_row_max[group] = row_max;
          cached_log_denom[group] = log_denom;
        }

        double lp = (log_num[static_cast<size_t>(obs_col)] - row_max) - log_denom;
        if (has_weight) {
          lp *= weight_vec[i];
        }
        log_prob_mat(i, q) = lp;
        for (int k = 0; k < k_cat; ++k) {
          probs_q(i, k) = prob_row[static_cast<size_t>(k)] / denom_sum;
        }
      }
      prob_list[q] = probs_q;
    } else {
      for (int i = 0; i < n; ++i) {
        const int person_row = person_int[i] - 1;
        const int obs_col = score_k[i];
        const int group = reuse_probabilities ? probability_rows.group[i] : 0;
        const int source_row = reuse_probabilities ? probability_rows.first[group] : i;
        if (source_row != i) {
          double lp = (cached_log_num[static_cast<size_t>(group) * k_cat + obs_col] -
                       cached_row_max[group]) - cached_log_denom[group];
          if (has_weight) lp *= weight_vec[i];
          log_prob_mat(i, q) = lp;
          continue;
        }
        const double eta_q = base_eta[i] + person_nodes(person_row, q);
        double row_max = -std::numeric_limits<double>::infinity();

        for (int k = 0; k < k_cat; ++k) {
          const double value = eta_q * static_cast<double>(k) - step_cum_obs(i, k);
          log_num[static_cast<size_t>(k)] = value;
          if (value > row_max) {
            row_max = value;
          }
        }

        double denom_sum = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          denom_sum += std::exp(log_num[static_cast<size_t>(k)] - row_max);
        }
        const double log_denom = std::log(denom_sum);
        if (reuse_probabilities) {
          for (int k = 0; k < k_cat; ++k) {
            cached_log_num[static_cast<size_t>(group) * k_cat + k] = log_num[static_cast<size_t>(k)];
          }
          cached_row_max[group] = row_max;
          cached_log_denom[group] = log_denom;
        }

        double lp = (log_num[static_cast<size_t>(obs_col)] - row_max) - log_denom;
        if (has_weight) {
          lp *= weight_vec[i];
        }
        log_prob_mat(i, q) = lp;
      }
    }
  }

  if (include_probs) {
    return writable::list({
      "log_prob_mat"_nm = log_prob_mat,
      "prob_list"_nm = prob_list
    });
  }

  return writable::list({
    "log_prob_mat"_nm = log_prob_mat
  });
}

[[cpp11::register]]
writable::list mfrm_cpp_expected_category_bundle(list prob_list,
                                                 doubles_matrix<> obs_posterior,
                                                 bool include_p_geq) {
  const int n_nodes = prob_list.size();
  if (n_nodes == 0) {
    stop("`prob_list` must contain at least one probability matrix.");
  }

  doubles_matrix<> first_prob(prob_list[0]);
  const int n = first_prob.nrow();
  const int k_cat = first_prob.ncol();
  writable::doubles_matrix<> posterior_prob(n, k_cat);
  for (int i = 0; i < n; ++i) {
    for (int k = 0; k < k_cat; ++k) {
      posterior_prob(i, k) = 0.0;
    }
  }

  for (int q = 0; q < n_nodes; ++q) {
    doubles_matrix<> probs_q(prob_list[q]);
    for (int i = 0; i < n; ++i) {
      const double post_q = obs_posterior(i, q);
      for (int k = 0; k < k_cat; ++k) {
        posterior_prob(i, k) += probs_q(i, k) * post_q;
      }
    }
  }

  writable::doubles expected_k(n);
  writable::doubles var_k(n);
  for (int i = 0; i < n; ++i) {
    double first_moment = 0.0;
    for (int k = 0; k < k_cat; ++k) {
      const double p = posterior_prob(i, k);
      first_moment += p * static_cast<double>(k);
    }
    expected_k[i] = first_moment;
    double variance = 0.0;
    for (int k = 0; k < k_cat; ++k) {
      const double centered = static_cast<double>(k) - first_moment;
      variance += posterior_prob(i, k) * centered * centered;
    }
    var_k[i] = variance;
  }

  if (include_p_geq && k_cat > 1) {
    return writable::list({
      "posterior_prob"_nm = posterior_prob,
      "expected_k"_nm = expected_k,
      "var_k"_nm = var_k,
      "p_geq"_nm = build_p_geq(posterior_prob)
    });
  }

  return writable::list({
    "posterior_prob"_nm = posterior_prob,
    "expected_k"_nm = expected_k,
    "var_k"_nm = var_k
  });
}

// Fused fixed-grid MML (and EM M-step) likelihood, posterior, and gradient
// sufficient-statistics kernel for RSM (0), PCM (1), and GPCM (2).
// Eliminates R allocation of per-node n x K probability matrices, linear-part
// matrices, and n x (K-1) P_geq matrices during optimization and optimHess.
[[cpp11::register]]
writable::list mfrm_cpp_mml_eval_bundle(int model_code,
                                        integers score_k,
                                        integers person_int,
                                        doubles base_eta,
                                        doubles_matrix<> person_nodes,
                                        doubles_matrix<> person_log_weights,
                                        doubles step_cum_rsm,
                                        doubles_matrix<> step_cum_mat,
                                        integers step_idx,
                                        doubles slopes,
                                        integers slope_idx,
                                        sexp weight,
                                        sexp external_obs_posterior,
                                        bool include_grad,
                                        bool pop_active,
                                        doubles_matrix<> pop_design_person,
                                        doubles quad_std_nodes,
                                        double sigma_pop) {
  const int n = base_eta.size();
  const int n_nodes = person_nodes.ncol();
  const int k_cat = (model_code == 0) ? step_cum_rsm.size() : step_cum_mat.ncol();
  const int n_steps = std::max(k_cat - 1, 0);
  const int n_criteria = (model_code == 0) ? 1 : step_cum_mat.nrow();
  const int n_slopes = (model_code == 2) ? slopes.size() : 0;
  const bool has_weight = !Rf_isNull(weight);
  const bool has_ext_post = !Rf_isNull(external_obs_posterior);
  doubles weight_vec;
  if (has_weight) weight_vec = as_doubles(weight);
  doubles ext_post_vec;
  const double* ext_post_ptr = nullptr;
  if (has_ext_post) {
    ext_post_vec = as_doubles(external_obs_posterior);
    ext_post_ptr = REAL(ext_post_vec);
  }

  // Build row-major step table for cache-local category traversal.
  std::vector<double> step_rm;
  if (model_code != 0) {
    step_rm.resize(static_cast<size_t>(n_criteria) * k_cat);
    for (int c = 0; c < n_criteria; ++c) {
      for (int k = 0; k < k_cat; ++k) {
        step_rm[static_cast<size_t>(c) * k_cat + k] = step_cum_mat(c, k);
      }
    }
  }
  const double* step_rsm_ptr = (model_code == 0 && k_cat > 0) ? REAL(step_cum_rsm) : nullptr;
  const int* step_idx_ptr = (model_code != 0 && n > 0) ? INTEGER(step_idx) : nullptr;
  const double* slopes_ptr = (model_code == 2 && n_slopes > 0) ? REAL(slopes) : nullptr;
  const int* slope_idx_ptr = (model_code == 2 && n > 0) ? INTEGER(slope_idx) : nullptr;

  // Map person_int (1-based) to first-observed person rows (matching rowsum(..., reorder = FALSE)).
  const int n_person_rows = person_nodes.nrow();
  std::vector<int> person_to_row(static_cast<size_t>(n_person_rows), -1);
  std::vector<int> person_ids_vec;
  person_ids_vec.reserve(static_cast<size_t>(n_person_rows));
  std::vector<int> obs_person_row(static_cast<size_t>(n), 0);
  if (!has_ext_post) {
    for (int i = 0; i < n; ++i) {
      const int p_id = person_int[i];
      int r = person_to_row[static_cast<size_t>(p_id - 1)];
      if (r < 0) {
        r = static_cast<int>(person_ids_vec.size());
        person_to_row[static_cast<size_t>(p_id - 1)] = r;
        person_ids_vec.push_back(p_id);
      }
      obs_person_row[static_cast<size_t>(i)] = r;
    }
  }
  const int n_active_persons = static_cast<int>(person_ids_vec.size());

  const ProbabilityRows rep_rows = probability_representatives_indexed(
    model_code, base_eta, person_nodes, step_rsm_ptr, step_rm, n_criteria,
    step_idx_ptr, slopes_ptr, n_slopes, slope_idx_ptr, k_cat);
  const bool reuse_rep = !rep_rows.group.empty();
  const size_t n_rep = rep_rows.first.size();

  // When representative deduplication applies, precompute category log-probs,
  // expected category, cumulative P_geq, and (for GPCM) category slope contrasts
  // across the G * Q unique pairs once.
  std::vector<double> rep_lp;
  std::vector<double> rep_expected;
  std::vector<double> rep_p_geq;
  std::vector<double> rep_slope_contrast;
  std::vector<double> linear_buf(static_cast<size_t>(k_cat));
  std::vector<double> log_num_buf(static_cast<size_t>(k_cat));
  std::vector<double> prob_buf(static_cast<size_t>(k_cat));
  std::vector<double> pgeq_buf(static_cast<size_t>(std::max(n_steps, 1)));

  if (reuse_rep) {
    rep_lp.resize(n_rep * static_cast<size_t>(n_nodes) * k_cat);
    if (include_grad) {
      rep_expected.resize(n_rep * static_cast<size_t>(n_nodes));
      if (n_steps > 0) {
        rep_p_geq.resize(n_rep * static_cast<size_t>(n_nodes) * n_steps);
      }
      if (model_code == 2) {
        rep_slope_contrast.resize(n_rep * static_cast<size_t>(n_nodes) * k_cat);
      }
    }
    for (int q = 0; q < n_nodes; ++q) {
      const double node_q = person_nodes(0, q);
      for (size_t g = 0; g < n_rep; ++g) {
        const int i0 = rep_rows.first[g];
        const double eta_q = base_eta[i0] + node_q;
        const double sl = (model_code == 2) ? slopes_ptr[slope_idx_ptr[i0] - 1] : 1.0;
        const double* st_ptr = (model_code == 0)
          ? step_rsm_ptr
          : (step_rm.data() + static_cast<size_t>(step_idx_ptr[i0] - 1) * k_cat);

        double row_max = -std::numeric_limits<double>::infinity();
        for (int k = 0; k < k_cat; ++k) {
          const double lin = eta_q * static_cast<double>(k) - st_ptr[k];
          const double val = (model_code == 2) ? (lin * sl) : lin;
          linear_buf[static_cast<size_t>(k)] = lin;
          log_num_buf[static_cast<size_t>(k)] = val;
          if (val > row_max) row_max = val;
        }
        double denom_sum = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double e = std::exp(log_num_buf[static_cast<size_t>(k)] - row_max);
          prob_buf[static_cast<size_t>(k)] = e;
          denom_sum += e;
        }
        const double log_denom = std::log(denom_sum);
        const size_t gq = g * static_cast<size_t>(n_nodes) + static_cast<size_t>(q);
        double* lp_dst = rep_lp.data() + gq * k_cat;
        for (int k = 0; k < k_cat; ++k) {
          lp_dst[k] = (log_num_buf[static_cast<size_t>(k)] - row_max) - log_denom;
        }
        if (include_grad) {
          double expected = 0.0;
          for (int k = 0; k < k_cat; ++k) {
            prob_buf[static_cast<size_t>(k)] /= denom_sum;
            expected += prob_buf[static_cast<size_t>(k)] * static_cast<double>(k);
          }
          rep_expected[gq] = expected;
          if (n_steps > 0) {
            double* pg_dst = rep_p_geq.data() + gq * n_steps;
            pg_dst[n_steps - 1] = prob_buf[static_cast<size_t>(k_cat - 1)];
            for (int s = n_steps - 2; s >= 0; --s) {
              pg_dst[s] = pg_dst[s + 1] + prob_buf[static_cast<size_t>(s + 1)];
            }
          }
          if (model_code == 2) {
            double* sc_dst = rep_slope_contrast.data() + gq * k_cat;
            for (int c = 0; c < k_cat; ++c) {
              const double obs_lin = linear_buf[static_cast<size_t>(c)];
              double acc = 0.0;
              for (int k = 0; k < k_cat; ++k) {
                acc += prob_buf[static_cast<size_t>(k)] * (obs_lin - linear_buf[static_cast<size_t>(k)]);
              }
              sc_dst[c] = sl * acc;
            }
          }
        }
      }
    }
  }

  // Pass 1: accumulate person log-likelihoods (or complete-data objective for EM M-step).
  double neg_loglik = 0.0;
  std::vector<double> ll_by_person;
  if (!has_ext_post) {
    ll_by_person.assign(static_cast<size_t>(n_active_persons) * n_nodes, 0.0);
  }

  for (int q = 0; q < n_nodes; ++q) {
    if (reuse_rep) {
      for (int i = 0; i < n; ++i) {
        const size_t g = static_cast<size_t>(rep_rows.group[static_cast<size_t>(i)]);
        const size_t gq = g * static_cast<size_t>(n_nodes) + static_cast<size_t>(q);
        double lp = rep_lp[gq * k_cat + static_cast<size_t>(score_k[i])];
        if (has_weight) lp *= weight_vec[i];
        if (has_ext_post) {
          neg_loglik -= lp * ext_post_ptr[static_cast<size_t>(q) * n + i];
        } else {
          const int r = obs_person_row[static_cast<size_t>(i)];
          ll_by_person[static_cast<size_t>(r) * n_nodes + q] += lp;
        }
      }
    } else {
      for (int i = 0; i < n; ++i) {
        const int p_row = person_int[i] - 1;
        const double eta_q = base_eta[i] + person_nodes(p_row, q);
        const double sl = (model_code == 2) ? slopes_ptr[slope_idx_ptr[i] - 1] : 1.0;
        const double* st_ptr = (model_code == 0)
          ? step_rsm_ptr
          : (step_rm.data() + static_cast<size_t>(step_idx_ptr[i] - 1) * k_cat);

        double row_max = -std::numeric_limits<double>::infinity();
        for (int k = 0; k < k_cat; ++k) {
          const double lin = eta_q * static_cast<double>(k) - st_ptr[k];
          const double val = (model_code == 2) ? (lin * sl) : lin;
          log_num_buf[static_cast<size_t>(k)] = val;
          if (val > row_max) row_max = val;
        }
        double denom_sum = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          denom_sum += std::exp(log_num_buf[static_cast<size_t>(k)] - row_max);
        }
        double lp = (log_num_buf[static_cast<size_t>(score_k[i])] - row_max) - std::log(denom_sum);
        if (has_weight) lp *= weight_vec[i];
        if (has_ext_post) {
          neg_loglik -= lp * ext_post_ptr[static_cast<size_t>(q) * n + i];
        } else {
          const int r = obs_person_row[static_cast<size_t>(i)];
          ll_by_person[static_cast<size_t>(r) * n_nodes + q] += lp;
        }
      }
    }
  }

  writable::doubles log_marginal_out(has_ext_post ? 0 : n_active_persons);
  writable::integers person_ids_out(has_ext_post ? 0 : n_active_persons);
  std::vector<double> posterior_flat;
  if (!has_ext_post) {
    if (include_grad) {
      posterior_flat.resize(static_cast<size_t>(n_active_persons) * n_nodes);
    }
    std::vector<double> shifted_row(static_cast<size_t>(n_nodes));
    for (int r = 0; r < n_active_persons; ++r) {
      person_ids_out[r] = person_ids_vec[static_cast<size_t>(r)];
      const int p_id0 = person_ids_vec[static_cast<size_t>(r)] - 1;
      const double* ll_row = ll_by_person.data() + static_cast<size_t>(r) * n_nodes;

      double offset = -std::numeric_limits<double>::infinity();
      for (int q = 0; q < n_nodes; ++q) {
        if (ll_row[q] > offset) offset = ll_row[q];
      }
      double r_max = -std::numeric_limits<double>::infinity();
      for (int q = 0; q < n_nodes; ++q) {
        const double sh = (ll_row[q] - offset) + person_log_weights(p_id0, q);
        shifted_row[static_cast<size_t>(q)] = sh;
        if (sh > r_max) r_max = sh;
      }
      double sum_exp = 0.0;
      for (int q = 0; q < n_nodes; ++q) {
        shifted_row[static_cast<size_t>(q)] -= r_max;
        sum_exp += std::exp(shifted_row[static_cast<size_t>(q)]);
      }
      const double log_norm = std::log(sum_exp);
      const double lm = offset + (r_max + log_norm);
      log_marginal_out[r] = lm;
      neg_loglik -= lm;
      if (include_grad) {
        double* post_row = posterior_flat.data() + static_cast<size_t>(r) * n_nodes;
        for (int q = 0; q < n_nodes; ++q) {
          post_row[q] = std::exp(shifted_row[static_cast<size_t>(q)] - log_norm);
        }
      }
    }
  }

  if (!include_grad) {
    return writable::list({
      "value"_nm = neg_loglik,
      "log_marginal"_nm = log_marginal_out,
      "person_ids"_nm = person_ids_out
    });
  }

  // Pass 2: accumulate gradient sufficient statistics in identical q-first order.
  writable::doubles marginal_residual(n);
  for (int i = 0; i < n; ++i) marginal_residual[i] = 0.0;

  writable::doubles_matrix<> grad_step_mat(n_criteria, n_steps);
  for (int c = 0; c < n_criteria; ++c) {
    for (int s = 0; s < n_steps; ++s) {
      grad_step_mat(c, s) = 0.0;
    }
  }
  std::vector<double> marginal_step_residual;
  if (model_code != 0 && n_steps > 0) {
    marginal_step_residual.assign(static_cast<size_t>(n) * n_steps, 0.0);
  }

  writable::doubles grad_log_slope_exp(n_slopes);
  for (int s = 0; s < n_slopes; ++s) grad_log_slope_exp[s] = 0.0;
  std::vector<double> marginal_slope_score;
  if (model_code == 2) {
    marginal_slope_score.assign(static_cast<size_t>(n), 0.0);
  }

  const bool do_pop = pop_active && !has_ext_post;
  const int n_beta = do_pop ? pop_design_person.ncol() : 0;
  writable::doubles grad_beta(n_beta);
  for (int b = 0; b < n_beta; ++b) grad_beta[b] = 0.0;
  double grad_log_sigma2 = 0.0;
  std::vector<double> person_score_q(do_pop ? static_cast<size_t>(n_active_persons) : 0);

  for (int q = 0; q < n_nodes; ++q) {
    if (do_pop) {
      std::fill(person_score_q.begin(), person_score_q.end(), 0.0);
    }
    std::vector<double> rsm_step_q(model_code == 0 ? static_cast<size_t>(n_steps) : 0, 0.0);

    if (reuse_rep) {
      for (int i = 0; i < n; ++i) {
        const size_t g = static_cast<size_t>(rep_rows.group[static_cast<size_t>(i)]);
        const size_t gq = g * static_cast<size_t>(n_nodes) + static_cast<size_t>(q);
        const int y = score_k[i];
        const double sl = (model_code == 2) ? slopes_ptr[slope_idx_ptr[i] - 1] : 1.0;
        const double w = has_weight ? weight_vec[i] : 1.0;

        double res_q = (model_code == 2)
          ? (sl * (static_cast<double>(y) - rep_expected[gq]))
          : (static_cast<double>(y) - rep_expected[gq]);
        if (has_weight) res_q *= w;

        const double post_iq = has_ext_post
          ? ext_post_ptr[static_cast<size_t>(q) * n + i]
          : posterior_flat[static_cast<size_t>(obs_person_row[static_cast<size_t>(i)]) * n_nodes + q];

        if (do_pop) {
          person_score_q[static_cast<size_t>(obs_person_row[static_cast<size_t>(i)])] += res_q;
        }
        marginal_residual[i] += res_q * post_iq;

        if (n_steps > 0) {
          const double* pg = rep_p_geq.data() + gq * n_steps;
          if (model_code == 0) {
            const double scale_step = has_weight ? (post_iq * w) : post_iq;
            for (int s = 0; s < n_steps; ++s) {
              const double ind = (y >= (s + 1)) ? 1.0 : 0.0;
              rsm_step_q[static_cast<size_t>(s)] += (pg[s] - ind) * scale_step;
            }
          } else {
            double scale_step = (model_code == 2) ? (sl * post_iq) : post_iq;
            if (has_weight) scale_step *= w;
            double* msr = marginal_step_residual.data() + static_cast<size_t>(i) * n_steps;
            for (int s = 0; s < n_steps; ++s) {
              const double ind = (y >= (s + 1)) ? 1.0 : 0.0;
              msr[s] += (pg[s] - ind) * scale_step;
            }
          }
        }

        if (model_code == 2) {
          double sc = rep_slope_contrast[gq * k_cat + static_cast<size_t>(y)] * post_iq;
          if (has_weight) sc *= w;
          marginal_slope_score[static_cast<size_t>(i)] += sc;
        }
      }
    } else {
      for (int i = 0; i < n; ++i) {
        const int p_row = person_int[i] - 1;
        const int y = score_k[i];
        const double eta_q = base_eta[i] + person_nodes(p_row, q);
        const double sl = (model_code == 2) ? slopes_ptr[slope_idx_ptr[i] - 1] : 1.0;
        const double w = has_weight ? weight_vec[i] : 1.0;
        const double* st_ptr = (model_code == 0)
          ? step_rsm_ptr
          : (step_rm.data() + static_cast<size_t>(step_idx_ptr[i] - 1) * k_cat);

        double row_max = -std::numeric_limits<double>::infinity();
        for (int k = 0; k < k_cat; ++k) {
          const double lin = eta_q * static_cast<double>(k) - st_ptr[k];
          const double val = (model_code == 2) ? (lin * sl) : lin;
          linear_buf[static_cast<size_t>(k)] = lin;
          log_num_buf[static_cast<size_t>(k)] = val;
          if (val > row_max) row_max = val;
        }
        double denom_sum = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double e = std::exp(log_num_buf[static_cast<size_t>(k)] - row_max);
          prob_buf[static_cast<size_t>(k)] = e;
          denom_sum += e;
        }
        double expected = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          prob_buf[static_cast<size_t>(k)] /= denom_sum;
          expected += prob_buf[static_cast<size_t>(k)] * static_cast<double>(k);
        }

        double res_q = (model_code == 2)
          ? (sl * (static_cast<double>(y) - expected))
          : (static_cast<double>(y) - expected);
        if (has_weight) res_q *= w;

        const double post_iq = has_ext_post
          ? ext_post_ptr[static_cast<size_t>(q) * n + i]
          : posterior_flat[static_cast<size_t>(obs_person_row[static_cast<size_t>(i)]) * n_nodes + q];

        if (do_pop) {
          person_score_q[static_cast<size_t>(obs_person_row[static_cast<size_t>(i)])] += res_q;
        }
        marginal_residual[i] += res_q * post_iq;

        if (n_steps > 0) {
          pgeq_buf[static_cast<size_t>(n_steps - 1)] = prob_buf[static_cast<size_t>(k_cat - 1)];
          for (int s = n_steps - 2; s >= 0; --s) {
            pgeq_buf[static_cast<size_t>(s)] = pgeq_buf[static_cast<size_t>(s + 1)] +
                                               prob_buf[static_cast<size_t>(s + 1)];
          }
          if (model_code == 0) {
            const double scale_step = has_weight ? (post_iq * w) : post_iq;
            for (int s = 0; s < n_steps; ++s) {
              const double ind = (y >= (s + 1)) ? 1.0 : 0.0;
              rsm_step_q[static_cast<size_t>(s)] += (pgeq_buf[static_cast<size_t>(s)] - ind) * scale_step;
            }
          } else {
            double scale_step = (model_code == 2) ? (sl * post_iq) : post_iq;
            if (has_weight) scale_step *= w;
            double* msr = marginal_step_residual.data() + static_cast<size_t>(i) * n_steps;
            for (int s = 0; s < n_steps; ++s) {
              const double ind = (y >= (s + 1)) ? 1.0 : 0.0;
              msr[s] += (pgeq_buf[static_cast<size_t>(s)] - ind) * scale_step;
            }
          }
        }

        if (model_code == 2) {
          const double obs_lin = linear_buf[static_cast<size_t>(y)];
          double acc = 0.0;
          for (int k = 0; k < k_cat; ++k) {
            acc += prob_buf[static_cast<size_t>(k)] * (obs_lin - linear_buf[static_cast<size_t>(k)]);
          }
          double sc = sl * acc * post_iq;
          if (has_weight) sc *= w;
          marginal_slope_score[static_cast<size_t>(i)] += sc;
        }
      }
    }

    if (model_code == 0) {
      for (int s = 0; s < n_steps; ++s) {
        grad_step_mat(0, s) += rsm_step_q[static_cast<size_t>(s)];
      }
    }

    if (do_pop) {
      double sum_sigma_q = 0.0;
      const double z_q = quad_std_nodes[q];
      for (int r = 0; r < n_active_persons; ++r) {
        const double w_pq = posterior_flat[static_cast<size_t>(r) * n_nodes + q] *
                            person_score_q[static_cast<size_t>(r)];
        const int p_id0 = person_ids_vec[static_cast<size_t>(r)] - 1;
        for (int b = 0; b < n_beta; ++b) {
          grad_beta[b] += pop_design_person(p_id0, b) * w_pq;
        }
        sum_sigma_q += w_pq * z_q;
      }
      grad_log_sigma2 += sum_sigma_q * (0.5 * sigma_pop);
    }
  }

  if (model_code != 0 && n_steps > 0) {
    for (int i = 0; i < n; ++i) {
      const int c = step_idx_ptr[i] - 1;
      const double* msr = marginal_step_residual.data() + static_cast<size_t>(i) * n_steps;
      for (int s = 0; s < n_steps; ++s) {
        grad_step_mat(c, s) += msr[s];
      }
    }
  }
  if (model_code == 2) {
    for (int i = 0; i < n; ++i) {
      const int sl_i = slope_idx_ptr[i] - 1;
      grad_log_slope_exp[sl_i] += marginal_slope_score[static_cast<size_t>(i)];
    }
  }

  return writable::list({
    "value"_nm = neg_loglik,
    "log_marginal"_nm = log_marginal_out,
    "person_ids"_nm = person_ids_out,
    "marginal_residual"_nm = marginal_residual,
    "grad_step_mat"_nm = grad_step_mat,
    "grad_log_slope_exp"_nm = grad_log_slope_exp,
    "grad_beta"_nm = grad_beta,
    "grad_log_sigma2"_nm = grad_log_sigma2
  });
}

[[cpp11::register]]
writable::doubles mfrm_cpp_indexed_sum(doubles x,
                                       integers idx,
                                       int n_levels,
                                       double scale) {
  const int n = x.size();
  writable::doubles out(n_levels);
  for (int l = 0; l < n_levels; ++l) out[l] = 0.0;
  if (scale == 1.0) {
    for (int i = 0; i < n; ++i) {
      out[idx[i] - 1] += x[i];
    }
  } else if (scale == -1.0) {
    for (int i = 0; i < n; ++i) {
      out[idx[i] - 1] -= x[i];
    }
  } else {
    for (int i = 0; i < n; ++i) {
      out[idx[i] - 1] += scale * x[i];
    }
  }
  return out;
}


[[cpp11::register]]
writable::list mfrm_cpp_adaptive_quad_basis(int model_code,
                                            int k_cat,
                                            integers persons,
                                            integers group_starts,
                                            integers group_rows,
                                            integers score_k,
                                            doubles weights,
                                            doubles base_eta,
                                            doubles step_cum_rsm,
                                            doubles_matrix<> step_cum_mat,
                                            integers step_idx,
                                            doubles slopes,
                                            integers slope_idx,
                                            doubles mu,
                                            double sigma,
                                            doubles quad_nodes,
                                            doubles log_quad_weights,
                                            doubles log_dnorm_quad_nodes,
                                            doubles_matrix<> init_nodes,
                                            doubles_matrix<> init_log_weights) {
  const int n_groups = persons.size();
  const int n_nodes = quad_nodes.size();
  const int n_person_total = init_nodes.nrow();
  const int n_criteria = (model_code == 0) ? 1 : step_cum_mat.nrow();

  writable::doubles_matrix<> out_nodes(n_person_total, n_nodes);
  writable::doubles_matrix<> out_log_weights(n_person_total, n_nodes);
  for (int p = 0; p < n_person_total; ++p) {
    for (int q = 0; q < n_nodes; ++q) {
      out_nodes(p, q) = init_nodes(p, q);
      out_log_weights(p, q) = init_log_weights(p, q);
    }
  }

  std::vector<double> step_rm;
  if (model_code != 0) {
    step_rm.resize(static_cast<size_t>(n_criteria) * k_cat);
    for (int c = 0; c < n_criteria; ++c) {
      for (int k = 0; k < k_cat; ++k) {
        step_rm[static_cast<size_t>(c) * k_cat + k] = step_cum_mat(c, k);
      }
    }
  }
  const double* step_rsm_ptr = (model_code == 0 && k_cat > 0) ? REAL(step_cum_rsm) : nullptr;

  std::vector<double> base_sub;
  std::vector<int> score_sub;
  std::vector<double> weight_sub;
  std::vector<double> slope_sub;
  std::vector<int> step_sub;
  std::vector<double> log_num_buf(static_cast<size_t>(k_cat));
  std::vector<double> prob_buf(static_cast<size_t>(k_cat));

  for (int g = 0; g < n_groups; ++g) {
    const int p_id0 = persons[g] - 1;
    const int r_begin = group_starts[g];
    const int r_end = group_starts[g + 1];
    const int m_obs = r_end - r_begin;

    base_sub.resize(static_cast<size_t>(m_obs));
    score_sub.resize(static_cast<size_t>(m_obs));
    weight_sub.resize(static_cast<size_t>(m_obs));
    if (model_code != 0) step_sub.resize(static_cast<size_t>(m_obs));
    if (model_code == 2) slope_sub.resize(static_cast<size_t>(m_obs));

    for (int j = 0; j < m_obs; ++j) {
      const int obs = group_rows[r_begin + j] - 1;
      base_sub[static_cast<size_t>(j)] = base_eta[obs];
      score_sub[static_cast<size_t>(j)] = score_k[obs];
      weight_sub[static_cast<size_t>(j)] = weights[obs];
      if (model_code != 0) step_sub[static_cast<size_t>(j)] = step_idx[obs];
      if (model_code == 2) {
        const double sl = slopes[slope_idx[obs] - 1];
        if (!std::isfinite(sl) || sl <= 0.0) {
          return writable::list({
            "error_code"_nm = 3,
            "error_message"_nm = std::string("The retained slopes are not positive finite values.")
          });
        }
        slope_sub[static_cast<size_t>(j)] = sl;
      }
    }

    const AdaptiveModeResult loc = find_adaptive_posterior_mode(
      mu[p_id0], sigma, m_obs, k_cat, model_code,
      base_sub.data(), score_sub.data(), weight_sub.data(),
      model_code == 2 ? slope_sub.data() : nullptr,
      step_rsm_ptr, step_rm.data(),
      model_code != 0 ? step_sub.data() : nullptr,
      log_num_buf, prob_buf);

    if (loc.error_code != 0) {
      return writable::list({
        "error_code"_nm = loc.error_code,
        "error_message"_nm = loc.error_message
      });
    }

    const double log_scale = std::log(loc.scale);
    for (int q = 0; q < n_nodes; ++q) {
      const double z_q = loc.mode + loc.scale * quad_nodes[q];
      out_nodes(p_id0, q) = mu[p_id0] + sigma * z_q;
      out_log_weights(p_id0, q) = log_quad_weights[q] +
                                  Rf_dnorm4(z_q, 0.0, 1.0, 1) -
                                  log_dnorm_quad_nodes[q] +
                                  log_scale;
    }
  }

  return writable::list({
    "error_code"_nm = 0,
    "error_message"_nm = std::string(""),
    "nodes"_nm = out_nodes,
    "log_weights"_nm = out_log_weights
  });
}

[[cpp11::register]]
writable::list mfrm_cpp_adaptive_mml_eval(int model_code,
                                          int k_cat,
                                          int p_dim,
                                          integers pat_person_ids,
                                          doubles pat_multiplicity,
                                          integers pat_row_starts,
                                          integers pat_obs_idx,
                                          integers score_k,
                                          doubles weights,
                                          doubles base_eta,
                                          doubles step_cum_rsm,
                                          doubles_matrix<> step_cum_mat,
                                          integers step_idx,
                                          doubles slopes,
                                          integers slope_idx,
                                          doubles mu,
                                          double sigma,
                                          doubles rule_nodes,
                                          doubles log_rule_weights,
                                          doubles log_dnorm_rule_nodes,
                                          integers cum_pat_col_starts,
                                          integers cum_active_col,
                                          integers cum_col_val_starts,
                                          integers cum_row_i,
                                          doubles cum_val_x,
                                          bool has_log_slopes,
                                          integers ls_pat_col_starts,
                                          integers ls_active_col,
                                          integers ls_col_val_starts,
                                          integers ls_row_i,
                                          doubles ls_val_x,
                                          integers beta_cols0,
                                          doubles_matrix<> pat_pop_design,
                                          int log_sigma2_col0,
                                          bool include_person_summaries) {
  const int n_pat = pat_person_ids.size();
  const int n_nodes = rule_nodes.size();
  const int n_steps = k_cat - 1;
  const int n_criteria = (model_code == 0) ? 1 : step_cum_mat.nrow();
  const int n_beta = beta_cols0.size();

  std::vector<double> step_rm;
  if (model_code != 0) {
    step_rm.resize(static_cast<size_t>(n_criteria) * k_cat);
    for (int c = 0; c < n_criteria; ++c) {
      for (int k = 0; k < k_cat; ++k) {
        step_rm[static_cast<size_t>(c) * k_cat + k] = step_cum_mat(c, k);
      }
    }
  }
  const double* step_rsm_ptr = (model_code == 0 && k_cat > 0) ? REAL(step_cum_rsm) : nullptr;
  const int* cum_pcs = INTEGER(cum_pat_col_starts);
  const int* cum_ac = cum_active_col.size() > 0 ? INTEGER(cum_active_col) : nullptr;
  const int* cum_cvs = INTEGER(cum_col_val_starts);
  const int* cum_ri = cum_row_i.size() > 0 ? INTEGER(cum_row_i) : nullptr;
  const double* cum_vx = cum_val_x.size() > 0 ? REAL(cum_val_x) : nullptr;

  const int* ls_pcs = INTEGER(ls_pat_col_starts);
  const int* ls_ac = ls_active_col.size() > 0 ? INTEGER(ls_active_col) : nullptr;
  const int* ls_cvs = INTEGER(ls_col_val_starts);
  const int* ls_ri = ls_row_i.size() > 0 ? INTEGER(ls_row_i) : nullptr;
  const double* ls_vx = ls_val_x.size() > 0 ? REAL(ls_val_x) : nullptr;

  double value = 0.0;
  std::vector<double> gradient(static_cast<size_t>(p_dim), 0.0);
  writable::doubles_matrix<> pat_summaries(include_person_summaries ? n_pat : 0,
                                           include_person_summaries ? 3 : 0);

  std::vector<double> base_sub;
  std::vector<int> score_sub;
  std::vector<double> weight_sub;
  std::vector<double> slope_sub;
  std::vector<int> step_sub;

  std::vector<double> log_num_buf(static_cast<size_t>(k_cat));
  std::vector<double> prob_buf(static_cast<size_t>(k_cat));
  std::vector<double> mode_prob;
  std::vector<double> mode_linear;
  std::vector<double> mode_expected;
  std::vector<double> mode_variance;

  std::vector<double> vec_cum;
  std::vector<double> vec_ls;
  std::vector<double> mixed(static_cast<size_t>(p_dim));
  std::vector<double> curv_deriv(static_cast<size_t>(p_dim));
  std::vector<double> mode_deriv(static_cast<size_t>(p_dim));
  std::vector<double> log_scale_deriv(static_cast<size_t>(p_dim));
  std::vector<double> fixed_deriv(static_cast<size_t>(p_dim));

  std::vector<double> z_nodes(static_cast<size_t>(n_nodes));
  std::vector<double> node_ll(static_cast<size_t>(n_nodes));
  std::vector<double> node_score(static_cast<size_t>(n_nodes));
  std::vector<double> joint(static_cast<size_t>(n_nodes));
  std::vector<double> posterior(static_cast<size_t>(n_nodes));
  std::vector<double> node_probs_all;
  std::vector<double> node_linear_all;
  std::vector<double> residual_mean;
  std::vector<double> slope_mean;

  const double inv_sigma2 = 1.0 / (sigma * sigma);

  for (int pat = 0; pat < n_pat; ++pat) {
    const int p_id0 = pat_person_ids[pat] - 1;
    const double mult = pat_multiplicity[pat];
    const double mu_p = mu[p_id0];
    const int r_begin = pat_row_starts[pat];
    const int r_end = pat_row_starts[pat + 1];
    const int m_obs = r_end - r_begin;

    base_sub.resize(static_cast<size_t>(m_obs));
    score_sub.resize(static_cast<size_t>(m_obs));
    weight_sub.resize(static_cast<size_t>(m_obs));
    slope_sub.resize(static_cast<size_t>(m_obs));
    if (model_code != 0) step_sub.resize(static_cast<size_t>(m_obs));

    for (int r = 0; r < m_obs; ++r) {
      const int obs = pat_obs_idx[r_begin + r] - 1;
      base_sub[static_cast<size_t>(r)] = base_eta[obs];
      score_sub[static_cast<size_t>(r)] = score_k[obs];
      weight_sub[static_cast<size_t>(r)] = weights[obs];
      if (model_code != 0) step_sub[static_cast<size_t>(r)] = step_idx[obs];
      if (model_code == 2) {
        const double sl = slopes[slope_idx[obs] - 1];
        if (!std::isfinite(sl) || sl <= 0.0) {
          return writable::list({
            "error_code"_nm = 3,
            "error_message"_nm = std::string("The retained slopes are not positive finite values.")
          });
        }
        slope_sub[static_cast<size_t>(r)] = sl;
      } else {
        slope_sub[static_cast<size_t>(r)] = 1.0;
      }
    }

    const AdaptiveModeResult loc = find_adaptive_posterior_mode(
      mu_p, sigma, m_obs, k_cat, model_code,
      base_sub.data(), score_sub.data(), weight_sub.data(),
      model_code == 2 ? slope_sub.data() : nullptr,
      step_rsm_ptr, step_rm.data(),
      model_code != 0 ? step_sub.data() : nullptr,
      log_num_buf, prob_buf);

    if (loc.error_code != 0) {
      return writable::list({
        "error_code"_nm = loc.error_code,
        "error_message"_nm = loc.error_message
      });
    }

    const double mode = loc.mode;
    const double scale = loc.scale;

    // Evaluate mode probabilities, linear parts, moments, and third moment.
    mode_prob.resize(static_cast<size_t>(m_obs) * k_cat);
    mode_linear.resize(static_cast<size_t>(m_obs) * k_cat);
    mode_expected.resize(static_cast<size_t>(m_obs));
    mode_variance.resize(static_cast<size_t>(m_obs));
    const double theta_mode = mu_p + sigma * mode;
    double mode_info_sum = 0.0;
    double curvature_theta = 0.0;

    for (int r = 0; r < m_obs; ++r) {
      const double eta = base_sub[static_cast<size_t>(r)] + theta_mode;
      const double sl = slope_sub[static_cast<size_t>(r)];
      const double w = weight_sub[static_cast<size_t>(r)];
      const double* st_ptr = (model_code == 0)
        ? step_rsm_ptr
        : (step_rm.data() + static_cast<size_t>(step_sub[static_cast<size_t>(r)] - 1) * k_cat);

      double row_max = -std::numeric_limits<double>::infinity();
      for (int k = 0; k < k_cat; ++k) {
        const double lin = eta * static_cast<double>(k) - st_ptr[k];
        const double val = (model_code == 2) ? (lin * sl) : lin;
        mode_linear[static_cast<size_t>(r) * k_cat + k] = lin;
        log_num_buf[static_cast<size_t>(k)] = val;
        if (val > row_max) row_max = val;
      }
      double denom = 0.0;
      for (int k = 0; k < k_cat; ++k) {
        const double e = std::exp(log_num_buf[static_cast<size_t>(k)] - row_max);
        prob_buf[static_cast<size_t>(k)] = e;
        denom += e;
      }
      double exp_r = 0.0;
      for (int k = 0; k < k_cat; ++k) {
        const double p_rk = prob_buf[static_cast<size_t>(k)] / denom;
        mode_prob[static_cast<size_t>(r) * k_cat + k] = p_rk;
        exp_r += p_rk * static_cast<double>(k);
      }
      mode_expected[static_cast<size_t>(r)] = exp_r;
      double var_r = 0.0;
      double m3_r = 0.0;
      for (int k = 0; k < k_cat; ++k) {
        const double c_rk = static_cast<double>(k) - exp_r;
        const double c2 = c_rk * c_rk;
        const double p_rk = mode_prob[static_cast<size_t>(r) * k_cat + k];
        var_r += p_rk * c2;
        m3_r += p_rk * c2 * c_rk;
      }
      mode_variance[static_cast<size_t>(r)] = var_r;
      mode_info_sum += (w * sl * sl) * var_r;
      curvature_theta += (w * sl * sl * sl) * m3_r;
    }
    const double at_mode_information = sigma * sigma * mode_info_sum + 1.0;
    const double curvature = at_mode_information * inv_sigma2;

    vec_cum.resize(static_cast<size_t>(m_obs) * std::max(n_steps, 0));
    vec_ls.resize(static_cast<size_t>(m_obs));

    // mixed = -project(prob * centered * (w * slope), linear) +
    //         crossprod(log_slope, w * slope * (score_k - expected)) +
    //         mean_derivative / sigma^2 + (mode / sigma) * variance_derivative
    std::fill(mixed.begin(), mixed.end(), 0.0);
    for (int r = 0; r < m_obs; ++r) {
      const double ws = weight_sub[static_cast<size_t>(r)] * slope_sub[static_cast<size_t>(r)];
      const double sl = slope_sub[static_cast<size_t>(r)];
      const double exp_r = mode_expected[static_cast<size_t>(r)];
      for (int k = 1; k < k_cat; ++k) {
        const double coeff = mode_prob[static_cast<size_t>(r) * k_cat + k] *
                             (static_cast<double>(k) - exp_r) * ws;
        vec_cum[static_cast<size_t>(k - 1) * m_obs + r] = coeff * sl;
      }
    }
    if (n_steps > 0 && cum_ac != nullptr) {
      sparse_crossprod_add(pat, cum_pcs, cum_ac, cum_cvs, cum_ri, cum_vx,
                           vec_cum.data(), -1.0, mixed);
    }
    if (has_log_slopes && ls_ac != nullptr) {
      for (int r = 0; r < m_obs; ++r) {
        const double ws = weight_sub[static_cast<size_t>(r)] * slope_sub[static_cast<size_t>(r)];
        const double sl = slope_sub[static_cast<size_t>(r)];
        const double exp_r = mode_expected[static_cast<size_t>(r)];
        double dot_lin = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double coeff = mode_prob[static_cast<size_t>(r) * k_cat + k] *
                               (static_cast<double>(k) - exp_r) * ws;
          dot_lin += coeff * mode_linear[static_cast<size_t>(r) * k_cat + k];
        }
        // Combine -project's log_slope term with +crossprod(log_slope, w * slope * (y - expected))
        vec_ls[static_cast<size_t>(r)] =
          -dot_lin * sl + ws * (static_cast<double>(score_sub[static_cast<size_t>(r)]) - exp_r);
      }
      sparse_crossprod_add(pat, ls_pcs, ls_ac, ls_cvs, ls_ri, ls_vx,
                           vec_ls.data(), 1.0, mixed);
    }
    for (int b = 0; b < n_beta; ++b) {
      mixed[static_cast<size_t>(beta_cols0[b])] += pat_pop_design(pat, b) * inv_sigma2;
    }
    if (log_sigma2_col0 >= 0) {
      mixed[static_cast<size_t>(log_sigma2_col0)] += mode / sigma;
    }

    // curvature_derivative = project(prob * (centered^2 - variance) * (w * slope^2), linear) +
    //                        crossprod(log_slope, 2 * w * slope^2 * variance) -
    //                        variance_derivative / sigma^2
    std::fill(curv_deriv.begin(), curv_deriv.end(), 0.0);
    for (int r = 0; r < m_obs; ++r) {
      const double sl = slope_sub[static_cast<size_t>(r)];
      const double ws2 = weight_sub[static_cast<size_t>(r)] * sl * sl;
      const double exp_r = mode_expected[static_cast<size_t>(r)];
      const double var_r = mode_variance[static_cast<size_t>(r)];
      for (int k = 1; k < k_cat; ++k) {
        const double c_rk = static_cast<double>(k) - exp_r;
        const double coeff = mode_prob[static_cast<size_t>(r) * k_cat + k] *
                             (c_rk * c_rk - var_r) * ws2;
        vec_cum[static_cast<size_t>(k - 1) * m_obs + r] = coeff * sl;
      }
    }
    if (n_steps > 0 && cum_ac != nullptr) {
      sparse_crossprod_add(pat, cum_pcs, cum_ac, cum_cvs, cum_ri, cum_vx,
                           vec_cum.data(), 1.0, curv_deriv);
    }
    if (has_log_slopes && ls_ac != nullptr) {
      for (int r = 0; r < m_obs; ++r) {
        const double sl = slope_sub[static_cast<size_t>(r)];
        const double ws2 = weight_sub[static_cast<size_t>(r)] * sl * sl;
        const double exp_r = mode_expected[static_cast<size_t>(r)];
        const double var_r = mode_variance[static_cast<size_t>(r)];
        double dot_lin = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double c_rk = static_cast<double>(k) - exp_r;
          const double coeff = mode_prob[static_cast<size_t>(r) * k_cat + k] *
                               (c_rk * c_rk - var_r) * ws2;
          dot_lin += coeff * mode_linear[static_cast<size_t>(r) * k_cat + k];
        }
        vec_ls[static_cast<size_t>(r)] = dot_lin * sl + 2.0 * ws2 * var_r;
      }
      sparse_crossprod_add(pat, ls_pcs, ls_ac, ls_cvs, ls_ri, ls_vx,
                           vec_ls.data(), 1.0, curv_deriv);
    }
    if (log_sigma2_col0 >= 0) {
      curv_deriv[static_cast<size_t>(log_sigma2_col0)] -= inv_sigma2;
    }

    const double inv_curv = 1.0 / curvature;
    const double inv_2curv = 0.5 * inv_curv;
    for (int d = 0; d < p_dim; ++d) {
      const double md = mixed[static_cast<size_t>(d)] * inv_curv;
      mode_deriv[static_cast<size_t>(d)] = md;
      log_scale_deriv[static_cast<size_t>(d)] =
        -(curv_deriv[static_cast<size_t>(d)] + curvature_theta * md) * inv_2curv;
    }

    // Evaluate adaptive Gauss-Hermite nodes z = mode + scale * rule_nodes
    node_probs_all.resize(static_cast<size_t>(n_nodes) * m_obs * k_cat);
    if (has_log_slopes) {
      node_linear_all.resize(static_cast<size_t>(n_nodes) * m_obs * k_cat);
    }
    double offset = -std::numeric_limits<double>::infinity();

    for (int q = 0; q < n_nodes; ++q) {
      const double z_q = mode + scale * rule_nodes[q];
      z_nodes[static_cast<size_t>(q)] = z_q;
      const double theta_q = mu_p + sigma * z_q;
      double ll_q = 0.0;
      double score_sum_q = 0.0;
      double info_sum_q = 0.0;
      double* probs_q_ptr = node_probs_all.data() + static_cast<size_t>(q) * m_obs * k_cat;
      double* lin_q_ptr = has_log_slopes
        ? (node_linear_all.data() + static_cast<size_t>(q) * m_obs * k_cat)
        : nullptr;

      for (int r = 0; r < m_obs; ++r) {
        const double eta = base_sub[static_cast<size_t>(r)] + theta_q;
        const double sl = slope_sub[static_cast<size_t>(r)];
        const double w = weight_sub[static_cast<size_t>(r)];
        const int y = score_sub[static_cast<size_t>(r)];
        const double* st_ptr = (model_code == 0)
          ? step_rsm_ptr
          : (step_rm.data() + static_cast<size_t>(step_sub[static_cast<size_t>(r)] - 1) * k_cat);

        double row_max = -std::numeric_limits<double>::infinity();
        for (int k = 0; k < k_cat; ++k) {
          const double lin = eta * static_cast<double>(k) - st_ptr[k];
          const double val = (model_code == 2) ? (lin * sl) : lin;
          if (has_log_slopes) lin_q_ptr[static_cast<size_t>(r) * k_cat + k] = lin;
          log_num_buf[static_cast<size_t>(k)] = val;
          if (val > row_max) row_max = val;
        }
        double denom = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double e = std::exp(log_num_buf[static_cast<size_t>(k)] - row_max);
          prob_buf[static_cast<size_t>(k)] = e;
          denom += e;
        }
        ll_q += w * ((log_num_buf[static_cast<size_t>(y)] - row_max) - std::log(denom));
        double exp_r = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double p_rk = prob_buf[static_cast<size_t>(k)] / denom;
          probs_q_ptr[static_cast<size_t>(r) * k_cat + k] = p_rk;
          exp_r += p_rk * static_cast<double>(k);
        }
        double var_r = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double c_rk = static_cast<double>(k) - exp_r;
          var_r += probs_q_ptr[static_cast<size_t>(r) * k_cat + k] * c_rk * c_rk;
        }
        score_sum_q += (w * sl) * (static_cast<double>(y) - exp_r);
        info_sum_q += (w * sl * sl) * var_r;
      }

      const double m1_q = sigma * score_sum_q;
      const double m2_q = sigma * sigma * info_sum_q;
      if (!std::isfinite(m1_q) || !std::isfinite(m2_q)) {
        return writable::list({
          "error_code"_nm = 1,
          "error_message"_nm = std::string("Non-finite adaptive posterior score or information.")
        });
      }
      node_ll[static_cast<size_t>(q)] = ll_q;
      node_score[static_cast<size_t>(q)] = m1_q - z_q;
      if (ll_q > offset) offset = ll_q;
    }

    const double log_scale = std::log(scale);
    double max_joint = -std::numeric_limits<double>::infinity();
    for (int q = 0; q < n_nodes; ++q) {
      const double z_q = z_nodes[static_cast<size_t>(q)];
      const double j_q = log_rule_weights[q] +
                         (node_ll[static_cast<size_t>(q)] - offset) +
                         Rf_dnorm4(z_q, 0.0, 1.0, 1) -
                         log_dnorm_rule_nodes[q] +
                         log_scale;
      if (!std::isfinite(j_q)) {
        return writable::list({
          "error_code"_nm = 4,
          "error_message"_nm = std::string("Non-finite integration terms.")
        });
      }
      joint[static_cast<size_t>(q)] = j_q;
      if (j_q > max_joint) max_joint = j_q;
    }

    double sum_post = 0.0;
    for (int q = 0; q < n_nodes; ++q) {
      const double p_q = std::exp(joint[static_cast<size_t>(q)] - max_joint);
      posterior[static_cast<size_t>(q)] = p_q;
      sum_post += p_q;
    }
    const double normalizer = max_joint + std::log(sum_post);
    for (int q = 0; q < n_nodes; ++q) {
      posterior[static_cast<size_t>(q)] /= sum_post;
    }

    value -= mult * (offset + normalizer);

    if (include_person_summaries) {
      double center = 0.0;
      for (int q = 0; q < n_nodes; ++q) {
        center += posterior[static_cast<size_t>(q)] * z_nodes[static_cast<size_t>(q)];
      }
      double z_var = 0.0;
      for (int q = 0; q < n_nodes; ++q) {
        const double dz = z_nodes[static_cast<size_t>(q)] - center;
        z_var += posterior[static_cast<size_t>(q)] * dz * dz;
      }
      pat_summaries(pat, 0) = offset + normalizer;
      pat_summaries(pat, 1) = mu_p + sigma * center;
      pat_summaries(pat, 2) = sigma * std::sqrt(z_var);
    }

    residual_mean.assign(static_cast<size_t>(m_obs) * k_cat, 0.0);
    if (has_log_slopes) {
      slope_mean.assign(static_cast<size_t>(m_obs), 0.0);
    }
    for (int q = 0; q < n_nodes; ++q) {
      const double post_q = posterior[static_cast<size_t>(q)];
      const double* probs_q_ptr = node_probs_all.data() + static_cast<size_t>(q) * m_obs * k_cat;
      const double* lin_q_ptr = has_log_slopes
        ? (node_linear_all.data() + static_cast<size_t>(q) * m_obs * k_cat)
        : nullptr;
      for (int r = 0; r < m_obs; ++r) {
        const int y = score_sub[static_cast<size_t>(r)];
        double sl_acc = 0.0;
        for (int k = 0; k < k_cat; ++k) {
          const double res_rk = ((k == y) ? 1.0 : 0.0) - probs_q_ptr[static_cast<size_t>(r) * k_cat + k];
          residual_mean[static_cast<size_t>(r) * k_cat + k] += post_q * res_rk;
          if (has_log_slopes) {
            sl_acc += res_rk * lin_q_ptr[static_cast<size_t>(r) * k_cat + k];
          }
        }
        if (has_log_slopes) {
          slope_mean[static_cast<size_t>(r)] += post_q * sl_acc;
        }
      }
    }

    std::fill(fixed_deriv.begin(), fixed_deriv.end(), 0.0);
    for (int r = 0; r < m_obs; ++r) {
      const double ws = weight_sub[static_cast<size_t>(r)] * slope_sub[static_cast<size_t>(r)];
      for (int k = 1; k < k_cat; ++k) {
        vec_cum[static_cast<size_t>(k - 1) * m_obs + r] =
          residual_mean[static_cast<size_t>(r) * k_cat + k] * ws;
      }
    }
    if (n_steps > 0 && cum_ac != nullptr) {
      sparse_crossprod_add(pat, cum_pcs, cum_ac, cum_cvs, cum_ri, cum_vx,
                           vec_cum.data(), 1.0, fixed_deriv);
    }
    if (has_log_slopes && ls_ac != nullptr) {
      for (int r = 0; r < m_obs; ++r) {
        vec_ls[static_cast<size_t>(r)] =
          slope_mean[static_cast<size_t>(r)] *
          (weight_sub[static_cast<size_t>(r)] * slope_sub[static_cast<size_t>(r)]);
      }
      sparse_crossprod_add(pat, ls_pcs, ls_ac, ls_cvs, ls_ri, ls_vx,
                           vec_ls.data(), 1.0, fixed_deriv);
    }

    double z_post_mean = 0.0;
    double z2m1_post_mean = 0.0;
    double score_post_mean = 0.0;
    double scale_post_mean = 0.0;
    for (int q = 0; q < n_nodes; ++q) {
      const double post_q = posterior[static_cast<size_t>(q)];
      const double z_q = z_nodes[static_cast<size_t>(q)];
      const double sc_q = node_score[static_cast<size_t>(q)];
      z_post_mean += post_q * z_q;
      z2m1_post_mean += post_q * (z_q * z_q - 1.0);
      score_post_mean += post_q * sc_q;
      scale_post_mean += post_q * (scale * sc_q * rule_nodes[q] + 1.0);
    }
    for (int b = 0; b < n_beta; ++b) {
      fixed_deriv[static_cast<size_t>(beta_cols0[b])] +=
        (z_post_mean / sigma) * pat_pop_design(pat, b);
    }
    if (log_sigma2_col0 >= 0) {
      fixed_deriv[static_cast<size_t>(log_sigma2_col0)] += 0.5 * z2m1_post_mean;
    }

    const double coef_mode = score_post_mean / sigma;
    const double coef_scale = scale_post_mean;
    for (int d = 0; d < p_dim; ++d) {
      gradient[static_cast<size_t>(d)] -= mult * (
        fixed_deriv[static_cast<size_t>(d)] +
        coef_mode * mode_deriv[static_cast<size_t>(d)] +
        coef_scale * log_scale_deriv[static_cast<size_t>(d)]
      );
    }
  }

  writable::doubles grad_out(p_dim);
  for (int d = 0; d < p_dim; ++d) {
    grad_out[d] = gradient[static_cast<size_t>(d)];
  }
  return writable::list({
    "error_code"_nm = 0,
    "error_message"_nm = std::string(""),
    "value"_nm = value,
    "gradient"_nm = grad_out,
    "pat_summaries"_nm = pat_summaries
  });
}

