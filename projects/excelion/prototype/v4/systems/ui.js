/** DOM UI bindings */

export function createUI() {
  const php = document.getElementById('php');
  const bhp = document.getElementById('bhp');
  const blabel = document.getElementById('blabel');
  const dash = document.getElementById('dash');
  const banner = document.getElementById('banner');
  const reason = document.getElementById('reason');
  const dbg = document.getElementById('dbg');

  let bannerT = 0;

  return {
    showBanner(text, sec = 1.5) {
      banner.textContent = text;
      bannerT = sec;
    },
    setReason(text) {
      reason.textContent = text || '';
    },
    tick(dt, cleared, gameOver) {
      if (bannerT > 0 && bannerT < 90) {
        bannerT -= dt;
        if (bannerT <= 0 && !cleared && !gameOver) banner.textContent = '';
      }
    },
    update(player, enemies, dashCdMax, debug) {
      php.style.width = `${Math.max(0, player.hp)}%`;
      const alive = enemies.filter((e) => e.alive);
      const focus = alive.find((e) => e.type === 'anubis') || alive[0];
      if (focus) {
        blabel.textContent =
          focus.type === 'anubis' ? `ANUBIS P${focus.phase}` : focus.type.toUpperCase();
        bhp.style.width = `${(100 * focus.hp) / focus.maxHp}%`;
      } else {
        blabel.textContent = '—';
        bhp.style.width = '0%';
      }
      const dashPct =
        player.dashCd <= 0 ? 100 : Math.max(0, 100 * (1 - player.dashCd / dashCdMax));
      dash.style.width = `${dashPct}%`;
      dbg.textContent = `F1 HB:${debug.hb ? 'ON' : 'off'} · F2 GOD:${debug.god ? 'ON' : 'off'} · F3 skip · F4 x${debug.speed} · F5 loop:${debug.loop ? 'ON' : 'off'} · hits:${debug.hits}`;
    },
  };
}
