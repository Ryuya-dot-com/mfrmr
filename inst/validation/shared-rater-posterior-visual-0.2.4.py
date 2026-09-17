"""Bounded posterior reference and scientific figure for the saved two-person case."""
import csv
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import sys

import numpy as np
from scipy.stats import norm

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve()
NOTES = HERE.parents[3] / 'research-notes/2026-09-17-random-effects-rating-design'
spec = importlib.util.spec_from_file_location('sharing_reference', NOTES / 'model-sharing-check.py')
reference = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reference)
SAVED = json.loads((NOTES / 'model-sharing-check.json').read_text())
FIXTURE = SAVED['shared_and_local_models']
Y = np.asarray(FIXTURE['responses'])
BETA = np.asarray(FIXTURE['criterion_difficulties'])
OUT = HERE.parents[2] / 'validation-results/shared-rater-posterior-visual-20260917'


def joint_likelihood(theta, order, rater_sd):
    """Fix both abilities; integrate each rater shared across the two people."""
    z, w = reference.normal_grid(order)
    u, uw = (np.array([0.]), np.array([1.])) if rater_sd == 0 else (rater_sd * z, w)
    likelihood = np.ones((len(theta), len(theta)))
    for r in range(2):
        people = []
        for p in range(2):
            conditional = np.ones((len(theta), len(u)))
            for j in range(2):
                conditional *= reference.rsm(theta[:, None] - u[None, :] - BETA[j])[..., Y[p, r, j]]
            people.append(conditional)
        likelihood *= (people[0] * uw) @ people[1].T
    return likelihood


def moments(theta, mass):
    mean = np.array([theta @ mass.sum(axis=1), theta @ mass.sum(axis=0)])
    centered = theta[:, None] - mean[None, :]
    covariance = np.array([
        [centered[:, 0] ** 2 @ mass.sum(axis=1), centered[:, 0] @ mass @ centered[:, 1]],
        [centered[:, 0] @ mass @ centered[:, 1], centered[:, 1] ** 2 @ mass.sum(axis=0)]])
    return mean, covariance


def posterior(order, rater_sd=.7):
    z, w = reference.normal_grid(order)
    raw = joint_likelihood(z, order, rater_sd) * np.outer(w, w)
    evidence = raw.sum()
    mass = raw / evidence
    mean, covariance = moments(z, mass)
    return {'loglik': float(np.log(evidence)), 'mean': mean, 'covariance': covariance,
            'mass_error': float(abs(mass.sum() - 1))}


def posterior_by_shared_u(order=81):
    """Reverse the integration order; total covariance retains common u."""
    z, w = reference.normal_grid(order)
    likelihoods, means, variances = [], [], []
    for p in range(2):
        likelihood = np.ones((order, order, order))
        for r in range(2):
            u = .7 * (z[None, :, None] if r == 0 else z[None, None, :])
            for j in range(2):
                likelihood *= reference.rsm(z[:, None, None] - u - BETA[j])[..., Y[p, r, j]]
        integrated = np.einsum('i,ijk->jk', w, likelihood)
        mean = np.einsum('i,ijk->jk', w * z, likelihood) / integrated
        variance = np.einsum('i,ijk->jk', w * z**2, likelihood) / integrated - mean**2
        likelihoods.append(integrated); means.append(mean); variances.append(variance)
    raw = np.outer(w, w) * likelihoods[0] * likelihoods[1]
    evidence = raw.sum(); mass = raw / evidence
    mean = np.array([np.sum(mass * value) for value in means])
    covariance = np.array([[np.sum(mass * (means[p] - mean[p]) * (means[q] - mean[q]))
                            for q in range(2)] for p in range(2)])
    covariance += np.diag([np.sum(mass * value) for value in variances])
    delta_mean = means[0] - means[1]
    difference_variance = np.sum(mass * (variances[0] + variances[1])) + np.sum(
        mass * (delta_mean - np.sum(mass * delta_mean))**2)
    return float(np.log(evidence)), mean, covariance, float(difference_variance)


