# makefile for ada compiler front end
# veyacc version
SHELL	= /bin/sh
P	= ada_front
CC	= gcc 

PRINT	=
YACC	= ../veyacc/veyacc

DEBUG	= -DDEBUG
MACH	= -DPC
PRINT	= -DPRINTF
GDB	= -ggdb

#LDFLAGS	= -i 
CFLAGS  = -w -O   $(DEBUG) $(MACH) $(PRINT) 
LIBS	= -ll ../libvy/libvy.a ../view/viewlib.a
#LIBS	= -ll -ly ../view/viewlib.a

SRC	= 1A00.c	\
	  1A02.c 	\
	  1A03.c	\
	  1A04.c	\
	  1A05.c	\
	  1A06.c	\
	  1A07.c	\
	  1A08.c	\
	  1A09.c	\
	  1A10.c	\
	  1A11.c	\
	  1A12.c	\
	  1A13.c	\
	  1A14.c	\
	  1A16.c	\
	  1A17.c	\
	  1A18.c	\
	  1A19.c	\
	  1A20.c	\
	  predicates.c	\
	  front.h	\
	  y.tab.h	\
	CGcode00.c	\
	CGcode01.c	\
	CGcode02.c	\
	CGcode03.c	\
	CGcode04.c	\
	CGcode05.c	\
	CGcode06.c	\
	CGcode07.c	\
	CGcode08.c	\
	CGcode09.c	\
	CGcode10.c	\
	CGcode11.c	\
	CGdesc00.c	\
	CGdesc01.c	\
	CGdesc02.c	\
	CGgddb00.c	\
	CGgpcc00.c	\
	CGstor01.c	\
	CGstor02.c	\
	CGstor03.c	\
	CGstor04.c	\
	CGstor05.c	\
	CGstor06.c	\
	CGstor07.c	\
	CGtrac00.c	\
	  ../h/tokens.h ../h/reader.h ../h/main.h ../h/print.h ../h/put_tree.h \
	  ../h/rec_sizes.h ../h/record_man.h  ../h/rt_defs.h \
	  ../h/rt_types.h ../h/std.h ../h/tokens.h ../h/tree.h \
	  ../share/reader.c main.c ../share/put_tree.c \
	  ../share/rec_sizes.c	\
	  ../share/record_man.c	\
	  ../share/std.c	\
	  ../share/tokens.c	\
	  rec_funcs.o	

.c.o:
	gcc -ggdb -c -O $(CFLAGS) $<

.c.s:
	cc -S $(CFLAGS) $<

all:	$(P)

$(P):	1A00.o \
	1A02.o \
	1A03.o \
	1A04.o \
	1A05.o \
	1A06.o \
	1A07.o \
	1A08.o \
	1A09.o \
	1A10.o \
	1A11.o \
	1A12.o \
	1A13.o	\
	1A14.o	\
	1A16.o \
	1A17.o \
	1A18.o \
	1A19.o \
	1A20.o \
	predicates.o	\
	CGcode00.o	\
	CGcode01.o	\
	CGcode02.o	\
	CGcode03.o	\
	CGcode04.o	\
	CGcode05.o	\
	CGcode06.o	\
	CGcode07.o	\
	CGcode08.o	\
	CGcode09.o	\
	CGcode10.o	\
	CGcode11.o	\
	CGdesc00.o	\
	CGdesc01.o	\
	CGdesc02.o	\
	CGgddb00.o	\
	CGgpcc00.o	\
	CGstor01.o	\
	CGstor02.o	\
	CGstor03.o	\
	CGstor04.o	\
	CGstor05.o	\
	CGstor06.o	\
	CGstor07.o	\
	CGtrac00.o	\
	put_tree.o record_man.o main.o \
	rec_funcs.o	\
	reader.o std.o rec_sizes.o  tokens.o ../view/viewlib.a 
	cc $(LDFLAGS) -o $(P) main.o \
	1A00.o	\
	1A02.o	\
	1A03.o	\
	1A04.o	\
	1A05.o	\
	1A06.o	\
	1A07.o	\
	1A08.o	\
	1A09.o	\
	1A10.o	\
	1A11.o	\
	1A12.o	\
	1A13.o	\
	1A14.o	\
	1A16.o	\
	1A17.o	\
	1A18.o	\
	1A19.o	\
	1A20.o	\
	predicates.o	\
	CGcode00.o	\
	CGcode01.o	\
	CGcode02.o	\
	CGcode03.o	\
	CGcode04.o	\
	CGcode05.o	\
	CGcode06.o	\
	CGcode07.o	\
	CGcode08.o	\
	CGcode09.o	\
	CGcode10.o	\
	CGcode11.o	\
	CGdesc00.o	\
	CGdesc01.o	\
	CGdesc02.o	\
	CGgddb00.o	\
	CGgpcc00.o	\
	CGstor01.o	\
	CGstor02.o	\
	CGstor03.o	\
	CGstor04.o	\
	CGstor05.o	\
	CGstor06.o	\
	CGstor07.o	\
	CGtrac00.o	\
	put_tree.o	\
	tokens.o	\
	rec_funcs.o	\
	reader.o record_man.o std.o rec_sizes.o $(LIBS)

