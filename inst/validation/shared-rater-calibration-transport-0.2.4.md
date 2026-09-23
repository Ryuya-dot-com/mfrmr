# Affine-reference follow-through for calibration likelihood changes

2026-09-23. Fixed after the original 144-point comparison and before evaluating
any affine-transport reference. Original decisions: 83 bounded agreement,
4 inconclusive, 57 reference-precision unresolved; no material discrepancy.
The original mean log-ratio MCSE reaches .0883. Preserve these results.

Use the same eight rosters, same 144 parameter points, all four saved chains
and every saved iteration. No new simulation, calibration refit, adjusted
acceptance tolerance or selected subset. Apply this refinement to all points.

For each fixed calibration a, find the mode m_a and negative-log-joint Hessian
H_a of all latent abilities and shared severities. Direct ordinal likelihood
plus proper normal priors is strictly log-concave in those latent coordinates.
Use an independent Newton calculation with analytic derivatives, line search,
maximum 50 iterations, gradient maximum <1e-7 and positive Cholesky factor
R_a, with H_a = R_a' R_a. The same source response probability defines value,
gradient and Hessian. No fixed calibration coordinate is optimized. Check
three prespecified normalized directions by central differences (step 1e-5,
gradient agreement 1e-6 and Hessian-vector agreement 1e-5) at every mode.

For each original joint posterior draw z at a0, set

  T_a(z) = m_a + R_a^-1 R_0 (z-m_0),
  log J_a = sum(log diag R_0) - sum(log diag R_a).

This invertible map exactly transforms the Gaussian mode/curvature reference;
it need not transform the actual posterior exactly. The exact integral identity
is Z(a)/Z(a0) = E_p0[exp(log f_a(T_a(z)) - log f_a0(z) + log J_a)].
Compute both joint densities directly, including normal constants. The mapping
reduces importance-weight variation; no Laplace integral is used as the target
or as the estimate of the likelihood ratio. Its Jacobian is essential.

Require a separate direct R density comparison for the first draw of every
chain at every point (1e-8), original Stan log_joint agreement at baseline
(1e-8), determinant identity (1e-8) and zero-map log weights (1e-10).
Retain the original sampler, raw-weight Rhat/ESS/Pareto-k and log-MCSE gates,
the original .05-log-likelihood tolerance with four-MCSE allowances, and the
saved 123/241-node production comparisons. Use raw, unsmoothed weights.
Preserve failures separately; a failed transport cannot qualify a point.

Allow 20 minutes / 512 MiB of new artifacts for this reference refinement.
Save maps, log weights, derivatives/checks, source/input hashes and every
outcome. Do not extend chains or fit another calibration. If precision still
fails, leave that result unresolved. This is not independent replication or
a new package estimation method; all scope limits of the original protocol
remain. In particular, local likelihood agreement is not a coverage theorem,
absolute marginal-likelihood check or full SD-profile qualification.
