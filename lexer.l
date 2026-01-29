%{

%}

%%
// Arithmetic Logic
// Tanken er at gruppere dem basseret på antal registre?
"ADD" {yylval.bit4 = OP_ADD; return BIN;}
"SUB" {yylval.bit4 = OP_SUB; return BIN;}
"ADD1" {yylval.bit4 = OP_ADD1; return UNI;}
"SUB1" {yylval.bit4 = OP_SUB1; return UNI;}
"NEG" {yylval.bit4 = OP_NEG; return UNI;}
"XOR" {yylval.bit4 = OP_XOR; return BIN;}
"XORI" {return XORI;}
"MUL2" {return MUL2;}
"DIV2" {return DIV2;}

// Branch/Memory Instruction
"BGEZ" {return BGEZ;}
"BLZ" {return BLZ;}
"BEVN" {return BEVN;}
"BODD" {return BODD;}
"BRA" {return BRA;}
"SWB" {return SWB;}
"RSWB" {return RSWB;}
// Exchange
"EXCH" {return EXCH;}

// Registers?
"reg"([0-9]|1[0-5])(?![0-9]){
    yylval = atoi(yytext[3]);
    return REGISTER;
}
"pc" {return PC_REG;}
"br" {return BR_REG;}
"dir" {return DIR_REG;}

-?[0-9]+ {
  yylval = atoi(yytext);
  return INTEGER;
}

[ \t]+ // Igfnroe whitespace
"," {return COMMA;}
"\n" {return EOL;}
";".* { //Ignore anything after ; }

[a-zA-Z_][a-zA-Z0-9_]* { return IDENTIFIER;}

. {printf("fucked around and found out: %s\n", yytext);}





%%
int yywrap(){
    return 1;
}
