// Website-only regression: execute the actual widget, then export its numbers
// for comparison with the R likelihood kernels in check-curve-explorer.R.
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const html = fs.readFileSync('vignettes/articles/curve-explorer.html', 'utf8');
const script = html.match(/<script>([\s\S]*?)<\/script>/)[1];
const modes = ['RSM', 'PCM', 'GPCM'].map(value => ({value, checked: value === 'RSM'}));
const panels = [...html.matchAll(/<div class="mce-panel"[\s\S]*?(?=<div class="mce-panel"|<div class="mce-legend")/g)].map(match => {
  const inputs = Object.fromEntries([...match[0].matchAll(/<input type="range"([^>]+)>/g)].map(m => {
    const a = Object.fromEntries([...m[1].matchAll(/([\w-]+)="([^"]*)"/g)].map(x => [x[1], x[2]]));
    return [a['data-par'], {value: a.value, dataset: {own: a['data-own'], default: a['data-default']},
      disabled: false, parentNode: {classList: {toggle() {}}}, matches: () => true}];
  }));
  const outputs = Object.fromEntries(Object.keys(inputs).map(k => [k, {}]));
  const svg = {addEventListener() {}, innerHTML: ''};
  const readout = {};
  return {inputs, outputs, svg, querySelector(selector) {
    if (selector === 'svg') return svg;
    if (selector === '.mce-readout') return readout;
    const key = selector.match(/data-par=([^\]]+)/)[1];
    return selector.endsWith(' + output') ? outputs[key] : inputs[key];
  }};
});
assert.equal(panels.length, 2);
const events = {};
const root = {
  querySelectorAll(selector) {
    return selector === '.mce-panel' ? panels : panels.flatMap(p => Object.values(p.inputs));
  },
  querySelector(selector) {
    if (selector === 'input[name=mce-model]:checked') return modes.find(m => m.checked);
    if (selector === 'input[name=mce-model][value=RSM]') return modes[0];
    if (selector === '.mce-reset') return {addEventListener: (name, callback) => { events.reset = callback; }};
    return {};
  },
  addEventListener: (name, callback) => { events[name] = callback; }
};
const context = {document: {getElementById: () => root}};
vm.createContext(context);
assert.match(script, /\}\)\(\);\s*$/);
vm.runInContext(script.replace(/\}\)\(\);\s*$/, 'globalThis.widget = {probabilities, effectiveParams, update};})();'), context);
const widget = context.widget;
const setMode = name => { modes.forEach(m => { m.checked = m.value === name; }); events.change({}); };
const move = (i, key, value) => { const target = panels[i].inputs[key]; target.value = String(value); events.input({target}); };

assert.equal(panels[1].inputs.spacing.disabled, true);
move(0, 'spacing', 1.7);
assert.equal(widget.effectiveParams(1).spacing, 1.7);
setMode('PCM');
assert.equal(widget.effectiveParams(1).spacing, 0.6);
assert.ok(panels.every(p => p.inputs.slope.disabled));
setMode('GPCM');
assert.equal(panels[0].inputs.slope.disabled, false);
assert.equal(panels[1].inputs.slope.disabled, true);
move(0, 'slope', 0.4);
assert.equal(widget.effectiveParams(1).slope, 2.5);
assert.ok(Math.abs(widget.effectiveParams(0).slope * widget.effectiveParams(1).slope - 1) < 1e-14);
setMode('RSM');
assert.ok(panels.every((p, i) => widget.effectiveParams(i).slope === 1));
setMode('GPCM');
assert.equal(widget.effectiveParams(0).slope, 0.4);
// Native radio buttons enforce this exclusivity; the fixture applies it too.
modes.forEach(m => { m.checked = false; });
events.reset();
assert.equal(modes[0].checked, true);
assert.ok(panels.every(p => Object.values(p.inputs).every(v => v.dataset.own === v.dataset.default)));

const rows = ['Model,Panel,Theta,Delta,Spacing,Slope,P0,P1,P2,P3'];
for (const name of ['RSM', 'PCM', 'GPCM']) {
  setMode(name);
  for (const slope of [0.4, 0.8, 1, 2.5]) {
    if (name === 'GPCM') move(0, 'slope', slope);
    panels.forEach((panel, i) => {
      const p = widget.effectiveParams(i);
      for (const theta of [-4, -1, 0, 1, 4, p.delta - p.spacing, p.delta, p.delta + p.spacing]) {
        const probs = widget.probabilities(theta, p.delta, p.spacing, p.slope);
        assert.ok(probs.every(v => Number.isFinite(v) && v >= 0 && v <= 1));
        assert.ok(Math.abs(probs.reduce((a, b) => a + b) - 1) < 1e-14);
        rows.push([name, i, theta, p.delta, p.spacing, p.slope, ...probs].join(','));
      }
      [-1, 0, 1].forEach((offset, k) => {
        const pAtCrossing = widget.probabilities(p.delta + offset * p.spacing, p.delta, p.spacing, p.slope);
        assert.ok(Math.abs(pAtCrossing[k] - pAtCrossing[k + 1]) < 1e-14);
      });
    });
  }
}
fs.writeFileSync(process.argv[2], rows.join('\n') + '\n');
console.log('PASS: widget mode, shared steps, relative-slope constraint, reset and probability crossings.');
