import { createTiming, createFeel } from './systems/timing.js';
import { createPlayer } from './systems/player.js';
import { makeBossFromDef, updateBoss, drawBoss } from './systems/boss.js';
import { createUI } from './systems/ui.js';
import { createAudio } from './systems/audio.js';
import { createStage } from './systems/stage.js';

const canvas = document.getElementById('c');
const ctx = canvas.getContext('2d');
const W = 800;
const H = 480;

const keys = {};
let roster = null;
let bossCache = {};
let timing = null;
let feel = null;
let playerSys = null;
let ui = null;
let sfx = null;
let stage = null;
let boss = null;
let lastDeath = '';

const debug = { hb: false, god: false, speed: 1, hits: 0 };

async function loadBossFile(file) {
  if (bossCache[file]) return bossCache[file];
  const res = await fetch('./data/' + file);
  const j = await res.json();
  bossCache[file] = j;
  return j;
}

async function loadData() {
  const res = await fetch('./data/roster.json');
  roster = await res.json();
  timing = createTiming(roster.timing);
  feel = createFeel();
  playerSys = createPlayer(roster.timing, W, H);
  ui = createUI();
  sfx = createAudio();
  stage = createStage();
}

async function startBoss(file) {
  const def = await loadBossFile(file);
  stage.setBoss(def);
  playerSys.reset();
  boss = makeBossFromDef(def, 640, H / 2);
  lastDeath = '';
  ui.setReason('');
  ui.showBanner(def.displayName, 1.6);
  sfx.warn();
  debug.hits = 0;
}

function onHitPlayer(e) {
  const p = playerSys.p;
  if (debug.god || p.invuln > 0 || stage.status !== 'fight') return;
  p.hp -= e.damage;
  stage.hitsTaken++;
  debug.hits = stage.hitsTaken;
  p.flash = 0.12;
  feel.flashRed = 0.14;
  feel.addShake(0.28);
  feel.addHitstop(0.1);
  feel.bossTint = 0.12;
  sfx.hurt();

  let reason;
  if (e._act && e._act.type === 'fake') reason = timing.classifyFakeFail();
  else if (e.comboLeft > 0 || e.redirectLeft > 0) reason = timing.classifyComboFail();
  else reason = timing.classifyDodge(p.dashAge, p.invuln, false);

  if (p.hp <= 0) {
    stage.onFail();
    lastDeath = reason;
    ui.setReason(reason);
    ui.showBanner('YOU DIED', 99);
  } else {
    ui.setReason(reason);
  }
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
    // near-invuln dodge window as PERFECT on contact while dashing
    if (p.invuln > 0 && p.dashAge <= timing.perfect) {
      feel.triggerPerfect();
      stage.perfects++;
      sfx.perfect();
      ui.setReason('PERFECT');
    } else if (p.invuln > 0) {
      feel.triggerGood();
      stage.goods++;
      sfx.hit();
      ui.setReason('GOOD');
    } else {
      feel.flashWhite = 0.05;
      feel.addHitstop(0.05);
      feel.addShake(0.1);
      sfx.hit();
    }
    if (boss.hp <= 0) {
      boss.alive = false;
      stage.onClear();
      sfx.clear();
      ui.showBanner('CLEAR', 99);
      ui.setReason(
        `TIME ${stage.stageTime | 0}s · HITS ${stage.hitsTaken} · P${stage.perfects}/G${stage.goods}`
      );
    }
  }
}

function update(dt) {
  const scaled = dt * debug.speed;
  if (feel.tick(scaled)) return;
  const t = scaled * feel.timeScale();

  ui.tick(t, stage.status === 'clear', stage.status === 'fail');

  if (stage.status !== 'fight') return;
  stage.stageTime += t;
  playerSys.update(t, keys, { W, H });
  if (playerSys.consumeAttackBuffer()) playerAttack();
  if (boss) updateBoss(boss, t, playerSys.p, W, H, sfx, onHitPlayer, stage);
  ui.update(playerSys.p, boss ? [boss] : [], playerSys.dashCd, {
    ...debug,
    loop: false,
  });
}

function drawPlayer() {
  const p = playerSys.p;
  ctx.save();
  if (p.invuln > 0 && ((p.invuln * 18) | 0) % 2 === 0) ctx.globalAlpha = 0.4;
  // silhouette: capsule body
  ctx.fillStyle = p.flash > 0 ? '#ff6b6b' : '#7ec8ff';
  ctx.beginPath();
  ctx.ellipse(p.x, p.y, p.r * 0.7, p.r * 1.15, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#e8f4ff';
  ctx.beginPath();
  ctx.arc(p.x + p.facing * 4, p.y - p.r * 0.5, 5, 0, Math.PI * 2);
  ctx.fill();
  if (p.invuln > 0) {
    ctx.strokeStyle = 'rgba(88,166,255,0.7)';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.r + 6, 0, Math.PI * 2);
    ctx.stroke();
  }
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
  ctx.fillText('EXCELION  V5', W / 2, H / 2 - 70);
  ctx.font = '14px system-ui';
  ctx.fillStyle = '#8b949e';
  ctx.fillText('Select boss — keys 1 / 2 / 3', W / 2, H / 2 - 40);
  if (roster) {
    roster.bosses.forEach((b, i) => {
      ctx.fillStyle = '#58a6ff';
      ctx.font = '16px system-ui';
      ctx.fillText(b.label, W / 2, H / 2 + i * 28);
    });
  }
}

