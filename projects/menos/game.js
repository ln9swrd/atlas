import { TOWERS, ENEMIES, ROBOT, WAVES, MAP } from './data.js';

const canvas = document.querySelector('#battlefield');
const ctx = canvas.getContext('2d');
const ui = {
  baseHp: document.querySelector('#baseHp'), gold: document.querySelector('#gold'), wave: document.querySelector('#waveNumber'),
  nextWave: document.querySelector('#nextWaveInfo'), startWave: document.querySelector('#startWave'), restart: document.querySelector('#restart'),
  selectedSlot: document.querySelector('#selectedSlot'), robotStatus: document.querySelector('#robotStatus'), robotHp: document.querySelector('#robotHp'),
  moveCommands: document.querySelector('#moveCommands'), launchRobot: document.querySelector('#launchRobot'), eventFeed: document.querySelector('#eventFeed'),
  runStatus: document.querySelector('#runStatus'), timer: document.querySelector('#timer'),
  abilityModal: document.querySelector('#abilityModal'), abilityOptions: document.querySelector('#abilityOptions')
};

const ABILITY_DEFINITIONS = {
  ability_area: {
    id: 'ability_area',
    name: 'AREA ATTACK',
    desc: 'Triggers an AoE shockwave dealing 28 DMG when 3+ enemies gather near Atlas-01.',
    meta: 'CD: 6s · Radius: 72px · 3+ Targets'
  },
  ability_heavy_pierce: {
    id: 'ability_heavy_pierce',
    name: 'HEAVY PIERCE',
    desc: 'Fires a high-velocity piercing beam dealing 105 DMG to Heavy and Giant enemies.',
    meta: 'CD: 7s · Targets: Heavy & Giant'
  }
};

let state;
let lastFrame = performance.now();

const EXPERIMENT = {
  active: false,
  disableTowers: true,
  enemyType: 'enemy_heavy',
  lane: 'left',
  spawnCount: 5,
  spawnInterval: 1.2
};

function buildExperimentWave() {
  return {
    number: 1,
    label: 'HEAVY TEST',
    spawns: [{
      type: EXPERIMENT.enemyType,
      count: EXPERIMENT.spawnCount,
      interval: EXPERIMENT.spawnInterval,
      lanes: [EXPERIMENT.lane]
    }]
  };
}

function resetGame() {
  state = {
    baseHp: 100, gold: 180, currentWave: 1, waveRunning: false, waveComplete: false, elapsed: 0,
    enemies: [], towers: [], selectedSlot: null, selectedEntity: null, spawnQueue: [], spawnTimer: 0, waveClock: 0, effects: [], feed: [],
    robot: { active: false, x: MAP.robotSpots[1].x, y: MAP.robotSpots[1].y, hp: ROBOT.hp, commands: ROBOT.maxMoves, targetSpot: 'CENTER', attackTimer: 0, areaTimer: 0, pierceTimer: 0, unlockedAbilities: [] },
    pendingAbilityChoice: false
  };
  hideAbilityModal();
  addFeed('Build a tower, then start the first wave.');
  updateUi();
}

function addFeed(message, type = '') {
  state.feed.unshift({ message, type });
  state.feed = state.feed.slice(0, 7);
  ui.eventFeed.innerHTML = state.feed.map(item => `<p class="${item.type}">${item.message}</p>`).join('');
}

