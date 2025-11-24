CS	= src
UI	= /usr/include
O	= obj
IFLAGS	= -I$(UI) -I$(O) 
#
#	MENU				851001 EVK
#	@(#)MENU	1.8	86/09/11
#
#

ROOT =		/
TARGET =	libvy.a
DIR =		home/adacomp/lib

AR =		ar
CC =		gcc
SHELL =		/bin/sh
CFLAGS =	-ggdb -O

ALLOBJS =	$(O)/creat_val.o $(O)/del_symbol.o $(O)/main.o $(O)/rr_bonus.o  \
	$(O)/rr_insert.o $(O)/rr_skip.o $(O)/rr_usermess.o  \
	$(O)/syntax_error.o $(O)/termfun.o $(O)/token.o $(O)/yyerror.o  \
	$(O)/yylino.o 

all :		$(TARGET)
		:

install :	all
		cp  $(TARGET) $(ROOT)$(DIR)/$(TARGET)
		:

$(TARGET) :	$(ALLOBJS)
		$(AR) cr $(TARGET) $(ALLOBJS)
		:

clean :
		/bin/rm -f $(ALLOBJS) $(TARGET) Version.* *.lg


#
#	Stuff to regenerate makefile
#
#

CS =		src

SRC =		\
		creat_val.c \
		del_symbol.c \
		main.c \
		rr_bonus.c \
		rr_insert.c \
		rr_skip.c \
		rr_usermess.c \
		syntax_error.c \
		termfun.c \
		token.c \
		yyerror.c \
		yylino.c

S =		-sCS=$(CS)
#
#makefile :	neverthere
#		-cp makefile .old
#		gendep -m MENU $(S) $(SRC) > makefile
#
#neverthere :
#
#
#	Start of machine generated part
#
#



$(O)/creat_val.o : $(CS)/creat_val.c 
	$(CC) -c $(CS)/creat_val.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv creat_val.o $(O)

$(O)/del_symbol.o : $(CS)/del_symbol.c 
	$(CC) -c $(CS)/del_symbol.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv del_symbol.o $(O)

$(O)/main.o : $(CS)/main.c 
	$(CC) -c $(CS)/main.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv main.o $(O)

$(O)/rr_bonus.o : $(CS)/rr_bonus.c 
	$(CC) -c $(CS)/rr_bonus.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv rr_bonus.o $(O)

$(O)/rr_insert.o : $(CS)/rr_insert.c 
	$(CC) -c $(CS)/rr_insert.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv rr_insert.o $(O)

$(O)/rr_skip.o : $(CS)/rr_skip.c 
	$(CC) -c $(CS)/rr_skip.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv rr_skip.o $(O)

$(O)/rr_usermess.o : $(CS)/rr_usermess.c 
	$(CC) -c $(CS)/rr_usermess.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv rr_usermess.o $(O)

$(O)/syntax_error.o : $(CS)/syntax_error.c 
	$(CC) -c $(CS)/syntax_error.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv syntax_error.o $(O)

$(O)/termfun.o : $(CS)/termfun.c 
	$(CC) -c $(CS)/termfun.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv termfun.o $(O)

$(O)/token.o : $(CS)/token.c 
	$(CC) -c $(CS)/token.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv token.o $(O)

$(O)/yyerror.o : $(CS)/yyerror.c 
	$(CC) -c $(CS)/yyerror.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv yyerror.o $(O)

$(O)/yylino.o : $(CS)/yylino.c 
	$(CC) -c $(CS)/yylino.c $(CFLAGS) $(IFLAGS) $(DFLAGS)
	mv yylino.o $(O)
