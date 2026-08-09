/** Feel Polish — hitstop · zoom · desaturate · combo edge glow */

export function createFeedback() {
  return {
    slow: 0,
    shake: 0,
    flashWhite: 0,
    flashRed: 0,
    lineFlash: 0,
    bossTint: 0,
    invert: 0,
    zoom: 0,
    telegraphFlash: 0,
    distort: 0,
    phaseZoom: 0,
    desaturate: 0,

    onPerfect() {
      this.slow = Math.max(this.slow, 0.1);
      this.flashWhite = 0.18;
      this.lineFlash = 0.14;
      this.zoom = Math.max(this.zoom, 0.28);
      this.shake = Math.max(this.shake, 0.06);
    },
    onGood() {
      this.slow = Math.max(this.slow, 0.06);
      this.flashWhite = 0.07;
      this.shake = Math.max(this.shake, 0.05);
    },
    onMiss() {
      this.shake = Math.max(this.shake, 0.32);
      this.flashRed = 0.16;
    },
    onHurt() {
      this.shake = Math.max(this.shake, 0.34);
      this.flashRed = 0.18;
      this.bossTint = 0.12;
    },
    onTelegraph() {
      this.telegraphFlash = 0.12;
    },
    onCriticalEnter() {
      this.flashRed = 0.35;
      this.shake = 0.42;
      this.invert = 0.12;
      this.distort = 0.55;
      this.phaseZoom = 0.5;
    },
    onFinaleEnter() {
      this.desaturate = 1;
      this.distort = 0.6;
      this.phaseZoom = 0.55;
      this.flashRed = 0.25;
    },
    onPhaseEnter() {
      this.phaseZoom = 0.38;
      this.flashWhite = 0.12;
    },

    tick(dt) {
      for (const k of [
        'slow',
        'shake',
        'flashWhite',
        'flashRed',
        'lineFlash',
        'bossTint',
        'invert',
        'zoom',
        'telegraphFlash',
        'distort',
        'phaseZoom',
      ]) {
        if (this[k] > 0) this[k] -= dt;
      }
      // desaturate stays while finale; decay only when cleared externally
    },

    timeScale() {
      if (this.slow > 0.05) return 0.82;
      if (this.slow > 0) return 0.88;
      return 1;
    },
    zoomScale() {
      return 1 + Math.max(0, this.zoom) * 0.12 + Math.max(0, this.phaseZoom) * 0.09;
    },

    comboTier(combo) {
      if (combo >= 50) return 3;
      if (combo >= 25) return 2;
      if (combo >= 10) return 1;
      return 0;
    },

    drawOverlays(ctx, W, H, opts = {}) {
      if (this.desaturate > 0 || opts.finale) {
        ctx.fillStyle = 'rgba(40,35,50,0.22)';
        ctx.fillRect(0, 0, W, H);
      }
      if (this.distort > 0) {
        for (let i = 0; i < 4; i++) {
          ctx.strokeStyle = `rgba(180,40,255,${this.distort * 0.12})`;
          ctx.beginPath();
          ctx.moveTo(0, (H / 4) * i + Math.sin(performance.now() / 35 + i) * 8);
          ctx.lineTo(W, (H / 4) * i + Math.cos(performance.now() / 45 + i) * 8);
          ctx.stroke();
        }
      }
      if (this.telegraphFlash > 0) {
        ctx.fillStyle = `rgba(255,60,40,${this.telegraphFlash * 0.25})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.lineFlash > 0) {
        ctx.strokeStyle = `rgba(255,255,255,${this.lineFlash * 2})`;
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(0, H * 0.5);
        ctx.lineTo(W, H * 0.5);
        ctx.moveTo(W * 0.5, 0);
        ctx.lineTo(W * 0.5, H);
        ctx.stroke();
      }
      if (this.flashRed > 0) {
        ctx.fillStyle = `rgba(255,40,40,${Math.min(0.55, this.flashRed * 2.2)})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.flashWhite > 0) {
        ctx.fillStyle = `rgba(255,255,255,${this.flashWhite * 1.35})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.bossTint > 0) {
        ctx.fillStyle = `rgba(120,40,180,${this.bossTint})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.invert > 0) {
        ctx.fillStyle = `rgba(255,255,255,${this.invert * 0.35})`;
        ctx.globalCompositeOperation = 'difference';
        ctx.fillRect(0, 0, W, H);
        ctx.globalCompositeOperation = 'source-over';
      }
      const combo = opts.combo || 0;
      if (combo >= 10) {
        const a = combo >= 50 ? 0.65 : combo >= 25 ? 0.4 : 0.22;
        ctx.strokeStyle = `rgba(240,193,74,${a})`;
        ctx.lineWidth = combo >= 50 ? 8 : combo >= 25 ? 5 : 3;
        ctx.strokeRect(3, 3, W - 6, H - 6);
        if (combo >= 50) {
          ctx.shadowColor = 'rgba(240,193,74,0.6)';
          ctx.shadowBlur = 18;
          ctx.strokeRect(6, 6, W - 12, H - 12);
          ctx.shadowBlur = 0;
        }
      }
      if (opts.lowHp) {
        ctx.fillStyle = 'rgba(180,20,40,0.1)';
        ctx.fillRect(0, 0, W, H);
        ctx.strokeStyle = 'rgba(255,60,60,0.4)';
        ctx.lineWidth = 3;
        ctx.strokeRect(2, 2, W - 4, H - 4);
      }
    },

    drawPlayerAura(ctx, p, combo) {
      const tier = this.comboTier(combo);
      if (tier === 0) return;
      ctx.save();
      ctx.strokeStyle = `rgba(126,200,255,${0.35 + tier * 0.15})`;
      ctx.lineWidth = 2 + tier;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r + 6 + tier * 2, 0, Math.PI * 2);
      ctx.stroke();
      if (tier >= 2) {
        ctx.globalAlpha = 0.4;
        ctx.fillStyle = '#7ec8ff';
        ctx.beginPath();
        ctx.ellipse(p.x - p.facing * 12, p.y, p.r * 0.55, p.r * 0.85, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.globalAlpha = 1;
      }
      ctx.restore();
    },
  };
}

export function computeRank(accuracy, maxCombo, hitsTaken, cleared) {
  if (!cleared) return 'C';
  if (accuracy >= 90 && hitsTaken <= 1 && maxCombo >= 20) return 'S';
  if (accuracy >= 75 && hitsTaken <= 3) return 'A';
  if (accuracy >= 55) return 'B';
  return 'C';
}
