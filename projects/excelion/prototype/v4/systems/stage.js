/** Stage lifecycle + score loop */

const PTS = { PERFECT: 100, GOOD: 50, MISS: 0 };

export function createStage() {
  return {
    bossDef: null,
    status: 'select',
    phase: 1,
    stageTime: 0,
    hitsTaken: 0,
    perfects: 0,
    goods: 0,
    misses: 0,
    score: 0,
    combo: 0,
    maxCombo: 0,
    judgments: 0,
    lastFile: null,

    setBoss(def, file) {
      this.bossDef = def;
      this.lastFile = file || null;
      this.status = 'fight';
      this.phase = 1;
      this.stageTime = 0;
      this.hitsTaken = 0;
      this.perfects = 0;
      this.goods = 0;
      this.misses = 0;
      this.score = 0;
      this.combo = 0;
      this.maxCombo = 0;
      this.judgments = 0;
    },

    addJudgment(kind) {
      this.judgments++;
      if (kind === 'PERFECT') {
        this.perfects++;
        this.combo++;
        this.score += Math.floor(PTS.PERFECT * (1 + this.combo * 0.05));
      } else if (kind === 'GOOD') {
        this.goods++;
        this.combo++;
        this.score += Math.floor(PTS.GOOD * (1 + this.combo * 0.05));
      } else {
        this.misses++;
        this.combo = 0;
      }
      if (this.combo > this.maxCombo) this.maxCombo = this.combo;
    },

    breakCombo() {
      this.combo = 0;
      this.misses++;
      this.judgments++;
    },

    accuracy() {
      if (this.judgments <= 0) return 0;
      return Math.round((100 * (this.perfects + this.goods * 0.5)) / this.judgments);
    },

    computePhase(hpRatio, thresholds) {
      const t = thresholds || [1, 0.66, 0.33];
      if (hpRatio > t[1]) return 1;
      if (hpRatio > t[2]) return 2;
      return 3;
    },

    phaseLabel() {
      const labels = (this.bossDef && this.bossDef.phaseLabels) || {};
      return labels[String(this.phase)] || `PHASE ${this.phase}`;
    },

    onClear() {
      this.status = 'clear';
    },
    onFail() {
      this.status = 'fail';
    },
    backToSelect() {
      this.status = 'select';
      this.bossDef = null;
    },
  };
}
