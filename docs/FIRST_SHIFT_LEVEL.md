# First Shift

A continuous 7,660-unit route through an overgrown railway district. Preserve the established 290-unit run speed, variable jump and 26×40 player collision. Decorative architecture never adds collision or masks the landing rim.

| Area | Main action | Identity and pacing |
| --- | --- | --- |
| Cinder Yard, 0–1850 | Learn jumps, patrol combat and a moving platform | Station clock, stone viaducts, hanging rooftop catwalks. Optional upper line reconnects to the workshop checkpoint. |
| Repair works, 1850–2980 | Break the crate, throw at the gate switch, insert battery, lower bridge | Crane machinery and copper pipes. A deliberate puzzle break between traversal sections. |
| Piston hall, 2980–4280 | Read warnings and cross between piston cycles | Repeated press bays, visible warning symbols, maintenance loft and rare part. |
| Flooded viaduct, 4280–5350 | Ride the moving service platform | Water reflections, suspension supports and lanterns. Safe banks before the foundry. |
| Foundry, 5350–7660 | Start the hoist, climb, cross the moving gantry, reach PATCH | Hoist frame, an optional upper salvage climb, far-bank checkpoint and a warmly lit workshop. |

Two new optional rare parts sit above the main route at (850,270) and (6290,220). Each restores health and collects once. Along with the original loft part, these give three discoveries. Rare parts and the 38 scrap pieces persist across checkpoint retries, and reset on a fresh run or page reload. No collectible gates the main route.

Chapter and checkpoint notices fade after 3.2 seconds. The bottom HUD shows area, discoveries, elapsed time and route position. Esc freezes the simulation and clock, and opens controls/resume/restart. The workshop opens a results screen showing elapsed time, scrap, discoveries and checkpoint retries; Enter or its button starts a fresh run. R or its button returns to the last checkpoint. Retry is processed once by the player, including while results disable movement.

`tests/level_smoke.gd` exercises actual jump inputs for both new branches, collection across retries, pause/resume timing, completion and returning from results. Existing suites cover movement, machinery, hazards, canal, art and combat. Browser review uses a separate temporary QA copy to visit representative districts; the published build starts at the original entrance and contains no QA spawn controls.

This remains a desktop-browser demo. Persistent saves, mobile touch controls, production audio, controller menu navigation and a full campaign are separate work.
