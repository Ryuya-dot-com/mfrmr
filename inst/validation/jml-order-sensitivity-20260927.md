# Adjustment-order sensitivity: bounded method decision

Question: without generating truth, can the observed change between adjustment
orders justify stopping or qualify remaining bias? Reuse all saved reviewed
sample fits in the design-aware study: orders 1/2/4 for complete and sparse,
1/4 for the unequal-length case after its recorded solver repair. Do not fit a
new simulation grid or choose a correction order using the known truth.

The comparison must account for the fact that both fits use the same Persons.
For centered Person influence IF_k, the difference has influence IF_l - IF_k,
and covariance sum_i (IF_li-IF_ki)(IF_li-IF_ki)' / N^2. Fixed-roster centering
is retained. Adding separate variances would omit the cross covariance. This
is a local linearized sensitivity calculation about method-specific roots,
not a calibrated significance test or confidence interval for generating truth.

Report signed coordinate differences, each method's local SE, paired-difference
SE and ratios to the later method's SE and the paired-difference SE. Ratios are
descriptive: no p-values, cutoff, automatic selected order or coverage label.
Require matching Person IDs, coordinate names, strata and sampling target.
A failed root cannot join the comparison by dropping its diagnostic status.

Engineering verification: reproduce saved covariance by expanding each sample's
Person contributions; independently reconstruct difference covariance as
V_k + V_l - C_kl - C_lk; check PSD and aligned inputs. Same-estimate/same-influence
pairs produce zero difference variance and an undefined standardized ratio,
not a spurious rejection. Explicitly reject mismatched Persons, mixed sampling
targets and unreviewed roots. A shared displacement added to all estimates
leaves the difference-based diagnostics unchanged: these summaries cannot
identify or bound common residual bias.

Check the derivative of the sparse order-4 minus order-1 estimate by perturbing
the same within-roster empirical frequencies for both fits and re-solving at
h=1e-5,5e-6; keep original fixed fractions, root tolerances and 1e-3 relative
influence-error threshold. These are targeted numerical checks, not independent
statistical validation. Preserve inputs and source hashes.

Decision boundary: agreement can describe low observed sensitivity to the
examined orders. It cannot prove an unbiased limit, bound the unexamined tail,
select an optimal MSE order, or justify ordinary intervals after adaptive
selection. If comparison alone cannot justify a rule, retain explicit
research orders and an unselected result; do not manufacture an automatic rule.
