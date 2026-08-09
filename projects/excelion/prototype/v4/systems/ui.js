/** DOM UI bindings */

export function createUI() {
  const php = document.getElementById('php');
  const bhp = document.getElementById('bhp');
  const blabel = document.getElementById('blabel');
  const dash = document.getElementById('dash');
  const banner = document.getElementById('banner');
  const reason = document.getElementById('reason');
  const dbg = document.getElementById('dbg');
  const scoreEl = document.getElementById('score');
  const comboEl = document.getElementById('combo');

  let bannerT = 0;

  return {
    showBanner(text, sec = 1.5) {
      banner.textContent = text;
      bannerT = sec;
    },
    setReason(text) {
      reason.textContent = text || '';
    },
    tick(dt, locked) {
      if (bannerT > 0 && bannerT < 90) {
        bannerT -= dt;
        if (bannerT <= 0 && !locked) banner.textContent = '';
      }
    },
    update(player, boss, dashCdMax, debug, stage) {
      php.style.width = `${Math.max(0, player.hp)}%`;
      if (boss && boss.alive) {
        blabel.textContent = `${boss.displayName || 'BOSS'} · P${boss.phase}`;
        bhp.style.width = `${(100 * boss.hp) / boss.maxHp}%`;
      } else if (boss && !boss.alive) {
        blabel.textContent = boss.displayName || 'BOSS';
        bhp.style.width = '0%';
      } else {
        blabel.textContent = '—';
        bhp.style.width = '0%';
      }
      const dashPct =
        player.dashCd <= 0 ? 100 : Math.max(0, 100 * (1 - player.dashCd / dashCdMax));
      dash.style.width = `${dashPct}%`;
      if (scoreEl) scoreEl.textContent = `SCORE ${stage ? stage.score : 0}`;
      if (comboEl) comboEl.textContent = stage && stage.combo > 0 ? `${stage.combo} COMBO` : '';
      dbg.textContent = `F1 HB · F2 GOD · F3 clear · F4 x${debug.speed} · F5 phase · F6 skip · hits:${debug.hits}`;
    },
  };
}
