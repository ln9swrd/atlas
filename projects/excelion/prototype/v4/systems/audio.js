/**
 * Audio — WebAudio fallback.
 * Optional files (place under projects/excelion/assets/audio/):
 *   hit.wav · perfect.wav · warning.wav · dash.wav · charge.wav
 */

let actx = null;

function ensure() {
  if (!actx) actx = new (window.AudioContext || window.webkitAudioContext)();
  if (actx.state === 'suspended') actx.resume();
}

function beep(freq, dur, type = 'square', gain = 0.04) {
  try {
    ensure();
    const o = actx.createOscillator();
    const g = actx.createGain();
    o.type = type;
    o.frequency.value = freq;
    g.gain.value = gain;
    o.connect(g);
    g.connect(actx.destination);
    o.start();
    g.gain.exponentialRampToValueAtTime(0.001, actx.currentTime + dur);
    o.stop(actx.currentTime + dur);
  } catch (_) {}
}

export function createAudio() {
  return {
    resume: ensure,
    dash: () => beep(180, 0.08, 'sawtooth', 0.03),
    hit: () => beep(120, 0.06, 'square', 0.05),
    perfect: () => {
      beep(520, 0.06, 'sine', 0.05);
      setTimeout(() => beep(780, 0.1, 'sine', 0.04), 40);
    },
    hurt: () => beep(80, 0.12, 'sawtooth', 0.06),
    miss: () => beep(90, 0.08, 'triangle', 0.03),
    charge: () => beep(55, 0.2, 'triangle', 0.05),
    warn: () => beep(320, 0.05, 'sine', 0.03),
    clear: () => {
      beep(440, 0.1);
      setTimeout(() => beep(660, 0.15), 100);
    },
  };
}
