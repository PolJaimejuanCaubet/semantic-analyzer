CC     = gcc
CFLAGS = -Wall -g

BISON  = /usr/bin/bison
FLEX   = /usr/bin/flex

all: cp1

cp1: cp1.tab.c cp1.tab.h lex.yy.c symtab.c
	$(CC) $(CFLAGS) -o cp1 cp1.tab.c lex.yy.c symtab.c -lfl

cp1.tab.c cp1.tab.h: cp1.y
	$(BISON) -d cp1.y

lex.yy.c: cp1.l cp1.tab.h
	$(FLEX) cp1.l

clean:
	rm -f cp1 cp1.tab.c cp1.tab.h lex.yy.c *.o

test-correct: cp1
	./cp1 tests/test_correct.cp1

test-incorrect: cp1
	./cp1 tests/test_incorrect.cp1

test: test-correct test-incorrect