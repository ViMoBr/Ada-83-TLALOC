CS	= .
CI	= .
UI	= /usr/include
O	= ../obj
#IFLAGS	= -I$(CI) -I$(UI) -I$(O) 
#
#	MENU				851001 EVK
#	@(#)MENU	1.3	86/09/05
#
#

ROOT =		/
TARGET =	veyacc
DIR =		usr/bin

SHELL =		/bin/sh
CFLAGS =	-O

ALLOBJS =	$(O)/y1.o $(O)/y2.o $(O)/y3.o $(O)/y4.o $(O)/y5.o $(O)/y6.o  \
	$(O)/y7.o $(O)/y8.o 

all :		$(TARGET)
		:

install :	all
		install -s -c $(TARGET) $(ROOT)$(DIR)/$(TARGET)
		:

$(TARGET) :	$(ALLOBJS)
		$(CC) $(CFLAGS) $(ALLOBJS) -o $(TARGET)
		size $(TARGET)

clean :
		/bin/rm -f $(ALLOBJS) $(TARGET) Version.* *.lg


#
#	Stuff to regenerate makefile
#
#

#CI =		include
#CS =		src

SRC =		y1.c y2.c y3.c y4.c y5.c y6.c y7.c y8.c

#I =		-iCI=$(CI)
#S =		-sCS=$(CS)

#makefile :	neverthere
#		-cp makefile .old
#		gendep -m MENU $(I) $(S) $(SRC) > makefile

neverthere :

#
#	Start of machine generated part
#
#



$(O)/y1.o : $(CS)/y1.c $(CI)/dextern.h $(CI)/files.h 
	$(CC) -c $(CS)/y1.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv y1.o $(O)

$(O)/y2.o : $(CS)/y2.c $(CI)/prep.h $(CI)/dextern.h $(CI)/files.h 
	$(CC) -c $(CS)/y2.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv y2.o $(O)

$(O)/y3.o : $(CS)/y3.c $(CI)/dextern.h $(CI)/files.h 
	$(CC) -c $(CS)/y3.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv y3.o $(O)

$(O)/y4.o : $(CS)/y4.c $(CI)/dextern.h $(CI)/files.h 
	$(CC) -c $(CS)/y4.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv y4.o $(O)

$(O)/y5.o : $(CS)/y5.c $(CI)/prep.h $(CI)/dextern.h $(CI)/files.h 
	$(CC) -c $(CS)/y5.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv y5.o $(O)

$(O)/y6.o : $(CS)/y6.c $(CI)/prep.h $(CI)/dextern.h $(CI)/files.h 
	$(CC) -c $(CS)/y6.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv y6.o $(O)

$(O)/y7.o : $(CS)/y7.c $(CI)/dextern.h $(CI)/files.h 
	$(CC) -c $(CS)/y7.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv y7.o $(O)

$(O)/y8.o : $(CS)/y8.c $(CI)/dextern.h $(CI)/files.h 
	$(CC) -c $(CS)/y8.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv y8.o $(O)