def compute():
    assert Y.shape == (2, 2, 2) and FIXTURE['person_sd'] == 1 and FIXTURE['rater_sd'] == .7
    assert FIXTURE['thresholds'] == [-.6, .6] and np.array_equal(Y, reference.Y)
    OUT.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(HERE, OUT / 'computed-with.py')
    shutil.copyfile(HERE.with_suffix('.md'), OUT / 'plan.md')
    checks = []

    def check(name, error, tolerance):
        checks.append({'check': name, 'error': float(error), 'tolerance': tolerance,
                       'pass': bool(np.isfinite(error) and error <= tolerance)})

    low, high = posterior(41), posterior(81)
    for key in ('loglik', 'mean', 'covariance'):
        check('q41_q81_' + key, np.max(np.abs(low[key] - high[key])), 1e-7)
    with HERE.with_name('shared-rater-fixed-point-0.2.4-values.csv').open() as stream:
        r_values = {row['Case']: float(row['LogLik']) for row in csv.DictReader(stream)}
    for n, result in ((41, low), (81, high)):
        check(f'saved_R_q{n}_loglik', abs(result['loglik'] - r_values[f'shared_q{n}']), 1e-7)
        check(f'q{n}_posterior_mass', result['mass_error'], 1e-12)
    ll, mean, covariance, delta_variance = posterior_by_shared_u()
    check('reverse_integral_loglik', abs(ll - high['loglik']), 1e-7)
    check('total_expectation', np.max(abs(mean - high['mean'])), 1e-7)
    check('total_covariance', np.max(abs(covariance - high['covariance'])), 1e-7)
    contrast = np.array([1., -1.])
    actual_variance = float(contrast @ high['covariance'] @ contrast)
    check('total_difference_variance', abs(delta_variance - actual_variance), 1e-7)
    check('covariance_positive_semidefinite', max(0., -np.linalg.eigvalsh(high['covariance']).min()), 1e-12)
    zero = posterior(81, rater_sd=0)
    check('zero_rater_covariance', abs(zero['covariance'][0, 1]), 1e-12)
    check('zero_rater_saved_loglik', abs(zero['loglik'] - np.log(FIXTURE['zero_rater_sd']['shared_rater_likelihood'])), 1e-7)
    grid = np.linspace(-8, 8, 401)
    widths = np.full(len(grid), grid[1] - grid[0]); widths[[0, -1]] /= 2
    density = joint_likelihood(grid, 81, .7) * np.outer(norm.pdf(grid), norm.pdf(grid)) / np.exp(high['loglik'])
    grid_mass = density * np.outer(widths, widths)
    grid_mean, grid_covariance = moments(grid, grid_mass)
    check('plot_density_integral', abs(grid_mass.sum() - 1), 1e-6)
    check('plot_mean', np.max(abs(grid_mean - high['mean'])), 1e-6)
    check('plot_covariance', np.max(abs(grid_covariance - high['covariance'])), 1e-6)
    product = np.outer(density @ widths, widths @ density)
    _, product_covariance = moments(grid, product * np.outer(widths, widths))
    check('product_marginals_covariance', abs(product_covariance[0, 1]), 1e-10)
    check('product_retains_marginal_variances', np.max(abs(np.diag(product_covariance) - np.diag(high['covariance']))), 1e-6)
    inputs = [HERE, NOTES / 'model-sharing-check.py', NOTES / 'model-sharing-check.json',
              HERE.with_name('shared-rater-fixed-point-0.2.4-values.csv')]
    result = {'scope': 'Fixed-calibration posterior for one saved response example; not interval coverage or model ranking',
              'source_sha256': {str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs},
              'loglik': high['loglik'], 'mean': high['mean'].tolist(), 'covariance': high['covariance'].tolist(),
              'correlation': float(high['covariance'][0, 1] / np.sqrt(np.prod(np.diag(high['covariance'])))),
              'difference_mean': float(contrast @ high['mean']), 'difference_variance': actual_variance,
              'difference_sd': float(np.sqrt(actual_variance)),
              'difference_sd_without_covariance': float(np.sqrt(np.trace(high['covariance']))), 'checks': checks}
    HERE.with_suffix('.json').write_text(json.dumps(result, indent=2) + '\n')
    np.savez_compressed(OUT / 'density.npz', grid=grid, density=density, product=product, widths=widths)
    assert all(check['pass'] for check in checks), checks
    print(json.dumps({key: result[key] for key in ('mean', 'covariance', 'correlation', 'difference_sd',
                                                  'difference_sd_without_covariance')}, indent=2))
    print(f'{len(checks)}/{len(checks)} checks passed')


