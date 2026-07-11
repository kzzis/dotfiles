#!/bin/zsh
# Switch Karabiner-Elements profile automatically depending on whether HHKB is connected.

KARABINER_CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
STATE_FILE="$HOME/.cache/karabiner-hhkb-switch/state"

if ioreg -c IOHIDDevice -r -l 2>/dev/null | grep -q '"Product" = "HHKB-Hybrid_1"'; then
  TARGET_PROFILE="HHKB"
else
  TARGET_PROFILE="Default profile"
fi

LAST_PROFILE=""
[ -f "$STATE_FILE" ] && LAST_PROFILE=$(cat "$STATE_FILE")

if [ "$TARGET_PROFILE" != "$LAST_PROFILE" ]; then
  "$KARABINER_CLI" --select-profile "$TARGET_PROFILE"
  echo "$TARGET_PROFILE" > "$STATE_FILE"
fi
