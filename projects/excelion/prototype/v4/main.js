import { createTiming, createFeel } from './systems/timing.js';
import { createPlayer } from './systems/player.js';
import { makeEnemy, updateEnemy, drawEnemy } from './systems/boss.js';
import { createUI } from './systems/ui.js';
import { createAudio } from './systems/audio.js';

const canvas = document.getElementById('c');
const ctx = canvas.getContext('2d');
const W = 800;
const H = 480;

const keys = {};
let data = null;
let timing = null;
let feel = null;
let playerSys = null;
let ui = null;
let sfx = null;

let enemies = [];
let wave = 0;
let started = false;
let gameOver = false;
let cleared = false;
let stageTime = 0;
let hitsTaken = 0;
let lastDeath = '';

const debug = { hb: false, god: false, speed: 1, loop: false, hits: 0 };

async function loadData() {
  const res = await fetch('./data/boss_patterns.json');
  data = await res.json();
  timing = createTiming(data.timing);
  feel = createFeel();
  playerSys = createPlayer(data.timing, W, H);
  ui = createUI();
  sfx = createAudio();
}

function spawnWave(n) {
  enemies = [];
  if (n === 1) {
    ui.showBanner('WAVE 1');
    sfx.warn();
    enemies = [
      makeEnemy('montu', 600, 150, data),
      makeEnemy('montu', 680, 240, data),
      makeEnemy('montu', 600, 350, data),
    ];
  } else if (n === 2) {
    ui.showBanner('WAVE 2 — READ THE FAKE');
    sfx.warn();
    enemies = [
      makeEnemy('fast', 640, 170, data),
      makeEnemy('fake', 700, 300, data),
      makeEnemy('montu', 580, 260, data),
    ];
  } else if (n === 3) {
    ui.showBanner('⚠ BOSS — ANUBIS');
    sfx.charge();
    enemies = [makeEnemy('anubis', 640, H / 2, data)];
  }
}

function startGame() {
  gameOver = false;
  cleared = false;
  started = true;
  lastDeath = '';
  ui.setReason('');
  playerSys.reset();
  wave = 1;
  stageTime = 0;
  hitsTaken = 0;
  debug.hits = 0;
  spawnWave(1);
  ui.update(playerSys.p, enemies, playerSys.dashCd, debug);
}

function onHitPlayer(e) {
  const p = playerSys.p;
  if (debug.god || p.invuln > 0 || gameOver || cleared) return;
  p.hp -= e.damage;
  hitsTaken++;
  debug.hits = hitsTaken;
  p.flash = 0.12;
  feel.flashRed = 0.14;
  feel.addShake(e.type === 'anubis' ? 0.35 : 0.22);
  feel.addHitstop(e.type === 'anubis' ? 0.12 : 0.1);
  if (e.type === 'anubis') feel.bossTint = 0.15;
  sfx.hurt();

  let reason;
  if (e.type === 'fake') reason = timing.classifyFakeFail();
  else if (e.comboLeft > 0 || e.redirectLeft > 0) reason = timing.classifyComboFail();
  else reason = timing.classifyDodge(p.dashAge, p.invuln, false);

  if (p.hp <= 0) {
    gameOver = true;
    lastDeath = reason;
    ui.setReason(reason);
    ui.showBanner('YOU DIED', 99);
  } else {
    ui.setReason(reason);
  }
}

function playerAttack() {
  if (gameOver || cleared || !started) return;
  const p = playerSys.p;
  for (const e of enemies) {
    if (!e.alive) continue;
    const dx = e.x - p.x;
    const dy = e.y - p.y;
    if (dx * dx + dy * dy < (p.r + e.r + 22) ** 2) {
      e.hp -= e.type === 'anubis' ? 11 : 17;
      e.flash = 0.1;
      e.scale = 0.88;
      feel.flashWhite = 0.05;
      feel.addHitstop(0.05);
      feel.addShake(e.type === 'anubis' ? 0.18 : 0.1);
      if (e.type === 'anubis') feel.bossTint = 0.08;
      sfx.hit();
      // success slow-mo
      feel.slow = Math.max(feel.slow, 0.1);
      if (e.hp <= 0) e.alive = false;
    }
  }
}

function checkWaveClear() {
  if (gameOver || cleared || !started) return;
  if (enemies.length && enemies.every((e) => !e.alive)) {
    if (debug.loop && wave === 3) {
      spawnWave(3);
      return;
    }
    if (wave === 1) {
      wave = 2;
      spawnWave(2);
    } else if (wave === 2) {
      wave = 3;
      spawnWave(3);
    } else if (wave === 3) {
      wave = 4;
      cleared = true;
      sfx.clear();
      ui.showBanner('CLEAR', 99);
      ui.setReason(`TIME ${stageTime | 0}s · HITS ${hitsTaken}`);
    }
  }
}

