import { createTiming } from './systems/timing.js';
import { createPlayer } from './systems/player.js';
import { makeBossFromDef, updateBoss, drawBoss } from './systems/boss.js';
import { createUI } from './systems/ui.js';
import { createStage } from './systems/stage.js';
import { createPatternRunner, applyPatternCmd } from './systems/patternRunner.js';
import { createFeedback, computeRank } from './systems/feedback.js';
import { createAudioLayer } from './systems/audioLayer.js';
import { resolveChains, applyCritical, adaptiveSnapshot } from './systems/adaptive.js';

const canvas = document.getElementById('c');
const ctx = canvas.getContext('2d');
const W = 800;
const H = 480;
const BEST_KEY = 'excelion_nemesis_best';

const keys = {};
let roster = null;
let bossCache = {};
let patternCache = {};
let timing = null;
let fb = null;
let playerSys = null;
let ui = null;
let sfx = null;
let stage = null;
let boss = null;
let runner = null;
let lastDeath = '';
let lastBossFile = null;
let lastPatternId = null;
let improved = false;
let lastRank = 'C';

window.debugNemesis = false;
const debug = { hb: false, god: false, speed: 1, hits: 0, timeline: false };

async function loadBossFile(file) {
  if (bossCache[file]) return bossCache[file];
  const res = await fetch('./data/' + file);
  bossCache[file] = await res.json();
  return bossCache[file];
}
async function loadPattern(id) {
  if (patternCache[id]) return patternCache[id];
  const res = await fetch('./data/patterns/' + id + '.json');
  patternCache[id] = await res.json();
  return patternCache[id];
}
async function loadData() {
  roster = await (await fetch('./data/roster.json')).json();
  timing = createTiming(roster.timing);
  fb = createFeedback();
  playerSys = createPlayer(roster.timing, W, H);
  ui = createUI();
  sfx = createAudioLayer();
  stage = createStage();
  runner = createPatternRunner();
}

async function startNextPattern() {
  if (!boss || !boss.patternDriven) return;
  const chainTo = resolveChains(boss.def, lastPatternId, stage);
  const ph = boss.def.phases.find((p) => p.id === boss.phase) || boss.def.phases[boss.phase - 1];
  if (!ph && !chainTo) return;
  let list = (ph && ph.patterns ? ph.patterns.slice() : []);
  if (boss.extraPatterns.length) list = boss.extraPatterns.concat(list);
  let id = chainTo || list[boss.patternCursor % Math.max(1, list.length)];
  if (!chainTo) boss.patternCursor++;
  lastPatternId = id;
  const pat = await loadPattern(id);
  runner.load(pat);
}

async function startBoss(file) {
  const def = await loadBossFile(file);
  lastBossFile = file;
  stage.setBoss(def, file);
  playerSys.reset();
  boss = makeBossFromDef(def, 640, H / 2);
  boss.critical = false;
  lastDeath = '';
  lastPatternId = null;
  improved = false;
  ui.setReason('');
  ui.showBanner(def.displayName, 1.4);
  sfx.warn();
  sfx.phaseBgm(1);
  sfx.setCritical(false);
  sfx.setComboTier(0);
  sfx.setHarmony(false);
  debug.hits = 0;
  if (boss.patternDriven) {
    runner.stop();
    await startNextPattern();
  }
}

function onPhaseChange(e, phase) {
  fb.flashWhite = 0.2;
  fb.shake = 0.25;
  ui.showBanner(stage.phaseLabel(), 2.0);
  sfx.warn();
  sfx.phaseBgm(phase);
  e.patternCursor = 0;
  if (e.patternDriven) {
    runner.stop();
    startNextPattern();
  }
}

function onHitPlayer(e) {
  const p = playerSys.p;
  if (debug.god || p.invuln > 0 || stage.status !== 'fight') return;
  p.hp -= e.damage;
  stage.hitsTaken++;
  stage.breakCombo();
  debug.hits = stage.hitsTaken;
  p.flash = 0.12;
  fb.onHurt();
  sfx.hurt();
  sfx.setComboTier(0);
  sfx.setHarmony(false);
  let reason;
  if (e._act && e._act.type === 'fake') reason = timing.classifyFakeFail();
  else if (e.comboLeft > 0 || e.redirectLeft > 0) reason = timing.classifyComboFail();
  else reason = timing.classifyDodge(p.dashAge, p.invuln, false);
  if (p.hp <= 0) {
    stage.onFail();
    lastDeath = reason;
    finishResult(false);
  } else ui.setReason(reason);
}

