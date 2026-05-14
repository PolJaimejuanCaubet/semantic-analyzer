%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int registers[26];
static int reg_defined[26];

extern int  yylex(void);
extern int  line_num;
void yyerror(const char *s);

static int cond_value;

static void print_defined_registers(void)
{
    int i;
    for (i = 0; i < 26; i++) {
        if (reg_defined[i])
            printf("%c = %d\n", 'a' + i, registers[i]);
    }
}
%}

%union {
    int  ival;
    char cval;
    struct { int val; int is_assign; } bval;
}

%token <ival>  INTEGER
%token <cval>  REGISTER
%token PLUS MINUS TIMES DIVIDE MOD
%token LT GT LE GE EQ NE
%token NOT AND OR
%token ASSIGN QMARK COLON SEMICOLON LPAREN RPAREN
%token LEXERROR

%type <ival>  expr logic_expr rel_expr arith_expr term unary_expr primary assign_expr
%type <bval>  branch

%left  OR
%left  AND
%right NOT
%left  EQ NE
%left  LT GT LE GE
%left  PLUS MINUS
%left  TIMES DIVIDE MOD
%right UMINUS UPLUS

%start program

%%

program
    : stmt_list
        { print_defined_registers(); }
    ;

stmt_list
    : stmt_list stmt
    | /* buit */
    ;

stmt
    : expr SEMICOLON
        { printf("%d\n", $1); }
    | assign_expr SEMICOLON
        { /* assignació simple: no imprimim */ }
    | cond_stmt SEMICOLON
        { /* tot fet dins cond_stmt */ }
    | error SEMICOLON
        {
            fprintf(stderr,
                "Error sintàctic a la línia %d, recuperant...\n", line_num);
            yyerrok;
        }
    ;

assign_expr
    : REGISTER ASSIGN expr
        {
            int idx = $1 - 'a';
            registers[idx] = $3;
            reg_defined[idx] = 1;
            $$ = $3;
        }
    ;

cond_stmt
    : logic_expr
        { cond_value = $1; }
      QMARK branch COLON branch
        {
            int result;
            int is_assign;
            if (cond_value) {
                result    = $4.val;
                is_assign = $4.is_assign;
            } else {
                result    = $6.val;
                is_assign = $6.is_assign;
            }
            if (!is_assign)
                printf("%d\n", result);
        }
    ;

branch
    : assign_expr  { $$.val = $1; $$.is_assign = 1; }
    | expr         { $$.val = $1; $$.is_assign = 0; }
    ;

expr
    : logic_expr   { $$ = $1; }
    ;

logic_expr
    : logic_expr OR  logic_expr   { $$ = $1 || $3; }
    | logic_expr AND logic_expr   { $$ = $1 && $3; }
    | NOT logic_expr              { $$ = !$2; }
    | rel_expr                    { $$ = $1; }
    ;

rel_expr
    : arith_expr LT arith_expr    { $$ = $1 <  $3; }
    | arith_expr GT arith_expr    { $$ = $1 >  $3; }
    | arith_expr LE arith_expr    { $$ = $1 <= $3; }
    | arith_expr GE arith_expr    { $$ = $1 >= $3; }
    | arith_expr EQ arith_expr    { $$ = $1 == $3; }
    | arith_expr NE arith_expr    { $$ = $1 != $3; }
    | arith_expr                  { $$ = $1; }
    ;

arith_expr
    : arith_expr PLUS  term       { $$ = $1 + $3; }
    | arith_expr MINUS term       { $$ = $1 - $3; }
    | term                        { $$ = $1; }
    ;

term
    : term TIMES  unary_expr      { $$ = $1 * $3; }
    | term DIVIDE unary_expr
        {
            if ($3 == 0) {
                fprintf(stderr, "Error: divisió per zero a la línia %d\n", line_num);
                $$ = 0;
            } else {
                $$ = $1 / $3;
            }
        }
    | term MOD unary_expr
        {
            if ($3 == 0) {
                fprintf(stderr, "Error: mòdul per zero a la línia %d\n", line_num);
                $$ = 0;
            } else {
                $$ = $1 % $3;
            }
        }
    | unary_expr                  { $$ = $1; }
    ;

unary_expr
    : MINUS unary_expr %prec UMINUS   { $$ = -$2; }
    | PLUS  unary_expr %prec UPLUS    { $$ = +$2; }
    | primary                         { $$ = $1; }
    ;

primary
    : INTEGER                     { $$ = $1; }
    | REGISTER                    { $$ = registers[$1 - 'a']; }
    | LPAREN expr RPAREN          { $$ = $2; }
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "Error a la línia %d: %s\n", line_num, s);
}

int main(void)
{
    memset(registers,   0, sizeof(registers));
    memset(reg_defined, 0, sizeof(reg_defined));
    return yyparse();
}
