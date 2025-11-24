/*
 * package unix
 *
 * h/unix.h
 */
#define	CPI	4

#define	BPC	8
#define	BPI	(BPC * CPI)

#define	BMASK	01
#define	CMASK	0377

#define	FNL	50
#define	IDL	50

typedef	char	*t_tag;
typedef	char	*string;

typedef	string	filename;

typedef	char	byte;

typedef	short	t_index;

typedef	byte	char_value;

typedef	short	bool;
#define	FALSE	0
#define	TRUE	1


#define	NULL	0


/*
 * end package unix
 */
