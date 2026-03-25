#include <stdbool.h>

#include "../../include/bootsel.h"

/* Defined in bootsel_button.c (extracted from TinyUSB BSP) */
bool get_bootsel_button(void);

bool
Bootsel_pressed(void)
{
  // get_bootsel_button() returns the raw QSPI CS pin state:
  // HIGH (true) when not pressed, LOW (false) when pressed.
  return !get_bootsel_button();
}
