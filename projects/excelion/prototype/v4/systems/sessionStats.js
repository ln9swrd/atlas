/** Session metrics → mild difficulty suggestion */

export function createSessionStats() {
  return {
    startedAt: 0,
    retries: 0,
    perfects: 0,
    goods: 0,
    misses: 0,
    maxCombo: 0,
    comboSum: 0,
    comboSamples: 0,
    lastEndAt: 0,
    runStarts: [],

    begin() {
      if (!this.startedAt) this.startedAt = performance.now();
      this.runStarts.push(performance.now());
    },

    onRetry() {
      this.retries++;
      this.lastEndAt = performance.now();
      this.runStarts.push(performance.now());
    },

    onJudgment(type, combo) {
      if (type === 'PERFECT') this.perfects++;
      else if (type === 'GOOD') this.goods++;
      else if (type === 'MISS') this.misses++;
      if (combo > this.maxCombo) this.maxCombo = combo;
      this.comboSum += combo;
      this.comboSamples++;
    },

    avgRunSec() {
      if (this.runStarts.length < 2) return 999;
      const gaps = [];
      for (let i = 1; i < this.runStarts.length; i++) {
        gaps.push((this.runStarts[i] - this.runStarts[i - 1]) / 1000);
      }
      return gaps.reduce((a, b) => a + b, 0) / gaps.length;
    },

    /** true → slightly ease (telegraph longer / less speed) */
    shouldEase() {
      return this.retries >= 3 && this.avgRunSec() < 60;
    },

    applyEase(boss) {
      if (!this.shouldEase() || !boss) return false;
      boss.telegraphScaleTarget = Math.min(1.15, (boss.telegraphScaleTarget || 1) + 0.05);
      boss.adaptSpeed = Math.max(1, (boss.adaptSpeed || 1) * 0.97);
      return true;
    },

    snapshot() {
      const total = Math.max(1, this.perfects + this.goods + this.misses);
      const mins = this.startedAt ? (performance.now() - this.startedAt) / 60000 : 0;
      return {
        sessionMin: +mins.toFixed(2),
        retries: this.retries,
        avgRunSec: +this.avgRunSec().toFixed(1),
        perfectPct: +((this.perfects / total) * 100).toFixed(1),
        avgCombo: this.comboSamples ? +(this.comboSum / this.comboSamples).toFixed(1) : 0,
        maxCombo: this.maxCombo,
        easeSuggested: this.shouldEase(),
        stopHint: this.retries >= 3 ? 'addiction_ok' : 'need_more_retries',
      };
    },
  };
}
