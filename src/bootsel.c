#include "mrubyc.h"
#include "pico/bootrom.h"

static void
c_bootsel_pressed_q(mrbc_vm *vm, mrbc_value v[], int argc)
{
  if (get_bootsel_button()) {
    SET_TRUE_RETURN();
  } else {
    SET_FALSE_RETURN();
  }
}

void
mrbc_bootsel_init(mrbc_vm *vm)
{
  mrbc_class *module_Bootsel = mrbc_define_module(vm, "Bootsel");

  mrbc_define_method(vm, module_Bootsel, "pressed?", c_bootsel_pressed_q);
}
