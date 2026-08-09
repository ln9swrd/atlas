/** Replay timeline UI helpers */

export function drawReplayTimeline(ctx, W, H, replayData, cursorT, loopA, loopB) {
  if (!replayData || !replayData.inputs) return;
  const inputs = replayData.inputs;
  const maxT = Math.max(1, ...inputs.map((i) => i.t), ...(replayData.frames || []).map((f) => f.t));
  const x = 40;
  const y = H - 52;
  const w = W - 80;
  ctx.fillStyle = 'rgba(0,0,0,0.5)';
  ctx.fillRect(x - 4, y - 8, w + 8, 28);
  ctx.fillStyle = '#30363d';
  ctx.fillRect(x, y, w, 6);
  // events
  for (const ev of inputs) {
    const px = x + (ev.t / maxT) * w;
    ctx.fillStyle = ev.type === 'dash' ? '#58a6ff' : '#3fb950';
    ctx.fillRect(px, y - 2, 2, 10);
  }
  if (loopA != null && loopB != null) {
    const a = x + (loopA / maxT) * w;
    const b = x + (loopB / maxT) * w;
    ctx.fillStyle = 'rgba(240,193,74,0.25)';
    ctx.fillRect(a, y - 4, Math.max(2, b - a), 14);
  }
  const cx = x + (cursorT / maxT) * w;
  ctx.fillStyle = '#fff';
  ctx.fillRect(cx - 1, y - 6, 2, 18);
  ctx.fillStyle = '#8b949e';
  ctx.font = '10px system-ui';
  ctx.fillText(`${(cursorT / 1000).toFixed(1)}s / ${(maxT / 1000).toFixed(1)}s`, x, y + 18);
}

export function makeLoopSegment(replayData, startRatio = 0.4, endRatio = 0.7) {
  if (!replayData) return null;
  const maxT = Math.max(
    1,
    ...((replayData.inputs || []).map((i) => i.t) || [1]),
    ...((replayData.frames || []).map((f) => f.t) || [1])
  );
  return { a: maxT * startRatio, b: maxT * endRatio, maxT };
}