function playerAttack() {
  if (stage.status !== 'fight' || !boss || !boss.alive) return;
  const p = playerSys.p;
  const dx = boss.x - p.x;
  const dy = boss.y - p.y;
  if (dx * dx + dy * dy < (p.r + boss.r + 22) ** 2) {
    boss.hp -= 14;
    boss.flash = 0.1;
    boss.scale = 0.88;
    if (p.invuln > 0 && p.dashAge <= timing.perfect) {
      fb.onPerfect();
      stage.addJudgment('PERFECT');
      sfx.perfect();
      ui.setReason('PERFECT');
      sfx.setComboTier(fb.comboTier(stage.combo));
      if (stage.combo >= 10) sfx.setHarmony(true);
    } else if (p.invuln > 0) {
      fb.onGood();
      stage.addJudgment('GOOD');
      sfx.hit();
      ui.setReason('GOOD');
      sfx.setComboTier(fb.comboTier(stage.combo));
    } else {
      fb.onMiss();
      sfx.miss();
      stage.addJudgment('MISS');
      sfx.setHarmony(false);
    }
    if (applyCritical(boss, stage, fb, sfx)) {
      ui.showBanner(boss.def.critical.label || 'CRITICAL', 2.2);
    }
    if (boss.hp <= 0) {
      boss.alive = false;
      stage.onClear();
      sfx.clear();
      finishResult(true);
    }
  }
}

function finishResult(cleared) {
  lastRank = computeRank(stage.accuracy(), stage.maxCombo, stage.hitsTaken, cleared);
  if (cleared && lastBossFile && lastBossFile.includes('nemesis')) {
    try {
      const prev = JSON.parse(localStorage.getItem(BEST_KEY) || 'null');
      if (!prev || stage.score > prev.score) {
        improved = !!prev;
        localStorage.setItem(
          BEST_KEY,
          JSON.stringify({ score: stage.score, rank: lastRank, acc: stage.accuracy() })
        );
      } else if (prev && stage.score > prev.score * 0.95) improved = true;
    } catch (_) {}
  }
  ui.showBanner(cleared ? 'CLEAR' : 'YOU DIED', 99);
}

function update(dt) {
  const scaled = dt * debug.speed;
  fb.tick(scaled);
  const t = scaled * fb.timeScale();
  ui.tick(t, stage.status === 'clear' || stage.status === 'fail');
  if (stage.status !== 'fight') return;
  stage.stageTime += t;
  playerSys.update(t, keys, { W, H });
  if (playerSys.consumeAttackBuffer()) playerAttack();

  if (boss && boss.patternDriven) {
    const mod = boss.def.phases.find((p) => p.id === boss.phase);
    let speedScale = ((mod && mod.modifier && mod.modifier.speed_scale) || 1) * (boss.adaptSpeed || 1);
    if (boss.critical && boss.def.critical?.modifiers?.speed) {
      speedScale *= boss.def.critical.modifiers.speed / Math.max(1, boss.adaptSpeed);
      speedScale = Math.max(speedScale, boss.def.critical.modifiers.speed);
    }
    const delayBoost =
      boss.def.adaptiveRules?.onMissSpike && stage.misses >= (boss.def.adaptiveRules.onMissSpike.threshold || 3)
        ? boss.def.adaptiveRules.onMissSpike.delayIncrease || 0
        : 0;
    if (!runner.active && boss.state === 'idle') startNextPattern();
    const cmds = runner.tick(t * 1000, {
      boss,
      player: playerSys.p,
      speedScale,
      delayBoost,
      onEvent(ev, cmd) {
        if (ev.action === 'telegraph' || (cmd && cmd.kind === 'pre_telegraph')) {
          fb.onTelegraph();
          sfx.warning_beep && sfx.warning_beep();
        }
      },
    });
    for (const c of cmds) {
      applyPatternCmd(boss, c, playerSys.p, {
        onTelegraph() {
          fb.onTelegraph();
          sfx.warning_beep && sfx.warning_beep();
        },
      });
      if (c.kind !== 'pre_telegraph' && sfx) sfx.warn();
    }
  }

  if (boss) {
    applyCritical(boss, stage, fb, sfx);
    updateBoss(boss, t, playerSys.p, W, H, sfx, onHitPlayer, stage, onPhaseChange);
  }
  ui.update(playerSys.p, boss, playerSys.dashCd, debug, stage);
}

