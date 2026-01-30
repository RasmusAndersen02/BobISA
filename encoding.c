#include "encoding.h"
#include <stdint.h>
#include <stdlib.h>

uint16_t arith_uni(uint16_t op, uint16_t regd) {
  uint16_t encoding = 0x0b << 12;
  encoding |= regd << 8;
  switch (op) {
  case OP_ADD1:
    encoding |= 0x06;
    break;
  case OP_SUB1:
    encoding |= 0x0f;
    break;
  case OP_NEG:
    encoding |= 0x07;
    break;
  }
  return (encoding);
}
uint16_t arith_bin(uint16_t op, uint16_t regd, uint16_t regs) {
  uint16_t encoding = 0x0b << 12;
  encoding |= regd << 8;
  encoding |= regs << 4;
  switch (op) {
  case OP_ADD:
    encoding |= 0x04;
    break;
  case OP_SUB:
    encoding |= 0x0d;
    break;
  case OP_XOR:
    encoding |= 0x00;
    break;
  }
  return (encoding);
}
uint16_t arith_na(uint16_t op, uint16_t regd) {
  uint16_t encoding = 0x00;
  encoding |= regd << 8;
  switch (op) {
  case OP_MUL2:
    encoding |= 0x0a << 12;
    break;
  case OP_DIV2:
    encoding |= 0x09 << 12;
    break;
  }
  return (encoding);
}
uint16_t arith_xori(uint16_t op, uint16_t regd, uint16_t imm) {
  uint16_t encoding = 0x00;
  encoding |= regd << 8;
  encoding |= imm;
  return (encoding);
}
uint16_t mem_exchange(uint16_t op, uint16_t regd, uint16_t rega) {
  uint16_t encoding = 0x08 << 12;
  encoding |= regd << 8;
  encoding |= rega << 4;
  return (encoding);
}
uint16_t branch_regoff(uint16_t op, uint16_t regd, uint16_t offset) {
  uint16_t encoding = 0x00;
  encoding |= regd << 8;
  encoding |= offset;
  switch (op) {
  case OP_BGEZ:
    encoding |= 0x03 << 12;
    break;
  case OP_BLZ:
    encoding |= 0x02 << 12;
    break;
  case OP_BEVN:
    encoding |= 0x05 << 12;
    break;
  case OP_BODD:
    encoding |= 0x04 << 12;
    break;
  }
  return (encoding);
}
uint16_t branch_off(uint16_t op, uint16_t offset) {
  uint16_t encoding = 0x01 << 12;
  encoding |= offset;
  return (encoding);
}
uint16_t branch_reg(uint16_t op, uint16_t regd) {
  uint16_t encoding = 0x00;
  encoding |= regd << 8;
  switch (op) {
  case OP_SWB:
    encoding |= 0x06 << 12;
    break;
  case OP_RSWB:
    encoding |= 0x07 << 12;
    break;
  }
  return (encoding);
}