function updateUi() {
  const wave = WAVES[state.currentWave - 1] || WAVES[0];
  const isVictory = state.waveComplete && state.currentWave > WAVES.length;
  ui.baseHp.textContent = Math.max(0, Math.ceil(state.baseHp));
  ui.gold.textContent = state.gold;
  ui.wave.textContent = `${Math.min(WAVES.length, state.currentWave)} / ${WAVES.length}`;
  ui.nextWave.textContent = `WAVE ${wave.number}: ${wave.label}`;
  ui.startWave.textContent = state.waveRunning
    ? `WAVE ${state.currentWave} IN PROGRESS`
    : state.pendingAbilityChoice
    ? 'SELECT ABILITY UPGRADE'
    : state.waveComplete
    ? (isVictory ? 'ALL WAVES CLEAR' : `START WAVE ${state.currentWave}`)
    : `START WAVE ${state.currentWave}`;
  ui.startWave.disabled = state.waveRunning || state.baseHp <= 0 || state.currentWave > WAVES.length || state.pendingAbilityChoice || isVictory;
  ui.launchRobot.disabled = state.robot.active || state.baseHp <= 0 || state.currentWave > WAVES.length;
  ui.robotStatus.textContent = state.selectedEntity?.kind === 'robot'
    ? `SELECTED · DEPLOYED · ${state.robot.targetSpot}`
    : state.robot.active ? `DEPLOYED · ${state.robot.targetSpot}` : 'DOCKED';
  ui.robotHp.textContent = `${Math.max(0, Math.ceil(state.robot.hp))} / ${ROBOT.hp}`;
  ui.moveCommands.textContent = '∞';
  const selTower = state.selectedSlot ? state.towers.find(t => t.id === state.selectedSlot.id) : null;
  if (selTower) {
    const l2 = selTower.data.level2;
    const costText = selTower.level === 2 ? 'MAX LVL 2' : (l2 ? `UPGRADE: ${l2.upgradeCost}g` : '');
    ui.selectedSlot.textContent = `${selTower.id} · ${selTower.data.name} LVL ${selTower.level || 1} (${costText})`;
  } else {
    ui.selectedSlot.textContent = state.selectedSlot ? `${state.selectedSlot.id} · SELECTED` : 'NO SLOT';
  }
  ui.runStatus.textContent = state.baseHp <= 0 ? 'BREACHED' : state.waveRunning ? 'LIVE' : state.pendingAbilityChoice ? 'UPGRADE PENDING' : isVictory ? 'VICTORY' : state.waveComplete ? 'WAVE CLEAR' : 'READY';
  ui.timer.textContent = formatTime(state.elapsed);
}

function formatTime(seconds) {
  const minutes = Math.floor(seconds / 60).toString().padStart(2, '0');
  const remainder = Math.floor(seconds % 60).toString().padStart(2, '0');
  return `${minutes}:${remainder}`;
}

function startWave() {
  const isVictory = state.waveComplete && state.currentWave > WAVES.length;
  if (state.waveRunning || state.baseHp <= 0 || state.currentWave > WAVES.length || state.pendingAbilityChoice || isVictory) return;
  const wave = EXPERIMENT.active ? buildExperimentWave() : WAVES[state.currentWave - 1];
  state.spawnQueue = wave.spawns.flatMap(spawn => Array.from({ length: spawn.count }, (_, index) => ({ ...spawn, delay: index * spawn.interval })));
  state.waveClock = 0;
  state.spawnTimer = 0;
  state.waveRunning = true;
  state.waveComplete = false;
  addFeed(`${EXPERIMENT.active ? 'Experiment wave' : `Wave ${state.currentWave}`} started: ${wave.label.toLowerCase()}.`, 'good');
  updateUi();
}

function spawnDueEnemies(dt) {
  if (!state.spawnQueue.length) return;
  state.spawnTimer += dt;
  while (state.spawnQueue.length && state.spawnQueue[0].delay <= state.waveClock) {
    const entry = state.spawnQueue.shift();
    const lane = entry.lanes[(state.enemies.length + state.spawnQueue.length) % entry.lanes.length];
    const data = ENEMIES[entry.type];
    state.enemies.push({ type: entry.type, lane, x: MAP.lanes[lane].x, y: MAP.lanes[lane].y, hp: data.hp, maxHp: data.hp, flash: 0, robotAttackTimer: 0, id: `${entry.type}-${state.elapsed}-${Math.random()}` });
  }
}

