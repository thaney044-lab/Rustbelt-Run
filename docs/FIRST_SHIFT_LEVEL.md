# First Shift

A continuous 8,860-unit route through an overgrown railway district. Preserve the established 290-unit run speed, variable jump and 26×40 player collision. Decorative architecture never adds collision or masks the landing rim.

| Area | Main action | Identity and pacing |
| --- | --- | --- |
| Cinder Yard, 0–1850 | Learn jumps, patrol combat and a moving platform | Station clock, stone viaducts, hanging rooftop catwalks. Optional upper line reconnects to the workshop checkpoint. |
| Repair works, 1850–2980 | Break the crate, throw at the gate switch, insert battery, lower bridge | Crane machinery and copper pipes. A deliberate puzzle break between traversal sections. |
| Piston hall, 2980–4280 | Read warnings and cross between piston cycles | Repeated press bays, visible warning symbols, maintenance loft and rare part. |
| Flooded viaduct, 4280–5350 | Ride the moving service platform | Water reflections, suspension supports and lanterns. Safe banks before the foundry. |
| Foundry, 5350–8860 | Start the hoist, climb, cross the moving gantry, reach PATCH | Hoist frame, an optional upper salvage climb, faster gantry, far-bank checkpoint, transfer span with timed vents, service-island checkpoint and a warmly lit workshop. |

Two new optional rare parts sit above the main route at (850,270) and (6290,220). Each restores health and collects once. Along with the original loft part, these give three discoveries. Rare parts and the 45 scrap pieces persist across checkpoint retries, and reset on a fresh run or page reload. No collectible gates the main route.

Chapter and checkpoint notices fade after 3.2 seconds. The bottom HUD shows area, discoveries, elapsed time and route position. Esc freezes the simulation and clock, and opens controls/resume/restart. The workshop opens a results screen showing elapsed time, scrap, discoveries and checkpoint retries; Enter or its button starts a fresh run. R or its button returns to the last checkpoint. Retry is processed once by the player, including while results disable movement.

`tests/level_smoke.gd` exercises actual jump inputs for both new branches, collection across retries, pause/resume timing, completion and returning from results. Existing suites cover movement, machinery, hazards, canal, art and combat. Browser review uses a separate temporary QA copy to visit representative districts; the published build starts at the original entrance and contains no QA spawn controls.

This remains a desktop-browser demo. Persistent saves, mobile touch controls, production audio, controller menu navigation and a full campaign are separate work.

The difficulty pass narrows the opening banks and optional rooftops, expands the opening ground gaps to 155–160 units, and moves a low shelf clear of the takeoff. Player speed and jump tuning stay unchanged. Moving platforms expose per-instance speed and travel settings. The canal shuttle uses pace 1.45, the foundry gantry 1.65, and the new transfer shuttle 1.6 with 70-unit travel.

The transfer span occupies x=7260–8515, ending at the relocated workshop bank. Vent landings are centered at (7460,475) and (8230,490); each vent has a 4.6-second cycle, a 0.8-second amber ! warning and a 1.1-second damaging plume. The service island spans x=7850–8030 and saves at (7940,490). Hazard contact resets the cycle and returns to the current checkpoint. This separates the two precision sequences with a safe rest.

`tests/transfer_smoke.gd` uses real jump inputs across the wider entrance, vent landings, moving shuttle, service island and final upper ledge; it also verifies warning safety, live contact, cycle reset and checkpoint persistence. Browser captures inspect the wider camera and vent cues. The published project contains no QA spawn controls.
