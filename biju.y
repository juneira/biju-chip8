%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SYMB_TABLE_MAX 50
#define SYMB_FUNC_TABLE_MAX 50

struct ast {
  int nodetype;
  struct ast *l;
  struct ast *r;
};

struct number {
  int nodetype; /* K => Constant */
  int integer;
};

struct id {
  int nodetype; /* I => ID */
  char id_str[50];
};

struct id* symb_table[SYMB_TABLE_MAX]; /* symbol table */
struct id* symb_func_table[SYMB_FUNC_TABLE_MAX]; /* symbol function table */

int
lookup_symb_table(char* id_str)
{
  int i;
  for(i = 0; i < SYMB_TABLE_MAX; i++) {
    if(strcmp(symb_table[i]->id_str, id_str) == 0) return i;
  }

  return -1;
}

struct ast*
newast(int nodetype, struct ast *l, struct ast *r)
{
  struct ast* a = malloc(sizeof(struct ast));

  if(!a) {
    printf("out of memory\n");
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
    printf("out of memory\n");
    exit(0);
  }

  n->nodetype = 'K';
  n->integer = integer;

  return (struct ast *) n;
}

struct ast*
newid(char *id_str, int nodetype)
{
  struct id* new_id = malloc(sizeof(struct id));

  if(!new_id) {
    printf("out of memory\n");
    exit(0);
  }

  new_id->nodetype = nodetype;

  strcpy(new_id->id_str, id_str);

  if(nodetype == 'I')
  {
    int i;
    for(i = 0; symb_table[i] != NULL && i < SYMB_TABLE_MAX; i++);

    if(i < SYMB_TABLE_MAX) return (struct ast*) (symb_table[i] = new_id);

    printf("symbol table max reached\n");
  }

  if(nodetype == 'F')
  {
    int i;
    for(i = 0; symb_func_table[i] != NULL && i < SYMB_FUNC_TABLE_MAX; i++);

    if(i < SYMB_FUNC_TABLE_MAX) return (struct ast*) (symb_func_table[i] = new_id);

    printf("symbol function table max reached\n");
  }

  printf("nodetype invalid\n");
  exit(0);

  return NULL;
}

// DEBUG
// void
// showtree(struct ast* node)
// {
//   printf("%c =>\n", node->nodetype);
//   if(node->nodetype != 'K' && node->nodetype != 'I' && node->nodetype != 'F') {
//     printf("%c XXX\n", node->nodetype);
//     if(node->l != NULL) showtree(node->l);
//     if(node->r != NULL) showtree(node->r);
//   }
// }

void
compile(struct ast* root)
{
  insert_header();
  compile_ast(root);

}

void
insert_header()
{
  printf("JP main\n");

  insert_print();

  printf("main:\n");
}

void
insert_print()
{
  printf("print:\n");
  printf("CLS\n");
  printf("LD I, #000\n");
  printf("ADD I, V0\n");
  printf("ADD I, V0\n");
  printf("ADD I, V0\n");
  printf("ADD I, V0\n");
  printf("ADD I, V0\n");
  printf("LD V2, 0\n");
  printf("LD V3, 0\n");
  printf("DRW V2, V3, #005\n");
  printf("RET\n");
}

void compile_ast(struct ast* node)
{
  if(node == NULL) return;

  if(node->nodetype == 'o')
  {
    compile_ast(node->l);
    compile_ast(node->r);
  }

  if(node->nodetype == '=')
  {
    int addr = 0xF00 - lookup_symb_table(((struct id*) node->l)->id_str) * 0xFF;
    int num = ((struct number*) node->r)->integer;

    printf("LD I, #%X\n", addr);
    printf("LD V0, %d\n", num);
    printf("LD [I], V0\n");
  }

  if(node->nodetype == '+')
  {
    int addr_a = 0xF00 - lookup_symb_table(((struct id*) node->l)->id_str) * 0xFF;
    int addr_b = 0xF00 - lookup_symb_table(((struct id*) node->r)->id_str) * 0xFF;

    printf("LD I, #%X\n", addr_a);
    printf("LD V0, [I]\n");
    printf("LD V1, V0\n");

    printf("LD I, #%X\n", addr_b);
    printf("LD V0, [I]\n");
    printf("LD V2, V0\n");

    printf("LD V0, V1\n");
    printf("ADD V0, V2\n");
  }

  if(node->nodetype == 'C')
  {
    char* func_s = ((struct id*) node->l)->id_str;
    compile_ast(node->r);

    printf("CALL %s\n", func_s);
  }
}

%}

%union {
  int n;
  char c[50];
  struct ast *a;
}

%type <a> sum op ops call_func assign

%token <a> NUMBER
%token <c> ID

%token DEF END MAIN '=' '+' '(' ')' EOL

%%

prog: DEF MAIN ops END { compile($3); }
;

ops: { $$ = NULL; }
| op ops { $$ = newast('o', $1, $2); }
;

op: assign
| sum
| call_func
;

assign: ID '=' NUMBER { $$ = newast('=', newid($1, 'I'), newnumber($3)); }
;

sum: ID '+' ID { $$ = newast('+', newid($1, 'I'), newid($3, 'I'));  }
;

call_func: ID '(' op ')' { $$ = newast('C', newid($1, 'I'), $3); } /* C -> call function */
;

%%

main(int argc, char **argv)
{
  yyparse();
}

yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}