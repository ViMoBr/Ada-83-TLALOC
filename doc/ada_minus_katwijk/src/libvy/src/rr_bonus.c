/*
 *	@(#)rr_bonus.c	1.1	86/08/18
 *
 *	rr_bonus - return bonus for shifting sym after pos tokens
 *	from the window have been shifted.
 *
 *	original - this function computes a bonus as function of the
 *	amounts of symbols sym that, after performing the repair on
 *	position pos, can be shifted before running into the next error.
 *	The bonus value is subtracted from the computed cost.
 */
/* LINTLIBRARY */

/* ARGSUSED */
short
rr_bonus (sym, pos)
short	sym;
short	pos;
{
	return (short) (2 * pos);
}
