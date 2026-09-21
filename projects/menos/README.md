# MENOS PoC

A Godot 4 tactical defense prototype validating whether robot positioning creates meaningful decisions. A browser version remains available as a quick fallback.

## Godot

Open `godot/project.godot` with Godot 4.7.2 and press F6/F5. The game uses no external assets.

- Click empty slots, then use BUILD CANNON or BUILD GATLING.
- Launch ATLAS-01 and click LEFT, CENTER, or RIGHT to spend movement commands.
- Start all four waves and compare the same tower setup with different robot positions.
- Press `R` or click RESTART to repeat an experiment.

## Run

Open `index.html` directly in a browser. No build step or external asset download is required.

## Experiment

1. Build towers in the six marked slots.
2. Launch Atlas-01.
3. Click LEFT, CENTER, or RIGHT lane markers to spend movement commands.
4. Restart and repeat the same tower/wave setup with a different robot position.
5. Compare base HP, gold, and the event feed.

The simulation uses data definitions in `data.js`; combat and rendering live in `game.js`.
