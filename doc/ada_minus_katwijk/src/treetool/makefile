# makefile for treetool
# veyacc version
SHELL	= /bin/sh
CC	= cc
YACC	= ../veyacc/veyacc

CFLAGS	= -O
LIBS	= -ll


treetool:	y.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o treetool y.tab.c $(LIBS)

y.tab.c:	treegen.y
	$(YACC) treegen.y

lex.yy.c:	treegen.l
	lex treegen.l

