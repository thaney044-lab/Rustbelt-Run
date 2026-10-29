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

Movement tuning, existing platform collision dimensions, puzzle state and hazard timing are preserved. Later level passes add optional routes. Art tests verify transparency, atlas layout and pose selection; gameplay tests verify the mechanics. Browser screenshots assess readability and shaders.

## Foundry and patrol update

`painted/foundry_panorama.png` is a new 2075×758 district painting, blended into the backdrop as the fox approaches the canal. `painted/patrol_bot.png` is a transparent 1346×1168 single robot sprite; its padded source region is rendered at one shared aspect ratio, mirrored with patrol direction. Both were generated with host-native ImageGen. Full prompts and source references are in `painted/foundry-and-bot-provenance.json`, with hashes/dimensions in `painted/validation.json`.

Trestle supports beneath large decks give the gameplay layer a structural connection to the valley. They are decorative and do not change collision or moving-platform paths.

## Living background and larger fox

The paintings remain the scenic base, with independently animated clouds, expanding/dissolving steam, and rotating flywheels on a faster parallax plane in `scripts/living_background.gd`. `shaders/living_panorama.gdshader` adds restrained distant-water ripples. These are decorative layers below the game world and HUD. The fox uses one shared 0.265 source-pixel scale (about 23% larger than 0.215) with its existing boot anchor and collision dimensions.

The decorative low-opacity background train has been removed. Large static decks now use staggered beveled masonry, iron coping, moss and stone piers; thin catwalks have plank joints. The foundry service run adds a proximity-operated E control, a vertical hoist, upper catwalks, a moving gantry, two checkpoints and a final landing. These extend the route from about 5,480 to 7,660 world units. New tests: `godot --headless --path . --script tests/foundry_smoke.gd`.

## First Shift level art

`painted/viaduct_stone.png` is an original 1536×1024 host-native ImageGen masonry material, copied without pixel edits. Its full prompt and source are recorded in `painted/viaduct-provenance.json`; dimensions and SHA-256 are in `painted/validation.json`. It is rendered at four source pixels per world unit with mipmaps, subdued tint and repeated UVs. The image is a bespoke material source; visually perfect edge seamlessness is not assumed.

`platform_art.gd` builds textured arch rings, spandrels and piers below the landing edge, and textured catwalk webs with timber treads and under-brackets. `level_dressing.gd` adds world-space cables, hanging supports, railings, a station clock, water tower, copper pipe runs, a canal suspension bridge, lanterns, ferns and the final workshop. This layer renders behind the fox and colliders. The stone and steel materials are applied to in-engine architecture. The final workshop uses a separate painted building sprite. Static sections and small details now use retained mesh batches; the subtle fern sway and workshop light pulse are cached to avoid rebuilding the architecture every frame. No external asset service or third-party stock package was used.

`painted/workshop.png` is an original transparent 1536×1024 ImageGen building, preserved unchanged and rendered at one shared 0.22 scale. Its painted doorway sits on the final landing's foot baseline. Full prompt/source provenance is in `painted/workshop-provenance.json`, and hash, dimensions and alpha checks are in `painted/validation.json`. A small in-engine nameplate fits the empty signboard; a subtle animated light pool complements the painted windows. The final landing is widened from 250 to 330 units to support the building; the last gap remains a jump. The fox renders in front of all world machinery.
