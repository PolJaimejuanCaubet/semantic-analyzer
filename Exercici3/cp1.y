%code requires {
#include "symtab.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
extern int yylex(void);
void yyerror(const char *s);

static int formula_line;
static int base_depth;
%}

%union {
    char    *sval;
    int      ival;
    TypeList tl;     /* TypeList embedded directly in the union */
}

%token <sval> ID
%token <ival> SEMICOLON TYPE
%token FORALL EXISTS AND OR NOT IMPLIES IFF LPAREN RPAREN COMMA COLON

%type <tl>   termlist
%type <ival> term

%%

program
    : formulalist
    ;

formulalist
    : formulalist formula_stmt
    | formula_stmt
    ;

formula_stmt
    : start_formula formula SEMICOLON
      {
          scope_pop();
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
          printf("ERROR Fórmula INCORRECTA Línia %d\n", yylineno);
          formula_ok = 1;
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

/* ── formula: IFF / IMPLIES lowest priority ────────────────────────────────── */

formula
    : formula IFF     or_f  {}
    | formula IMPLIES or_f  {}
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

/* Quantifiers push their own scope with the variable's type */
quant_f
    : FORALL ID COLON TYPE
      { scope_push(); add_variable($2, $4, yylineno); free($2); }
      quant_f
      { scope_pop(); }
    | EXISTS ID COLON TYPE
      { scope_push(); add_variable($2, $4, yylineno); free($2); }
      quant_f
      { scope_pop(); }
    | not_f
    ;

not_f
    : NOT not_f {}
    | primary
    ;

primary
    : LPAREN formula RPAREN {}
    | atom
    ;

/* Atom = predicate application */
atom
    : ID LPAREN termlist RPAREN
      { add_predicate($1, &$3, yylineno); free($1); }
    | ID LPAREN RPAREN
      { add_predicate($1, NULL, yylineno); free($1); }
    ;

/* termlist builds a TypeList: each term contributes its type */
termlist
    : term
      { $$.count = 1; $$.types[0] = $1; }
    | termlist COMMA term
      {
          $$ = $1;
          if ($$.count < MAX_ARGS) $$.types[$$.count++] = $3;
      }
    ;

/* term returns the type of the expression */
term
    /* function call WITH return type (first or subsequent definition) */
    : ID LPAREN termlist RPAREN COLON TYPE
      { $$ = add_function($1, &$3, $6, yylineno); free($1); }

    /* function call WITHOUT return type (must already be defined) */
    | ID LPAREN termlist RPAREN
      { $$ = check_function($1, &$3, yylineno); free($1); }

    /* 0-arity function WITH return type */
    | ID LPAREN RPAREN COLON TYPE
      { $$ = add_function($1, NULL, $5, yylineno); free($1); }

    /* 0-arity function WITHOUT return type */
    | ID LPAREN RPAREN
      { $$ = check_function($1, NULL, yylineno); free($1); }

    /* constant with type annotation */
    | ID COLON TYPE
      { add_constant($1, $3, yylineno); $$ = $3; free($1); }

    /* variable or constant already defined */
    | ID
      { $$ = get_id_type($1, yylineno); free($1); }
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
