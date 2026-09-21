import { TOWERS, ENEMIES, ROBOT, WAVES, MAP } from './data.js';

const canvas = document.querySelector('#battlefield');
const ctx = canvas.getContext('2d');
const ui = {
  baseHp: document.querySelector('#baseHp'), gold: document.querySelector('#gold'), wave: document.querySelector('#waveNumber'),
  nextWave: document.querySelector('#nextWaveInfo'), startWave: document.querySelector('#startWave'), restart: document.querySelector('#restart'),
  selectedSlot: document.querySelector('#selectedSlot'), robotStatus: document.querySelector('#robotStatus'), robotHp: document.querySelector('#robotHp'),
  moveCommands: document.querySelector('#moveCommands'), launchRobot: document.querySelector('#launchRobot'), eventFeed: document.querySelector('#eventFeed'),
  runStatus: document.querySelector('#runStatus'), timer: document.querySelector('#timer')
};

let state;
let lastFrame = performance.now();

function resetGame() {
  state = {
    baseHp: 100, gold: 180, currentWave: 1, waveRunning: false, waveComplete: false, elapsed: 0,
    enemies: [], towers: [], selectedSlot: null, spawnQueue: [], spawnTimer: 0, waveClock: 0, effects: [], feed: [],
    robot: { active: false, x: MAP.robotSpots[1].x, y: MAP.robotSpots[1].y, hp: ROBOT.hp, commands: ROBOT.maxMoves, targetSpot: 'CENTER', attackTimer: 0, areaTimer: 0, pierceTimer: 0 }
  };
  addFeed('Build a tower, then start the first wave.');
  updateUi();
}

function addFeed(message, type = '') {
  state.feed.unshift({ message, type });
  state.feed = state.feed.slice(0, 7);
  ui.eventFeed.innerHTML = state.feed.map(item => `<p class="${item.type}">${item.message}</p>`).join('');
}

function updateUi() {
  const wave = WAVES[state.currentWave - 1];
  const next = WAVES[state.currentWave] || wave;
  ui.baseHp.textContent = Math.max(0, Math.ceil(state.baseHp));
  ui.gold.textContent = state.gold;
  ui.wave.textContent = `${state.currentWave} / ${WAVES.length}`;
  ui.nextWave.textContent = next.label;
  ui.startWave.textContent = state.waveRunning ? `WAVE ${state.currentWave} IN PROGRESS` : state.waveComplete ? (state.currentWave === WAVES.length ? 'ALL WAVES CLEAR' : `START WAVE ${state.currentWave + 1}`) : `START WAVE ${state.currentWave}`;
  ui.startWave.disabled = state.waveRunning || state.baseHp <= 0 || state.currentWave > WAVES.length;
  ui.robotStatus.textContent = state.robot.active ? `DEPLOYED · ${state.robot.targetSpot}` : 'DOCKED';
  ui.robotHp.textContent = `${Math.max(0, Math.ceil(state.robot.hp))} / ${ROBOT.hp}`;
  ui.moveCommands.textContent = state.robot.commands;
  ui.selectedSlot.textContent = state.selectedSlot ? `${state.selectedSlot.id} · SELECTED` : 'NO SLOT';
  ui.runStatus.textContent = state.baseHp <= 0 ? 'BREACHED' : state.waveRunning ? 'LIVE' : state.waveComplete ? 'WAVE CLEAR' : 'READY';
  ui.timer.textContent = formatTime(state.elapsed);
}

function formatTime(seconds) {
  const minutes = Math.floor(seconds / 60).toString().padStart(2, '0');
  const remainder = Math.floor(seconds % 60).toString().padStart(2, '0');
  return `${minutes}:${remainder}`;
}

