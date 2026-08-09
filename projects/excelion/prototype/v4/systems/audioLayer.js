/** State-based audio layers on top of WebAudio beeps */

let actx = null;
let drone = null;
let rhythm = null;
let harmony = null;

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

function stopNode(n) {
  if (!n) return;
  try {
    n.stop();
  } catch (_) {}
}

export function createAudioLayer() {
  let comboTier = 0;
  let critical = false;

  return {
    resume: ensure,
    dash: () => beep(180, 0.08, 'sawtooth', 0.03),
    hit: () => {
      beep(120, 0.06, 'square', 0.05);
      beep(50, 0.1, 'triangle', 0.04);
    },
    perfect: () => {
      beep(520, 0.06, 'sine', 0.055);
      setTimeout(() => beep(780, 0.1, 'sine', 0.04), 40);
      setTimeout(() => beep(1040, 0.08, 'sine', 0.03), 90);
      if (comboTier >= 2) setTimeout(() => beep(1310, 0.06, 'sine', 0.025), 120);
    },
    hurt: () => {
      beep(80, 0.12, 'sawtooth', 0.06);
      beep(40, 0.2, 'triangle', 0.055);
    },
    miss: () => {
      beep(90, 0.08, 'triangle', 0.03);
      beep(55, 0.15, 'sawtooth', 0.04);
    },
    charge: () => beep(55, 0.2, 'triangle', 0.05),
    warn: () => beep(320, 0.05, 'sine', 0.03),
    warning_beep: () => {
      beep(880, 0.04, 'square', 0.035);
      setTimeout(() => beep(660, 0.05, 'square', 0.03), 50);
    },
    clear: () => {
      beep(440, 0.1);
      setTimeout(() => beep(660, 0.15), 100);
    },

    setComboTier(t) {
      if (t === comboTier) return;
      comboTier = t;
      stopNode(rhythm);
      rhythm = null;
      if (t >= 1) {
        try {
          ensure();
          const o = actx.createOscillator();
          const g = actx.createGain();
          o.type = 'triangle';
          o.frequency.value = 110 + t * 20;
          g.gain.value = 0.008 + t * 0.004;
          o.connect(g);
          g.connect(actx.destination);
          o.start();
          rhythm = o;
        } catch (_) {}
      }
    },

    setCritical(on) {
      if (on === critical) return;
      critical = on;
      if (on) {
        beep(200, 0.3, 'sawtooth', 0.05);
        this.phaseBgm(4);
      }
    },

    setHarmony(on) {
      stopNode(harmony);
      harmony = null;
      if (!on) return;
      try {
        ensure();
        const o = actx.createOscillator();
        const g = actx.createGain();
        o.type = 'sine';
        o.frequency.value = 330;
        g.gain.value = 0.01;
        o.connect(g);
        g.connect(actx.destination);
        o.start();
        harmony = o;
      } catch (_) {}
    },

    phaseBgm(phase) {
      try {
        ensure();
        stopNode(drone);
        const o = actx.createOscillator();
        const g = actx.createGain();
        o.type = 'sine';
        o.frequency.value = critical ? 90 : 55 + phase * 18;
        g.gain.value = critical ? 0.02 : 0.012;
        o.connect(g);
        g.connect(actx.destination);
        o.start();
        drone = o;
      } catch (_) {}
    },
  };
}
