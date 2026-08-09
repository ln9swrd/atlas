/** Input-frame replay record / playback (localStorage) */

const STORE = 'excelion_replays_v1';
const MAX = 8;

export function createReplayRecorder() {
  return {
    seed: (Math.random() * 1e9) | 0,
    inputs: [],
    frames: [],
    t0: 0,
    recording: false,

    start() {
      this.seed = (Math.random() * 1e9) | 0;
      this.inputs = [];
      this.frames = [];
      this.t0 = performance.now();
      this.recording = true;
    },

    /** type: move|dash|attack · data optional */
    push(type, data = {}) {
      if (!this.recording) return;
      this.inputs.push({
        t: performance.now() - this.t0,
        type,
        ...data,
      });
    },

    samplePos(x, y) {
      if (!this.recording) return;
      const t = performance.now() - this.t0;
      const last = this.frames[this.frames.length - 1];
      if (last && t - last.t < 33) return;
      this.frames.push({ t, x, y });
    },

    stop() {
      this.recording = false;
    },

    toJSON(meta = {}) {
      return {
        seed: this.seed,
        timestamp: Date.now(),
        inputs: this.inputs,
        frames: this.frames,
        ...meta,
      };
    },
  };
}

export function saveReplay(rec, meta) {
  const data = rec.toJSON(meta);
  let list = [];
  try {
    list = JSON.parse(localStorage.getItem(STORE) || '[]');
  } catch (_) {}
  list.unshift(data);
  if (list.length > MAX) list = list.slice(0, MAX);
  localStorage.setItem(STORE, JSON.stringify(list));
  return data;
}

export function listReplays() {
  try {
    return JSON.parse(localStorage.getItem(STORE) || '[]');
  } catch (_) {
    return [];
  }
}

export function getReplay(idOrIndex) {
  const list = listReplays();
  if (typeof idOrIndex === 'number') return list[idOrIndex] || null;
  return list.find((r) => String(r.timestamp) === String(idOrIndex)) || list[0] || null;
}

export function createReplayPlayer(data) {
  const inputs = (data && data.inputs) || [];
  const frames = (data && data.frames) || [];
  let t0 = 0;
  let idx = 0;
  let fidx = 0;
  let playing = false;

  return {
    data,
    playing: false,
    start() {
      t0 = performance.now();
      idx = 0;
      fidx = 0;
      playing = true;
      this.playing = true;
    },
    stop() {
      playing = false;
      this.playing = false;
    },
    /** returns list of input events due this frame */
    tick() {
      if (!playing) return [];
      const elapsed = performance.now() - t0;
      const due = [];
      while (idx < inputs.length && inputs[idx].t <= elapsed) {
        due.push(inputs[idx++]);
      }
      return due;
    },
    ghostPos() {
      if (!playing || !frames.length) return null;
      const elapsed = performance.now() - t0;
      while (fidx < frames.length - 1 && frames[fidx + 1].t <= elapsed) fidx++;
      const a = frames[fidx];
      const b = frames[fidx + 1] || a;
      if (!a) return null;
      const span = b.t - a.t || 1;
      const u = Math.min(1, (elapsed - a.t) / span);
      return { x: a.x + (b.x - a.x) * u, y: a.y + (b.y - a.y) * u };
    },
    done() {
      return playing && idx >= inputs.length && fidx >= frames.length - 1;
    },
  };
}

export function exportReplayJSON(index = 0) {
  const r = getReplay(index);
  return r ? JSON.stringify(r, null, 2) : null;
}
