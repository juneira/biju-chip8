%option noyywrap

%{
#include "biju.tab.h"
%}

%%

"(" |
")" |
"=" |
"+"      { return yytext[0]; }

"def "   { return DEF; }
"end"    { return END; }
"main"   { return MAIN; }
[a-z]+   { strcpy(yylval.c, yytext); return ID; }
[0-9]+   { yylval.n = atoi(yytext); return NUMBER; }
[ \t \n] { /* ignore whitespace */ }
.        { printf("INVALIDCHAR %c\n", *yytext); }

%%
