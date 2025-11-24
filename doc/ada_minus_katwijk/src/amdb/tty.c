#

/*
 *	tty.c contains all the terminal dependent functions
 */

/*
 *	include files
 */

#include "debug.h"

/*
 *	print the string s in bold characters
 */

bold(s)
char *s;
{
	fprintf(stderr,"\033[1m%s\033[m",s);
}

/*
 *	print the string s in reverse video
 */

rev_video(s)
char *s;
{
	fprintf(stderr,"\033[7m%s\033[0m",s);
}


/*
 *	save cursor position
 */

savecrs()
{
	fputc('\033',stderr);
	fputc('7',stderr);
}


/*
 *	restore cursor position
 */

resetcrs()
{
	fputc('\033',stderr);
	fputc('8',stderr);
}

/*
 *	clear screen with cursor in home position
 */

cls()
{
	fprintf(stderr,"\033[H\033[J");
}


/*
 *	move cursor to line x, column y
 */

cursorto(x,y)
int x,y;
{
	fprintf(stderr,"\033[%d;%dH",x,y);
}


/*
 *	erase line x
 */

clrline(x)
int x;
{
	cursorto(x,1);
	fprintf(stderr,"\033[2K");
}


/*
 *	set scrolling region to top and bottom
 */

scroll(top,bottom)
int top,bottom;
{
	fprintf(stderr,"\033[%d;%dr",top,bottom);
}


/*
 *	move cursor to begin of next line
 */

newline()
{
	fputc('\n',stderr);
}
	


/*
 *	clear line x from position y
 */

clrfrom(x,y)
int x,y;
{
	cursorto(x,y);
	fprintf(stderr,"\033[0K");
}


/*
 *	clear line x to position y
 */

clrto(x,y)
int x,y;
{
	cursorto(x,y);
	fprintf(stderr,"\033[1K");
	cursorto(x,1);
}



/*
 *	clear display screen
 */

clrdisplay()
{
	to_display();
	fprintf(stderr,"\033[J");
}
