%{
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "encoding.h"

int LC = 0;
int pass = 1;
sym *lookup_list = NULL;
extern FILE *yyin;
extern FILE *output_file;

int yylex(void);
void yyrestart(FILE *in);
void yyerror(const char *s);

%}
%union {
  uint16_t bit16;
  char* label;
}

%token <bit16> EXCHANGE BRANCH_REGOFF BRANCH_OFF BRANCH_REG 
%token <bit16> ARITH_BIN ARITH_UNI ARITH_NA ARITH_XORI
%token <bit16> REGISTER IMMEDIATE
%token <label> IDENTIFIER
%token <label> LABEL
%token COMMA EOL

// %type <bit16> instruction
// %type *<bit16> program
// AT&T type thing
%%
program:

  |program line
  ;
line:
  LABEL {
    if (pass ==1){
    add_sym($1, LC);
    }
  }
  | instruction EOL
  | EOL
  ;

instruction: 
  ARITH_UNI REGISTER {
    if (pass == 2){
      uint16_t bin = arith_uni($1, $2);
      write_to_bin(bin, output_file);
    }
    LC++;
  }
  |ARITH_BIN REGISTER COMMA REGISTER {
    if (pass == 2){
      uint16_t bin = arith_bin($1, $2, $4);
      write_to_bin(bin, output_file);
    }
    LC++;
  }  
  |ARITH_NA REGISTER {
    if (pass == 2){
      uint16_t bin = arith_na($1, $2);
      write_to_bin(bin, output_file);
    }
    LC++;
  }  
  |ARITH_XORI REGISTER COMMA IMMEDIATE {
    if (pass == 2){
      uint16_t bin = arith_xori($1, $2, $4);
      write_to_bin(bin, output_file);
    }
    LC++;
  }

  |BRANCH_REGOFF REGISTER COMMA IDENTIFIER {
    if (pass == 2){
      int offset = lookup_sym($4) - LC;
      uint16_t bin = branch_regoff($1, $2, offset);
      write_to_bin(bin, output_file);
    }
    LC++;
  } 

  |BRANCH_OFF IDENTIFIER {
    if (pass == 2){
      int offset = lookup_sym($2) - LC;
      uint16_t bin = branch_off($1, offset);
      write_to_bin(bin, output_file);
    }
    LC++;
  }

  |BRANCH_REG REGISTER {
    if (pass == 2){
      uint16_t bin = branch_reg($1,$2);
      write_to_bin(bin, output_file);
    }
    LC++;
  }

  |EXCHANGE REGISTER COMMA REGISTER {
    if (pass == 2){
      uint16_t bin = mem_exchange($1, $2, $4);
      write_to_bin(bin, output_file);
    }
    LC++;
  }

%%


FILE *output_file = NULL;

void yyerror(const char *s) {
    fprintf(stderr, "Error at LC %d: %s\n", LC, s);
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "wrong args : [input.bob] [output.out]");
        return 1;
    }

    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        fprintf(stderr, ".bob file opening failed");
        return 1;
    }
    yyin = input_file;
    // first pass
    pass = 1;
    LC = 0;
    yyparse();
    // reset
    rewind(yyin);
    yyrestart(yyin); 

    output_file = fopen(argv[2], "wb");
    if (!output_file) {
        fprintf(stderr, "bin file error");
        return 1;
    }
    pass = 2;
    LC = 0;

    yyparse();
    fclose(input_file);
    fclose(output_file);

    printf("LC: %d\n", LC);
    return 0;
}


