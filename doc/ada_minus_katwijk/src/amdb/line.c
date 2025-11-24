#

/*
 *	routines for line_break control
 */

/*
 *	include files
 */

#include "debug.h"
#include "context.h"
#include "ptrace.h"

/*
 *	scalars
 */

static LLIST		*unit;
FILE			*unitfd;

static int		l_line;
static char		_line[256];
bool			status;

/*
 * screen modes
 */

#define NORMAL 0
#define BOLD 1
#define SET_BOLD printf ("\033[1m");
#define SET_NORMAL printf ("\033[0m");



/*
 *	line_break() 
 */

line_break()
{
	int line,i;

	if (stepflg)
		if (--nr_steps == 0) {
			stepflg = FALSE;
			set_break(cur_body->b_event[LINES]);
			if (contextflg)
				i = SHOW;
			else
				i = BREAK;
		}
		else
			i = MY_DELETE;
	else 
		i = cur_body->b_event[LINES];

	switch(i) {
		case SHOW  :
			contextflg = TRUE;
			pr_context();
			breakflg = TRUE;
			break;
		case BREAK :
			breakflg=TRUE;
		case TRACE :
			lineout(line_no());
		case MY_DELETE :
			if (!breakflg && !intflg)
				proceed(CONTINUE);
			else
				contextflg = TRUE;
	}
}

/*
 *	lineout() prints the executed source line.
 */

lineout(line_no)
{
	char *full_body_name();
	char *source;
	register	char *c;
	register int cc;

	if (cur_body == &bodylist)
	{
	   printf ("line break not within body\n");
	   return;
	}
	if (cur_body -> b_bodylun != unit) {
		lineclose();
		source = source_file ( cur_body -> b_bodylun);
		if ((unitfd = fopen(source,"r")) == NULL && *source != 0) 
		{
		   sysdb_error ( "cannot access source: %s of %s", source, full_body_name ( cur_body));
			return;
		}
		unit = cur_body -> b_bodylun;
	}

	/* display current unit and line number executed */
	newline();
	if (line_no <= 0)
	{
	   sysdb_error ("illegal line number %d", line_no);
	   return;
	}
	printf ("%s", source_file (cur_body -> b_bodylun));
	printf(" : %d",line_no);
	newline();

	if (line_no == l_line) {
		printf("%s",_line);
		return;
	}

	if (line_no < l_line) {
		fseek(unitfd,0,0);
		l_line=0;
	}

	skip_line(unitfd,(line_no - l_line) - 1);

	c= _line;
	while ((cc = fgetc(unitfd)) != '\n')
	{
	      if (cc == EOF)
	      {
		 sysdb_error ("illegal linenr %d\n", line_no);
		 break;
	      }
	      *c = cc;
	      fputc(*c++,stdout);
	}
	*c='\0';
	newline();
	l_line=line_no;
}

lineclose()
{
	if (unit) {
		fclose(unitfd);
		unit=0;
	}
	l_line=0;
}

pr_context()
{
	register int		line , i;
	char			*source;
	FILE			*fd;
	LUN			unit;

	ccommand("context");
	if (!contextflg) 
	{
		resetcrs ();
		sysdb_error("not a statement executed");
		return;
	}

	if (cur_body == &bodylist)
	{
	   printf ("line break not within body\n");
	   return;
	}
	source = source_file (cur_body -> b_bodylun);
	if ((fd = fopen(source,"r")) == NULL)  {
		sysdb_error ( "cannot access source of %s", full_body_name ( cur_body));
		return;
	}
	clrdisplay();
	line = line_no();
	if (line <= 0)
	{
	   sysdb_error ("illegal line number %d", line);
	   return;
	}
	i = (23 - size_display)/2;
	if ( line > (i + 1)) {
		skip_line(fd,line - (i + 1));
		pr_line(fd,i, NORMAL);
	}
	else
		pr_line(fd,line - 1, NORMAL);
	pr_line(fd,1, BOLD);
	pr_line(fd,i, NORMAL);
	fclose(fd);
	savecrs();
}

skip_line(fd,lines)
FILE *fd;
int lines;
{
	while (lines-- > 0)
		while (fgetc(fd) != '\n')
			;
}

pr_line(fd,lines, mode)
FILE *fd;
int lines, mode;
{
	char c;

	settty ();
	if (mode == BOLD)
	    SET_BOLD;
	while (lines-- >  0) {
		while ((c = fgetc(fd)) != EOF) {
			putchar(c);
			if (c == '\n')
				break;
		}
		if (c == EOF)
			break;
	}
	if (mode != NORMAL)
	    SET_NORMAL;
}
