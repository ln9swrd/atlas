/** PERFECT rhythm chords · finale low-pass feel */

let actx = null;
let drone = null;
let rhythm = null;
let harmony = null;

function ensure() {
  if (!actx) actx = new (window.AudioContext || window.webkitAudioContext)();
  if (actx.state === 'suspended') actx.resume();
}

function beep(freq, dur, type = 'square', gain = 0.04, delay = 0) {
  try {
    ensure();
    const t0 = actx.currentTime + delay;
    const o = actx.createOscillator();
    const g = actx.createGain();
    o.type = type;
    o.frequency.value = freq;
    g.gain.setValueAtTime(gain, t0);
    g.gain.exponentialRampToValueAtTime(0.001, t0 + dur);
    o.connect(g);
    g.connect(actx.destination);
    o.start(t0);
    o.stop(t0 + dur + 0.02);
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
  let perfectStreak = 0;
  let critical = false;

  return {
    resume: ensure,
    dash: () => beep(180, 0.08, 'sawtooth', 0.03),
    hit: () => {
      beep(140, 0.05, 'square', 0.045);
      beep(60, 0.09, 'triangle', 0.035);
    },
    perfect: () => {
      perfectStreak++;
      // 1–3 single, 4–9 dual, 10+ chord
      beep(660, 0.07, 'sine', 0.06);
      if (perfectStreak >= 4) beep(830, 0.09, 'sine', 0.04, 0.03);
      if (perfectStreak >= 10) {
        beep(990, 0.1, 'sine', 0.035, 0.05);
        beep(1320, 0.12, 'sine', 0.025, 0.08);
      } else {
        beep(990, 0.1, 'sine', 0.04, 0.05);
        beep(1320, 0.1, 'sine', 0.025, 0.1);
      }
      if (comboTier >= 2) beep(1760, 0.08, 'sine', 0.022, 0.14);
    },
    resetPerfectStreak() {
      perfectStreak = 0;
    },
    hurt: () => {
      perfectStreak = 0;
      beep(70, 0.14, 'sawtooth', 0.07);
      beep(35, 0.22, 'triangle', 0.05);
    },
    miss: () => {
      perfectStreak = 0;
      beep(70, 0.12, 'triangle', 0.055);
      beep(42, 0.2, 'sawtooth', 0.05);
      beep(28, 0.25, 'sine', 0.04);
    },
    charge: () => beep(55, 0.22, 'triangle', 0.05),
    warn: () => beep(340, 0.05, 'sine', 0.03),
    warning_beep: () => {
      beep(920, 0.04, 'square', 0.04);
      beep(700, 0.05, 'square', 0.03, 0.05);
    },
    phaseCut: () => {
      beep(200, 0.08, 'sawtooth', 0.06);
      beep(100, 0.2, 'triangle', 0.04, 0.05);
    },
    clear: () => {
      beep(440, 0.1, 'sine', 0.05);
      beep(660, 0.14, 'sine', 0.04, 0.1);
      beep(880, 0.16, 'sine', 0.03, 0.2);
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
          o.frequency.value = 110 + t * 22;
          g.gain.value = 0.008 + t * 0.005;
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
        beep(180, 0.35, 'sawtooth', 0.055);
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
        o.frequency.value = 330 + comboTier * 40;
        g.gain.value = 0.012;
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
        // finale/critical: lower, heavier
        o.frequency.value = critical || phase >= 4 ? 48 + phase * 4 : 55 + phase * 18;
        g.gain.value = critical || phase >= 4 ? 0.028 : 0.012;
        o.connect(g);
        g.connect(actx.destination);
        o.start();
        drone = o;
      } catch (_) {}
    },
  };
}
