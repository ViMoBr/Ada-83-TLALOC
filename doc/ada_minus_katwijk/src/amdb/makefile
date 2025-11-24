# makefile for symbolic ADA debugger

PROG	= amdb
DAS	= ..
SHARE	= ${DAS}/share

DAPSE	= ../view

INCL	=  debug.h


HEADER  = $(INCL) ptrace.h context.h mode.h

#LIB	=  libman.a -ll -lc
LIB	=  ${DAPSE}/viewlib.a -ll -lc
CFLAGS	=  -I${DAPSE} -DVAX

FILES	= command.o context.o line.o main.o\
       	  get_tree.o lib_read.o record_man.o std.o rec_sizes.o\
	  call.o object.o print.o dapse_int.o run.o \
	  screen.o symbol.o trace.o  tty.o

$(PROG)	:	$(FILES)
		cc -i $(FILES) $(LIB) -o $(PROG)
		size $(PROG)

install	:	${PROG}
		mv ${PROG} ${BIN}

lint	:
		lint -abchx -I{DAPSE} *.c >lintlist


$(HEADER)	:

call.o		:	$(INCL) context.h ptrace.h

command.o	:	$(INCL) mode.h ptrace.h context.h

context.o	: 	$(INCL) context.h

line.o		:	$(INCL) context.h ptrace.h

main.o		:	$(INCL) context.h

object.o 	: 	$(INCL) mode.h context.h

print.o		:	$(INCL) context.h

dapse_int.o	:	${INCL}

run.o		: 	$(INCL) ptrace.h context.h mode.h

screen.o	:	$(INCL) mode.h context.h

symbol.o	:	$(INCL) ptrace.h

trace.o		:	$(INCL) mode.h context.h

tty.o		:	$(INCL)
#get_tree.o	:	${INCL} context.h
#		cc -c -O -w ${CFLAGS} get_tree.c
#lib_read.o	:	${SHARE}/lib_read.c
#		cc -c -O -w ${CFLAGS} ${SHARE}/lib_read.c
#record_man.o	:	${SHARE}/record_man.c
#		cc -c -O -w ${CFLAGS} ${SHARE}/record_man.c
#std.o	:	${SHARE}/std.c
#		cc -c -O -w ${CFLAGS} ${SHARE}/std.c
#rec_sizes.o	:	${SHARE}/rec_sizes.c
#		cc -c -O -w ${CFLAGS} ${SHARE}/rec_sizes.c

