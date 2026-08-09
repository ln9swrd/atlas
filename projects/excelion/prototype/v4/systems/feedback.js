/** v12.1 tuning — fixed hitstop · miss persuasion · combo reward */

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
    zoomHold: 0,
    telegraphFlash: 0,
    distort: 0,
    phaseZoom: 0,
    desaturate: 0,
    vignette: 0,
    saturation: 0,
    whiteFrame: 0,
    timingError: '',
    timingLabel: '',
    timingErrorT: 0,
    telegraphReplay: 0,
    missWave: 0,
    missRing: 0,
    missRingX: 0,
    missRingY: 0,
    lastAimX: -1,
    lastAimY: 0,
    lastTelegraphColor: 'rgba(255,55,40,0.8)',
    hitWindowBonus: 0,

    /** PERFECT = full reward 0.15 · GOOD = 70% → 0.10 */
    onPerfect(combo = 0) {
      this.slow = Math.max(this.slow, 0.15);
      this.flashWhite = 0.22;
      this.lineFlash = 0.16;
      this.zoom = Math.max(this.zoom, 0.34);
      this.zoomHold = Math.max(this.zoomHold, 0.14);
      this.whiteFrame = 1;
      this.shake = Math.max(this.shake, 0.05);
      if (combo >= 20) this.hitWindowBonus = Math.min(0.02, 0.01 + Math.floor(combo / 20) * 0.005);
      if (combo >= 30) this.saturation = Math.min(0.35, 0.12 + (combo - 30) * 0.005);
      this.setComboVignette(combo);
    },
    onGood(combo = 0) {
      this.slow = Math.max(this.slow, 0.1);
      this.flashWhite = 0.1;
      this.zoom = Math.max(this.zoom, 0.12);
      this.shake = Math.max(this.shake, 0.04);
      this.setComboVignette(combo);
    },
    /**
     * @param {number} deltaMs
     * @param {'timing'|'range'|string} reason
     * @param {{x?:number,y?:number}} pos
     */
    onMiss(deltaMs, reason = 'timing', pos = {}) {
      this.shake = Math.max(this.shake, 0.34);
      this.flashRed = 0.2;
      this.hitWindowBonus = 0;
      this.saturation = 0;
      if (typeof deltaMs === 'number') {
        const late = deltaMs > 0;
        this.timingLabel = late ? 'LATE' : 'EARLY';
        const sign = late ? '+' : '';
        this.timingError = `${this.timingLabel} ${sign}${Math.round(deltaMs)}ms`;
        this.timingErrorT = 1.4;
      }
      this.telegraphReplay = 0.3;
      if (reason === 'range') {
        this.missRing = 0.45;
        this.missRingX = pos.x || 0;
        this.missRingY = pos.y || 0;
      } else {
        this.missWave = 0.4;
      }
    },
    onHurt() {
      this.shake = Math.max(this.shake, 0.36);
      this.flashRed = 0.2;
      this.bossTint = 0.12;
      this.hitWindowBonus = 0;
    },
    onTelegraph(aimX, aimY, color) {
      this.telegraphFlash = 0.1;
      if (aimX != null) this.lastAimX = aimX;
      if (aimY != null) this.lastAimY = aimY;
      if (color) this.lastTelegraphColor = color;
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
    setComboVignette(combo) {
      this.vignette = combo >= 50 ? 0.35 : combo >= 25 ? 0.15 : 0;
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
        'telegraphFlash',
        'distort',
        'phaseZoom',
        'timingErrorT',
        'telegraphReplay',
        'missWave',
        'missRing',
      ]) {
        if (this[k] > 0) this[k] -= dt;
      }
      if (this.whiteFrame > 0) this.whiteFrame -= 1;
      if (this.zoomHold > 0) this.zoomHold -= dt;
      else if (this.zoom > 0) this.zoom = Math.max(0, this.zoom - dt * 1.8);
    },

    timeScale() {
      if (this.slow >= 0.14) return 0.78;
      if (this.slow >= 0.1) return 0.85;
      if (this.slow > 0) return 0.9;
      return 1;
    },
    zoomScale() {
      const z = Math.max(0, this.zoom);
      return 1 + z * z * 0.14 + Math.max(0, this.phaseZoom) * 0.09;
    },

    comboTier(combo) {
      if (combo >= 50) return 3;
      if (combo >= 25) return 2;
      if (combo >= 10) return 1;
      return 0;
    },

    drawOverlays(ctx, W, H, opts = {}) {
      if (this.whiteFrame > 0) {
        ctx.fillStyle = 'rgba(255,255,255,0.85)';
        ctx.fillRect(0, 0, W, H);
      }
      if (this.desaturate > 0 || opts.finale) {
        ctx.fillStyle = 'rgba(40,35,50,0.22)';
        ctx.fillRect(0, 0, W, H);
      }
      // combo saturation lift (subtle warm overlay)
      if (this.saturation > 0 || (opts.combo || 0) >= 30) {
        const s = Math.max(this.saturation, (opts.combo || 0) >= 30 ? 0.12 : 0);
        ctx.fillStyle = `rgba(255, 200, 120, ${s * 0.15})`;
        ctx.fillRect(0, 0, W, H);
      }
      if (this.vignette > 0 || (opts.combo || 0) >= 50) {
        const v = Math.max(this.vignette, (opts.combo || 0) >= 50 ? 0.3 : 0);
        const g = ctx.createRadialGradient(W / 2, H / 2, H * 0.25, W / 2, H / 2, H * 0.75);
        g.addColorStop(0, 'rgba(0,0,0,0)');
        g.addColorStop(1, `rgba(0,0,0,${v})`);
        ctx.fillStyle = g;
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
      // miss: red wave (timing)
      if (this.missWave > 0) {
        const t = 1 - this.missWave / 0.4;
        ctx.strokeStyle = `rgba(255,50,50,${0.55 * this.missWave / 0.4})`;
        ctx.lineWidth = 3;
        ctx.beginPath();
        for (let x = 0; x < W; x += 6) {
          const y = H * 0.45 + Math.sin(x * 0.04 + t * 12) * (18 + t * 25);
          if (x === 0) ctx.moveTo(x, y);
          else ctx.lineTo(x, y);
        }
        ctx.stroke();
      }
      // miss: distorted ring (range)
      if (this.missRing > 0) {
        const a = this.missRing / 0.45;
        ctx.strokeStyle = `rgba(255,120,80,${0.7 * a})`;
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.ellipse(
          this.missRingX || W / 2,
          this.missRingY || H / 2,
          28 + (1 - a) * 40,
          16 + (1 - a) * 20,
          Math.sin(performance.now() / 80) * 0.4,
          0,
          Math.PI * 2
        );
        ctx.stroke();
      }
      if (this.telegraphFlash > 0 || this.telegraphReplay > 0) {
        const a = Math.max(this.telegraphFlash, this.telegraphReplay) * 0.35;
        ctx.fillStyle = `rgba(255,60,40,${a})`;
        ctx.fillRect(0, 0, W, H);
        if (this.telegraphReplay > 0) {
          ctx.strokeStyle = this.lastTelegraphColor;
          ctx.lineWidth = 4;
          ctx.setLineDash([8, 6]);
          ctx.beginPath();
          ctx.moveTo(W * 0.7, H * 0.5);
          ctx.lineTo(W * 0.7 + this.lastAimX * 400, H * 0.5 + this.lastAimY * 400);
          ctx.stroke();
          ctx.setLineDash([]);
        }
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
      if (this.flashWhite > 0 && this.whiteFrame <= 0) {
        ctx.fillStyle = `rgba(255,255,255,${this.flashWhite * 1.2})`;
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
        const a = combo >= 50 ? 0.7 : combo >= 25 ? 0.4 : 0.22;
        ctx.strokeStyle = `rgba(240,193,74,${a})`;
        ctx.lineWidth = combo >= 50 ? 8 : combo >= 25 ? 5 : 3;
        ctx.strokeRect(3, 3, W - 6, H - 6);
        if (combo >= 50) {
          ctx.shadowColor = 'rgba(240,193,74,0.65)';
          ctx.shadowBlur = 20;
          ctx.strokeRect(6, 6, W - 12, H - 12);
          ctx.shadowBlur = 0;
        }
      }
      if (opts.lowHp) {
        ctx.fillStyle = 'rgba(180,20,40,0.1)';
        ctx.fillRect(0, 0, W, H);
      }
      if (this.timingErrorT > 0 && this.timingError) {
        ctx.fillStyle = `rgba(255,120,100,${Math.min(1, this.timingErrorT)})`;
        ctx.font = 'bold 20px system-ui';
        ctx.textAlign = 'center';
        ctx.fillText(this.timingError, W / 2, H * 0.4);
        if (this.timingLabel) {
          ctx.font = 'bold 14px system-ui';
          ctx.fillStyle = this.timingLabel === 'LATE' ? '#ff7b72' : '#ffa657';
          ctx.fillText(this.timingLabel === 'LATE' ? '늦었습니다' : '빨랐습니다', W / 2, H * 0.4 + 22);
        }
      }
    },

    drawPlayerAura(ctx, p, combo) {
      const tier = this.comboTier(combo);
      if (tier === 0 && combo < 50) return;
      ctx.save();
      if (tier >= 1) {
        ctx.strokeStyle = `rgba(126,200,255,${0.35 + tier * 0.15})`;
        ctx.lineWidth = 2 + tier;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r + 6 + tier * 2, 0, Math.PI * 2);
        ctx.stroke();
      }
      if (combo >= 50) {
        const pulse = 1 + Math.sin(performance.now() / 120) * 0.08;
        ctx.strokeStyle = 'rgba(240,193,74,0.55)';
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.arc(p.x, p.y, (p.r + 18) * pulse, 0, Math.PI * 2);
        ctx.stroke();
      }
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

export function estimateDeltaMs(dashAge, perfectWindow = 0.05) {
  if (dashAge <= 0) return 80;
  return Math.round((dashAge - perfectWindow) * 1000);
}
