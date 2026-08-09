/** Player movement, dash, input buffer */

export function createPlayer(timingCfg, W, H) {
  const dashInvuln = timingCfg.dashInvuln ?? 0.3;
  const dashDuration = timingCfg.dashDuration ?? 0.28;
  const dashCd = timingCfg.dashCooldown ?? 0.85;

  const p = {
    x: 180,
    y: H / 2,
    r: 14,
    hp: 100,
    maxHp: 100,
    speed: 230,
    dashT: 0,
    dashCd: 0,
    invuln: 0,
    facing: 1,
    flash: 0,
    dashAge: 0,
    bufferAttack: 0,
    bufferDash: 0,
  };

  const BUFFER = 0.12;

  return {
    p,
    dashInvuln,
    dashDuration,
    dashCd,
    queue() {
      p.x = 180;
      p.y = H / 2;
      p.hp = 100;
      p.dashT = p.dashCd = p.invuln = 0;
      p.dashAge = 0;
      p.bufferAttack = p.bufferDash = 0;
      p.flash = 0;
    },
    queueAttack() {
      p.bufferAttack = BUFFER;
    },
    queueDash() {
      p.bufferDash = BUFFER;
    },
    tryDash(sfx) {
      if (p.dashCd > 0 || p.dashT > 0) return false;
      p.dashT = dashDuration;
      p.invuln = dashInvuln;
      p.dashCd = dashCd;
      p.dashAge = 0;
      p.bufferDash = 0;
      if (sfx) sfx.dash();
      return true;
    },
    update(dt, keys, bounds) {
      if (p.bufferAttack > 0) p.bufferAttack -= dt;
      if (p.bufferDash > 0) p.bufferDash -= dt;

      if (p.bufferDash > 0) this.tryDash();

      let mx = 0, my = 0;
      if (keys['KeyW'] || keys['ArrowUp']) my -= 1;
      if (keys['KeyS'] || keys['ArrowDown']) my += 1;
      if (keys['KeyA'] || keys['ArrowLeft']) mx -= 1;
      if (keys['KeyD'] || keys['ArrowRight']) mx += 1;
      if (mx || my) {
        const len = Math.hypot(mx, my);
        mx /= len; my /= len;
        p.facing = mx >= 0 ? 1 : -1;
        const sp = p.speed * (p.dashT > 0 ? 2.5 : 1);
        p.x += mx * sp * dt;
        p.y += my * sp * dt;
      }
      p.x = Math.max(p.r, Math.min(bounds.W - p.r, p.x));
      p.y = Math.max(p.r, Math.min(bounds.H - p.r, p.y));

      if (p.dashT > 0) {
        p.dashT -= dt;
        p.dashAge += dt;
      }
      if (p.dashCd > 0) p.dashCd -= dt;
      if (p.invuln > 0) p.invuln -= dt;
      if (p.flash > 0) p.flash -= dt;
    },
    consumeAttackBuffer() {
      if (p.bufferAttack > 0) {
        p.bufferAttack = 0;
        return true;
      }
      return false;
    },
  };
}
