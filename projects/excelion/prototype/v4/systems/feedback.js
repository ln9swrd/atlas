/** Hit Feedback 2.0 + combo visual evolution */

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

    onPerfect() {
      this.slow = Math.max(this.slow, 0.08);
      this.flashWhite = 0.16;
      this.lineFlash = 0.12;
      this.zoom = Math.max(this.zoom, 0.18);
      this.shake = Math.max(this.shake, 0.08);
    },
    onGood() {
      this.slow = Math.max(this.slow, 0.05);
      this.flashWhite = 0.06;
      this.shake = Math.max(this.shake, 0.06);
    },
    onMiss() {
      this.shake = Math.max(this.shake, 0.28);
      this.flashRed = 0.12;
    },
    onHurt() {
      this.shake = Math.max(this.shake, 0.3);
      this.flashRed = 0.14;
      this.bossTint = 0.1;
    },
    onTelegraph() {
      this.telegraphFlash = 0.18;
    },
    onCriticalEnter() {
      this.flashRed = 0.35;
      this.shake = 0.4;
      this.invert = 0.15;
    },

    tick(dt) {
      const keys = [
        'slow',
        'shake',
        'flashWhite',
        'flashRed',
        'lineFlash',
        'bossTint',
        'invert',
        'zoom',
        'telegraphFlash',
      ];
      for (const k of keys) if (this[k] > 0) this[k] -= dt;
    },

    timeScale() {
      return this.slow > 0 ? 0.85 : 1;
    },
    zoomScale() {
      return 1 + Math.max(0, this.zoom) * 0.1;
    },

    /** Combo visual tier 0/1/2/3 */
    comboTier(combo) {
      if (combo >= 50) return 3;
      if (combo >= 25) return 2;
      if (combo >= 10) return 1;
      return 0;
    },

    drawOverlays(ctx, W, H) {
      if (this.telegraphFlash > 0) {
        ctx.fillStyle = `rgba(255,60,40,${this.telegraphFlash * 0.35})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.lineFlash > 0) {
        ctx.strokeStyle = `rgba(255,255,255,${this.lineFlash * 2})`;
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(0, H * 0.5);
        ctx.lineTo(W, H * 0.5);
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(W * 0.5, 0);
        ctx.lineTo(W * 0.5, H);
        ctx.stroke();
      }
      if (this.flashRed > 0) {
        ctx.fillStyle = `rgba(255,40,40,${Math.min(0.5, this.flashRed * 2)})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.flashWhite > 0) {
        ctx.fillStyle = `rgba(255,255,255,${this.flashWhite * 1.3})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.bossTint > 0) {
        ctx.fillStyle = `rgba(120,40,180,${this.bossTint})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.invert > 0) {
        ctx.fillStyle = `rgba(255,255,255,${this.invert * 0.4})`;
        ctx.globalCompositeOperation = 'difference';
        ctx.fillRect(0, 0, W, H);
        ctx.globalCompositeOperation = 'source-over';
      }
    },

    drawPlayerAura(ctx, p, combo) {
      const tier = this.comboTier(combo);
      if (tier === 0) return;
      ctx.save();
      if (tier >= 1) {
        ctx.strokeStyle = `rgba(126,200,255,${0.35 + tier * 0.15})`;
        ctx.lineWidth = 2 + tier;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r + 6 + tier * 2, 0, Math.PI * 2);
        ctx.stroke();
      }
      if (tier >= 2) {
        ctx.globalAlpha = 0.35;
        ctx.fillStyle = '#7ec8ff';
        ctx.beginPath();
        ctx.ellipse(p.x - p.facing * 10, p.y, p.r * 0.5, p.r * 0.8, 0, 0, Math.PI * 2);
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
