# Browser rendering budget

The graphics additions exposed two costs: rebuilding a single level-wide decoration canvas every frame, and issuing separate polygon/antialiased-line operations for individual leaves, rivets, rails and arch segments. High-resolution windows also rendered the entire canvas at the window's native resolution.

The renderer now retains static architecture in nine independently culled sections. Small colored shapes and textured stone arches share retained `ArrayMesh` batches built by `scripts/draw_batch.gd`. Line edges use a vertex-alpha fringe within the same mesh. The painted textures, collisions, jump settings, timing and level positions remain intact. Ferns and the workshop light pool are cached; clouds, steam, birds, flywheels, water and gameplay hazards still animate. Fully invisible panorama layers are skipped.

The project uses `viewport` stretch mode: the game renders at its 1152×648 design resolution, then scales to the browser window. High-DPI/fullscreen windows therefore do not multiply the cost of every world layer. Large displays can look softer than native-resolution rendering. Input and HUD coordinates scale together.

## Measurements

The same entrance scene was sampled after loading/warmup, over six seconds, in headless Chromium with software WebGL, at a 1152×648 browser viewport. Both builds had the same temporary telemetry probe; the published game has no probe. The baseline was commit `ae1fe3d`.

| Metric | Baseline repeat | Optimized |
| --- | ---: | ---: |
| Median engine draw calls/frame | 2,335 | 333 |
| Median browser frame interval | 199.95 ms | 66.70 ms |
| Mean browser frame interval | 198.88 ms | 78.07 ms |
| 95th percentile frame interval | 249.90 ms | 116.70 ms |

Draw calls fell about 86%. These software-rendering timings establish a comparative improvement in this environment; they are not a Windows hardware FPS guarantee. A first baseline sample also measured roughly 200 ms median, consistent with the repeat. Intermediate candidates were measured before the final batching changes.

The current workspace retains sample JSON and screenshots under `/workspace/artifacts/perf-*.json` and `perf-*.png`. Browser checks exercise running, jumping, retry, pause, high-DPI resize and the fullscreen button. Static masonry ROI comparison differed by about 0.12/255 mean channel value. All 78 gameplay/art checks pass.
