#!/bin/bash
set -eu

EXAMPLE_DIR="$(cd "$(dirname "$0")" && pwd)"
R2P2_DIR="$EXAMPLE_DIR/R2P2"
BUILD_CONFIG="$EXAMPLE_DIR/build_config/r2p2-bootsel-pico.rb"
BUILD_CONFIG_NAME="r2p2-bootsel-pico"
BUILD_DIR="build/bootsel/pico/prod"

PICO_SDK_TAG="2.2.0"
PICO_EXTRAS_TAG="sdk-$PICO_SDK_TAG"

clone_r2p2() {
  if [ ! -d "$R2P2_DIR" ]; then
    echo "==> Cloning R2P2..."
    git clone https://github.com/picoruby/R2P2.git "$R2P2_DIR"
  fi

  cd "$R2P2_DIR"
  git submodule update --init

  echo "==> Initializing picoruby submodules..."
  cd lib/picoruby
  git submodule update --init --recursive
  cd "$R2P2_DIR"

  echo "==> Checking out pico-sdk $PICO_SDK_TAG..."
  cd lib/pico-sdk
  git fetch origin --tags
  git checkout "$PICO_SDK_TAG"
  git submodule update --init --recursive
  cd "$R2P2_DIR"

  echo "==> Checking out pico-extras $PICO_EXTRAS_TAG..."
  cd lib/pico-extras
  git fetch origin --tags
  git checkout "$PICO_EXTRAS_TAG"
  git submodule update --init --recursive
  cd "$R2P2_DIR"

  cd lib/picoruby
  bundle install
  cd "$R2P2_DIR"
}

build_libmruby() {
  echo "==> Building libmruby..."
  cd "$R2P2_DIR/lib/picoruby"
  MRUBY_CONFIG="$BUILD_CONFIG" rake
  cd "$R2P2_DIR"
}

build_firmware() {
  echo "==> Building firmware..."
  cd "$R2P2_DIR"

  export PICO_SDK_PATH="$R2P2_DIR/lib/pico-sdk"
  export PICO_EXTRAS_PATH="$R2P2_DIR/lib/pico-extras"

  MRUBY_BUILD_PATH="$R2P2_DIR/lib/picoruby/build/$BUILD_CONFIG_NAME"

  mkdir -p "$BUILD_DIR"
  cmake -B "$BUILD_DIR" \
    -D EXTRA_LIBRARY_PATH="$MRUBY_BUILD_PATH/lib" \
    -D EXTRA_INCLUDE_DIR="$MRUBY_BUILD_PATH/include" \
    -D PICO_CYW43_SUPPORTED=1 \
    -D MRUBY_CONFIG="$BUILD_CONFIG" \
    -D BUILD_DIR="$BUILD_DIR" \
    -D PICORB_VM_MRUBYC=1 \
    -D R2P2_NAME=R2P2-BOOTSEL-PICO \
    -D PICO_PLATFORM=rp2040 \
    -D PICO_BOARD=pico \
    -D CMAKE_BUILD_TYPE=Release \
    -D NDEBUG=1 \
    -D PICORUBY_MSC_FLASH=1

  cmake --build "$BUILD_DIR"
}

link_gem() {
  local GEM_DIR="$R2P2_DIR/lib/picoruby/mrbgems/picoruby-bootsel"
  if [ ! -e "$GEM_DIR" ]; then
    echo "==> Linking picoruby-bootsel into mrbgems..."
    ln -s "$EXAMPLE_DIR/.." "$GEM_DIR"
  fi
}

install_example() {
  local SHELL_EXE_DIR="$R2P2_DIR/lib/picoruby/mrbgems/picoruby-shell/shell_executables"
  local PATH_TXT="$SHELL_EXE_DIR/_path.txt"
  local EXE_NAME="bootsel_led"

  if [ ! -f "$SHELL_EXE_DIR/$EXE_NAME.rb" ]; then
    echo "==> Installing $EXE_NAME into shell_executables..."
    cp "$EXAMPLE_DIR/app.rb" "$SHELL_EXE_DIR/$EXE_NAME.rb"
    if ! grep -q "$EXE_NAME" "$PATH_TXT"; then
      echo "/bin/$EXE_NAME" >> "$PATH_TXT"
    fi
  fi
}

clone_r2p2
link_gem
install_example
build_libmruby
build_firmware

echo ""
echo "==> Build complete!"
echo "    UF2 file: $R2P2_DIR/$BUILD_DIR/"
echo ""
echo "    To flash: hold BOOTSEL button, connect Pico via USB, then copy the .uf2 file to the mounted drive."
