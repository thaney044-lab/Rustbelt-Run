# Rustbelt Run

A 2D puzzle platformer following a fox mechanic through an overgrown industrial valley. Repair machinery, discover secrets, and chase a runaway robot.

## Current prototype

Godot **4.6.3**, GDScript, Compatibility renderer. Open `project.godot` and press **F6** on `scenes/movement_lab.tscn`, or press **F5** to run the project. From a terminal in this directory: `godot --path .`.

First Shift connects five areas: Cinder Yard, the repair works, piston hall, flooded viaduct and the foundry. Painted stone viaducts, iron catwalks, cables, lanterns and ferns tie the playable route into the industrial valley. The fox has acceleration, variable jump height, coyote time, jump buffering, a follow camera and checkpoint recovery. The main route combines patrol combat, a crane repair puzzle, timed pistons, canal crossings and a powered hoist.

- Move: A/D, arrows, controller left stick or D-pad.
- Jump: Space or controller A; release early for a short hop.
- Retry: R. Reach the flag to set the checkpoint.
- Pause/resume: Esc. The pause screen includes controls and a full-run restart.
- Optional rooftop routes hold two rare parts; a third is in the maintenance loft. Parts and scrap survive checkpoint retries during this page session. The rooftop parts also restore health.
- Reach PATCH's lit workshop for the results screen: time, scrap, rare parts and retries. Enter/the button starts a fresh run; R returns to the final checkpoint for more exploration.

In the repair yard, J swings the wrench, K throws it toward a highlighted switch, E carries/inserts the battery or uses the crane control, and T resets the puzzle at its checkpoint. Controller bindings: X swing, B throw, Y use, Back reset. Lower the crane bridge and cross to the exit. Falls restore the whole puzzle to a recoverable state. Patrol bots, three health points, brief damage protection and optional scrap trails are implemented. Production audio, a title screen, remapping, persistent saves and Windows exports remain planned. Controller bindings exist but have not been tested with physical hardware. The owner has playtested and approved the movement; new art and level additions still benefit from further playtesting.

See [the implementation plan](docs/IMPLEMENTATION_PLAN.md) for milestones and acceptance criteria based on the supplied v0.1 outline. Godot is the initial default; the outline did not specify an engine.

The repeating foreground flywheels have been removed so bottom-of-screen machinery no longer appears to follow the player.

## Item graphics polish

Catwalks have cross-braced metal webs, brass rivets, timber treads and bounded under-brackets. Moving decks use amber hazard stripes and paired lamps; stone decks have segmented coping aligned to their collision top. Wooden crates have grain, diagonal braces and metal straps, while gates have inset hazard panels and reinforced rails.

Cinder Yard uses staggered ledges instead of closely stacked decks. Patrol bots render 40% larger and retain their painted artwork with animated brass wheel hubs, exhaust steam, a pulsing lens and a collapsing defeat animation with an impact flash, spinning metal fragments and rising smoke. The targeting brackets use local coordinates and highlight only the nearest valid wrench target. Collision shapes, movement speeds and jump tuning are unchanged. The art smoke test checks target priority, facing, defeated-target handoff and animation reset.

## Validation

```sh
godot --headless --editor --import --path . --quit
godot --headless --path . --quit-after 120
godot --headless --path . --script tests/movement_smoke.gd
godot --headless --path . --script tests/repair_smoke.gd
godot --headless --path . --script tests/passage_smoke.gd
godot --headless --path . --script tests/canal_smoke.gd
godot --headless --path . --script tests/art_smoke.gd
godot --headless --path . --script tests/gameplay_smoke.gd
godot --headless --path . --script tests/foundry_smoke.gd
godot --headless --path . --script tests/level_smoke.gd
```

The smoke test exercises real physics: landing, different jump heights, checkpoint activation, fall recovery, and moving-platform carrying. It exits nonzero on failure.

In a cloud sandbox where the default home directories are read-only, initialize writable runtime directories before either command:

```sh
mkdir -p /workspace/.runtime/godot/{data,config,cache}
export XDG_DATA_HOME=/workspace/.runtime/godot/data
export XDG_CONFIG_HOME=/workspace/.runtime/godot/config
export XDG_CACHE_HOME=/workspace/.runtime/godot/cache
```

No external services, credentials, or third-party assets are required. The `.godot` cache is generated and ignored. Windows export templates and target-device validation are separate future steps.

## Browser build

The Web export uses single-threaded WebAssembly and the Compatibility renderer. Install the matching **Godot 4.6.3 export templates** through Godot's template manager on your own machine. In this cloud environment the verified official web templates are installed under the configured XDG data directory.

```sh
mkdir -p builds/web
godot --headless --path . --export-release Web builds/web/index.html
python -m http.server 8060 --directory builds/web
```

