%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct ast {
  int nodetype;
  struct ast *l;
  struct ast *r;
};

struct number {
  int nodetype; /* K => Constant */
  int integer;
}

struct ast*
newast(int nodetype, struct ast *l, struct ast *r)
{
  struct ast* a = malloc(sizeof(struct ast));

  if(!a) {
    printf("out of memory");
    exit(0);
  }

  a->nodetype = nodetype;
  a->l = l;
  a->r = r;

  return a;
}

struct ast*
newnumber(int integer)
{
  struct number* n = malloc(sizeof(struct number));

  if(!n) {
    printf("out of memory");
    exit(0);
  }

  n->nodetype = 'K';
  n->integer = integer;

  return (struct ast *) n;
}

%}

%union {
int n;
char c[50];
}

%type <n> sum op call_func assign

%token <n> NUMBER
%token <c> ID

%token DEF END MAIN '=' '+' '(' ')' EOL

%%

prog: DEF MAIN ops END { printf("MAIN\n"); }
;

ops:
| op ops;

op: assign
| sum
| call_func
;

assign: ID '=' NUMBER { $$ = assign($1, $3); }
;

sum: ID '+' ID { $$ = lookup($1)->value + lookup($3)->value; }
;

call_func: ID '(' op ')' { printf("call %s with %d\n", $1, $3); $$ = $3; }
;

%%

main(int argc, char **argv)
{
  printf(":D\n");

  yyparse();
}

yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}