SHELL	= /bin/sh
AS	= /bin/as
AR	= ar
CC	= cc
LD	= ld
LIB	= /usr/lib
CFLAGS	= -O -OI -X -DTG_68000 $(DEBUG) $(PRINT)
# WARNING: do not compile wait.c with OI flag
C2FLAGS	= -O -X -DTG_68000 $(DEBUG) $(PRINT)
PRINT	=
DEBUG	= -DDEBUG

LIBFILES	=	adb_break.o  	\
			and.o		\
			assign.o     	\
			attributes.o	\
			check.o      	\
			catcc.o		\
			catcs.o		\
			catsc.o		\
			catss.o		\
			dats.o		\
			equal.o      	\
			free.o       	\
			ge.o         	\
			gr.o         	\
			hardret.o   	\
			in.o         	\
			indcheck.o   	\
			indexing.o   	\
			io.o         	\
			largqual.o   	\
			le.o         	\
			less.o       	\
			not.o		\
			or.o		\
			params.o     	\
			printdesc.o  	\
			realsize.o   	\
			rt_decl.o    	\
			run_error.o  	\
			scc.o		\
			slice.o      	\
			swap.o		\
			start_t.o	\
			unco_as.o	\
			wait.o

HFILES		=	../h/rt_types.h	\
			../h/rt_defs.h	\
			dats.h		\
			cnames.h    	\
			names.h     	

CPPFILES	=	dasrt0.cpp	\
			dasexit.cpp

SFILES		=	adb_break.s  	\
			and.s		\
			catcc.s		\
			catsc.s		\
			catcs.s		\
			catss.s		\
			hardret.s	\
			not.s		\
			or.s		\
			swap.s

CFILES		=	assign.c     	\
			attributes.c	\
			check.c      	\
			dats.c		\
			equal.c      	\
			free.c       	\
			in.c         	\
			indcheck.c   	\
			indexing.c   	\
			io.c         	\
			largqual.c   	\
			params.c     	\
			printdesc.c  	\
			realsize.c   	\
			rt_decl.c    	\
			run_error.c  	\
			scc.c		\
			start_t.c	\
			slice.c		\
			wait.c

SRC	=	$(CFILES) $(HFILES)

.SUFFIXES:	.o .c .s .i .l .y

.c.o:
	$(CC) -c $(CFLAGS) $<

.c.s:
	$(CC) -S $(CFLAGS) $<

.c.i:
	$(CC) -P $(CFLAGS) $<

all:	daslib.a dasrt0.s dastaskrt0.s dasexit.o

dastaskrt0.s:	dasrt0.cpp names.h
		/lib/cpp -DTASKING dasrt0.cpp | sed -e '/^$$/d' -e '/^#/d' > dastaskrt0.s

dasrt0.s:	dasrt0.cpp names.h
		/lib/cpp dasrt0.cpp | sed -e '/^$$/d' -e '/^#/d' > dasrt0.s

dasexit.s:	dasexit.cpp names.h
		/lib/cpp dasexit.cpp | sed -e '/^$$/d' -e '/^#/d' > dasexit.s

dasexit.o:	dasexit.s
		$(AS) -o dasexit.o dasexit.s

daslib.a:	$(LIBFILES) std_pb.o
		$(AR) r daslib.a $(LIBFILES) std_pb.o

std_pb.o:	../standard/std_pb.c
		cc -c ../standard/std_pb.c

rt_decl.o:	../h/rt_types.h ../h/rt_defs.h
		$(CC) -c $(CFLAGS) -DRT_DECL $<

c_handler.o:

wait.o:		dats.h
		$(CC) -c -$(C2FLAGS) $<

indexing.o:

indcheck.o:

assign.o:

break.o:

craise.o:

dats.o:

hardret.o:

largqual.o:

tags:	$(SRC)
	ctags    $(SRC) > meldtags 2>&1

lpr:
	pr $(CFILES) | redcomm -c | lpr
	pr $(SFILES) $(CPPFILES) | redcomm -u | lpr

cleanup:
	rm -f  dasrt0.s dasexit.s dasexit.o $(LIBFILES) daslib.a tags xtags

install:	all
	cp daslib.a  $(LIB)/daslib.a
	cp dasrt0.s  $(LIB)/dasrt0.s
	cp dastaskrt0.s  $(LIB)/dastaskrt0.s
	cp dasexit.o $(LIB)/dasexit.o
	cp dasload   $(LIB)/dasload
