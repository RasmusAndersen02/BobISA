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

%token <bit16> ARITH_UNI

%token COMMA EOL

%union {
  
}

%%
operation: instruction  



%%
int main(int argc, char* argv[]){

  yyparse();
}
void(char *s){
  fprintf(stderr, "whoops %s\n", s);
}