function draw() {
  ctx.save();
  const z = feel.zoomScale();
  ctx.translate(W / 2, H / 2);
  ctx.scale(z, z);
  ctx.translate(-W / 2, -H / 2);
  if (feel.shake > 0) {
    const s = feel.shake * 16;
    ctx.translate((Math.random() - 0.5) * s, (Math.random() - 0.5) * s);
  }
  ctx.fillStyle = '#161b22';
  ctx.fillRect(-20, -20, W + 40, H + 40);
  ctx.strokeStyle = '#21262d';
  for (let x = 0; x < W; x += 40) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, H);
    ctx.stroke();
  }
  for (let y = 0; y < H; y += 40) {
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(W, y);
    ctx.stroke();
  }

  if (stage.status === 'select') {
    drawSelect();
    ctx.restore();
    return;
  }

  if (boss) drawBoss(ctx, boss, debug.hb);
  drawPlayer();

  if (feel.invert > 0) {
    ctx.fillStyle = `rgba(255,255,255,${feel.invert * 0.5})`;
    ctx.globalCompositeOperation = 'difference';
    ctx.fillRect(0, 0, W, H);
    ctx.globalCompositeOperation = 'source-over';
  }
  if (feel.flashRed > 0) {
    ctx.fillStyle = `rgba(255,40,40,${Math.min(0.45, feel.flashRed * 2.2)})`;
    ctx.fillRect(0, 0, W, H);
  }
  if (feel.flashWhite > 0) {
    ctx.fillStyle = `rgba(255,255,255,${feel.flashWhite * 1.4})`;
    ctx.fillRect(0, 0, W, H);
  }
  if (feel.bossTint > 0) {
    ctx.fillStyle = `rgba(120,40,180,${feel.bossTint})`;
    ctx.fillRect(0, 0, W, H);
  }

  if (stage.status === 'clear' || stage.status === 'fail') {
    ctx.fillStyle = 'rgba(0,0,0,0.6)';
    ctx.fillRect(0, 0, W, H);
    ctx.textAlign = 'center';
    if (stage.status === 'clear') {
      ctx.fillStyle = '#3fb950';
      ctx.font = 'bold 32px system-ui';
      ctx.fillText('CLEAR', W / 2, H / 2 - 36);
      ctx.fillStyle = '#e6edf3';
      ctx.font = '15px system-ui';
      ctx.fillText(`Time ${stage.stageTime | 0}s · Hits ${stage.hitsTaken}`, W / 2, H / 2);
      ctx.fillText(`PERFECT ${stage.perfects} · GOOD ${stage.goods}`, W / 2, H / 2 + 24);
    } else {
      ctx.fillStyle = '#f85149';
      ctx.font = 'bold 28px system-ui';
      ctx.fillText('YOU DIED', W / 2, H / 2 - 28);
      ctx.fillStyle = '#ff7b72';
      ctx.font = '14px system-ui';
      ctx.fillText(lastDeath, W / 2, H / 2 + 4);
    }
    ctx.fillStyle = '#8b949e';
    ctx.font = '13px system-ui';
    ctx.fillText('R — menu · 1/2/3 — retry boss', W / 2, H / 2 + 56);
  }
  ctx.restore();
}

window.addEventListener('keydown', (e) => {
  keys[e.code] = true;
  sfx && sfx.resume();
  if (e.code === 'KeyR') {
    stage.backToSelect();
    boss = null;
    ui.showBanner('SELECT 1/2/3', 99);
  }
  if (e.code === 'Digit1' || e.code === 'Numpad1') startBoss('boss_brave.json');
  if (e.code === 'Digit2' || e.code === 'Numpad2') startBoss('boss_mass.json');
  if (e.code === 'Digit3' || e.code === 'Numpad3') startBoss('boss_ashur.json');
  if (e.code === 'KeyJ' || e.code === 'KeyZ') playerSys && playerSys.queueAttack();
  if (e.code === 'Space' || e.code === 'ShiftLeft' || e.code === 'ShiftRight') {
    e.preventDefault();
    playerSys && playerSys.queueDash();
    playerSys && playerSys.tryDash(sfx);
  }
  if (e.code === 'F1') {
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
    ui.showBanner('CLEAR', 99);
  }
  if (e.code === 'F4') {
    e.preventDefault();
    debug.speed = debug.speed === 1 ? 0.5 : debug.speed === 0.5 ? 1.5 : 1;
  }
  if (e.code === 'F5' && boss) {
    e.preventDefault();
    // force next phase
    const th = boss.def.phaseThresholds || [1, 0.66, 0.33];
    if (boss.phase === 1) boss.hp = boss.maxHp * th[1] - 1;
    else if (boss.phase === 2) boss.hp = boss.maxHp * th[2] - 1;
  }
  if (e.code === 'F6' && boss) {
    e.preventDefault();
    boss.patternIdx++;
    boss.state = 'idle';
    boss.timer = 0.1;
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
