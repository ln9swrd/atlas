/** 5-minute addiction / session metrics */

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

    begin() {
      if (!this.startedAt) this.startedAt = performance.now();
    },

    onRetry() {
      this.retries++;
      this.lastEndAt = performance.now();
    },

    onJudgment(type, combo) {
      if (type === 'PERFECT') this.perfects++;
      else if (type === 'GOOD') this.goods++;
      else if (type === 'MISS') this.misses++;
      if (combo > this.maxCombo) this.maxCombo = combo;
      this.comboSum += combo;
      this.comboSamples++;
    },

    snapshot() {
      const total = Math.max(1, this.perfects + this.goods + this.misses);
      const mins = this.startedAt ? (performance.now() - this.startedAt) / 60000 : 0;
      return {
        sessionMin: +mins.toFixed(2),
        retries: this.retries,
        perfectPct: +((this.perfects / total) * 100).toFixed(1),
        avgCombo: this.comboSamples
          ? +(this.comboSum / this.comboSamples).toFixed(1)
          : 0,
        maxCombo: this.maxCombo,
        stopHint: this.retries >= 3 ? 'addiction_ok' : 'need_more_retries',
      };
    },
  };
}
