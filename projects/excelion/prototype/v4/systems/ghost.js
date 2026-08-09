/** Ghost from best S-rank position trail */

const GHOST_KEY = 'excelion_ghost_s';

export function createGhost() {
  return {
    enabled: true,
    frames: [],
    t0: 0,
    playing: false,

    loadBest() {
      try {
        const j = JSON.parse(localStorage.getItem(GHOST_KEY) || 'null');
        this.frames = (j && j.frames) || [];
      } catch (_) {
        this.frames = [];
      }
    },

    saveIfS(rank, frames, meta = {}) {
      if (rank !== 'S' || !frames || frames.length < 10) return false;
      try {
        localStorage.setItem(
          GHOST_KEY,
          JSON.stringify({ rank, frames, timestamp: Date.now(), ...meta })
        );
        return true;
      } catch (_) {
        return false;
      }
    },

    start() {
      this.loadBest();
      this.t0 = performance.now();
      this.playing = this.frames.length > 0 && this.enabled;
    },

    stop() {
      this.playing = false;
    },

    toggle() {
      this.enabled = !this.enabled;
      return this.enabled;
    },

    pos() {
      if (!this.playing || !this.enabled || !this.frames.length) return null;
      const elapsed = performance.now() - this.t0;
      let i = 0;
      while (i < this.frames.length - 1 && this.frames[i + 1].t <= elapsed) i++;
      const a = this.frames[i];
      const b = this.frames[i + 1] || a;
      const span = b.t - a.t || 1;
      const u = Math.min(1, (elapsed - a.t) / span);
      return { x: a.x + (b.x - a.x) * u, y: a.y + (b.y - a.y) * u };
    },

    draw(ctx) {
      const p = this.pos();
      if (!p) return;
      ctx.save();
      ctx.globalAlpha = 0.35;
      ctx.fillStyle = '#c9d1d9';
      ctx.beginPath();
      ctx.ellipse(p.x, p.y, 10, 16, 0, 0, Math.PI * 2);
      ctx.fill();
      ctx.globalAlpha = 1;
      ctx.restore();
    },
  };
}
