#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# sync-upstream.sh — Pull latest from QuantumNous/new-api
#                    and keep your private render config safe
# ═══════════════════════════════════════════════════════════════
set -e

UPSTREAM="upstream/main"
ORIGIN="origin/main"
PRIVATE_BRANCH="render-private"
PRIVATE_FILES=".env.render render.yaml"

echo "=== new-api Sync Workflow ==="
echo ""

# Step 1: Make sure private files exist on render-private branch
echo "[1/4] Ensuring private files are on $PRIVATE_BRANCH..."
git checkout "$PRIVATE_BRANCH"
for f in $PRIVATE_FILES; do
    if [ -f "$f" ]; then
        git add "$f" 2>/dev/null || true
    fi
done
echo "  Private files present on $PRIVATE_BRANCH ✓"
echo ""

# Step 2: Switch to main and pull upstream
echo "[2/4] Switching to main and pulling from upstream..."
git checkout main
git fetch upstream
UPSTREAM_LATEST=$(git rev-parse upstream/main)
ORIGIN_CURRENT=$(git rev-parse origin/main 2>/dev/null || echo "")

if [ "$UPSTREAM_LATEST" = "$ORIGIN_CURRENT" ]; then
    echo "  Upstream is already in sync — nothing to pull."
else
    git pull --ff-only upstream main
    echo "  Pulled upstream changes ✓"
fi
echo ""

# Step 3: Push clean main to origin (no private stuff)
echo "[3/4] Pushing main to origin/Bzcasper fork..."
git push origin main
echo "  Pushed to origin ✓"
echo ""

# Step 4: Rebase render-private on latest main
echo "[4/4] Rebasing $PRIVATE_BRANCH on latest main..."
git checkout "$PRIVATE_BRANCH"
git rebase main
for f in $PRIVATE_FILES; do
    if [ -f "$f" ]; then
        git add "$f" 2>/dev/null || true
    fi
done
echo ""
echo "=== Sync complete ==="
echo ""
echo "  main:           synced with upstream/QuantumNous ✓  (pushed to origin)"
echo "  render-private: rebased on latest main ✓  (LOCAL ONLY — never pushed)"
echo ""
echo "To work on private deploy config:"
echo "  git checkout render-private"
echo "  # edit .env.render and render.yaml"
echo "  # test locally..."
echo ""
echo "NEVER run: git push origin render-private  ← it contains your secrets!"
