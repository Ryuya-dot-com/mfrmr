function(el, x, d) {
  const panel = el.closest(".surface-panel");
  const [rater, criterion, event] = panel.querySelectorAll("select");
  const output = panel.querySelector("output");

  function update() {
    const context = criterion.selectedIndex * d.raters.length + rater.selectedIndex;
    const eventIndex = event.selectedIndex;
    const exact = eventIndex < d.scores.length;
    const column = exact ? eventIndex : eventIndex - d.scores.length + 1;
    const eventProb = d.prob[context].map(row => exact ? row[column] :
      row.slice(column).reduce((sum, p) => sum + p, 0));
    const z = d.change10.map(delta => d.ability10.map(theta => eventProb[theta - delta - d.first]));
    const fitted = z[d.change10.indexOf(0)];
    const prefix = "<b>" + event.value + "</b><br>Rater: " + rater.value +
      "<br>Criterion: " + criterion.value + "<br>Person ability: %{x:.2f} logits";
    const scenarioHover = prefix + "<br>Severity change: %{y:+.2f} logits<br>Probability: %{z:.1%}<extra></extra>";
    const fittedHover = prefix + "<br>Severity change: 0 (fitted)<br>Probability: %{z:.1%}<extra></extra>";
    Plotly.restyle(el, {z: [z, fitted], hovertemplate: [scenarioHover, fittedHover]}, [0, 1]);
    output.textContent = "At ability 0 and fitted severity: " +
      (100 * fitted[d.ability10.indexOf(0)]).toFixed(1) + "%";
  }

  for (const select of [rater, criterion, event]) select.onchange = update;
  const pair = panel.parentElement;
  el.on("plotly_relayout", changes => {
    const camera = changes["scene.camera"];
    if (!camera || pair.syncingCamera) return;
    const peer = Array.from(pair.querySelectorAll(".js-plotly-plot")).find(graph => graph !== el);
    if (!peer || !peer.data) return;
    pair.syncingCamera = true;
    Plotly.relayout(peer, {"scene.camera": camera}).finally(() => { pair.syncingCamera = false; });
  });
  update();
}
