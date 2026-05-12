%{
#include "cp1.tab.h"
#include <string.h>
%}

%option yylineno noyywrap

%%

"forall"            { return FORALL; }
"exists"            { return EXISTS; }
"and"               { return AND; }
"or"                { return OR; }
"bool"              { yylval.ival = 1; return TYPE; }
"char"              { yylval.ival = 2; return TYPE; }
"int"               { yylval.ival = 3; return TYPE; }
"real"              { yylval.ival = 4; return TYPE; }
"->"                { return IMPLIES; }
"<->"               { return IFF; }
"!"                 { return NOT; }
"¬"                 { return NOT; }
"("                 { return LPAREN; }
")"                 { return RPAREN; }
","                 { return COMMA; }
":"                 { return COLON; }
";"                 { yylval.ival = yylineno; return SEMICOLON; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sval = strdup(yytext);
    return ID;
}

"//"[^\n]*          { /* comentari de línia */ }
[ \t\r]+            { }
\n                  { }

. {
    fprintf(stderr, "Error lèxic: caràcter '%s' línia %d\n", yytext, yylineno);
}

%%
