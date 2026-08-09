/** Ghost S-rank trail + timing delta vs live player */

const GHOST_KEY = 'excelion_ghost_s';

export function createGhost() {
  return {
    enabled: true,
    frames: [],
    t0: 0,
    playing: false,
    lastDeltaMs: 0,

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
      this.lastDeltaMs = 0;
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
      return { x: a.x + (b.x - a.x) * u, y: a.y + (b.y - a.y) * u, t: elapsed };
    },

    /** Compare live player position lag vs ghost (ms estimate) */
    compare(player) {
      const g = this.pos();
      if (!g || !player) return null;
      const dist = Math.hypot(player.x - g.x, player.y - g.y);
      // rough: 300px/s movement → ms behind
      this.lastDeltaMs = Math.round((dist / 300) * 1000);
      return { dist, deltaMs: this.lastDeltaMs, ahead: dist < 20 };
    },

    draw(ctx, player) {
      const p = this.pos();
      if (!p) return;
      ctx.save();
      ctx.globalAlpha = 0.38;
      ctx.fillStyle = '#c9d1d9';
      ctx.beginPath();
      ctx.ellipse(p.x, p.y, 10, 16, 0, 0, Math.PI * 2);
      ctx.fill();
      // motion tick (faster feel)
      ctx.globalAlpha = 0.2;
      ctx.fillStyle = '#58a6ff';
      ctx.beginPath();
      ctx.ellipse(p.x - 8, p.y, 6, 10, 0, 0, Math.PI * 2);
      ctx.fill();
      ctx.globalAlpha = 1;

      if (player) {
        const c = this.compare(player);
        if (c) {
          ctx.font = '10px system-ui';
          ctx.fillStyle = c.ahead ? '#3fb950' : '#f0c14a';
          const label = c.ahead ? 'GHOST ~' : `GHOST +${c.deltaMs}ms`;
          ctx.fillText(label, p.x - 18, p.y - 22);
        }
      }
      ctx.restore();
    },
  };
}
