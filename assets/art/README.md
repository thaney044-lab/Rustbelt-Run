# Rustbelt Run artwork

The current game combines original ImageGen artwork with engine-drawn machinery and effects. The painted pass replaces the earlier flat vector scenery and procedural fox silhouette.

## Painted assets

- `painted/depot_panorama.png`: 1916×821 industrial valley, brick rail depot, distant mountains, foliage and canal. Rendered with slow parallax and a cool atmospheric treatment to separate it from the playable platforms.
- `painted/fox_animations.png`: 1536×1024 transparent, eight-pose character sheet. Idle, four running poses, rise, fall and wrench swing. Generated together and revised for spacing; `scripts/fox_visual.gd` isolates each pose and aligns it to a shared hip/boot anchor with one shared pixel scale. The artwork is not stretched separately per frame.
- `painted/weathered_steel.png`: 1254×1254 material source for platform panels, crane towers and piston housings. Gameplay rims, hazard stripes and target symbols are rendered separately for readability.
- `painted/provenance.json`, `painted/spacing-edit.txt`, and `painted/validation.json`: provider, complete prompts, source lineage, integrated asset hashes and layout measurements. Original generated sources remain under `/workspace/generated_images` in the current workspace.

All three sources were created using the host-native OpenAI ImageGen tool for this project. No paid external asset provider or third-party stock collection was used. The fox's reference was the existing in-game character screenshot. The original PNG artwork is retained without destructive pixel edits; frame isolation and alignment occur in-engine.

## Runtime presentation

- Textured metal, bevels, rivets, foliage and vines in `scripts/platform_art.gd`.
- Slow parallax in `scripts/depot_scenery.gd`, subtle sunlight/motes in `scripts/atmosphere.gd`, and a soft vignette below the HUD.
- Reflective rippling canal material in `shaders/canal_water.gdshader`.
- Small impact, repair and landing particle bursts in `scripts/visual_effects.gd`.
- Existing SVGs remain as earlier source artwork and the project emblem; the fox no longer uses the old vector head during gameplay.

Collision dimensions, movement tuning, puzzle state, hazard timing and level layout are preserved. Art tests verify transparency, atlas layout and pose selection; gameplay tests verify the existing mechanics. Browser screenshots are still needed to assess readability and shaders.

## Foundry and patrol update

`painted/foundry_panorama.png` is a new 2075×758 district painting, blended into the backdrop as the fox approaches the canal. `painted/patrol_bot.png` is a transparent 1346×1168 single robot sprite; its padded source region is rendered at one shared aspect ratio, mirrored with patrol direction. Both were generated with host-native ImageGen. Full prompts and source references are in `painted/foundry-and-bot-provenance.json`, with hashes/dimensions in `painted/validation.json`.

Trestle supports beneath large decks give the gameplay layer a structural connection to the valley. They are decorative and do not change collision or moving-platform paths.
