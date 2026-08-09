/** Boot overlay + share button wiring (loaded after main systems exist) */

import { buildShareUrl, readShareFromLocation } from './systems/share.js';

const TUTORIAL_KEY = 'excelion_tutorial_seen';

export function wireBoot(api) {
  const boot = document.getElementById('boot');
  const start = document.getElementById('btnStart');
  const tut = document.getElementById('btnTutorial');
  const share = document.getElementById('btnShare');
  const guide = document.getElementById('guide');

  function hideBoot() {
    if (boot) boot.classList.add('hidden');
  }

  if (start) {
    start.onclick = () => {
      hideBoot();
      api.startNemesis();
      if (!localStorage.getItem(TUTORIAL_KEY)) {
        if (guide) guide.textContent = '노란 선=가짜 · 빨간 선=위험 · 흰색=돌진 직전 · Space 대시';
        setTimeout(() => {
          if (guide) guide.textContent = '';
          localStorage.setItem(TUTORIAL_KEY, '1');
        }, 6000);
      }
    };
  }
  if (tut) {
    tut.onclick = () => {
      if (guide)
        guide.textContent =
          '튜토리얼: 예고선이 두꺼워질수록 임박. 중앙 타이밍바 = PERFECT. Space로 회피.';
      hideBoot();
      api.startNemesis();
      localStorage.setItem(TUTORIAL_KEY, '1');
    };
  }
  if (share) {
    share.onclick = () => {
      const url = buildShareUrl(api.getMeta());
      navigator.clipboard?.writeText(url);
      if (guide) guide.textContent = 'Share URL copied';
      console.log(url);
    };
  }

  const shared = readShareFromLocation();
  if (shared && guide) {
    guide.textContent = `Shared challenge · rank ${shared.r || '?'} score ${shared.s || 0}`;
  }

  return { hideBoot };
}
