#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#include "emulator.h"

uint16_t mask_and_shift(mask m, instruction inst) {
  switch (m) {
  case OP:
    return (inst & OP) >> 12;
  case REGd:
    return (inst & REGd) >> 8;
  case REGs:
    return (inst & REGs) >> 4;
  case ARITH:
    return (inst & ARITH);
  case OFFIMM:
    return (inst & OFFIMM);
  default:
    fprintf(stderr, "mask issue, enum: %d", m);
  }
}

void arith_uni(ProgramState *curr, uint16_t regd, arith_code arith) {
  switch (arith) {
  case ADD1:
    curr->standard_registers[regd] += 1;
  case SUB1:
    curr->standard_registers[regd] -= 1;
  case NEG:
    curr->standard_registers[regd] = -curr->standard_registers[regd];
  default:
    fprintf(stderr, "didnt hit unary enum: %d", arith);
  }
}

void arith_bin(ProgramState *curr, uint16_t regd, uint16_t regs,
               arith_code arith) {

  switch (arith) {
  case ADD:
    curr->standard_registers[regd] += curr->standard_registers[regs];
  case SUB:
    curr->standard_registers[regd] -= curr->standard_registers[regs];
  case XOR:
    curr->standard_registers[regd] ^= curr->standard_registers[regs];
  default:
    fprintf(stderr, "didnt hit binary enum: %d", arith);
  }
}

void arith_wrapper(ProgramState *curr, uint16_t regd, uint16_t regs,
                   arith_code arith) {
  if (regs == 0) {
    arith_uni(curr, regd, arith);
  } else {
    arith_bin(curr, regd, regs, arith);
  }
}

void arith_xori(ProgramState *curr, uint16_t regd, uint16_t immediate) {
  curr->standard_registers[regd] ^= immediate;
}
// Kan bruge BGEZ / BLZ for bounds checking af regd.
void arith_mul(ProgramState *curr, uint16_t regd) {
  // Shoutout ChatiGippity
  uint16_t temp = (uint16_t)curr->standard_registers[regd];
  temp <<= 1;
  curr->standard_registers[regd] = (int16_t)temp;

  // int16_t max = (int16_t)(1u << 14);
  // int16_t min = -(int16_t)(1u << 14);
  //
  // if (curr->standard_registers[regd] >= max) {
  //   curr->standard_registers[regd] =
  //       curr->standard_registers[regd] * 2 - (1 << 14) + 1;
  // } else if (curr->standard_registers[regd] < min) {
  //   curr->standard_registers[regd] =
  //       curr->standard_registers[regd] * 2 + (1 << 14) + 1;
  // } else {
  //   curr->standard_registers[regd] *= 2;
  // }
}
void arith_div(ProgramState *curr, uint16_t regd) {
  uint16_t temp = (uint16_t)curr->standard_registers[regd];
  uint16_t odd_mask = temp & 1;
  temp = (temp >> 1) | (odd_mask << 15);
  curr->standard_registers[regd] = (int16_t)temp;

  // if (curr->standard_registers[regd] % 2 == 0) {
  //   curr->standard_registers[regd] /= 2;
  // } else if (curr->standard_registers[regd] > 0) {
  //   curr->standard_registers[regd] =
  //       (curr->standard_registers[regd] - 1) / 2 + (1 << 14);
  // } else if (curr->standard_registers[regd] < 0) {
  //   curr->standard_registers[regd] =
  //       (curr->standard_registers[regd] - 1) / 2 - (1 << 14);
  // }
}
void mem_exchange(ProgramState *curr, uint16_t regd, uint16_t regs) {}
void branch_regoff(ProgramState *curr, uint16_t regd, uint16_t offset) {}
void branch_off(ProgramState *curr, uint16_t offset) {}
void branch_reg(ProgramState *curr, uint16_t regd) {}
