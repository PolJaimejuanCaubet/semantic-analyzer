%{
#include "calc.tab.h"
#include <stdlib.h>
#include <stdio.h>

int line_num = 1;
%}

%option noyywrap

DIGIT       [0-9]
INT         {DIGIT}+
REGISTER    [a-z]
WHITESPACE  [ \t\r]+
NEWLINE     \n
COMMENT     \/\/[^\n]*

%%

{COMMENT}       { /* Ignorar comentaris de línia */ }
{NEWLINE}       { line_num++; }
{WHITESPACE}    { /* Ignorar espais en blanc */ }

{INT}           {
                    yylval.ival = atoi(yytext);
                    return INTEGER;
                }

{REGISTER}      {
                    yylval.cval = yytext[0];
                    return REGISTER;
                }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"%"             { return MOD; }

"<="            { return LE; }
">="            { return GE; }
"=="            { return EQ; }
"!="            { return NE; }
"<"             { return LT; }
">"             { return GT; }

"!"             { return NOT; }
"&&"            { return AND; }
"||"            { return OR; }

"="             { return ASSIGN; }
"?"             { return QMARK; }
":"             { return COLON; }
";"             { return SEMICOLON; }
"("             { return LPAREN; }
")"             { return RPAREN; }

.               {
                    fprintf(stderr, "Error lèxic a la línia %d: caràcter desconegut '%s'\n", line_num, yytext);
                    return LEXERROR;
                }

%%
