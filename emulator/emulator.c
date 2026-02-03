#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "emulator.h"

int main(int argc, char *argv[]) { return EXIT_SUCCESS; }

ProgramState *new_state(ProgramState *prev_state, instruction input) {
  op_code opcode = mask_and_shift(OP, input);
  uint16_t regd = mask_and_shift(REGd, input);
  uint16_t regs = mask_and_shift(REGs, input);
  arith_code arith = mask_and_shift(ARITH, input);
  uint16_t offimm = mask_and_shift(OFFIMM, input);
  ProgramState curr_state = *prev_state;
  switch (opcode) {
  case ARITH_OP:
    arith_wrapper(&curr_state, regd, regs, arith);
  case ARITH_XORI:
    arith_xori(&curr_state, regd, offimm);
  case ARITH_MUL2:
    arith_mul(&curr_state, regd);
  case ARITH_DIV2:
    arith_div(&curr_state, regd);
  case MEM_EXCH:
    mem_exchange(&curr_state, regd, regs);
  case BGEZ:
    branch_bgez(&curr_state, regd, offimm);
  case BLZ:
    branch_blz(&curr_state, regd, offimm);
  case BEVN:
    branch_bevn(&curr_state, regd, offimm);
  case BODD:
    branch_bodd(&curr_state, regd, offimm);
  case BRA:
    branch_bra(&curr_state, offimm);
  case RSWB:
    branch_rswb(&curr_state, regd);
  case SWB:
    branch_swb(&curr_state, regd);
  }

  return NULL;
}
ProgramState init_state() {
  ProgramState init;
  init.memory = malloc(sizeof(uint16_t) * 1 << 16);
  init.program_counter = 0;
  init.br_register = 0;
  init.standard_registers = malloc(sizeof(uint16_t) * 16);
  init.direction_bit = false;
  return init;
}