function startWave() {
  if (state.waveRunning || state.baseHp <= 0 || state.currentWave > WAVES.length) return;
  const wave = WAVES[state.currentWave - 1];
  state.spawnQueue = wave.spawns.flatMap(spawn => Array.from({ length: spawn.count }, (_, index) => ({ ...spawn, delay: index * spawn.interval })));
  state.waveClock = 0;
  state.spawnTimer = 0;
  state.waveRunning = true;
  state.waveComplete = false;
  addFeed(`Wave ${state.currentWave} started: ${wave.label.toLowerCase()}.`, 'good');
  updateUi();
}

function spawnDueEnemies(dt) {
  if (!state.spawnQueue.length) return;
  state.spawnTimer += dt;
  while (state.spawnQueue.length && state.spawnQueue[0].delay <= state.waveClock) {
    const entry = state.spawnQueue.shift();
    const lane = entry.lanes[(state.enemies.length + state.spawnQueue.length) % entry.lanes.length];
    const data = ENEMIES[entry.type];
    state.enemies.push({ type: entry.type, lane, x: 0, y: MAP.lanes[lane].y, hp: data.hp, maxHp: data.hp, flash: 0, id: `${entry.type}-${state.elapsed}-${Math.random()}` });
  }
}

function moveEnemies(dt) {
  for (const enemy of state.enemies) {
    const data = ENEMIES[enemy.type];
    if (enemy.hp <= 0) continue;
    const targetY = MAP.base.y;
    const direction = enemy.lane === 'left' ? 1 : 1;
    enemy.x += data.speed * dt * direction;
    const progress = Math.min(1, enemy.x / 480);
    enemy.y = MAP.lanes[enemy.lane].y + (targetY - MAP.lanes[enemy.lane].y) * progress;
    if (enemy.x >= 465) {
      state.baseHp -= data.baseDamage;
      enemy.hp = 0;
      addFeed(`${data.name} hit the base for ${data.baseDamage}.`, 'alert');
    }
  }
}

function damageEnemy(enemy, amount, source) {
  if (!enemy || enemy.hp <= 0) return;
  const armor = ENEMIES[enemy.type].armor;
  enemy.hp -= Math.max(1, amount - armor);
  enemy.flash = 0.12;
  if (enemy.hp <= 0) {
    state.gold += ENEMIES[enemy.type].reward;
    if (enemy.type === 'enemy_giant') addFeed('GIANT neutralized. Atlas-01 changed the outcome.', 'good');
  }
  state.effects.push({ type: source, x: enemy.x, y: enemy.y, life: .28, maxLife: .28 });
}

function nearestEnemy(x, y, range, preference = null) {
  const candidates = state.enemies.filter(enemy => enemy.hp > 0 && Math.hypot(enemy.x - x, enemy.y - y) <= range);
  if (!candidates.length) return null;
  if (preference === 'heavy') {
    const heavy = candidates.filter(enemy => enemy.type === 'enemy_heavy' || enemy.type === 'enemy_giant');
    if (heavy.length) return heavy.sort((a, b) => b.x - a.x)[0];
  }
  if (preference === 'normal') {
    const fast = candidates.filter(enemy => enemy.type === 'enemy_rusher' || enemy.type === 'enemy_normal');
    if (fast.length) return fast.sort((a, b) => b.x - a.x)[0];
  }
  return candidates.sort((a, b) => b.x - a.x)[0];
}

function updateTowers(dt) {
  for (const tower of state.towers) {
    tower.cooldown -= dt;
    if (tower.cooldown > 0) continue;
    const target = nearestEnemy(tower.x, tower.y, tower.data.range, tower.data.target);
    if (!target) continue;
    damageEnemy(target, tower.data.damage, tower.type === 'tower_cannon' ? 'cannon' : 'gatling');
    tower.cooldown = tower.data.cooldown;
  }
}

