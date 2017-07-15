#!/bin/bash

INSTALLED_FILES=(~/.local/bin/atom ~/.local/bin/apm ~/.local/share/applications/atom.desktop ~/.local/share/icons/atom.png)

function _atom_install_extra {
  echoerr "mount atom AppImage"
  MOUNT_PATH_FILE="$(mktemp atom.XXXXXXXXXX)"
  stdbuf -o 0 ~/.local/bin/atom --appimage-mount > "$MOUNT_PATH_FILE" &
  MOUNT_PID=$!
  while [ -z "$MOUNT_PATH" ]; do
    MOUNT_PATH="$(cat "$MOUNT_PATH_FILE")"
  done

  echoerr "install atom.desktop"
  cp "$MOUNT_PATH/atom.desktop" ~/.local/share/applications/

  echoerr "install atom.png"
  cp "$MOUNT_PATH/atom.png" ~/.local/share/icons/

  echoerr "unmount atom AppImage"
  rm "$MOUNT_PATH_FILE"
  kill "$MOUNT_PID"

  echoerr "install apm"
  cp apm.sh ~/.local/bin/apm
  chmod u+x ~/.local/bin/apm
}

function _atom_uninstall_extra {
  echoerr "uninstall apm"
  rm -f ~/.local/bin/apm

  echoerr "uninstall atom.desktop"
  rm -f ~/.local/share/applications/atom.desktop

  echoerr "uninstall atom.png"
  rm -f ~/.local/share/icons/atom.png
}

function _last_version {
sleep 5
  LAST_VERSION="$(curl -sL https://api.bintray.com/packages/probono/AppImages/Atom | \
                  python3 -c "import sys, json; print(json.load(sys.stdin)['latest_version'])")"
}

function _set_installed_version {
  echo "$1" > "$MODULE_CONFIG_PATH/version"
}

function _install {
  _last_version

  echoerr "download atom"
  curl -L "https://dl.bintray.com/probono/AppImages/Atom-$LAST_VERSION-x86_64.AppImage" -o atom

  echoerr "install atom"
  chmod u+x ./atom
  mv ./atom ~/.local/bin/

  _atom_install_extra
  _set_installed_version "$LAST_VERSION"
}

function _uninstall {
  echoerr "uninstall atom"
  rm -f ~/.local/bin/atom

  _atom_uninstall_extra
}

function _update {
  appimageupdate ~/.local/bin/atom
  chmod u+x ~/.local/bin/atom
  _atom_uninstall_extra
  _atom_install_extra

  _last_version
  _set_installed_version "$LAST_VERSION"
}

function _installed_version {
  if [ -f "$MODULE_CONFIG_PATH/version" ]; then
    INSTALLED_VERSION="$(cat "$MODULE_CONFIG_PATH/version")"
  fi
}

function _is_installed {
  for file in "${INSTALLED_FILES[@]}"; do
    if [ -f "$file" ]; then
        EXIST="true"
    else
        EXIST="false"
    fi

    if [ -z "$IS_INSTALLED" ]; then
      IS_INSTALLED="$EXIST"
    else
      if [ "$IS_INSTALLED" != "$EXIST" ]; then
        IS_INSTALLED="partially"
        break;
      fi
    fi
  done
}
