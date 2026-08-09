/**
 * Pattern Runner — timeline DSL executor (ms-based t)
 * Actions: spawn, delay, feint, feint_cancel, redirect, redirect_chain, burst, shield
 */

export function createPatternRunner() {
  return {
    queue: [],
    elapsed: 0,
    active: false,
    patternId: null,
    label: '',
    nextIdx: 0,
    debugLog: [],

    load(pattern) {
      this.queue = (pattern.timeline || []).slice().sort((a, b) => a.t - b.t);
      this.elapsed = 0;
      this.active = true;
      this.patternId = pattern.id;
      this.label = pattern.label || pattern.id;
      this.nextIdx = 0;
      this.debugLog = [];
    },

    stop() {
      this.active = false;
      this.queue = [];
    },

    /**
     * ctx: { boss, player, speedScale, fakeBoost, onEvent }
     * Returns list of commands for boss AI to consume
     */
    tick(dtMs, ctx) {
      if (!this.active) return [];
      this.elapsed += dtMs;
      const cmds = [];
      while (this.nextIdx < this.queue.length && this.queue[this.nextIdx].t <= this.elapsed) {
        const ev = this.queue[this.nextIdx++];
        const cmd = this.execute(ev, ctx);
        if (cmd) cmds.push(cmd);
        this.debugLog.push({ t: this.elapsed, action: ev.action });
        if (this.debugLog.length > 12) this.debugLog.shift();
        if (ctx.onEvent) ctx.onEvent(ev);
      }
      if (this.nextIdx >= this.queue.length) {
        this.active = false;
      }
      return cmds;
    },

    execute(ev, ctx) {
      const sc = ctx.speedScale || 1;
      switch (ev.action) {
        case 'spawn':
          return {
            kind: 'telegraph_charge',
            type: ev.type || 'normal',
            speed: (ev.speed || 500) * sc,
            telegraph: (ev.telegraph || 0.6) / Math.max(0.8, sc),
            duration: ev.duration || 0.4,
          };
        case 'burst':
          return {
            kind: 'combo',
            count: ev.count || 3,
            gap: (ev.gap || 250) / 1000,
            speed: (ev.speed || 540) * sc,
            telegraph: ev.telegraph || 0.4,
            duration: ev.duration || 0.38,
          };
        case 'redirect':
        case 'redirect_chain':
          return {
            kind: 'redirect',
            count: ev.count || 2,
            gap: (ev.gap || 220) / 1000,
            speed: (ev.speed || 560) * sc,
            telegraph: (ev.telegraph || 0.35) / 1000 < 1 ? ev.telegraph || 0.35 : (ev.telegraph || 350) / 1000,
            spread: ev.spread || 0,
          };
        case 'feint':
          return {
            kind: 'fake',
            paint: (ev.paint || 400) / 1000,
            cancel: (ev.cancel || 300) / 1000,
            telegraph: (ev.telegraph || 200) / 1000,
            speed: (ev.speed || 520) * sc,
          };
        case 'feint_cancel':
          return {
            kind: 'fake',
            paint: 0.25,
            cancel: (ev.window || 150) / 1000,
            telegraph: 0.15,
            speed: (ev.speed || 580) * sc,
          };
        case 'shield':
          return { kind: 'recover', ms: ev.ms || 500 };
        case 'delay':
          return { kind: 'recover', ms: (ev.ms || 300) + (ctx.delayBoost || 0) };
        default:
          return null;
      }
    },

    progress() {
      if (!this.queue.length) return 1;
      return Math.min(1, this.nextIdx / this.queue.length);
    },

    nextEvent() {
      return this.queue[this.nextIdx] || null;
    },
  };
}

/** Apply a runner command onto boss entity */
export function applyPatternCmd(boss, cmd, player) {
  if (!cmd || !boss) return;
  const dx = player.x - boss.x;
  const dy = player.y - boss.y;
  const len = Math.hypot(dx, dy) || 1;
  boss.aimX = dx / len;
  boss.aimY = dy / len;

  if (cmd.kind === 'telegraph_charge') {
    boss._act = {
      type: cmd.type || 'normal',
      telegraph: cmd.telegraph,
      speed: cmd.speed,
      duration: cmd.duration,
    };
    boss.state = 'telegraph';
    boss.timer = cmd.telegraph;
    boss.comboLeft = 0;
    boss.redirectLeft = 0;
  } else if (cmd.kind === 'combo') {
    boss._act = {
      type: 'combo',
      count: cmd.count,
      gap: cmd.gap,
      speed: cmd.speed,
      telegraph: cmd.telegraph,
      duration: cmd.duration,
    };
    boss.comboLeft = cmd.count;
    boss.redirectLeft = 0;
    boss.state = 'telegraph';
    boss.timer = cmd.telegraph;
  } else if (cmd.kind === 'redirect') {
    boss._act = {
      type: 'redirect',
      gap: cmd.gap,
      speed: cmd.speed,
      telegraph: typeof cmd.telegraph === 'number' ? cmd.telegraph : 0.35,
      duration: 0.38,
    };
    boss.redirectLeft = cmd.count;
    boss.comboLeft = 0;
    boss.state = 'telegraph';
    boss.timer = boss._act.telegraph;
  } else if (cmd.kind === 'fake') {
    boss._act = {
      type: 'fake',
      paint: cmd.paint,
      cancel: cmd.cancel,
      telegraph: cmd.telegraph,
      speed: cmd.speed,
      duration: 0.4,
    };
    boss.state = 'fake_paint';
    boss.timer = cmd.paint;
  } else if (cmd.kind === 'recover') {
    boss.state = 'recover';
    boss.timer = (cmd.ms || 300) / 1000;
  }
}
