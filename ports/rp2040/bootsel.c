#include "pico/bootrom.h"

#include "../../include/bootsel.h"

bool
Bootsel_pressed(void)
{
  // get_bootsel_button() returns the raw QSPI CS pin state:
  // HIGH (true) when not pressed, LOW (false) when pressed.
  return !get_bootsel_button();
}
