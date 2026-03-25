#include "pico/bootrom.h"

#include "../../include/bootsel.h"

bool
Bootsel_pressed(void)
{
  return get_bootsel_button() != 0;
}
