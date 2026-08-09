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
let lastBossFile = null;

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
  lastBossFile = file;
  stage.setBoss(def, file);
  playerSys.reset();
  boss = makeBossFromDef(def, 640, H / 2);
  lastDeath = '';
  ui.setReason('');
  ui.showBanner(def.displayName, 1.4);
  sfx.warn();
  sfx.phaseBgm && sfx.phaseBgm(1);
  debug.hits = 0;
}

function onPhaseChange(e, phase) {
  feel.flashWhite = 0.2;
  feel.addShake(0.25);
  const label = stage.phaseLabel();
  ui.showBanner(label, 2.0);
  sfx.warn();
  sfx.phaseBgm && sfx.phaseBgm(phase);
}

function onHitPlayer(e) {
  const p = playerSys.p;
  if (debug.god || p.invuln > 0 || stage.status !== 'fight') return;
  p.hp -= e.damage;
  stage.hitsTaken++;
  stage.breakCombo();
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
    if (p.invuln > 0 && p.dashAge <= timing.perfect) {
      feel.triggerPerfect();
      stage.addJudgment('PERFECT');
      sfx.perfect();
      ui.setReason('PERFECT');
    } else if (p.invuln > 0) {
      feel.triggerGood();
      stage.addJudgment('GOOD');
      sfx.hit();
      ui.setReason('GOOD');
    } else {
      feel.flashWhite = 0.05;
      feel.addHitstop(0.05);
      feel.addShake(0.1);
      sfx.hit();
      stage.addJudgment('MISS');
    }
    if (boss.hp <= 0) {
      boss.alive = false;
      stage.onClear();
      sfx.clear();
      ui.showBanner('CLEAR', 99);
    }
  }
}

function update(dt) {
  const scaled = dt * debug.speed;
  if (feel.tick(scaled)) return;
  const t = scaled * feel.timeScale();

  ui.tick(t, stage.status === 'clear' || stage.status === 'fail');

  if (stage.status !== 'fight') return;
  stage.stageTime += t;
  playerSys.update(t, keys, { W, H });
  if (playerSys.consumeAttackBuffer()) playerAttack();
  if (boss) updateBoss(boss, t, playerSys.p, W, H, sfx, onHitPlayer, stage, onPhaseChange);
  ui.update(playerSys.p, boss, playerSys.dashCd, debug, stage);
}

function drawTimingBar() {
  const p = playerSys.p;
  const barW = 200;
  const barH = 10;
  const x = W / 2 - barW / 2;
  const y = H - 28;
  ctx.fillStyle = 'rgba(0,0,0,0.45)';
  ctx.fillRect(x - 4, y - 4, barW + 8, barH + 8);
  // GOOD zones
  ctx.fillStyle = '#3d5a80';
  ctx.fillRect(x, y, barW, barH);
  // PERFECT center
  const pw = barW * 0.22;
  ctx.fillStyle = '#3fb950';
  ctx.fillRect(x + (barW - pw) / 2, y, pw, barH);
  // cursor from dashAge while invuln or idle center
  let t = 0.5;
  if (p.invuln > 0) {
    t = Math.min(1, p.dashAge / (timing.good * 2));
  }
  const cx = x + t * barW;
  ctx.fillStyle = '#fff';
  ctx.fillRect(cx - 1, y - 2, 2, barH + 4);
  ctx.fillStyle = '#8b949e';
  ctx.font = '9px system-ui';
  ctx.textAlign = 'center';
  ctx.fillText('GOOD  PERFECT  GOOD', W / 2, y - 6);
}

function drawPlayer() {
  const p = playerSys.p;
  ctx.save();
  if (p.invuln > 0 && ((p.invuln * 18) | 0) % 2 === 0) ctx.globalAlpha = 0.4;
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
  ctx.fillText('EXCELION  V6', W / 2, H / 2 - 70);
  ctx.font = '14px system-ui';
  ctx.fillStyle = '#8b949e';
  ctx.fillText('Select boss — 1 / 2 / 3', W / 2, H / 2 - 40);
  if (roster) {
    roster.bosses.forEach((b, i) => {
      ctx.fillStyle = '#58a6ff';
      ctx.font = '16px system-ui';
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
    ctx.fillText('CLEAR', W / 2, H / 2 - 70);
  } else {
    ctx.fillStyle = '#f85149';
    ctx.font = 'bold 28px system-ui';
    ctx.fillText('YOU DIED', W / 2, H / 2 - 70);
    ctx.fillStyle = '#ff7b72';
    ctx.font = '13px system-ui';
    ctx.fillText(lastDeath, W / 2, H / 2 - 42);
  }
  ctx.fillStyle = '#e6edf3';
  ctx.font = '18px system-ui';
  ctx.fillText(`SCORE  ${stage.score}`, W / 2, H / 2 - 10);
  ctx.font = '14px system-ui';
  ctx.fillText(`Accuracy  ${stage.accuracy()}%`, W / 2, H / 2 + 16);
  ctx.fillText(`Max Combo  ${stage.maxCombo}`, W / 2, H / 2 + 38);
  ctx.fillText(`P ${stage.perfects}  G ${stage.goods}  M ${stage.misses}  Hits ${stage.hitsTaken}`, W / 2, H / 2 + 60);
  ctx.fillStyle = '#8b949e';
  ctx.font = '13px system-ui';
  ctx.fillText('Enter — Retry · R — Boss Select', W / 2, H / 2 + 92);
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
  if (stage.status === 'fight') drawTimingBar();

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

  if (stage.status === 'clear' || stage.status === 'fail') drawResult();
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
  if (e.code === 'Enter' && (stage.status === 'clear' || stage.status === 'fail') && lastBossFile) {
    startBoss(lastBossFile);
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
  }
  if (e.code === 'F4') {
    e.preventDefault();
    debug.speed = debug.speed === 1 ? 0.5 : debug.speed === 0.5 ? 1.5 : 1;
  }
  if (e.code === 'F5' && boss) {
    e.preventDefault();
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
