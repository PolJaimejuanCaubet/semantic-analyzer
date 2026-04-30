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
"->"                { return IMPLIES; }
"<->"               { return IFF; }
"!"                 { return NOT; }
"¬"                 { return NOT; }
"("                 { return LPAREN; }
")"                 { return RPAREN; }
","                 { return COMMA; }
";"                 { yylval.ival = yylineno; return SEMICOLON; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sval = strdup(yytext);
    return ID;
}

"//"[^\n]*          { /* comentari de línia */ }
[ \t\r]+            { /* espais */ }
\n                  { /* nova línia (yylineno s'incrementa automàticament) */ }

.  {
    fprintf(stderr, "Error lèxic: caràcter '%s' línia %d\n", yytext, yylineno);
}

%%