function updateRobot(dt) {
  const robot = state.robot;
  if (!robot.active || robot.hp <= 0) return;
  robot.attackTimer -= dt;
  robot.areaTimer -= dt;
  robot.pierceTimer -= dt;
  const target = nearestEnemy(robot.x, robot.y, ROBOT.range);
  const heavyTarget = nearestEnemy(robot.x, robot.y, ROBOT.range + 20, 'heavy');
  if (robot.areaTimer <= 0) {
    const nearby = state.enemies.filter(enemy => enemy.hp > 0 && Math.hypot(enemy.x - robot.x, enemy.y - robot.y) <= ROBOT.abilities.ability_area.radius);
    if (nearby.length >= ROBOT.abilities.ability_area.threshold) {
      nearby.forEach(enemy => damageEnemy(enemy, ROBOT.abilities.ability_area.damage, 'area'));
      state.effects.push({ type: 'areaBurst', x: robot.x, y: robot.y, life: .45, maxLife: .45 });
      robot.areaTimer = ROBOT.abilities.ability_area.cooldown;
      addFeed('Atlas-01 used AREA ATTACK.', 'good');
    }
  }
  if (robot.pierceTimer <= 0 && heavyTarget) {
    damageEnemy(heavyTarget, ROBOT.abilities.ability_heavy_pierce.damage, 'pierce');
    robot.pierceTimer = ROBOT.abilities.ability_heavy_pierce.cooldown;
    state.effects.push({ type: 'pierce', x: heavyTarget.x, y: heavyTarget.y, life: .35, maxLife: .35 });
    addFeed(`Atlas-01 used HEAVY PIERCE on ${ENEMIES[heavyTarget.type].name}.`, 'good');
  } else if (robot.attackTimer <= 0 && target) {
    damageEnemy(target, ROBOT.damage, 'robot');
    robot.attackTimer = ROBOT.cooldown;
  }
}

function updateEffects(dt) {
  state.effects.forEach(effect => { effect.life -= dt; });
  state.effects = state.effects.filter(effect => effect.life > 0);
  state.enemies.forEach(enemy => { enemy.flash = Math.max(0, enemy.flash - dt); });
}

function finishWaveIfReady() {
  if (!state.waveRunning || state.spawnQueue.length || state.enemies.some(enemy => enemy.hp > 0)) return;
  state.waveRunning = false;
  state.waveComplete = true;
  if (state.currentWave < WAVES.length) {
    addFeed(`Wave ${state.currentWave} clear. Read the next threat before committing Atlas-01.`, 'good');
    state.currentWave += 1;
  } else {
    addFeed('All four waves clear. Restart to repeat a position experiment.', 'good');
  }
  updateUi();
}

function update(dt) {
  state.elapsed += dt;
  if (state.waveRunning) {
    state.waveClock += dt;
    spawnDueEnemies(dt);
    moveEnemies(dt);
    updateTowers(dt);
    updateRobot(dt);
    finishWaveIfReady();
  }
  updateEffects(dt);
  updateUi();
}

function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawBackground();
  drawLanes();
  drawSlots();
  drawBase();
  state.towers.forEach(drawTower);
  state.enemies.filter(enemy => enemy.hp > 0).forEach(drawEnemy);
  drawRobot();
  drawEffects();
}

function drawBackground() {
  ctx.fillStyle = '#0a1519'; ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.strokeStyle = 'rgba(126,214,206,.055)'; ctx.lineWidth = 1;
  for (let x = 0; x < canvas.width; x += 32) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke(); }
  for (let y = 0; y < canvas.height; y += 32) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke(); }
  ctx.fillStyle = '#6c8790'; ctx.font = '11px Space Mono'; ctx.fillText('NORTH APPROACH', 22, 157); ctx.fillText('SOUTH APPROACH', 22, 440);
}

function drawLanes() {
  for (const lane of Object.values(MAP.lanes)) {
    ctx.strokeStyle = '#263c43'; ctx.lineWidth = 30; ctx.beginPath(); ctx.moveTo(0, lane.y); ctx.lineTo(MAP.base.x, MAP.base.y); ctx.stroke();
    ctx.strokeStyle = '#416068'; ctx.lineWidth = 1; ctx.setLineDash([7, 10]); ctx.beginPath(); ctx.moveTo(0, lane.y); ctx.lineTo(MAP.base.x, MAP.base.y); ctx.stroke(); ctx.setLineDash([]);
  }
  MAP.robotSpots.forEach(spot => { ctx.fillStyle = 'rgba(126,214,206,.04)'; ctx.beginPath(); ctx.arc(spot.x, spot.y, 62, 0, Math.PI * 2); ctx.fill(); });
}

