install:	cg68
	cp cg68 /usr/bin/tud/cg68

cg68:	cgy.tab.o grinc.o
	cc -o cg68 -i -s cgy.tab.o grinc.o -ly -ll
	:

cgy.tab.o: cgy.tab.c lex.yy.c grinc.h
	   cc -c cgy.tab.c

cgy.tab.c: gr.y
	 cgyacc -l gr.y

lex.yy.c: gr.l
	  lex gr.l 

grinc.o: grinc.c
	cc -c grinc.c

