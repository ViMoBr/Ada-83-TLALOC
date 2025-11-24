#include <stdio.h>

int is_letter (x)
register int x;
{
	return ('A' <= x && x <= 'Z') ||
	       ('0' <= x && x <= '9');
}

char low (c)
register char c;
{
	if ('A' <= c && c <= 'Z')
	   return c - 'A' + 'a';
}

char *lower (s)
register char *s;
{
	register char *v = s;
	while (*s != 0)
	   { *s = low (*s);
	     s ++;
	   }

	return v;
}

char *next_word () {
register int a;
static char s [20];
register char *b = &s [0];

a = getchar ();
while (!is_letter (a))
	{ if (a == -1)
	     return NULL;
	  a = getchar ();
	}

while (is_letter (a))
	{*b ++ = a;
	  a = getchar ();
	}

	*b = 0;
return s;
}

main () {

FILE *defs, *tokens, *sizes;

register int i;
register char *s;

i = 0;
defs	= fopen ("nodes.h", "w");
tokens	= fopen ("../share/tokens.c", "w");
fprintf (tokens, "char *token [] = {\n");
sizes	= fopen ("../share/rec_sizes.c", "w");

fprintf (sizes, "#include	\"../h/unix.h\"\n");
fprintf (sizes, "#include	\"../h/tree.h\"\n");
fprintf (sizes, "byte size [] = {\n");
while ((s = next_word ()) != NULL)
	{ fprintf (defs, "#define	X%s	%d\n", s, i++);
	  fprintf (tokens, "\"%s\",\n",s);
	  fprintf (sizes, "sizeof (struct _%s),\n", lower (s));
	}

fprintf (tokens, "\"NULL\"	};\n");
fprintf (sizes, "NULL	};\n");
fclose (defs);
fclose (tokens);
fclose (sizes);
}

