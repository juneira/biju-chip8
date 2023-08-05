biju: biju.lex biju.y
						bison -d biju.y
						flex biju.lex
						gcc -o $@ biju.tab.c lex.yy.c
