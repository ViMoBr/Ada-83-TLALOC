#

/*
 *	screen management routines
 */

/*
 *	include files
 */

#include "debug.h"
#include "mode.h"
#include "context.h"
#include <sgtty.h>

/*
 *	structures
 */

MODE	modes[] = {
	"main"	,1,
	"run"	,1,
	"trace"	,1,
	"break"	,1,
	"delete",1,
	"print"	,1,
	""	,0
};
MODE	*c_mode = &modes[6];

struct sgttyb	ttymode;

int		size_display;
static int	cbreak = FALSE;


/*
 *	print error message
 */

sysdb_error(a,b)
char *a,*b;
{
	savecrs();
	cursorto(3,1);
	settty();
	bold("error ");
	fprintf(stderr,a,b);
	swrite(" ,    type <return>");
	while (fgetc(stdin) != '\n')
		while (fgetc(stdin) != '\n')
			;
	clrline(3);
	resetcrs();
}

/*
 *	print mode and menu
 */

mode(mode_nr)
int mode_nr;
{
	int flag;

	rmprompt();
	clrto(1,19);
	bold("mode    ");
	swrite(modes[mode_nr].mode_name);
	flag = c_mode->mode_flag;
	c_mode = &modes[mode_nr];
	
	if (c_mode->mode_flag) {
		if (flag) {
			clrmenu();
			menu(c_mode->mode_name);
		}
		else
			small_display();
	}
	else
		if (flag)
			big_display();
}

/*
 *	clear or display current menu
 */

toggle()
{
	c_mode->mode_flag = (c_mode->mode_flag + 1) % 2;
	if (c_mode->mode_flag)
		small_display();
	else
		big_display();
}

/*
 *	enlarge scrolling region
 */

big_display()
{
	clines(4,3);
	display(5);
}

/*
 *	reduce scrolling region
 */

small_display()
{
	clines(4,3);
	menu(c_mode->mode_name);
	display(7);
}

display(x)
int x;
{
	size_display = x;
	scroll(x,24);
}

to_display()
{
	cursorto(size_display,1);
}


clrmenu()
{
	clines(4,2);
}

/*
 *	print program state
 */

state(s)
char *s;
{
	cursorto(2,20);
	bold("state   ");
	swrite(s);
}

/*
 *	print program name
 */

program(s)
char *s;
{
	clrfrom(1,20);
	bold("program ");
	swrite(s);
}

/*
 *	print current command
 */

ccommand(s)
char *s;
{
	rmprompt();
	cursorto(2,1);
	bold("command ");
	swrite(s);
}

/*
 *	print executing unit.body
 */

in_body(body)
BODY_P body;
{
	cursorto(2,40);
	bold("in  ");
	pr_name(body);
}

/*
 *	print current unit
 */

cunit(s)
char *s;
{
	clrfrom(1,40);
	bold("use ");
	swrite(s);
}

/*
 *	print string s on standard out
 */

swrite(s)
char *s;
{
	fprintf(stdout,"%s",s);
}

/*
 *	clear command line
 */

rmcommand()
{
	clrto(2,18);
	cursorto(2,1);
}

/*
 *	clear y lines, starting from line x
 */

clines(x,y)
int x,y;
{
	for ( ; y; y--)
		clrline(x + y -1);
}

/*
 *	print message in reverse video
 */

message(s1,s2)
char *s1,*s2;
{
	rmprompt();
	rev_video(s1);
	swrite(s2);
}

/*
 *	print a prompt
 */

prompt(s)
char *s;
{
	rmprompt();
	bold(s);
}

rmprompt()
{
	clrline(3);
}

/*
 *	get tty mode
 */

gettty()
{
	gtty(0,&ttymode);
}

/*
 *	set tty in cbreak and -echo mode
 */

settty()
{
	if (cbreak)
		return;
	ttymode.sg_flags |= CBREAK;
	ttymode.sg_flags &= ~ECHO;
	ttymode.sg_flags &= ~XTABS;
	stty(0,&ttymode);
	cbreak = TRUE;
}

/*
 *	reset tty to -CBREAK and ECHO mode
 */

resettty()
{
	if (!cbreak)
		return;
	ttymode.sg_flags &= ~CBREAK;
	ttymode.sg_flags |= ECHO;
	ttymode.sg_flags |= XTABS;
	stty(0,&ttymode);
	cbreak = FALSE;
}