def plot():
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib import font_manager
    from matplotlib.lines import Line2D

    font = Path('/System/Library/Fonts/Supplemental/Arial Unicode.ttf')
    if font.exists():
        font_manager.fontManager.addfont(str(font))
        plt.rcParams['font.family'] = font_manager.FontProperties(fname=font).get_name()
    plt.rcParams.update({'font.size': 12, 'axes.titlesize': 14, 'pdf.fonttype': 42, 'axes.unicode_minus': False})
    values = json.loads(HERE.with_suffix('.json').read_text())
    assert all(row['pass'] for row in values['checks'])
    saved = np.load(OUT / 'density.npz')
    grid, density, product, widths = [saved[key] for key in ('grid', 'density', 'product', 'widths')]
    blue, orange, neutral = '#0072B2', '#D55E00', '#575757'
    fig, axes = plt.subplots(2, 2, figsize=(12, 9), gridspec_kw={'height_ratios': [0.8, 1.2]})
    fig.subplots_adjust(left=.08, right=.96, top=.87, bottom=.16, hspace=.65, wspace=.35)
    fig.suptitle('同じ評定者を共有すると、能力差の不確実性はどう変わるか', fontsize=19, y=.965)
    fig.text(.5, .917, '2人 × 2評定者 × 2基準の保存小例 ｜ 較正値は固定', ha='center', fontsize=12)

    for ax, shared in zip(axes[0], (True, False)):
        ax.set(xlim=(0, 1), ylim=(0, 1)); ax.axis('off')
        ax.set_title('A  共有評定者効果（系列R）' if shared else 'B  人×評定者の局所効果（構造図）', loc='left', pad=10)
        if shared:
            nodes = [(0.3, 'u₁', blue), (0.7, 'u₂', blue)]
            edges = [(x, target) for x, _, _ in nodes for target in (.25, .75)]
        else:
            nodes = [(0.12, 'γ₁₁', neutral), (.38, 'γ₁₂', neutral), (.62, 'γ₂₁', neutral), (.88, 'γ₂₂', neutral)]
            edges = [(x, .25 if i < 2 else .75) for i, (x, _, _) in enumerate(nodes)]
        for x, target in edges:
            ax.annotate('', xy=(target, .27), xytext=(x, .71),
                        arrowprops={'arrowstyle': '->', 'color': blue if shared else neutral, 'lw': 1.4})
        for x, label, color in nodes:
            ax.text(x, .8, label, ha='center', va='center', fontsize=16,
                    bbox={'boxstyle': 'circle,pad=.35', 'fc': 'white', 'ec': color, 'lw': 1.4})
        for x, person in ((.25, 'P1'), (.75, 'P2')):
            ax.text(x, .15, person + 'の応答\n（評定者1・2）', ha='center', va='center',
                    bbox={'boxstyle': 'round,pad=.4', 'fc': '#F3F3F3', 'ec': 'none'})
        ax.text(.5, -.12, '各uは二人の応答に共有' if shared else '各γは一人の応答だけに共有', ha='center', color=neutral)

    ax = axes[1, 0]
    ax.set_title('C  能力の共同事後分布', loc='left', pad=12)
    for data, color, style in ((density, blue, '-'), (product, orange, '--')):
        ordered = np.argsort(data.ravel())[::-1]
        probability = (data * np.outer(widths, widths)).ravel()[ordered]
        cumulative = np.cumsum(probability)
        levels = [data.ravel()[ordered[np.searchsorted(cumulative, p)]] for p in (.9, .5)]
        ax.contour(grid, grid, data.T, levels=levels, colors=color, linestyles=style, linewidths=1.8)
    marginal_x, marginal_y = density @ widths, widths @ density
    lo = min(grid[np.searchsorted(np.cumsum(marginal_x * widths), .002)],
             grid[np.searchsorted(np.cumsum(marginal_y * widths), .002)])
    hi = max(grid[np.searchsorted(np.cumsum(marginal_x * widths), .998)],
             grid[np.searchsorted(np.cumsum(marginal_y * widths), .998)])
    ax.set(xlim=(lo, hi), ylim=(lo, hi), xlabel='P1の能力 θ₁（logit）', ylabel='P2の能力 θ₂（logit）', aspect='equal')
    ax.text(.03, .97, f"事後相関 ρ = {values['correlation']:.3f}", transform=ax.transAxes, va='top')
    ax.grid(alpha=.15)

    ax = axes[1, 1]
    ax.set_title('D  能力差 θ₁ − θ₂ の標準偏差', loc='left', pad=12)
    sds = [values['difference_sd'], values['difference_sd_without_covariance']]
    ax.barh([1, 0], sds, color=[blue, orange], height=.4)
    for y, value in zip([1, 0], sds):
        ax.text(value + .025, y, f'{value:.3f}', va='center', fontsize=14)
    ax.set(yticks=[1, 0], yticklabels=['共分散を保持', '共分散を0と扱う'], xlabel='事後標準偏差（logit）',
           xlim=(0, max(sds) * 1.22), ylim=(-.6, 1.6))
    ax.spines[['top', 'right']].set_visible(False)
    ax.text(.02, -.28, '同じ周辺分布のまま、依存だけを除いた比較', transform=ax.transAxes, fontsize=11)
    fig.legend([Line2D([0], [0], color=blue, lw=2), Line2D([0], [0], color=orange, lw=2, ls='--')],
               ['共有モデルの共同事後分布', 'その周辺分布の積（Bのモデルの結果ではない）'],
               loc='lower center', bbox_to_anchor=(.5, .072), ncol=2, frameon=False, fontsize=11)
    fig.text(.5, .036, '等高線：各分布の約50%・90%最高密度領域。小例の説明用であり、被覆性能の結果ではない。',
             ha='center', fontsize=10.5, color=neutral)
    for suffix in ('.png', '.pdf'):
        fig.savefig(HERE.with_suffix(suffix), dpi=180, facecolor='white')
    plt.close(fig)
    (OUT / 'render-provenance.json').write_text(json.dumps({
        'render_source_sha256': hashlib.sha256(HERE.read_bytes()).hexdigest(),
        'data_sha256': hashlib.sha256(HERE.with_suffix('.json').read_bytes()).hexdigest()}, indent=2) + '\n')


if __name__ == '__main__':
    if '--plot-only' not in sys.argv:
        compute()
    plot()
