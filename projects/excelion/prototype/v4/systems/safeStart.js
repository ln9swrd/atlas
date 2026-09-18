/** Guard when playerSys not ready or reset missing */

export function safePlayerReset(playerSys, W = 800, H = 480) {
  if (!playerSys) return false;
  if (typeof playerSys.reset === 'function') {
    playerSys.reset();
    return true;
  }
  // fallback inline
  const p = playerSys.p;
  if (!p) return false;
  p.x = 180;
  p.y = H / 2;
  p.hp = p.maxHp || 100;
  p.dashT = 0;
  p.dashCd = 0;
  p.invuln = 0;
  p.dashAge = 0;
  p.bufferAttack = 0;
  p.bufferDash = 0;
  p.flash = 0;
  return true;
}
