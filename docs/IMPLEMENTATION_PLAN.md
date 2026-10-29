# Rustbelt Run implementation plan

Based on Game Design Outline v0.1. Copper, PATCH, district names, and campaign scope remain provisional. The document is design input, not evidence of completed gameplay or authorization for external services or purchases.

## First deliverable

A complete single-player First Shift demo, initially targeting desktop web browsers, with Windows as a later packaging target, using keyboard and controller input. Build and evaluate a small graybox before committing to art, a campaign, or a schedule. Godot 4.6.3 is the initial implementation default; the owner may still choose another engine.

## Milestones and acceptance gates

1. **Movement laboratory.** Running, variable-height jumps, coyote time, jump buffering, solid collision, follow camera, checkpoint and fall recovery. Include low ceilings, edge jumps, and a moving platform. Gate: short and full jumps differ reliably, moving platforms carry the player without slipping, and retries return to a safe state. Human playtesting determines whether movement feels good.
2. **Repair changes the route.** Wrench swing and returning throw with directional target highlighting; nearby battery, socket, and crane with fixed stops. Add local reset and checkpoint snapshots. Gate: the crane creates a traversable bridge; dropped batteries and any mechanism state remain recoverable; checkpoint restoration resets all relevant objects together.
3. **First Shift graybox.** Connect workshop exit, loading yard, gate switch, crane bridge, optional workshop part, piston passage, and staged train departure. Add one patrol bot, three health points and temporary damage immunity. Gate: an unfamiliar player reaches the end without coaching, understands the crane, and can recover from every failure. Record observations before adding scope.
4. **Visual and audio pass.** Establish original hero silhouette, a small industrial tile set, target symbols, readable hazards, background layers and restrained sound/music. Gate: decoration never obscures landings or mechanisms; indicators work without color alone. Asset licensing must be recorded before admitting third-party assets.
5. **Complete demo.** Title/pause/end screens, remappable keyboard and controller controls, volume and shake settings, optional extra health, local stage/tool/part/settings saves, restart and packaged Windows build. Gate: save/load round trip, clean launch, full-level playthrough, controller-only navigation and failure recovery on the target platform.

## Implementation approach

- Keep movement, interactions, mechanism state, and checkpoint restoration independent. Use authored fixed stops and deterministic piston cycles rather than unconstrained physics.
- Introduce one mechanic safely, combine it, then test it in motion. Keep main puzzles readable on one screen.
- Use placeholder geometric art until movement and puzzle gates pass. Do not treat graybox automation as a replacement for a playtest.
- Validate Linux headless startup and representative physics behavior here. Windows exports and controller feel require separate target-platform validation.
- Defer magnets, tether, campaign map, shops, multiple districts, cooperative play, online accounts, cloud saves and complex crafting until the single-level demo is stable.

## Open decisions

Confirm engine; choose visual direction after graybox playtesting; tune speeds and final bindings through observation. Windows is a proposed release target, not a verified build. No schedule, commissioned art, release date, or campaign commitment is implied.