function drawSlots() {
  MAP.slots.forEach(slot => {
    const tower = state.towers.find(item => item.id === slot.id);
    if (tower) return;
    ctx.strokeStyle = state.selectedSlot?.id === slot.id ? '#f0a35a' : '#6a858a'; ctx.lineWidth = 2; ctx.setLineDash([3, 4]);
    ctx.beginPath(); ctx.arc(slot.x, slot.y, 18, 0, Math.PI * 2); ctx.stroke(); ctx.setLineDash([]);
    ctx.fillStyle = '#6a858a'; ctx.font = '10px Space Mono'; ctx.textAlign = 'center'; ctx.fillText(slot.id, slot.x, slot.y + 4); ctx.textAlign = 'left';
  });
  MAP.robotSpots.forEach(spot => { ctx.fillStyle = '#7ed6ce'; ctx.font = '10px Space Mono'; ctx.textAlign = 'center'; ctx.fillText(spot.id, spot.x, spot.y + 55); ctx.textAlign = 'left'; });
}

function drawBase() {
  ctx.save(); ctx.translate(MAP.base.x, MAP.base.y); ctx.fillStyle = '#182f35'; ctx.strokeStyle = '#7ed6ce'; ctx.lineWidth = 2;
  ctx.beginPath(); ctx.rect(-34, -34, 68, 68); ctx.fill(); ctx.stroke(); ctx.fillStyle = '#7ed6ce'; ctx.fillRect(-9, -9, 18, 18); ctx.restore();
  ctx.fillStyle = '#7ed6ce'; ctx.font = '11px Space Mono'; ctx.textAlign = 'center'; ctx.fillText('BASE', MAP.base.x, MAP.base.y + 55); ctx.textAlign = 'left';
}

function drawTower(tower) {
  ctx.save(); ctx.translate(tower.x, tower.y); ctx.fillStyle = tower.type === 'tower_cannon' ? '#f0a35a' : '#7ed6ce'; ctx.strokeStyle = '#0b1519'; ctx.lineWidth = 3;
  ctx.beginPath(); ctx.arc(0, 0, 15, 0, Math.PI * 2); ctx.fill(); ctx.stroke(); ctx.fillStyle = '#0b1519'; ctx.fillRect(-4, -4, 8, 8); ctx.restore();
}

function drawEnemy(enemy) {
  const data = ENEMIES[enemy.type]; ctx.save(); ctx.translate(enemy.x, enemy.y); ctx.fillStyle = enemy.flash > 0 ? '#ffffff' : data.color; ctx.strokeStyle = '#0b1519'; ctx.lineWidth = 2;
  ctx.beginPath(); ctx.arc(0, 0, data.radius, 0, Math.PI * 2); ctx.fill(); ctx.stroke();
  if (enemy.type === 'enemy_giant') { ctx.strokeStyle = '#f6c1c6'; ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(0, 0, data.radius - 6, 0, Math.PI * 2); ctx.stroke(); }
  ctx.fillStyle = '#11191f'; ctx.fillRect(-data.radius, -data.radius - 8, data.radius * 2, 3); ctx.fillStyle = '#92d28b'; ctx.fillRect(-data.radius, -data.radius - 8, data.radius * 2 * Math.max(0, enemy.hp / enemy.maxHp), 3); ctx.restore();
}

