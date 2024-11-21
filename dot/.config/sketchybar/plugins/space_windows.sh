#!/bin/bash

# TODO: Move this to the aerospace.sh plugin maybe?

echo $FOCUSED_WORKSPACE >> ~/.dotfiles/dot/.config/sketchybar/plugins/FOCUSED_WORKSPACE.txt
echo $NAME >> ~/.dotfiles/dot/.config/sketchybar/plugins/NAME.txt

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  apps="$(aerospace list-windows --json --workspace $FOCUSED_WORKSPACE | jq -r '.[] | ."app-name"')"
  echo $apps >> ~/.dotfiles/dot/.config/sketchybar/plugins/APPS.txt

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip="$FOCUSED_WORKSPACE —"
  fi

  sketchybar --set space.$FOCUSED_WORKSPACE label="$FOCUSED_WORKSPACE $icon_strip"
fi
