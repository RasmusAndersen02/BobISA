
#ifndef ENCODING_H
#define ENCODING_H
#include <stdint.h>

typedef enum {
  OP_ADD,
  OP_SUB,
  OP_XOR,
  OP_ADD1,
  OP_SUB1,
  OP_NEG,
  OP_XORI,
  OP_MUL2,
  OP_DIV2,
  OP_BGEZ,
  OP_BLZ,
  OP_BEVN,
  OP_BODD,
  OP_BRA,
  OP_SWB,
  OP_RSWB,
  OP_EXCH
} opcode_t;

uint16_t arith_uni(uint16_t op, uint16_t regd);
uint16_t arith_bin(uint16_t op, uint16_t regd, uint16_t regs);
uint16_t arith_na(uint16_t op, uint16_t regd);
uint16_t arith_xori(uint16_t op, uint16_t regd, uint16_t imm);
uint16_t mem_exchange(uint16_t op, uint16_t regd, uint16_t rega);
uint16_t branch_regoff(uint16_t op, uint16_t regd, uint16_t offset);
uint16_t branch_off(uint16_t op, uint16_t offset);
uint16_t branch_reg(uint16_t op, uint16_t regd);

#endif