function damageRobot(amount) {
  if (!state.robot.active) return;
  state.robot.hp = Math.max(0, state.robot.hp - amount);
  state.robot.flash = 0.12;
  state.effects.push({ type: 'giantHit', x: state.robot.x, y: state.robot.y, life: .28, maxLife: .28 });
  if (state.robot.hp <= 0) {
    state.robot.hp = 0;
    state.robot.active = false;
    if (state.selectedEntity?.kind === 'robot') state.selectedEntity = null;
    addFeed('Atlas-01 destroyed. Base defense remains active.', 'alert');
  }
}

function updateGiantRobotAttack(dt, enemy) {
  if (enemy.type !== 'enemy_giant' || !state.robot.active || state.robot.hp <= 0) return;
  const data = ENEMIES[enemy.type];
  enemy.robotAttackTimer -= dt;
  if (Math.hypot(enemy.x - state.robot.x, enemy.y - state.robot.y) > data.robotRange) return;
  if (enemy.robotAttackTimer > 0) return;
  damageRobot(data.robotDamage);
  addFeed(`Giant hit Atlas-01 (-${data.robotDamage} HP).`, 'alert');
  enemy.robotAttackTimer = data.robotCooldown;
}

function updateRusherSprint(enemy) {
  if (enemy.type !== 'enemy_rusher') return 1;
  if (!enemy.sprintLogged && enemy.y >= 180) {
    enemy.sprinting = true;
    enemy.sprintLogged = true;
    addFeed('Rusher initiated SPRINT BURST.', 'alert');
  }
  return enemy.sprinting ? 1.4 : 1;
}

