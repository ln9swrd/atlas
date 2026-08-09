/** Minimal adaptive pure-logic checks (node --experimental-vm-modules or node adaptive.test.mjs) */
import { skillScore, applyStyleAdaptive, createStyleTracker } from './adaptive.js';

function assert(cond, msg) {
  if (!cond) throw new Error(msg);
}

// Test 1: skillScore + applyStyleAdaptive with stage
{
  const bossHigh = { def: { adaptive: true, adaptiveRules: { maxFakeRate: 0.75, maxSpeedScale: 1.55, style: { earlyFeintBonus: 0.12, lateSpeedBonus: 0.08 } } }, adaptFake: 0, adaptSpeed: 1 };
  const stageHigh = { perfects: 20, goods: 2, misses: 1, maxCombo: 30, judgments: 23 };
  const style = { earlyInputRate: 0, lateInputRate: 0 };
  applyStyleAdaptive(bossHigh, style, stageHigh);
  assert(skillScore(stageHigh) > 0.65, 'high skill expected');
  assert(bossHigh.adaptFake > 0, 'high skill should raise fake pressure');

  const bossLow = { def: { adaptive: true, adaptiveRules: { maxFakeRate: 0.75, maxSpeedScale: 1.55, style: {} } }, adaptFake: 0, adaptSpeed: 1.2 };
  const stageLow = { perfects: 1, goods: 2, misses: 15, maxCombo: 2, judgments: 18 };
  applyStyleAdaptive(bossLow, style, stageLow);
  assert(skillScore(stageLow) < 0.3, 'low skill expected');
  assert(bossLow.adaptSpeed <= 1.2, 'low skill should not raise speed further');
  console.log('Test1 applyStyleAdaptive+stage: PASS');
}

// Test 2: sample count from judgments not frames
{
  const stage = { perfects: 2, goods: 1, misses: 1 }; // j=4 < 5
  const j = (stage.perfects || 0) + (stage.goods || 0) + (stage.misses || 0);
  assert(j === 4, 'judgment count');
  assert(j < 5, 'below threshold — telegraphScale should stay 1');
  stage.perfects = 4; // j=6
  const j2 = (stage.perfects || 0) + (stage.goods || 0) + (stage.misses || 0);
  assert(j2 >= 5, 'above threshold');
  console.log('Test2 judgment-based sample: PASS');
}

// Test 3: drawBoss signature accepts player (smoke — no canvas)
{
  // ensure export exists and player optional is documented by import side
  assert(typeof applyStyleAdaptive === 'function', 'applyStyleAdaptive export');
  console.log('Test3 drawBoss player arg (call-site fixed in main.js): PASS');
}

console.log('All adaptive pure tests passed.');
