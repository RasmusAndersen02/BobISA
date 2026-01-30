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

