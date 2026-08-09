/** Timing windows + hitstop/slow/zoom helpers */

export function createTiming(cfg = {}) {
  const perfect = cfg.perfect ?? 0.05;
  const good = cfg.good ?? 0.12;

  return {
    perfect,
    good,
    classifyDodge(dashAge, invulnLeft, wasInvulnOnContact) {
      if (wasInvulnOnContact || invulnLeft > 0) {
        if (dashAge <= perfect) return 'PERFECT';
        if (dashAge <= good) return 'GOOD';
        return 'GOOD';
      }
      if (dashAge > 0 && dashAge < 0.15) return 'TOO EARLY DODGE';
      return 'TOO LATE';
    },
    classifyFakeFail() {
      return 'FAKE READ FAIL';
    },
    classifyComboFail() {
      return 'COMBO POSITION FAIL';
    },
  };
}

export function createFeel() {
  return {
    hitstop: 0,
    shake: 0,
    flashRed: 0,
    flashWhite: 0,
    bossTint: 0,
    slow: 0,
    zoom: 0,
    invert: 0,
    addHitstop(t) {
      this.hitstop = Math.max(this.hitstop, t);
    },
    addShake(t) {
      this.shake = Math.max(this.shake, t);
    },
    triggerPerfect() {
      this.flashWhite = 0.18;
      this.slow = Math.max(this.slow, 0.18);
      this.zoom = Math.max(this.zoom, 0.22);
      this.invert = Math.max(this.invert, 0.08);
      this.addHitstop(0.08);
      this.addShake(0.2);
    },
    triggerGood() {
      this.flashWhite = 0.08;
      this.slow = Math.max(this.slow, 0.1);
      this.addHitstop(0.05);
      this.addShake(0.12);
    },
    tick(dt) {
      if (this.hitstop > 0) {
        this.hitstop -= dt;
        return true;
      }
      if (this.slow > 0) this.slow -= dt;
      if (this.shake > 0) this.shake -= dt;
      if (this.flashRed > 0) this.flashRed -= dt;
      if (this.flashWhite > 0) this.flashWhite -= dt;
      if (this.bossTint > 0) this.bossTint -= dt;
      if (this.zoom > 0) this.zoom -= dt;
      if (this.invert > 0) this.invert -= dt;
      return false;
    },
    timeScale() {
      return this.slow > 0 ? 0.3 : 1;
    },
    zoomScale() {
      return 1 + this.zoom * 0.12;
    },
  };
}
