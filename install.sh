#!/bin/bash

set -e

function update_natsumi() {
  # update the natsumi-browser submodule to the latest commit
  git submodule update --init --recursive
}

function get_profile_base_dir() {
  # on macos the profile base dir is ~/Library/Application Support/zen/Profiles
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "$HOME/Library/Application Support/zen/Profiles"
  else
    echo "$HOME/.zen/Profiles"
  fi
}

function ensure_profile_dir() {
  PROFILE="$1"
  # make sure the profile dir exists and is a directory 
  if [ ! -d "$PROFILE" ]; then
    echo "Profile directory does not exist" > `tty`
    exit 1
  fi
  if [ ! -d "$PROFILE" ]; then
    echo "Profile directory is not a directory" > `tty`
    exit 1
  fi
  # make sure the chrome directory exists in the profile else create it
  USER_CHROME_DIR="$PROFILE/chrome"
  if [ ! -d "$USER_CHROME_DIR" ]; then
    echo "Creating chrome directory in profile" > `tty`
    mkdir "$USER_CHROME_DIR"
  fi
}

function select_profile() {
  PROFILE_BASE_DIR=$(get_profile_base_dir)
  echo "Which profile do you want to install to?" > `tty`
  # Build arrays for the complete folder names and the display names (with the random id removed).
  FULL_PROFILES=()
  DISPLAY_PROFILES=()
  for dir in "$PROFILE_BASE_DIR"/*; do
    if [ -d "$dir" ]; then
        folder="$(basename "$dir")"
        display="${folder#*.}"
        FULL_PROFILES+=("$folder")
        DISPLAY_PROFILES+=("$display")
    fi
  done

  for i in "${!DISPLAY_PROFILES[@]}"; do
      echo "$i: ${DISPLAY_PROFILES[$i]}" > `tty`
  done
  read -p "Enter the number of the profile you want to install to: " PROFILE_INDEX
  # make sure the profile index is a number and within the range of the array
  if ! [[ "$PROFILE_INDEX" =~ ^[0-9]+$ ]]; then
    echo "Invalid profile index" > `tty`
    exit 1
  fi
  if [ "$PROFILE_INDEX" -ge "${#FULL_PROFILES[@]}" ]; then
    echo "Profile index out of range" > `tty`
    exit 1
  fi

  PROFILE="${FULL_PROFILES[$PROFILE_INDEX]}"
  echo "Installing to profile: $PROFILE" > `tty`
  PROFILE_DIR="$PROFILE_BASE_DIR/$PROFILE"

  # ensure the profile dir and exit on error
  ensure_profile_dir "$PROFILE_DIR"
  if [ $? -ne 0 ]; then
    exit 1
  fi

  echo "$PROFILE_DIR/chrome"
}

function copy_natsumi() {
  cp -rf "natsumi-browser/natsumi" "$1"
  cp -rf "natsumi-browser/natsumi-pages" "$1"
  cp -rf "natsumi-browser/bento.json" "$1"
}

function copy_css() {
  cp -rf *.css "$1"
}

if [ "$1" == "-u" ] || [ "$1" == "--update" ]; then
  update_natsumi
fi

PROFILE_DIR=$(select_profile)
copy_natsumi "$PROFILE_DIR"
copy_css "$PROFILE_DIR"

echo "Installation complete!"
