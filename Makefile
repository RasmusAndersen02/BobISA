CC = gcc
CFLAGS = -Wall -g

all: bob-ass

bob-ass: parser.tab.c lex.yy.c encoding.c
	$(CC) $(CFLAGS) -o bob-ass parser.tab.c lex.yy.c encoding.c

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

clean:
	rm -f bob-ass parser.tab.c parser.tab.h lex.yy.c
