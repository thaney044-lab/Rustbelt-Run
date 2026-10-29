#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p builds/web
godot --headless --path . --export-release Web builds/web/index.html
# Disable Jekyll processing when hosted on GitHub Pages.
touch builds/web/.nojekyll
