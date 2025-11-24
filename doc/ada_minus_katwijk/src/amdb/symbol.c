#

/*
 *	routines for handling the symbol table
 */

/*
 *	include files
 */

#include "debug.h"
#include "ptrace.h"
#include <filehdr.h>
#include <aouthdr.h>
#include <syms.h>
#include <scnhdr.h>

/*
 *	structures
 */

struct filehdr		 file;
struct aouthdr		 aout;

/*
 *	scalars/pointers
 */

long			symcount;
long		 	name_start;
int			wrflag 	= FALSE;
short			entryins;
short			trap = BPTRAP;
struct syment		*symtable;
FILE 			*in = NULL;

/*
 *	initialise() reads the header of an executable
 *	file and stores the information for later use;
 *	Before trying to read it is checked if a
 *	previous load file is still open, and if so it
 * 	is rewritten and closed.
 */

initialise(unit)
LUN *unit;
{
	char *lfile;


	/*
	 *  now open and read the headers
	 */

	lfile = exec_name ( unit);
	if (!openfile(lfile)) {
		sysdb_error("cannot open load file");
		return FALSE;
	}

	if (fread(&file,sizeof file,1,in) != 1) {
		sysdb_error("error reading fileheader");
		return FALSE;
	}
	if (fread(&aout,sizeof aout,1,in) != 1) {
		sysdb_error("error reading aoutheader");
		return FALSE;
	}

	/*
	 *  because the symbol table is searched quite
	 *  often the entries are read and stay in core
	 */

	in_symbols();
	return (setcontext(unit,symtable,&file,&aout));
}

/*
 *	read the symboltable incore
 */

in_symbols()
{
	name_start=file.f_symptr+(sizeof(struct syment))*file.f_nsyms;
	fseek(in,file.f_symptr,0);
	if ((symtable=(struct syment *)malloc((sizeof(struct syment))*file.f_nsyms))==0) {
		sysdb_error("no core available for symbol_table");
		bye ();
	}
	if (fread(symtable,sizeof(struct syment),file.f_nsyms,in)!=file.f_nsyms) {
		sysdb_error("error reading symbol_table");
		bye ();
	}
}

/*
 *	symequal(p,s) checks whether the symbol
 *	name p equals the string s.
 */

symequal(p,s)
register char *p,*s;
{
	if ((*p=='~') || (*p=='_')) p++;
	while (*p++==*s++)
		if ((*p=='\0') || (*s=='\0'))
			return TRUE;
	return FALSE;
}

/*
 *	REWIND()
 *	resets the readpointer to the beginning
 *	of the symbolbuffer, i.e. after the 
 *	symboltable entries.
 */

rewind()
{
	fseek(in,name_start,0);
}

/*
 *	this routine searches the addresses of fixed
 *	symbols and if the symbols are text symbols
 *	their corresponding machine instructions.
 */

prepare(breaks)
struct deb_symbol *breaks;
{
	register struct deb_symbol *debug;
	register struct syment     *symbol;
	register int		    nr;
	register long 		    symcount;
		 long		    offset;
		 char		   *sym_name;
		 char 		    symbuf[SYMLN];

	if (wrflag)
		return;		/* apparently run before */

	/* set all addresses to zero */
	
	nr=0;
	for (debug=breaks;*debug->deb_name;debug++) {
		debug->deb_address.whole=0;
		nr++	;
	}

	/* search for the addresses */

	symbol=symtable;
	symcount=file.f_nsyms;
	rewind();	/* fseek to beginning of symbolbuffer */
	while ((nr>0) && (symcount>0)) {

		/* read the symbolstring */
		for (sym_name=symbuf;*sym_name=fgetc(in);sym_name++)
			;

		for (debug=breaks;*debug->deb_name;debug++) {
			if (debug->deb_address.whole==0) {
				if (symequal(symbuf,debug->deb_name)) {
					debug->deb_address.whole=(int )symbol->n_value;
					nr--;
					break;
				}
			}
		}
		symcount--;
		symbol++;
	}


	/* store a breakpoint instruction at the entrypoint */

	offset=sizeof(file) + sizeof(aout) + sizeof(struct scnhdr)*file.f_nscns;
	fseek(in,offset + aout.entry,0);
	fread(&entryins,sizeof(entryins),1,in);
	fseek(in,offset + aout.entry,0);
	fwrite(&trap,sizeof(trap),1,in);

	wrflag=TRUE;
}



/*
 *	this routine searches the symbol table for the addresses of symbols
 *	specified in struct db_syms and collects their addresses
 */

sym_addrs (dbs)
struct db_syms *dbs;
{
	register struct db_syms	   *pdb;
	register struct syment     *symbol;
	register int		    nr;
	register long 		    symcount;
		 char		   *sym_name;
		 char 		    symbuf[SYMLN];


	/* set all addresses to zero */
	
	nr=0;
	for (pdb = dbs ;*pdb->db_symname ;pdb++) {
		pdb->db_address.whole=0;
		nr++	;
	}

	/* search for the addresses */

	symbol=symtable;
	symcount=file.f_nsyms;
	rewind();	/* fseek to beginning of symbolbuffer */
	while ((nr>0) && (symcount>0)) {

		/* read the symbolstring */
		for (sym_name=symbuf;*sym_name=fgetc(in);sym_name++)
			;

		for (pdb = dbs; *pdb->db_symname; pdb++) {
			if (pdb->db_address.whole==0) {
				if (symequal(symbuf,pdb->db_symname)) {
					pdb->db_address.whole=(int )symbol->n_value;
					nr--;
					break;
				}
			}
		}
		symcount--;
		symbol++;
	}


}



restore()
{
	if (wrflag) {
		fseek(in,aout.entry,0);
		fwrite(&entryins,2,1,in);
		wrflag=FALSE;
	}
}


closefile()
{
	fclose(in);
	in=NULL;
}


openfile(load)
char *load;
{
	in=fopen(load,"rw");
	if (in==NULL)
		return FALSE;
	return TRUE;
}




/*
 *	reads a symbol entry from the symboltable and reads
 *	the symbolname into a static buffer.
 */

char * readsym(offset)
long offset;
{
	static char symbuf[SYMLN];
	char *p;

	fseek(in,name_start+offset,0);
	for (p=symbuf;*p=getc(in);p++)
		;
	return(symbuf);
}





/*
 *	wait for the debugged process to start its
 *	execution. Because a breakpoint is set  at
 *	the entry point the debugger receives a signal
 *	which will be a signal to set the program 
 *	state to running and to clear the display.
 */

entrywait(pid,breaks)
int *pid;
register struct deb_symbol *breaks;
{
	if (dowait(pid)) {
		/* set breakpoints in the core image of the process */

		for (++breaks ;*breaks->deb_name;breaks++)  {
			breaks->deb_ins=(short) ptrace(RDINS,*pid,breaks->deb_address.whole,0);

			ptrace(WRINS,*pid,breaks->deb_address.whole,trap);
		}

		/* rewrite entrypoint in process image and continue */

		ptrace(WRINS,*pid,aout.entry,entryins);
		set_line(MY_DELETE);
		state("running    ");
		clrfrom(2,40);
		display (7);
		to_display ();
		savecrs ();
		clrdisplay();
		ptrace(CONTINUE,*pid,aout.entry,0);
	}
}
