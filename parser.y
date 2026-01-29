%{
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// maybe emit func for offset
%}
%union {
  uint16_t bit16;
  char* label;
}

%token <bit16> EXCHANGE BRANCH_REGOFF BRANCH_OFF BRANCH_REG ARITH_BIN ARITH_UNI
%token <bit16> REGISTER INTEGER
%token <label> IDENTIFIER

%token COMMA EOL

// AT&T type thing
%%
instruction: 
  |ARITH_UNI REGISTER {} 
  |ARITH_BIN REGISTER, REGISTER {} 
  |BRANCH_REGOFF REGISTER, REGISTER {} 
  |BRANCH_OFF REGISTER {} 
  |BRANCH_REG REGISTER {} 
  |EXCHANGE REGISTER, REGISTER {}



%%
int main(int argc, char* argv[]){
  yyparse();
}
uint16_t 

