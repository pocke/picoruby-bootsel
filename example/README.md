# picoruby-bootsel Example

A sample program that lights the onboard LED while the BOOTSEL button is pressed.

## Prerequisites

- arm-none-eabi-gcc
- cmake (3.22+)
- Ruby (3.0+) + Bundler

## Build

```sh
./build.sh
```

This script automatically clones R2P2, sets up dependencies, and builds the firmware.
On success, the path to the `.uf2` file is printed.

## Flashing

1. Hold the BOOTSEL button on the Pico while connecting the USB cable
2. The Pico mounts as a mass storage device
3. Copy the `.uf2` file to the mounted drive

## Running

The `bootsel_led` command is embedded in the firmware at build time.
Connect via serial console and type `bootsel_led` in the R2P2 shell.

```sh
screen /dev/ttyACM0 115200
```

The LED lights up while the BOOTSEL button is pressed, and turns off when released.

### Auto-run at boot

Copy the contents of `app.rb` to `/etc/init.d/r2p2` on the USB mass storage drive.
The script will run automatically on boot (press `s` during startup to skip).
