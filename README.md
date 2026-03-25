# picoruby-bootsel

A PicoRuby gem to read the BOOTSEL button state on Raspberry Pi Pico (RP2040/RP2350).

## Usage

```ruby
require "bootsel"

if Bootsel.pressed?
  puts "BOOTSEL button is pressed!"
end
```

## API

### `Bootsel.pressed?`

Returns `true` if the BOOTSEL button is currently pressed, `false` otherwise.

## How it works

The BOOTSEL button is connected to the QSPI chip select pin, which is shared with the flash memory. Reading it requires temporarily disabling flash access and interrupts. This gem wraps that low-level operation into a simple Ruby method.

## Installation

Add the gem to your PicoRuby build configuration:

```ruby
conf.gem github: 'pocke/picoruby-bootsel'
```

## Example

See the [example](example/) directory for a complete project that builds an R2P2 firmware with this gem included.

## License

MIT
