#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHANGELOG_FILE="$ROOT_DIR/CHANGELOG.md"
REPO_URL="https://github.com/badugisoft/antigravity-quota"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <version-or-tag> [--legacy-adhoc]" >&2
    exit 1
fi

RAW_VERSION="$1"
LEGACY_ADHOC=0
if [ "${2:-}" = "--legacy-adhoc" ]; then
    LEGACY_ADHOC=1
fi

VERSION="${RAW_VERSION#v}"
TAG="v${VERSION}"

if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "Error: $CHANGELOG_FILE not found!" >&2
    exit 1
fi

# Extract section for [VERSION] from CHANGELOG.md
SECTION="$(awk -v ver="$VERSION" '
    $0 ~ "^## \\[" ver "\\]" { found=1; next }
    found && ($0 ~ "^## \\[" || $0 ~ "^\\[[^]]+\\]: ") { exit }
    found { print }
' "$CHANGELOG_FILE" | sed -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}')"

if [ -z "$SECTION" ]; then
    SECTION="See the commit history for changes in ${TAG}."
fi

# Find previous tag in descending semantic version order
PREV_TAG="$(git -C "$ROOT_DIR" tag --sort=-v:refname | awk -v cur="$TAG" '
    found { print; exit }
    $0 == cur { found=1 }
')"

cat <<EOF
## Antigravity Quota ${TAG}

### What's Changed
${SECTION}
EOF

if [ -n "$PREV_TAG" ]; then
    echo ""
    echo "**Full Changelog**: ${REPO_URL}/compare/${PREV_TAG}...${TAG}"
fi

cat <<EOF

### Download & Installation

1. Download **\`Antigravity-Quota-${VERSION}.dmg\`** (or the \`.zip\` archive) below.
2. Open the disk image and drag **Antigravity Quota.app** into your **Applications** folder.
EOF

if [ "$LEGACY_ADHOC" -eq 1 ]; then
    cat <<EOF
3. **First-Time Launch (Gatekeeper Notice)**:
   - This historical release was ad-hoc signed. Right-click (or Control-click) \`Antigravity Quota.app\` in \`/Applications\` and select **Open**, or run: \`xattr -cr "/Applications/Antigravity Quota.app"\`
EOF
else
    cat <<EOF
3. Launch **Antigravity Quota** from Applications (signed with Developer ID and notarized by Apple).
EOF
fi