function moveEnemies(dt) {
  for (const enemy of state.enemies) {
    const data = ENEMIES[enemy.type];
    if (enemy.hp <= 0) continue;
    const speedMult = updateRusherSprint(enemy);
    const start = MAP.lanes[enemy.lane];
    enemy.y += data.speed * speedMult * dt;
    const progress = Math.min(1, (enemy.y - start.y) / (MAP.base.y - start.y));
    enemy.x = start.x + (MAP.base.x - start.x) * progress;
    if (enemy.type === 'enemy_giant') updateGiantRobotAttack(dt, enemy);
    if (enemy.y >= MAP.base.y - 25) {
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

function getRobotTarget() {
  const candidates = state.enemies.filter(enemy =>
    enemy.hp > 0 && Math.hypot(enemy.x - state.robot.x, enemy.y - state.robot.y) <= ROBOT.range
  );
  return candidates.sort((a, b) => b.x - a.x)[0] || null;
}

function getRobotHeavyTarget() {
  const eligible = state.enemies.filter(enemy =>
    enemy.hp > 0
    && (enemy.type === 'enemy_heavy' || enemy.type === 'enemy_giant')
    && Math.hypot(enemy.x - state.robot.x, enemy.y - state.robot.y) <= ROBOT.range + 20
  );
  return eligible.sort((a, b) => b.x - a.x)[0] || null;
}

function updateTowers(dt) {
  if (EXPERIMENT.active && EXPERIMENT.disableTowers) return;
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
  const target = getRobotTarget();
  const heavyTarget = getRobotHeavyTarget();

  const isAreaUnlocked = robot.unlockedAbilities && robot.unlockedAbilities.includes('ability_area');
  const isPierceUnlocked = robot.unlockedAbilities && robot.unlockedAbilities.includes('ability_heavy_pierce');

  if (isAreaUnlocked && robot.areaTimer <= 0) {
    const nearby = state.enemies.filter(enemy => enemy.hp > 0 && Math.hypot(enemy.x - robot.x, enemy.y - robot.y) <= ROBOT.abilities.ability_area.radius);
    if (nearby.length >= ROBOT.abilities.ability_area.threshold) {
      nearby.forEach(enemy => damageEnemy(enemy, ROBOT.abilities.ability_area.damage, 'area'));
      state.effects.push({ type: 'areaBurst', x: robot.x, y: robot.y, life: .45, maxLife: .45 });
      robot.areaTimer = ROBOT.abilities.ability_area.cooldown;
      addFeed('Atlas-01 used AREA ATTACK.', 'good');
    }
  }
  if (isPierceUnlocked && robot.pierceTimer <= 0 && heavyTarget) {
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
  if (state.robot) state.robot.flash = Math.max(0, (state.robot.flash || 0) - dt);
}

function openAbilityChoice() {
  const unlocked = state.robot.unlockedAbilities || [];
  const lockedIds = Object.keys(ABILITY_DEFINITIONS).filter(id => !unlocked.includes(id));
  if (lockedIds.length === 0) {
    state.pendingAbilityChoice = false;
    hideAbilityModal();
    return;
  }
  const candidateIds = lockedIds.slice(0, 2);
  state.pendingAbilityChoice = true;
  renderAbilityModal(candidateIds);
}

function renderAbilityModal(candidateIds) {
  if (!ui.abilityModal || !ui.abilityOptions) return;
  ui.abilityOptions.innerHTML = candidateIds.map(id => {
    const def = ABILITY_DEFINITIONS[id];
    return `<button class="ability-card" data-ability="${id}">
      <div>
        <b>${def.name}</b>
        <p>${def.desc}</p>
      </div>
      <div class="meta">${def.meta}</div>
    </button>`;
  }).join('');

  ui.abilityOptions.querySelectorAll('.ability-card').forEach(btn => {
    btn.addEventListener('click', () => selectAbility(btn.dataset.ability));
  });

  ui.abilityModal.style.display = 'flex';
}

function selectAbility(abilityId) {
  if (!state.robot.unlockedAbilities) state.robot.unlockedAbilities = [];
  if (!state.robot.unlockedAbilities.includes(abilityId)) {
    state.robot.unlockedAbilities.push(abilityId);
    const def = ABILITY_DEFINITIONS[abilityId];
    addFeed(`Atlas-01 unlocked ${def ? def.name : abilityId}.`, 'good');
  }
  const autoStartNextWave = state.waveComplete && state.currentWave <= WAVES.length && state.baseHp > 0;
  state.pendingAbilityChoice = false;
  hideAbilityModal();
  updateUi();
  if (autoStartNextWave) startWave();
}

function hideAbilityModal() {
  if (ui.abilityModal) {
    ui.abilityModal.style.display = 'none';
  }
}

function finishWaveIfReady() {
  if (!state.waveRunning || state.spawnQueue.length || state.enemies.some(enemy => enemy.hp > 0)) return;
  state.waveRunning = false;
  state.waveComplete = true;
  if (state.currentWave < WAVES.length) {
    addFeed(`Wave ${state.currentWave} clear. Choose an ability upgrade for Atlas-01.`, 'good');
    state.currentWave += 1;
    openAbilityChoice();
  } else {
    state.currentWave += 1;
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
  ctx.fillStyle = '#10242a'; ctx.fillRect(0, 0, canvas.width, 176);
  ctx.fillStyle = '#16343a'; ctx.fillRect(0, 176, canvas.width, 112);
  ctx.fillStyle = '#1b3b3f'; ctx.fillRect(0, 288, canvas.width, 272);
  ctx.strokeStyle = 'rgba(126,214,206,.12)'; ctx.lineWidth = 1;
  for (let x = 0; x < canvas.width; x += 48) { ctx.beginPath(); ctx.moveTo(x, 288); ctx.lineTo(x + 92, 560); ctx.stroke(); }
  for (let y = 320; y < canvas.height; y += 40) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke(); }
  ctx.fillStyle = '#31535b'; ctx.fillRect(0, 172, canvas.width, 4); ctx.fillRect(0, 284, canvas.width, 4);
  ctx.fillStyle = '#6c8790'; ctx.font = '11px Space Mono'; ctx.fillText('NORTH APPROACH // GATE 01', 22, 122); ctx.fillText('SOUTH APPROACH // GATE 02', 22, 463);
  ctx.fillStyle = '#7ed6ce'; ctx.font = '10px Space Mono'; ctx.fillText('NORTHBRIDGE DEFENSE GRID // 3/4 FIELD VIEW', 88, 80);
}

function drawLanes() {
  for (const lane of Object.values(MAP.lanes)) {
    ctx.strokeStyle = '#263c43'; ctx.lineWidth = 42; ctx.beginPath(); ctx.moveTo(lane.x, lane.y); ctx.lineTo(MAP.base.x, MAP.base.y); ctx.stroke();
    ctx.strokeStyle = '#527079'; ctx.lineWidth = 2; ctx.setLineDash([12, 14]); ctx.beginPath(); ctx.moveTo(lane.x, lane.y); ctx.lineTo(MAP.base.x, MAP.base.y); ctx.stroke(); ctx.setLineDash([]);
  }
  MAP.robotSpots.forEach(spot => { ctx.fillStyle = 'rgba(126,214,206,.05)'; ctx.strokeStyle = 'rgba(126,214,206,.3)'; ctx.lineWidth = 1; ctx.beginPath(); ctx.arc(spot.x, spot.y, 58, 0, Math.PI * 2); ctx.fill(); ctx.stroke(); });
  ctx.fillStyle = '#ef7068'; ctx.fillRect(MAP.lanes.left.x - 12, MAP.lanes.left.y - 6, 24, 12); ctx.fillRect(MAP.lanes.right.x - 12, MAP.lanes.right.y - 6, 24, 12);
}

function drawSlots() {
  MAP.slots.forEach(slot => {
    const tower = state.towers.find(item => item.id === slot.id);
    if (tower) return;
    ctx.fillStyle = 'rgba(10, 21, 25, .72)'; ctx.beginPath(); ctx.ellipse(slot.x, slot.y + 9, 26, 9, 0, 0, Math.PI * 2); ctx.fill();
    ctx.strokeStyle = state.selectedSlot?.id === slot.id ? '#f0a35a' : '#6a858a'; ctx.lineWidth = 2; ctx.setLineDash([3, 4]);
    ctx.beginPath(); ctx.arc(slot.x, slot.y, 18, 0, Math.PI * 2); ctx.stroke(); ctx.setLineDash([]);
    ctx.fillStyle = '#6a858a'; ctx.font = '10px Space Mono'; ctx.textAlign = 'center'; ctx.fillText(slot.id, slot.x, slot.y + 4); ctx.textAlign = 'left';
  });
  MAP.robotSpots.forEach(spot => { ctx.fillStyle = '#7ed6ce'; ctx.font = '10px Space Mono'; ctx.textAlign = 'center'; ctx.fillText(spot.id, spot.x, spot.y + 55); ctx.textAlign = 'left'; });
}

function drawBase() {
  ctx.save(); ctx.translate(MAP.base.x, MAP.base.y); ctx.fillStyle = '#182f35'; ctx.strokeStyle = '#7ed6ce'; ctx.lineWidth = 2;
  ctx.beginPath(); ctx.rect(-38, -38, 76, 76); ctx.fill(); ctx.stroke(); ctx.strokeStyle = 'rgba(126,214,206,.35)'; ctx.lineWidth = 8; ctx.strokeRect(-52, -52, 104, 104); ctx.fillStyle = '#7ed6ce'; ctx.fillRect(-10, -10, 20, 20); ctx.restore();
  ctx.fillStyle = '#7ed6ce'; ctx.font = '11px Space Mono'; ctx.textAlign = 'center'; ctx.fillText('BASE', MAP.base.x, MAP.base.y + 55); ctx.textAlign = 'left';
}

function drawTower(tower) {
  ctx.save(); ctx.translate(tower.x, tower.y);
  if (state.selectedEntity?.kind === 'tower' && state.selectedEntity.id === tower.id) {
    ctx.strokeStyle = '#7ed6ce'; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.arc(0, 0, 24, 0, Math.PI * 2); ctx.stroke();
  }
  ctx.fillStyle = tower.type === 'tower_cannon' ? '#f0a35a' : '#7ed6ce';
  ctx.strokeStyle = tower.level === 2 ? '#ffffff' : '#0b1519';
  ctx.lineWidth = tower.level === 2 ? 4 : 3;
  ctx.beginPath(); ctx.arc(0, 0, 15, 0, Math.PI * 2); ctx.fill(); ctx.stroke();
  if (tower.level === 2) {
    ctx.strokeStyle = '#f0a35a'; ctx.lineWidth = 1.5;
    ctx.beginPath(); ctx.arc(0, 0, 20, 0, Math.PI * 2); ctx.stroke();
  }
  ctx.fillStyle = '#0b1519'; ctx.fillRect(-4, -4, 8, 8);
  ctx.restore();
}

function drawEnemy(enemy) {
  const data = ENEMIES[enemy.type]; ctx.save(); ctx.translate(enemy.x, enemy.y); ctx.fillStyle = enemy.flash > 0 ? '#ffffff' : data.color; ctx.strokeStyle = '#0b1519'; ctx.lineWidth = 2;
  ctx.beginPath(); ctx.arc(0, 0, data.radius, 0, Math.PI * 2); ctx.fill(); ctx.stroke();
  if (enemy.type === 'enemy_giant') { ctx.strokeStyle = '#f6c1c6'; ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(0, 0, data.radius - 6, 0, Math.PI * 2); ctx.stroke(); }
  ctx.fillStyle = '#11191f'; ctx.fillRect(-data.radius, -data.radius - 8, data.radius * 2, 3); ctx.fillStyle = '#92d28b'; ctx.fillRect(-data.radius, -data.radius - 8, data.radius * 2 * Math.max(0, enemy.hp / enemy.maxHp), 3); ctx.restore();
}

function drawRobot() {
  const robot = state.robot; if (!robot.active) return;
  ctx.save(); ctx.translate(robot.x, robot.y);
  if (state.selectedEntity?.kind === 'robot') {
    ctx.strokeStyle = '#f0a35a'; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.arc(0, 0, 32, 0, Math.PI * 2); ctx.stroke();
  }
  const target = nearestEnemy(robot.x, robot.y, ROBOT.range) || nearestEnemy(robot.x, robot.y, ROBOT.range + 20, 'heavy');
  if (target) {
    ctx.strokeStyle = 'rgba(239, 112, 104, 0.55)';
    ctx.lineWidth = 1.5;
    ctx.setLineDash([4, 4]);
    ctx.beginPath(); ctx.arc(0, 0, 26, 0, Math.PI * 2); ctx.stroke();
    ctx.setLineDash([]);
  }
  ctx.fillStyle = robot.flash > 0 ? '#ffffff' : '#7ed6ce';
  ctx.strokeStyle = robot.flash > 0 ? '#ef7068' : '#d7fff7';
  ctx.lineWidth = robot.flash > 0 ? 4 : 2;
  ctx.beginPath(); ctx.moveTo(0, -22); ctx.lineTo(20, -10); ctx.lineTo(16, 18); ctx.lineTo(-16, 18); ctx.lineTo(-20, -10); ctx.closePath(); ctx.fill(); ctx.stroke(); ctx.fillStyle = '#102126'; ctx.fillRect(-8, -5, 16, 9); ctx.fillStyle = '#ef7068'; ctx.fillRect(-robot.range, -robot.range - 12, robot.range * 2, 4); ctx.fillStyle = '#92d28b'; ctx.fillRect(-robot.range, -robot.range - 12, robot.range * 2 * Math.max(0, robot.hp / ROBOT.hp), 4); ctx.restore();
}

function drawEffects() {
  state.effects.forEach(effect => {
    const alpha = effect.life / effect.maxLife; ctx.save(); ctx.globalAlpha = alpha;
    if (effect.type === 'areaBurst') { ctx.strokeStyle = '#f0a35a'; ctx.lineWidth = 4; ctx.beginPath(); ctx.arc(effect.x, effect.y, 80 - alpha * 20, 0, Math.PI * 2); ctx.stroke(); }
    else if (effect.type === 'giantHit') { ctx.strokeStyle = '#ef7068'; ctx.lineWidth = 3; ctx.beginPath(); ctx.arc(effect.x, effect.y, 35 - alpha * 12, 0, Math.PI * 2); ctx.stroke(); }
    else { ctx.strokeStyle = effect.type === 'pierce' ? '#aa8de5' : '#ffffff'; ctx.lineWidth = effect.type === 'pierce' ? 5 : 2; ctx.beginPath(); ctx.moveTo(effect.x - 16, effect.y); ctx.lineTo(effect.x + 16, effect.y); ctx.stroke(); }
    ctx.restore();
  });
}

function canvasPosition(event) { const rect = canvas.getBoundingClientRect(); return { x: (event.clientX - rect.left) * canvas.width / rect.width, y: (event.clientY - rect.top) * canvas.height / rect.height }; }
function selectSlot(slot) { state.selectedEntity = null; state.selectedSlot = slot; updateUi(); }
function selectTower(tower) {
  state.selectedEntity = { kind: 'tower', id: tower.id };
  state.selectedSlot = MAP.slots.find(slot => slot.id === tower.id) || null;
  updateUi();
}
function selectRobot() { state.selectedEntity = { kind: 'robot' }; state.selectedSlot = null; updateUi(); }
function upgradeTower(tower) {
  if (state.waveRunning) { addFeed('Cannot upgrade towers during wave.', 'alert'); return; }
  if (!tower || tower.level >= 2) { addFeed('Tower is already at MAX LVL 2.', 'alert'); return; }
  const l2Data = TOWERS[tower.type]?.level2;
  if (!l2Data) return;
  if (state.gold < l2Data.upgradeCost) { addFeed(`Need ${l2Data.upgradeCost} gold to upgrade ${tower.data.name} to LVL 2.`, 'alert'); return; }
  state.gold -= l2Data.upgradeCost;
  tower.level = 2;
  tower.data = { ...tower.data, damage: l2Data.damage, cooldown: l2Data.cooldown, range: l2Data.range, level: 2 };
  addFeed(`${tower.data.name} at ${tower.id} upgraded to LVL 2 (-${l2Data.upgradeCost}g).`, 'good');
  state.selectedEntity = null;
  state.selectedSlot = null;
  updateUi();
}
function buildTower(id) {
  if (state.baseHp <= 0 || state.currentWave > WAVES.length) return;
  if (!state.selectedSlot) { addFeed('Select a tower slot first.', 'alert'); return; }
  const existingTower = state.towers.find(tower => tower.id === state.selectedSlot.id);
  if (existingTower) {
    if (existingTower.level === 1 && existingTower.type === id) {
      upgradeTower(existingTower);
    } else if (existingTower.level >= 2) {
      addFeed(`${existingTower.data.name} at ${existingTower.id} is already MAX LVL 2.`, 'alert');
    } else {
      addFeed(`Slot ${existingTower.id} has ${existingTower.data.name} LVL 1. Select matching type to upgrade.`, 'alert');
    }
    return;
  }
  const data = TOWERS[id]; if (!data) return;
  if (state.gold < data.cost) { addFeed(`Need ${data.cost} gold for ${data.name}.`, 'alert'); return; }
  state.gold -= data.cost; state.towers.push({ ...state.selectedSlot, type: id, data: { ...data }, level: 1, cooldown: 0 }); addFeed(`${data.name} LVL 1 deployed at ${state.selectedSlot.id}.`, 'good'); state.selectedSlot = null; state.selectedEntity = null; updateUi();
}
function moveRobot(position) {
  const robot = state.robot; if (!robot.active || state.baseHp <= 0 || state.currentWave > WAVES.length) return;
  const spot = MAP.robotSpots.find(item => item.id === position.id); if (!spot || robot.targetSpot === spot.id) return;
  robot.targetSpot = spot.id; robot.x = spot.x; robot.y = spot.y; addFeed(`Atlas-01 repositioned to ${spot.id}.`); updateUi();
}

canvas.addEventListener('click', event => {
  const point = canvasPosition(event);
  const tower = state.towers.find(item => Math.hypot(item.x - point.x, item.y - point.y) < 21);
  if (tower) { selectTower(tower); return; }
  if (state.robot.active && Math.hypot(state.robot.x - point.x, state.robot.y - point.y) < 25) { selectRobot(); return; }
  const slot = MAP.slots.find(item => Math.hypot(item.x - point.x, item.y - point.y) < 24);
  if (slot) { selectSlot(slot); return; }
  const spot = MAP.robotSpots.find(item => Math.hypot(item.x - point.x, item.y - point.y) < 48);
  if (spot) { if (state.selectedEntity?.kind === 'robot') moveRobot(spot); return; }
  state.selectedEntity = null; state.selectedSlot = null; updateUi();
});
document.querySelectorAll('.tower-card').forEach(button => button.addEventListener('click', () => buildTower(button.dataset.tower)));
ui.startWave.addEventListener('click', startWave);
ui.launchRobot.addEventListener('click', () => { if (!state.robot.active && state.baseHp > 0 && state.currentWave <= WAVES.length) { state.robot.hp = ROBOT.hp; state.robot.active = true; state.selectedEntity = { kind: 'robot' }; addFeed(`Atlas-01 launched at ${state.robot.targetSpot}. Choose its first crisis zone.`, 'good'); updateUi(); } });
ui.restart.addEventListener('click', resetGame);

function frame(now) { const dt = Math.min(.05, (now - lastFrame) / 1000); lastFrame = now; update(dt); draw(); requestAnimationFrame(frame); }

function enableMinimalDiscriminatingExperiment() {
  EXPERIMENT.active = true;
  EXPERIMENT.disableTowers = true;
  EXPERIMENT.enemyType = 'enemy_heavy';
  EXPERIMENT.lane = 'left';
  EXPERIMENT.spawnCount = 5;
  EXPERIMENT.spawnInterval = 1.2;
  state.towers = [];
  state.robot.active = true;
  state.robot.targetSpot = 'CENTER';
  state.robot.x = MAP.robotSpots[1].x;
  state.robot.y = MAP.robotSpots[1].y;
  state.robot.commands = ROBOT.maxMoves;
  state.waveRunning = false;
  state.waveComplete = false;
  state.currentWave = 1;
  updateUi();
}

function configureRobotPosition(positionId) {
  const spot = MAP.robotSpots.find(item => item.id === positionId);
  if (!spot) return null;
  state.robot.x = spot.x;
  state.robot.y = spot.y;
  state.robot.targetSpot = spot.id;
  state.robot.active = true;
  updateUi();
  return { x: spot.x, y: spot.y, id: spot.id };
}

window.__MENOS_TEST__ = {
  EXPERIMENT,
  enableMinimalDiscriminatingExperiment,
  configureRobotPosition,
  resetGame,
  startWave,
  moveRobot,
  buildTower,
  upgradeTower,
  update,
  state,
  getState: () => state,
  openAbilityChoice,
  selectAbility,
  draw
};

resetGame(); requestAnimationFrame(frame);
