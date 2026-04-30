%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

extern int yylineno;
extern int yylex(void);
void yyerror(const char *s);

static int formula_line;
static int base_depth;   /* scope depth before this formula */
%}

%union {
    char *sval;
    int   ival;
}

%token <sval> ID
%token <ival> SEMICOLON
%token FORALL EXISTS AND OR NOT IMPLIES IFF LPAREN RPAREN COMMA

/* Precedence: lowest → highest (bison reads bottom-up) */
%left  IFF IMPLIES
%left  OR
%left  AND
%right FORALL EXISTS
%right NOT

%type <ival> termlist

%%

program
    : formulalist
    ;

formulalist
    : formulalist formula_stmt
    | formula_stmt
    ;

/* Each formula gets its own global scope pushed before parsing */
formula_stmt
    : start_formula formula SEMICOLON
      {
          scope_pop();   /* pop the global scope pushed in start_formula */
          if (formula_ok)
              printf("Fórmula CP1 Correcta Línia %d\n", $3);
          else
              printf("ERROR Fórmula INCORRECTA Línia %d\n", $3);
          formula_ok = 1;
      }
    | error SEMICOLON
      {
          yyerrok;
          scope_pop_to(base_depth);
          formula_ok = 0;
          fprintf(stderr, "Error sintàctic: recuperació línia %d\n", yylineno);
      }
    ;

start_formula
    : /* empty */
      {
          scope_reset();
          base_depth   = scope_depth();
          formula_line = yylineno;
          formula_ok   = 1;
          scope_push();
      }
    ;

/* ── formula grammar (layered to encode precedence unambiguously) ──────────── */

formula
    : formula IFF    or_f  {}
    | formula IMPLIES or_f {}
    | or_f
    ;

or_f
    : or_f OR and_f {}
    | and_f
    ;

and_f
    : and_f AND quant_f {}
    | quant_f
    ;

/* Quantifiers push their own scope, parse inner formula, then pop */
quant_f
    : FORALL ID
      { scope_push(); add_variable($2, yylineno); free($2); }
      quant_f
      { scope_pop(); }
    | EXISTS ID
      { scope_push(); add_variable($2, yylineno); free($2); }
      quant_f
      { scope_pop(); }
    | not_f
    ;

not_f
    : NOT not_f  {}
    | primary
    ;

primary
    : LPAREN formula RPAREN {}
    | atom
    ;

/* Atom = predicate application */
atom
    : ID LPAREN termlist RPAREN
      { add_predicate($1, $3, yylineno); free($1); }
    | ID LPAREN RPAREN
      { add_predicate($1, 0, yylineno); free($1); }
    ;

termlist
    : termlist COMMA term  { $$ = $1 + 1; }
    | term                 { $$ = 1; }
    ;

/* Term = variable / constant / function application */
term
    : ID LPAREN termlist RPAREN
      { add_function($1, $3, yylineno); free($1); }
    | ID LPAREN RPAREN
      { add_function($1, 0, yylineno); free($1); }
    | ID
      { use_term_id($1, yylineno); free($1); }
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "Error sintàctic: %s línia %d\n", s, yylineno);
    formula_ok = 0;
}

int main(int argc, char **argv)
{
    if (argc > 1) {
        extern FILE *yyin;
        yyin = fopen(argv[1], "r");
        if (!yyin) { perror(argv[1]); return 1; }
    }
    return yyparse();
}
