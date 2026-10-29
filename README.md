# Rustbelt Run

A 2D puzzle platformer following a red panda mechanic through an overgrown industrial valley. Repair machinery, discover secrets, and chase a runaway robot.

## Current prototype

Godot **4.6.3**, GDScript, Compatibility renderer. Open `project.godot` and press **F6** on `scenes/movement_lab.tscn`, or press **F5** to run the project. From a terminal in this directory: `godot --path .`.

The movement lab uses an original vector-art pass (red panda mechanic, layered valley and factory scenery, overgrown steel platforms, and illustrated machinery) and includes acceleration, variable jump height, coyote time, jump buffering, solid platforms, a moving platform, a follow camera, a checkpoint, and fall/manual recovery. This is the movement milestone foundation, not the complete First Shift level.

- Move: A/D, arrows, controller left stick or D-pad.
- Jump: Space or controller A; release early for a short hop.
- Retry: R. Reach the flag to set the checkpoint.

The next section is a repair yard: J swings the wrench, K throws it toward a highlighted switch, E carries/inserts the battery or uses the crane control, and T resets the puzzle at its checkpoint. Controller bindings: X swing, B throw, Y use, Back reset. Lower the crane bridge and cross to the exit. Falls restore the whole puzzle to a recoverable state. Enemies, final production art/audio, menus, remapping, persistence, and Windows exports are planned, not implemented. Controller bindings exist but have not been tested with physical hardware. Movement feel still needs a human playtest.

See [the implementation plan](docs/IMPLEMENTATION_PLAN.md) for milestones and acceptance criteria based on the supplied v0.1 outline. Godot is the initial default; the outline did not specify an engine.

## Validation

```sh
godot --headless --editor --import --path . --quit
godot --headless --path . --quit-after 120
godot --headless --path . --script tests/movement_smoke.gd
godot --headless --path . --script tests/repair_smoke.gd
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

No public deployment has been made. The browser build is the same movement lab, not the full game.

## Publish a browser link with GitHub Pages

The repository includes `.github/workflows/deploy-web.yml`. It verifies official Godot downloads, runs the physics smoke tests, exports the web game, and deploys it through GitHub Pages.

1. In the GitHub repository, open **Settings → Pages** and choose **GitHub Actions** as the source (subject to your repository/plan supporting Pages).
2. Push these project files to `main`, or run **Deploy browser game** from the Actions tab once the workflow is committed.
3. After deployment succeeds, open the URL reported by the deployment job. Players only need that browser link; they do not download or install the game.

These hosting steps have been prepared but have not been executed from this environment. The Pages URL is not live until the workflow successfully deploys.

Artwork notes and provenance: [assets/art/README.md](assets/art/README.md).