function update(dt) {
  const scaled = dt * debug.speed;
  if (feel.tick(scaled)) return;
  const t = scaled * feel.timeScale();

  ui.tick(t, cleared, gameOver);
  if (!started || gameOver || cleared) return;
  stageTime += t;

  playerSys.update(t, keys, { W, H });
  if (playerSys.consumeAttackBuffer()) playerAttack();

  for (const e of enemies) {
    updateEnemy(e, t, playerSys.p, data, W, H, sfx, onHitPlayer);
  }
  checkWaveClear();
  ui.update(playerSys.p, enemies, playerSys.dashCd, debug);
}

function drawPlayer() {
  const p = playerSys.p;
  ctx.save();
  if (p.invuln > 0 && ((p.invuln * 18) | 0) % 2 === 0) ctx.globalAlpha = 0.4;
  ctx.fillStyle = p.flash > 0 ? '#ff6b6b' : '#7ec8ff';
  ctx.beginPath();
  ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#3a7ca5';
  ctx.beginPath();
  ctx.arc(p.x, p.y, p.r * 0.55, 0, Math.PI * 2);
  ctx.fill();
  if (p.invuln > 0) {
    ctx.strokeStyle = 'rgba(88,166,255,0.7)';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.r + 5, 0, Math.PI * 2);
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

function draw() {
  ctx.save();
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

  if (!started) {
    ctx.fillStyle = '#e6edf3';
    ctx.font = 'bold 22px system-ui';
    ctx.textAlign = 'center';
    ctx.fillText('EXCELION  V4', W / 2, H / 2 - 20);
    ctx.font = '14px system-ui';
    ctx.fillStyle = '#8b949e';
    ctx.fillText('Press R to Start · needs local server for modules', W / 2, H / 2 + 16);
    ctx.restore();
    return;
  }

  for (const e of enemies) drawEnemy(ctx, e, debug.hb);
  drawPlayer();

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

  if (gameOver || cleared) {
    ctx.fillStyle = 'rgba(0,0,0,0.6)';
    ctx.fillRect(0, 0, W, H);
    ctx.textAlign = 'center';
    if (cleared) {
      ctx.fillStyle = '#3fb950';
      ctx.font = 'bold 32px system-ui';
      ctx.fillText('CLEAR', W / 2, H / 2 - 36);
      ctx.fillStyle = '#e6edf3';
      ctx.font = '15px system-ui';
      ctx.fillText(`Time  ${stageTime | 0}s`, W / 2, H / 2);
      ctx.fillText(`Hits  ${hitsTaken}`, W / 2, H / 2 + 24);
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
    ctx.fillText('R — Retry', W / 2, H / 2 + 56);
  }
  ctx.restore();
}

window.addEventListener('keydown', (e) => {
  keys[e.code] = true;
  sfx && sfx.resume();
  if (e.code === 'KeyR') startGame();
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
  if (e.code === 'F3') {
    e.preventDefault();
    if (wave < 3) {
      wave = 3;
      spawnWave(3);
    } else if (enemies[0]) {
      enemies[0].hp = 0;
      enemies[0].alive = false;
      checkWaveClear();
    }
  }
  if (e.code === 'F4') {
    e.preventDefault();
    debug.speed = debug.speed === 1 ? 0.5 : debug.speed === 0.5 ? 1.5 : 1;
  }
  if (e.code === 'F5') {
    e.preventDefault();
    debug.loop = !debug.loop;
  }
});
window.addEventListener('keyup', (e) => {
  keys[e.code] = false;
});
canvas.addEventListener('mousedown', () => {
  sfx && sfx.resume();
  playerSys && playerSys.queueAttack();
});
document.getElementById('restart').onclick = () => startGame();

let last = performance.now();
function frame(now) {
  const dt = Math.min(0.033, (now - last) / 1000);
  last = now;
  if (data) {
    update(dt);
    draw();
  }
  requestAnimationFrame(frame);
}

loadData()
  .then(() => {
    ui.showBanner('PRESS R TO START', 99);
    requestAnimationFrame(frame);
  })
  .catch((err) => {
    console.error(err);
    document.getElementById('banner').textContent =
      'Load failed — serve v4/ via http (e.g. npx serve)';
  });