function drawTimingBar() {
  const p = playerSys.p;
  const barW = 200;
  const x = W / 2 - barW / 2;
  const y = H - 28;
  ctx.fillStyle = 'rgba(0,0,0,0.45)';
  ctx.fillRect(x - 4, y - 4, barW + 8, 18);
  ctx.fillStyle = '#3d5a80';
  ctx.fillRect(x, y, barW, 10);
  ctx.fillStyle = '#3fb950';
  ctx.fillRect(x + barW * 0.39, y, barW * 0.22, 10);
  let t = 0.5;
  if (p.invuln > 0) t = Math.min(1, p.dashAge / (timing.good * 2));
  ctx.fillStyle = '#fff';
  ctx.fillRect(x + t * barW - 1, y - 2, 2, 14);
}

function drawDebugNemesis() {
  if (!window.debugNemesis || !boss) return;
  const snap = adaptiveSnapshot(boss, stage);
  ctx.fillStyle = 'rgba(0,0,0,0.6)';
  ctx.fillRect(W - 200, 80, 192, 100);
  ctx.fillStyle = '#f0c14a';
  ctx.font = '11px system-ui';
  ctx.textAlign = 'left';
  const lines = [
    `phase ${snap.phase}${snap.critical ? ' CRIT' : ''}`,
    `spd ${snap.adaptSpeed} fake ${snap.adaptFake}`,
    `pat ${runner?.patternId || '-'}`,
    `combo ${snap.combo} P${snap.perfects} M${snap.misses}`,
  ];
  lines.forEach((l, i) => ctx.fillText(l, W - 192, 98 + i * 16));
}

function drawPatternOverlay() {
  if (!debug.timeline || !runner) return;
  ctx.fillStyle = 'rgba(0,0,0,0.55)';
  ctx.fillRect(8, 80, 260, 110);
  ctx.fillStyle = '#58a6ff';
  ctx.font = '11px system-ui';
  ctx.textAlign = 'left';
  ctx.fillText(`Pattern: ${runner.patternId || '—'}`, 16, 98);
  ctx.fillStyle = '#e6edf3';
  ctx.fillText(`t=${runner.elapsed | 0}ms`, 16, 114);
  const next = runner.nextEvent();
  if (next) ctx.fillText(`next: ${next.action} @${next.t}`, 16, 130);
}

