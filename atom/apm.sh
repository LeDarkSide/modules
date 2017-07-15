#!/bin/bash
set +m

if [ ! -f ~/.local/bin/atom ]; then
  echo "atom AppImage is not installed"
  exit 1
fi

MOUNT_PATH_FILE="$(mktemp apm.XXXXXXXXXX)"
# echo "MOUNT_PATH_FILE=$MOUNT_PATH_FILE"

stdbuf -o 0 ~/.local/bin/atom --appimage-mount > "$MOUNT_PATH_FILE" &
MOUNT_PID=$!
while [ -z "$MOUNT_PATH" ]; do
  MOUNT_PATH="$(cat "$MOUNT_PATH_FILE")"
done
# echo "MOUNT_PATH=$MOUNT_PATH"

# echo "run" "$MOUNT_PATH"/usr/bin/resources/app/apm/bin/apm "$@"
"$MOUNT_PATH"/usr/bin/resources/app/apm/bin/apm "$@"

rm "$MOUNT_PATH_FILE"
kill $MOUNT_PID
