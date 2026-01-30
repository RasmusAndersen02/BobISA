%{
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "encoding.h"

// maybe emit func for offset
%}
%union {
  uint16_t bit16;
  char* label;
}

%token <bit16> EXCHANGE BRANCH_REGOFF BRANCH_OFF BRANCH_REG 
%token <bit16> ARITH_BIN ARITH_UNI ARITH_NA
%token <bit16> REGISTER INTEGER
%token <label> IDENTIFIER
%token COMMA EOL

%type <bit16> instruction
// AT&T type thing
%%
instruction: 
  |ARITH_UNI REGISTER {$$ = arith_uni($1, $2);  } 
  |ARITH_BIN REGISTER COMMA REGISTER {$$ = arith_bin($1,$2,$4);} 
  |ARITH_NA REGISTER {$$ = arith_na($1, $2);} 
  |ARITH_XORI REGISTER COMMA INTEGER {$$ = arith_xori($1,$2,$4);} 
  |BRANCH_REGOFF REGISTER COMMA REGISTER {$$ = branch_regoff($1,$2,$4);} 
  |BRANCH_OFF REGISTER {$$ = branch_off($1, $2);} 
  |BRANCH_REG REGISTER {$$ = branch_reg($1, $2);} 
  |EXCHANGE REGISTER COMMA REGISTER {$$ = mem_exchange($1,$2,$4);}



%%
int main(int argc, char* argv[]){
  yyparse();
}
uint16_t arith_uni(uint16_t op, uint16_t regd){
  uint16_t encoding = 0x0b << 12; 
  encoding |= regd << 8; 
  switch (op){
    case OP_ADD1: encoding |= 0x06; break;
    case OP_SUB1: encoding |= 0x0f; break; 
    case OP_NEG: encoding |= 0x07; break; 
  }
  return (encoding);
}
uint16_t arith_bin(uint16_t op, uint16_t regd, uint16_t regs){
  uint16_t encoding = 0x0b << 12;
  encoding |= regd << 8; 
  encoding |= regs << 4; 
  switch (op){
    case OP_ADD: encoding |= 0x04; break;
    case OP_SUB: encoding |= 0x0d; break; 
    case OP_XOR: encoding |= 0x00; break; 
  }
  return (encoding);
}
uint16_t arith_na(uint16_t op, uint16_t regd){
  uint16_t encoding = 0x00;
  encoding |= regd << 8; 
  switch (op){
    case OP_MUL2: encoding |= 0x0a << 12; break;
    case OP_DIV2: encoding |= 0x09 << 12; break; 
  }
  return (encoding);
}
uint16_t arith_xori(uint16_t op, uint16_t regd, uint16_t imm){
  uint16_t encoding = 0x00;
  encoding |= regd << 8; 
  encoding |= imm; 
  return (encoding);
}
uint16_t mem_exchange(uint16_t op, uint16_t regd, uint16_t rega){
  uint16_t encoding = 0x08 << 12;
  encoding |= regd << 8; 
  encoding |= rega << 4; 
  return (encoding);
}
uint16_t branch_regoff(uint16_t op, uint16_t regd, uint16_t offset){
  uint16_t encoding = 0x00;
  encoding |= regd << 8; 
  encoding |= offset; 
  switch (op){
    case OP_BGEZ: 0x03 << 12; break;
    case OP_BLZ: 0x02 << 12;break;
    case OP_BEVN: 0x05 << 12;break;
    case OP_BODD: 0x04 << 12;break;
  }
  return (encoding);
}
uint16_t branch_off(uint16_t op, uint16_t offset){
  uint16_t encoding = 0x01 << 12;
  encoding |= offset; 
  return (encoding);
}
uint16_t branch_reg(uint16_t op, uint16_t regd){
  uint16_t encoding = 0x00;
  encoding |= regd << 8; 
  switch (op){
    case OP_SWB: 0x06 << 12;break;
    case OP_RSWB: 0x07 << 12;break;
  }
  return (encoding);
}