function drawPlayer() {
  const p = playerSys.p;
  fb.drawPlayerAura(ctx, p, stage.combo);
  ctx.save();
  if (p.invuln > 0 && ((p.invuln * 18) | 0) % 2 === 0) ctx.globalAlpha = 0.4;
  const tier = fb.comboTier(stage.combo);
  ctx.fillStyle = p.flash > 0 ? '#ff6b6b' : tier >= 3 ? '#f0c14a' : '#7ec8ff';
  ctx.beginPath();
  ctx.ellipse(p.x, p.y, p.r * 0.7, p.r * 1.15, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();
  if (debug.hb) {
    ctx.strokeStyle = '#0ff';
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
    ctx.stroke();
  }
}

function drawSelect() {
  ctx.fillStyle = '#e6edf3';
  ctx.font = 'bold 22px system-ui';
  ctx.textAlign = 'center';
  ctx.fillText('EXCELION  V8 NEMESIS', W / 2, H / 2 - 70);
  ctx.font = '14px system-ui';
  ctx.fillStyle = '#8b949e';
  ctx.fillText('1 MONTU · 2 SETH · 3 NEMESIS', W / 2, H / 2 - 40);
  if (roster) {
    roster.bosses.forEach((b, i) => {
      ctx.fillStyle = '#58a6ff';
      ctx.fillText(b.label, W / 2, H / 2 + i * 28);
    });
  }
}

function drawResult() {
  ctx.fillStyle = 'rgba(0,0,0,0.65)';
  ctx.fillRect(0, 0, W, H);
  ctx.textAlign = 'center';
  if (stage.status === 'clear') {
    ctx.fillStyle = '#3fb950';
    ctx.font = 'bold 32px system-ui';
    ctx.fillText('CLEAR', W / 2, H / 2 - 90);
  } else {
    ctx.fillStyle = '#f85149';
    ctx.font = 'bold 28px system-ui';
    ctx.fillText('YOU DIED', W / 2, H / 2 - 90);
    ctx.fillStyle = '#ff7b72';
    ctx.font = '13px system-ui';
    ctx.fillText(lastDeath, W / 2, H / 2 - 62);
  }
  ctx.fillStyle = '#f0c14a';
  ctx.font = 'bold 36px system-ui';
  ctx.fillText(`RANK ${lastRank}`, W / 2, H / 2 - 28);
  ctx.fillStyle = '#e6edf3';
  ctx.font = '18px system-ui';
  ctx.fillText(`SCORE  ${stage.score}`, W / 2, H / 2 + 8);
  ctx.font = '14px system-ui';
  ctx.fillText(`Accuracy ${stage.accuracy()}% · Max Combo ${stage.maxCombo}`, W / 2, H / 2 + 32);
  if (improved) {
    ctx.fillStyle = '#58a6ff';
    ctx.fillText('You Improved', W / 2, H / 2 + 54);
  }
  ctx.fillStyle = '#8b949e';
  ctx.fillText('Enter — Retry · R — Select', W / 2, H / 2 + 80);
}

function draw() {
  ctx.save();
  const z = fb.zoomScale();
  ctx.translate(W / 2, H / 2);
  ctx.scale(z, z);
  ctx.translate(-W / 2, -H / 2);
  if (fb.shake > 0) {
    const s = fb.shake * 16;
    ctx.translate((Math.random() - 0.5) * s, (Math.random() - 0.5) * s);
  }
  ctx.fillStyle = boss && boss.critical ? '#1a0a18' : '#161b22';
  ctx.fillRect(-20, -20, W + 40, H + 40);
  if (stage.status === 'select') {
    drawSelect();
    ctx.restore();
    return;
  }
  if (boss) drawBoss(ctx, boss, debug.hb);
  drawPlayer();
  if (stage.status === 'fight') {
    drawTimingBar();
    drawPatternOverlay();
    drawDebugNemesis();
  }
  fb.drawOverlays(ctx, W, H);
  if (stage.status === 'clear' || stage.status === 'fail') drawResult();
  ctx.restore();
}

window.addEventListener('keydown', (e) => {
  keys[e.code] = true;
  sfx && sfx.resume();
  if (e.code === 'KeyR') {
    stage.backToSelect();
    boss = null;
    runner && runner.stop();
    ui.showBanner('SELECT 1/2/3', 99);
  }
  if (e.code === 'Enter' && (stage.status === 'clear' || stage.status === 'fail') && lastBossFile) {
    startBoss(lastBossFile);
  }
  if (e.code === 'Digit1' || e.code === 'Numpad1') startBoss('boss_brave.json');
  if (e.code === 'Digit2' || e.code === 'Numpad2') startBoss('boss_mass.json');
  if (e.code === 'Digit3' || e.code === 'Numpad3') startBoss('boss/nemesis.json');
  if (e.code === 'KeyJ' || e.code === 'KeyZ') playerSys && playerSys.queueAttack();
  if (e.code === 'Space' || e.code === 'ShiftLeft' || e.code === 'ShiftRight') {
    e.preventDefault();
    playerSys && playerSys.queueDash();
    playerSys && playerSys.tryDash(sfx);
  }
  if (e.code === 'F1' || e.code === 'F8') {
    e.preventDefault();
    debug.hb = !debug.hb;
  }
  if (e.code === 'F2') {
    e.preventDefault();
    debug.god = !debug.god;
  }
  if (e.code === 'F3' && boss) {
    e.preventDefault();
    boss.hp = 0;
    boss.alive = false;
    stage.onClear();
    sfx.clear();
    finishResult(true);
  }
  if (e.code === 'F4') {
    e.preventDefault();
    debug.speed = debug.speed === 1 ? 0.5 : debug.speed === 0.5 ? 1.5 : 1;
  }
  if (e.code === 'F5' && boss) {
    e.preventDefault();
    boss.hp = boss.maxHp * 0.29;
  }
  if (e.code === 'F6' && boss) {
    e.preventDefault();
    boss.state = 'idle';
    boss.timer = 0;
    runner.stop();
    startNextPattern();
  }
  if (e.code === 'F7') {
    e.preventDefault();
    debug.timeline = !debug.timeline;
  }
  if (e.code === 'F9') {
    e.preventDefault();
    window.debugNemesis = !window.debugNemesis;
  }
});
window.addEventListener('keyup', (e) => {
  keys[e.code] = false;
});
canvas.addEventListener('mousedown', () => {
  sfx && sfx.resume();
  playerSys && playerSys.queueAttack();
});
document.getElementById('restart').onclick = () => {
  stage.backToSelect();
  boss = null;
  runner && runner.stop();
  ui.showBanner('SELECT 1/2/3', 99);
};

let last = performance.now();
function frame(now) {
  const dt = Math.min(0.033, (now - last) / 1000);
  last = now;
  if (roster) {
    update(dt);
    draw();
  }
  requestAnimationFrame(frame);
}

loadData()
  .then(() => {
    ui.showBanner('SELECT BOSS 1 / 2 / 3', 99);
    requestAnimationFrame(frame);
  })
  .catch((err) => {
    console.error(err);
    document.getElementById('banner').textContent = 'Load failed — serve v4/ via http';
  });