function drawRobot() {
  const robot = state.robot; if (!robot.active) return;
  ctx.save(); ctx.translate(robot.x, robot.y); ctx.fillStyle = '#7ed6ce'; ctx.strokeStyle = '#d7fff7'; ctx.lineWidth = 2;
  ctx.beginPath(); ctx.moveTo(0, -22); ctx.lineTo(20, -10); ctx.lineTo(16, 18); ctx.lineTo(-16, 18); ctx.lineTo(-20, -10); ctx.closePath(); ctx.fill(); ctx.stroke(); ctx.fillStyle = '#102126'; ctx.fillRect(-8, -5, 16, 9); ctx.fillStyle = '#ef7068'; ctx.fillRect(-robot.range, -robot.range - 12, robot.range * 2, 4); ctx.fillStyle = '#92d28b'; ctx.fillRect(-robot.range, -robot.range - 12, robot.range * 2 * Math.max(0, robot.hp / ROBOT.hp), 4); ctx.restore();
}

function drawEffects() {
  state.effects.forEach(effect => {
    const alpha = effect.life / effect.maxLife; ctx.save(); ctx.globalAlpha = alpha;
    if (effect.type === 'areaBurst') { ctx.strokeStyle = '#f0a35a'; ctx.lineWidth = 4; ctx.beginPath(); ctx.arc(effect.x, effect.y, 80 - alpha * 20, 0, Math.PI * 2); ctx.stroke(); }
    else { ctx.strokeStyle = effect.type === 'pierce' ? '#aa8de5' : '#ffffff'; ctx.lineWidth = effect.type === 'pierce' ? 5 : 2; ctx.beginPath(); ctx.moveTo(effect.x - 16, effect.y); ctx.lineTo(effect.x + 16, effect.y); ctx.stroke(); }
    ctx.restore();
  });
}

function canvasPosition(event) { const rect = canvas.getBoundingClientRect(); return { x: (event.clientX - rect.left) * canvas.width / rect.width, y: (event.clientY - rect.top) * canvas.height / rect.height }; }
function selectSlot(slot) { state.selectedSlot = slot; updateUi(); }
function buildTower(id) {
  if (!state.selectedSlot) { addFeed('Select an empty tower slot first.', 'alert'); return; }
  if (state.towers.some(tower => tower.id === state.selectedSlot.id)) return;
  const data = TOWERS[id]; if (state.gold < data.cost) { addFeed(`Need ${data.cost} gold for ${data.name}.`, 'alert'); return; }
  state.gold -= data.cost; state.towers.push({ ...state.selectedSlot, type: id, data, cooldown: 0 }); addFeed(`${data.name} deployed at ${state.selectedSlot.id}.`, 'good'); state.selectedSlot = null; updateUi();
}
function moveRobot(position) {
  const robot = state.robot; if (!robot.active || robot.commands <= 0) return;
  const spot = MAP.robotSpots.find(item => item.id === position.id); if (!spot || robot.targetSpot === spot.id) return;
  robot.targetSpot = spot.id; robot.x = spot.x; robot.y = spot.y; robot.commands -= 1; addFeed(`Atlas-01 repositioned to ${spot.id}. ${robot.commands} commands remain.`); updateUi();
}

canvas.addEventListener('click', event => {
  const point = canvasPosition(event);
  const slot = MAP.slots.find(item => Math.hypot(item.x - point.x, item.y - point.y) < 24);
  if (slot && !state.towers.some(tower => tower.id === slot.id)) { selectSlot(slot); return; }
  const spot = MAP.robotSpots.find(item => Math.hypot(item.x - point.x, item.y - point.y) < 48);
  if (spot) moveRobot(spot);
});
document.querySelectorAll('.tower-card').forEach(button => button.addEventListener('click', () => buildTower(button.dataset.tower)));
ui.startWave.addEventListener('click', startWave);
ui.launchRobot.addEventListener('click', () => { if (!state.robot.active) { state.robot.active = true; state.robot.targetSpot = 'CENTER'; addFeed('Atlas-01 launched at CENTER. Choose its first crisis zone.', 'good'); updateUi(); } });
ui.restart.addEventListener('click', resetGame);

function frame(now) { const dt = Math.min(.05, (now - lastFrame) / 1000); lastFrame = now; update(dt); draw(); requestAnimationFrame(frame); }
resetGame(); requestAnimationFrame(frame);
