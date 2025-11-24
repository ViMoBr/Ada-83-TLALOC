SYSTEM = PC
CFLAGS = -ggdb -c -D${SYSTEM} 
DAPSE = ../das
HEADERS = ../h
OBJS = cungen.o view1.o view2.o view3.o def_lib.o compload.o\
	libr.o createmaster.o kapse.o lunlist.o dapse_int.o \
	arglist.o
PROGS = adarm newadalib rmadalib adaload printlib printview printcdb
AR	= /usr/bin/ar

viewlib.a	:	${OBJS}
		ar vr viewlib.a $?; ranlib viewlib.a

all		:	adarm adaload newadalib \
			printlib rmadalib printview printcdb
			
cleanup		:
		-rm -f ${PROGS} *.o core viewlib.a

libfil		:	libfil.o viewlib.a
		cc -o libfil libfil.o viewlib.a

adarm		:	adarm.o viewlib.a
		cc -o adarm adarm.o viewlib.a

newadalib	:	newadalib.o viewlib.a
		cc -o newadalib newadalib.o viewlib.a

rmadalib	:	rmadalib.o viewlib.a
		cc -o rmadalib rmadalib.o viewlib.a

printcdb	:	printcdb.o
		cc -o printcdb printcdb.o viewlib.a

printlib	:	viewlib.a printlib.o
		cc -o printlib printlib.o viewlib.a

printview	:	viewlib.a printview.o libr.h macros.h consts.h 
		cc -o printview printview.o viewlib.a

libext		:	libext.o viewlib.a
		cc -o libext libext.o viewlib.a

install		:	${PROGS}
		cp $? /usr/local/bin/

cungen.o	:	libr.h macros.h consts.h cungen.h
		cc ${CFLAGS}  cungen.c

libr.o	:	libr.h macros.h consts.h
		cc ${CFLAGS}  libr.c

createmaster.o	:	libr.h macros.h consts.h
		cc ${CFLAGS}  createmaster.c

kapse.o	:	libr.h macros.h consts.h
		cc ${CFLAGS}  kapse.c

lunlist.o	:	libr.h macros.h consts.h
		cc ${CFLAGS}  lunlist.c

compload.o	:	libr.h macros.h consts.h
		cc ${CFLAGS}  compload.c

def_lib.o	:	libr.h macros.h consts.h
		cc ${CFLAGS}  def_lib.c

dapse_int.o	:	libr.h macros.h consts.h
		cc ${CFLAGS}  dapse_int.c

view1.o	:	libr.h macros.h consts.h cungen.h ${HEADERS}/tree.h
		cc ${CFLAGS}  -I${HEADERS} view1.c

view2.o	:	libr.h macros.h consts.h 
		cc ${CFLAGS}  -I${HEADERS} view2.c

view3.o	:	libr.h macros.h consts.h cdb.h
		cc ${CFLAGS}  -I${HEADERS} view3.c

getcun	:	getcun.o viewlib.a
		cc getcun.o viewlib.a -o getcun

freecun	:	freecun.o viewlib.a
		cc freecun.o viewlib.a -o freecun

printcdb.o	:printcdb.c libr.h macros.h consts.h cdb.h

printview.o	:printview.c libr.h macros.h consts.h

rmadalib.o	:rmadalib.c libr.h macros.h consts.h

newadalib.o	:newadalib.c libr.h macros.h consts.h

adaload.o	:adaload.c libr.h macros.h consts.h

adaload	:	adaload.o viewlib.a
		cc -o adaload adaload.o viewlib.a -ll

newadalib.o	:	libr.h macros.h consts.h
		cc ${CFLAGS} -I${HEADERS} newadalib.c

printcdb.o	:	cdb.h consts.h
		cc ${CFLAGS} printcdb.c

printlib.o	:	libr.h macros.h consts.h
		cc ${CFLAGS} -I${HEADERS} printlib.c

