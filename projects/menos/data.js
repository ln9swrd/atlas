export const TOWERS = {
  tower_cannon: { id: 'tower_cannon', name: 'Cannon', cost: 55, damage: 42, cooldown: 1.35, range: 155, target: 'heavy', level2: { upgradeCost: 75, damage: 60, cooldown: 1.15, range: 165 } },
  tower_gatling: { id: 'tower_gatling', name: 'Gatling', cost: 35, damage: 9, cooldown: 0.23, range: 145, target: 'normal', level2: { upgradeCost: 50, damage: 13, cooldown: 0.20, range: 155 } }
};

export const ENEMIES = {
  enemy_normal: { id: 'enemy_normal', name: 'Normal', hp: 42, speed: 25, armor: 0, baseDamage: 8, reward: 12, radius: 10, color: '#f0b35a' },
  enemy_rusher: { id: 'enemy_rusher', name: 'Rusher', hp: 27, speed: 55, armor: 0, baseDamage: 6, reward: 10, radius: 8, color: '#ef7068' },
  enemy_heavy: { id: 'enemy_heavy', name: 'Heavy', hp: 125, speed: 14, armor: 8, baseDamage: 18, reward: 28, radius: 15, color: '#a98ce6' },
  enemy_giant: { id: 'enemy_giant', name: 'Giant', hp: 620, speed: 12, armor: 18, baseDamage: 45, reward: 90, radius: 28, color: '#f04f6b', robotDamage: 20, robotRange: 120, robotCooldown: 2 }
};

export const ROBOT = {
  id: 'robot_main', hp: 220, speed: 125, damage: 28, cooldown: 0.65, range: 180, maxMoves: 5,
  abilities: {
    ability_area: { id: 'ability_area', damage: 28, radius: 72, cooldown: 6, threshold: 3 },
    ability_heavy_pierce: { id: 'ability_heavy_pierce', damage: 105, cooldown: 7, targets: ['enemy_heavy', 'enemy_giant'] }
  }
};

export const WAVES = [
  { number: 1, label: 'NORMAL · BOTH LANES', spawns: [{ type: 'enemy_normal', count: 10, interval: 0.75, lanes: ['left', 'right'] }] },
  { number: 2, label: 'RUSHER · NORTH PRESSURE', spawns: [{ type: 'enemy_normal', count: 6, interval: 0.8, lanes: ['right'] }, { type: 'enemy_rusher', count: 8, interval: 0.5, lanes: ['left'] }] },
  { number: 3, label: 'HEAVY · SOUTH PRESSURE', spawns: [{ type: 'enemy_rusher', count: 7, interval: 0.45, lanes: ['right'] }, { type: 'enemy_heavy', count: 5, interval: 1.1, lanes: ['left'] }] },
  { number: 4, label: 'ALL TYPES · GIANT / BOTH LANES', spawns: [{ type: 'enemy_normal', count: 8, interval: 0.6, lanes: ['left', 'right'] }, { type: 'enemy_rusher', count: 8, interval: 0.42, lanes: ['left', 'right'] }, { type: 'enemy_heavy', count: 6, interval: 0.9, lanes: ['left', 'right'] }, { type: 'enemy_giant', count: 1, interval: 1, lanes: ['right'] }] }
];

export const MAP = {
  base: { x: 480, y: 500 },
  lanes: { left: { x: 270, y: 70 }, right: { x: 690, y: 70 } },
  slots: [
    { id: 'L1', x: 145, y: 145, lane: 'left' }, { id: 'L2', x: 300, y: 245, lane: 'left' }, { id: 'L3', x: 405, y: 350, lane: 'left' },
    { id: 'R1', x: 815, y: 145, lane: 'right' }, { id: 'R2', x: 660, y: 245, lane: 'right' }, { id: 'R3', x: 555, y: 350, lane: 'right' }
  ],
  robotSpots: [{ id: 'LEFT', x: 350, y: 310 }, { id: 'CENTER', x: 480, y: 390 }, { id: 'RIGHT', x: 610, y: 310 }]
};
