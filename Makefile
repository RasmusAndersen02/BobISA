assembler: lexer.l parser.y
	bison -d parser.y
	flex lexer.l
	gcc -S -g -Wall -Wextra -Werror -pedantic -std=c11 lex.yy.c
