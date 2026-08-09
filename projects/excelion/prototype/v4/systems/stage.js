/** Stage / boss fight lifecycle */

export function createStage() {
  return {
    bossDef: null,
    status: 'select', // select | fight | clear | fail
    phase: 1,
    stageTime: 0,
    hitsTaken: 0,
    perfects: 0,
    goods: 0,

    setBoss(def) {
      this.bossDef = def;
      this.status = 'fight';
      this.phase = 1;
      this.stageTime = 0;
      this.hitsTaken = 0;
      this.perfects = 0;
      this.goods = 0;
    },

    computePhase(hpRatio, thresholds) {
      // thresholds [1, 0.66, 0.33] → phase 1 while >0.66, etc.
      const t = thresholds || [1, 0.66, 0.33];
      if (hpRatio > t[1]) return 1;
      if (hpRatio > t[2]) return 2;
      return 3;
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
