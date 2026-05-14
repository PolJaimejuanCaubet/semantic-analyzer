# Makefile per a la mini calculadora (flex + bison)

CC      = gcc
CFLAGS  = -Wall -Wextra
TARGET  = calc

TESTDIR = tests
TESTFILE = $(TESTDIR)/test.txt

.PHONY: all clean test

all: $(TARGET)

$(TARGET): calc.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $@ $^ -lfl

calc.tab.c calc.tab.h: calc.y
	bison -d -v calc.y

lex.yy.c: calc.l calc.tab.h
	flex calc.l

clean:
	rm -f $(TARGET) calc.tab.c calc.tab.h calc.output lex.yy.c

test: $(TARGET)
	@echo "=== Executant test ==="
	@cat $(TESTFILE)
	@echo "\n=== Sortida del programa ==="
	@./$(TARGET) < $(TESTFILE)