/** Timing windows + hitstop/slow helpers */

export function createTiming(cfg = {}) {
  const perfect = cfg.perfect ?? 0.05;
  const good = cfg.good ?? 0.12;

  return {
    perfect,
    good,
    /**
     * Classify dodge vs attack contact.
     * dashAge: seconds since dash started (0 = just started)
     * invulnLeft: remaining invuln
     * inHit: whether overlapping danger this frame
     */
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
    addHitstop(t) { this.hitstop = Math.max(this.hitstop, t); },
    addShake(t) { this.shake = Math.max(this.shake, t); },
    tick(dt) {
      if (this.hitstop > 0) {
        this.hitstop -= dt;
        return true; // frozen
      }
      if (this.slow > 0) this.slow -= dt;
      if (this.shake > 0) this.shake -= dt;
      if (this.flashRed > 0) this.flashRed -= dt;
      if (this.flashWhite > 0) this.flashWhite -= dt;
      if (this.bossTint > 0) this.bossTint -= dt;
      return false;
    },
    timeScale() {
      return this.slow > 0 ? 0.35 : 1;
    },
  };
}