$(P)_d:	1A00.o \
	1A02.o \
	1A03.o \
	1A04.o \
	1A05.o \
	1A06.o \
	1A07.o \
	1A08.o \
	1A09.o \
	1A10.o \
	1A11.o \
	1A12.o \
	1A13.o	\
	1A14.o	\
	1A16.o \
	1A17.o \
	1A18.o \
	1A19.o \
	1A20.o \
	predicates.o	\
	CGcode00.c	\
	CGcode01.c	\
	CGcode02.c	\
	CGcode03.c	\
	CGcode04.c	\
	CGcode05.c	\
	CGcode06.c	\
	CGcode07.c	\
	CGcode08.c	\
	CGcode09.c	\
	CGcode10.c	\
	CGcode11.c	\
	CGdesc00.c	\
	CGdesc01.c	\
	CGdesc02.c	\
	CGgddb00.c	\
	CGgpcc00.c	\
	CGstor01.c	\
	CGstor02.c	\
	CGstor03.c	\
	CGstor04.c	\
	CGstor05.c	\
	CGstor06.c	\
	CGstor07.c	\
	CGtrac00.c	\
	put_tree.o record_man.o_d main.o \
	tokens.o \
	rec_funcs.o	\
	reader.o std.o rec_sizes.o
	cc $(LDFLAGS) -o $(P)_d main.o \
	1A00.o \
	1A02.o \
	1A03.o \
	1A04.o \
	1A05.o \
	1A06.o \
	1A07.o \
	1A08.o \
	1A09.o \
	1A10.o \
	1A11.o \
	1A12.o \
	1A13.o	\
	1A14.o	\
	1A16.o \
	1A17.o \
	1A18.o \
	1A19.o \
	1A20.o \
	predcicates.o	\
	CGcode00.c	\
	CGcode01.c	\
	CGcode02.c	\
	CGcode03.c	\
	CGcode04.c	\
	CGcode05.c	\
	CGcode06.c	\
	CGcode07.c	\
	CGcode08.c	\
	CGcode09.c	\
	CGcode10.c	\
	CGcode11.c	\
	CGdesc00.c	\
	CGdesc01.c	\
	CGdesc02.c	\
	CGgddb00.c	\
	CGgpcc00.c	\
	CGstor01.c	\
	CGstor02.c	\
	CGstor03.c	\
	CGstor04.c	\
	CGstor05.c	\
	CGstor06.c	\
	CGstor07.c	\
	CGtrac00.c	\
	put_tree.o \
	tokens.o \
	rec_funcs.o	\
	reader.o record_man.o_d std.o rec_sizes.o $(LIBS)
	size $(P) $(P)_d

1A00.o:		1A00.c lex.yy.c
		-cc -c $(CFLAGS) 1A00.c
#		-cc -c $(CFLAGS) -DREPAIR 1A00.c

1A00.c:		1A00.attrib
		$(YACC) -v -d 1A00.attrib
		mv y.tab.c 1A00.c

lex.yy.c:	1A01.l
		lex 1A01.l

record_man.o:	../share/record_man.c
		cc -c -O $(CFLAGS) ../share/record_man.c

record_man.o_d:	../share/record_man.c
		-mv record_man.o temp
		cc -c -O $(CFLAGS) -DASC ../share/record_man.c
		mv record_man.o record_man.o_d
		-mv temp record_man.o

put_tree.o:	../share/put_tree.c
		cc -c -O $(CFLAGS) ../share/put_tree.c

main.o:	main.c
		cc -c -O $(CFLAGS) main.c

reader.o:	../share/reader.c
		cc -c -O $(CFLAGS) ../share/reader.c

std.o:	../share/std.c
	cc -c -O $(CFLAGS) ../share/std.c

rec_sizes.o:	../share/rec_sizes.c
		cc -c -O $(CFLAGS) ../share/rec_sizes.c

tokens.o:	../share/tokens.c
	$(CC) -c -O $(CFLAGS) ../share/tokens.c

tags:	$(SRC)
	ctags    $(SRC) > meldtags 2>&1


install:	all
	cp $(P) /home/adacomp/lib

cleanup:
	rm -f *.o *.o_d meld front front_d
