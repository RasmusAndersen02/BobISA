%{

%}

%%
// Arithmetic Logic
// Tanken er at gruppere dem basseret på antal registre?
"ADD" {yylval.bit16 = OP_ADD; return ARITH_BIN;}
"SUB" {yylval.bit16 = OP_SUB; return ARITH_BIN;}
"ADD1" {yylval.bit16 = OP_ADD1; return ARITH_UNI;}
"SUB1" {yylval.bit16 = OP_SUB1; return ARITH_UNI;}
"NEG" {yylval.bit16 = OP_NEG; return ARITH_UNI;}
"XOR" {yylval.bit16 = OP_XOR; return ARITH_BIN;}
"XORI" {yylval.bit16 = OP_XORI; return ARITH_UNI;}
"MUL2" {yylval.bit16 = OP_MUL2; return ARITH_UNI;}
"DIV2" {yylval.bit16 = OP_DIV2; return ARITH_UNI;}

// Branch/Memory Instruction
"BGEZ" {yylval.bit16 = OP_BGEZ; return BRANCH_REGOFF;}
"BLZ" {yylval.bit16 = OP_BLZ; return BRANCH_REGOFF;}
"BEVN" {yylval.bit16 = OP_BEVN; return BRANCH_REGOFF;}
"BODD" {yylval.bit16 = OP_BODD; return BRANCH_REGOFF;}
"BRA" {yylval.bit16 = OP_BRA; return BRANCH_OFF;}
"SWB" {yylval.bit16 = OP_SWB; return BRANCH_REG;}
"RSWB" {yylval.bit16 = OP_RSWB; return BRANCH_REG;}
// Exchange
"EXCH" {yylval.bit16 = OP_EXCH; return EXCHANGE;}

// Registers?
"reg"([0-9]|1[0-5])(?![0-9]){yylval.bit16 = atoi(yytext+3); return REGISTER; }

"pc" {return PC_REG;}
"br" {return BR_REG;}
"dir" {return DIR_REG;}

-?[0-9]+ {yylval.bit16 = atoi(yytext); return INTEGER; }
[a-zA-Z_][a-zA-Z0-9_]* { return IDENTIFIER;}

[ \t]+ // Igfnroe whitespace
"," {return COMMA;}
"\n" {return EOL;}
// ";".* { //Ignore anything after ; }


. {printf("fucked around and found out: %s\n", yytext);}





%%
int yywrap(){
    return 1;
}
