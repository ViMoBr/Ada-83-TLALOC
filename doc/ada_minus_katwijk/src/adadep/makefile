SHELL	= /bin/sh
INCLUDE = ../view
CFLAGS	= -c -O -I${INCLUDE} $(DEBUG)
YACC	= /usr/bin/yacc
DEBUG	= 

all:	adaparse adadep

install:	all
		cp adaparse adadep /usr/bin/

cleanup:
		-rm adaparse adadep *.o adadeplex.c adadepyacc.c adaparselex.c adaparseyacc.c

adaparse:	adaparseyacc.o adaparse.o
		${CC} adaparse.o adaparseyacc.o -o adaparse -ll

adadep:		adadepyacc.o adadep.o adadep1.o adadep2.o adadep3.o
		${CC} adadep.o adadepyacc.o adadep1.o adadep2.o adadep3.o ../view/viewlib.a -o adadep -ll

adaparseyacc.o:	adaparselex.c adaparseyacc.c
		${CC} ${CFLAGS} adaparseyacc.c

adadepyacc.o:	adadeplex.c adadepyacc.c adadep.h
		${CC} ${CFLAGS} adadepyacc.c

adadep1.o:	adadep.h

adadep2.o:	adadep.h

adadep3.o:	adadep.h


