/** Audio — WebAudio fallback + phase BGM drone */

let actx = null;
let drone = null;

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
    hit: () => {
      beep(120, 0.06, 'square', 0.05);
      beep(50, 0.1, 'triangle', 0.04);
    },
    perfect: () => {
      beep(520, 0.06, 'sine', 0.055);
      setTimeout(() => beep(780, 0.12, 'sine', 0.045), 40);
      setTimeout(() => beep(1040, 0.08, 'sine', 0.03), 90);
    },
    hurt: () => {
      beep(80, 0.12, 'sawtooth', 0.06);
      beep(40, 0.18, 'triangle', 0.05);
    },
    miss: () => beep(90, 0.08, 'triangle', 0.03),
    charge: () => beep(55, 0.2, 'triangle', 0.05),
    warn: () => beep(320, 0.05, 'sine', 0.03),
    clear: () => {
      beep(440, 0.1);
      setTimeout(() => beep(660, 0.15), 100);
    },
    phaseBgm(phase) {
      try {
        ensure();
        if (drone) {
          try {
            drone.stop();
          } catch (_) {}
          drone = null;
        }
        const o = actx.createOscillator();
        const g = actx.createGain();
        o.type = 'sine';
        o.frequency.value = 55 + phase * 18;
        g.gain.value = 0.012;
        o.connect(g);
        g.connect(actx.destination);
        o.start();
        drone = o;
      } catch (_) {}
    },
  };
}
