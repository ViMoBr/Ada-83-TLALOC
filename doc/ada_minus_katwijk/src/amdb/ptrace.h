#
/*
 *	definitions for the ptrace system call
*/


/*
 *	definitions
 */


#define USERPC		 2*(512-1)
#define USERSP		 2*(512-3)
#define USERPS		 2*(512-3)
#define BASE		 2*(512-4)
#define BPTRAP   	   047160	/* reset instruction */

/*
 *	PTRACE requests
 */

#define STRACE		0
#define RDINS		1
#define RDDATA		2
#define	RDREG		3
#define WRINS		4
#define WRDATA		5
#define WRREG		6
#define CONTINUE	7
#define STOP		8
#define STEP		9

#define RESET		20	/* not really a PTRACE request */


/*
 *	union to access the high and low byte of a register
 */

union address {
	int	 whole;
	struct {
		short high;
		short low;
	} byte;
};

/*
 *	structure to describe a breakpoint
 */

struct deb_symbol {
	char		*deb_name;
	int		deb_event;
	union address	deb_address;
	short		deb_ins;
};

/*
 * struct db_sym for usefull symbols from symboltable
 */
struct db_syms
{
	char *db_symname;
	union address db_address;
};
