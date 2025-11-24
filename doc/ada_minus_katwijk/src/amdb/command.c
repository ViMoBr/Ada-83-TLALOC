#

/*
 *	screen management and main menu
 */

/*
 *	include files
 */

#include "debug.h"
#include "mode.h"
#include "ptrace.h"
#include "context.h"
#include <sys/types.h>
#include <sys/stat.h>

/*
 *	definitions
 */

#define DEBUGMANUAL	"/das1/adacomp/dasdb/manual"
#define DEBUGMENU	"/das1/adacomp/dasdb/menus"
#define MAX_MENU	10

/*
 *	structures
 */

struct menu_tab
{
	char menu_name[FNAMESIZE];
	char *menu_txt;
} menu_tab[MAX_MENU];


int		quitflg;
int		returnflg;

static char	buffer[80];

/*
 *	main mode
 */

go()
{
	cls();
	program (body_name (st_current));
	cunit (full_body_name (st_current));
	state ("fetched");
	mode(MAINMODE);
	for(;;) {
		quitflg = FALSE;
		switch ( command() ) {
			case 'a' :
				if (after()) {
					run(STEP);
					mode(MAINMODE);
				}
				break;
			case 'b' :
				if ( set(BREAK) )
					mode(MAINMODE);
				break;
			case 'c' :
				cat();
				break;
			case 'd' :
				if ( set(MY_DELETE) )
					mode(MAINMODE);
				break;
			case 'e' :
			case 4   :
				bye();
				break;
			case 12  :
				clrdisplay ();
				break;

			case 'h' :
				help();
				break;
			case 'l' :
				list();
				break;
			case 'm' :
				toggle();
				break;
			case 'q' :
				break;
			case 'r' :
				run(CONTINUE);
				mode(MAINMODE);
				break;
			case 's' :
			        nr_steps = 1;
			        run(STEP);
			        mode(MAINMODE);
				break;
			case 't' :
				if ( set(TRACE) )
					mode(MAINMODE);
				break;
			case 'w' :
				with();
				break;
			case '\n' :
				break;
			default  :
				illegal();
		}
	}
}

illegal() 
{
	resetcrs ();
	sysdb_error("illegal command");
}

/*
 *	help command
 */

help()
{
	char help_page[50];
	char *page;

	if (c_mode -> mode_flag)
	    big_display ();
	ccommand("help");
	for(;;) {
	    sprintf(help_page,"%s/%s.help",DEBUGMENU,c_mode->mode_name);
	    fcat(help_page,0);
	    savecrs ();
	    prompt("enter command name ");
	    page = inline();
	    resetcrs ();
	    if (*page == '\0')
	    	break;
	    sprintf(help_page,"%s/%s.man",DEBUGMANUAL,page);
	    if (! fcat(help_page,0) ) 
	    	sysdb_error("no manual page for %s",page);
	}
	if (c_mode -> mode_flag)
	    small_display ();
}

/*
 *	display menu
 */

menu(s)
char *s;
{
	char menu_file[50];
	char *c;
	short i;
	FILE *menu_fd;

	/*
	 * Kijk of menu al ingelezen is,lees anders in en druk af
	 */

	for (i = 0; i < MAX_MENU ; i++)
	{
             if (menu_tab[i] .menu_name[0] == '\0')
	     {
		 struct stat buf;
		 strcpy (menu_tab[i] .menu_name, s);
	         sprintf(menu_file,"%s/%s",DEBUGMENU,s);
	         menu_fd = fopen(menu_file,"r");
		 fstat (fileno (menu_fd), &buf);
		 menu_tab[i] .menu_txt = (char *) malloc (buf .st_size);
		 c = menu_tab[i] .menu_txt;
	         while ((*c++ = getc(menu_fd)) != EOF );
		 *--c = '\0';
	         fclose(menu_fd);
		 break;
	     }
	     if (strcmp (s, menu_tab[i] .menu_name) == 0)
		 break;
	}
	if (i == MAX_MENU)
	{
	    sysdb_error ("Menu table full,ask help");
	    bye ();
	}

	cursorto(4,1);
	printf ("%s", menu_tab[i] .menu_txt);
}

fcat(file,numbered)
char *file;
{
	FILE *fd;
	char c = ' ';
	register int line = 0;
	register int line_nr = 0;

	if ((fd = fopen(file,"r")) == NULL)
		return FALSE;
	clrdisplay();
	while ((c = getc(fd)) != EOF) {
		ungetc(c,fd);
		if (numbered) 
			fprintf(stdout,"%5d ",++line_nr);
		while ((c = getc(fd)) != '\n') 
			putchar(c);
		newline();
		if (++line == (24 - size_display)) {
			line = 0;
			settty();
			rev_video("MORE");
			c = getc(stdin);
			clrline(24);
			if (c == 'q')
				break;
		}
	}
	fclose(fd);
	savecrs();
	return TRUE;
}

/*
 *	command reads the standard input and returns the first letter
 */

char command()
{
	settty();
	rmcommand();
	prompt("enter command ");
	return fgetc (stdin);
}

/*
 *	read a line from standard input
 */

char *inline()
{
	char c,*p,*s;

	resettty();
	p = buffer;
	while ((c = fgetc(stdin)) != '\n')
		*p++ = c;
	*p = '\0';
	p = buffer;
	while ((*p == ' ') || (*p == '\t'))
		p++;
	s = p;
	while ((*s != ' ') && (*s != '\t') && (*s != '\0'))
		s++;
	*s = '\0';
	lowercase (p);
	return ( p );
}

leavemode()
{
	if (returnflg) {
		returnflg = FALSE;
		return TRUE;
	}
	if (quitflg)
		return TRUE;
	return FALSE;
}