Serve over HTTP for local testing or HTTPS for public hosting; opening `index.html` directly from disk does not work. Upload every file in `builds/web` together to a static host (or upload the ZIP as an HTML game on itch.io). This single-threaded build does not require COOP/COEP headers. Use a desktop browser with WebGL 2 and WebAssembly. Mobile touch controls are not implemented.

The browser prototype is live at https://thaney044-lab.github.io/Rustbelt-Run/. It is not yet the complete campaign.

## Publish a browser link with GitHub Pages

The repository includes `.github/workflows/deploy-web.yml`. It verifies official Godot downloads, runs the physics smoke tests, exports the web game, and deploys it through GitHub Pages.

1. In the GitHub repository, open **Settings → Pages** and choose **GitHub Actions** as the source (subject to your repository/plan supporting Pages).
2. Push these project files to `main`, or run **Deploy browser game** from the Actions tab once the workflow is committed.
3. After deployment succeeds, open the URL reported by the deployment job. Players only need that browser link; they do not download or install the game.

This workflow is active and publishes tested updates to the existing Pages URL.

Static scenery is cached in independently culled sections, and small decorative shapes share mesh batches. The web game renders canvas items at the window resolution so painted sprites stay clear on larger windows. This reduces per-frame work while retaining the painted assets and animated background layers. See [performance measurements and limits](docs/PERFORMANCE.md).

Artwork notes and provenance: [assets/art/README.md](assets/art/README.md).

## Piston passage and loft secret

Continue right after lowering the crane. A checkpoint before the piston passage restores you to safety and restarts its timing after a hit. Amber lights with an exclamation mark warn before descent. Wait for a head to retract, then cross beneath it. The maintenance loft above the checkpoint contains an optional machine part, retained across retries during the current play session (not saved after a page reload). Reach the freight car and PATCH landmark, then continue to the canal. R returns to the current checkpoint. The train here is a stationary world illustration; there is no moving background train.

Additional validation: `godot --headless --path . --script tests/passage_smoke.gd`.

The route now continues beyond the freight yard into a flooded service canal with a checkpoint, moving maintenance lift and foundry gate. Use the FULLSCREEN button for a larger browser view. The wider camera framing reveals more of the next landing; movement and player collision dimensions are unchanged. Additional test: `godot --headless --path . --script tests/canal_smoke.gd`.

## Patrols, health and scrap

Four patrol robots guard safe-ground routes. J swings the wrench, K throws toward a highlighted robot in front of you, and landing on a bot's flat top disables it with a bounce. Side contact costs one of three health points and knocks you clear; temporary protection prevents repeated hits. Losing all health returns you to the current checkpoint. Checkpoints restore health. Patrols and puzzle objects reset after a retry; collected scrap remains collected for the current play session. The 45 optional scrap pieces suggest jump paths and reward detours; none are required to finish.

When no bot is targeted in the repair yard, K continues to operate the existing switch puzzle. There is only one thrown wrench at a time. The HUD shows health and scrap totals. No new input bindings are required.

The background transitions from the rail depot to a separate canal/foundry painting near the final piston passage. Trestles support the larger decks visually, and the canal reflection uses the foundry scene. These supports remain decorative, with all original landing/collision dimensions intact.

The fox artwork is now about 23% larger, anchored to the same foot position. The painted backdrop is augmented by independent cloud drift, rising steam, and animated distant water. Player collision dimensions and jump tuning are unchanged.

The decorative low-opacity background train has been removed. Large static decks use a bespoke painted stone material and arched viaduct supports; catwalks use textured iron, timber treads and under-brackets. The foundry service run has a proximity-operated E control, vertical hoist, upper catwalks, moving gantry, two checkpoints and a workshop landing. The route spans 8,860 world units, with optional upper paths in Cinder Yard and the foundry. See [the level design notes](docs/FIRST_SHIFT_LEVEL.md).

## Wider, harder layout

The entrance now has 155–160-unit ground gaps, smaller banks and narrower rooftop landings. A low shelf has been moved away from the takeoff edge so full jumps remain possible. Canal and foundry shuttles have smaller decks and faster, predictable cycles. The camera shows a wider field.

Before the workshop, a new 1,200-unit transfer span combines raised landings, a moving shuttle, two timed steam vents and a safe island checkpoint. Amber **!** lamps warn for 0.8 seconds before each 1.1-second burst; wait for the plume to clear before committing. Steam contact returns you to your current checkpoint and resets the cycle. The final checkpoint is on the island at x=7940. The relocated workshop remains the finish. Seven more scrap pieces mark the extended route, bringing the total to 45.

Additional physics validation: `godot --headless --path . --script tests/transfer_smoke.gd` covers the widened entrance jumps, all new transfer jumps, shuttle riding, the new checkpoint and warning/live steam behavior.
