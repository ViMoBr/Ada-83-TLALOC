#define master_fp(x)		(x-> _mfp)
#define library_name(x)		(x-> _libname)

#define is_spec(x)		((x-> real_lun. _flags & BODY) == 0)
#define is_body(x)		(x-> real_lun. _flags & BODY)
#define is_subprogram(x)	(x-> real_lun. _flags & SS)
#define is_package(x)		(x -> real_lun ._flags & PS)
#define is_subunit(x)		(x-> real_lun. _flags & SU)
#define is_generic(x)		(x-> real_lun. _flags & GNRC)

#define is_compiled(x)		(x-> real_lun. _flags & COMPILED)
#define is_loaded(x)		(x-> real_lun. _flags & LOADED)
#define set_loaded(x)		(x-> real_lun. _flags |= LOADED)

#define is_free(x)		(x-> real_lun. _flags & VRIJ)
#define is_occupied(x)		(!is_free (x))
#define set_free(x)		(x-> real_lun. _flags |= VRIJ)
#define set_occupied(x)		(x-> real_lun. _flags &= ~VRIJ)

#define KIND_M	(SB | PS | TS | BODY | SU | GI | GNRC)

#define phy_ident(x)		(x-> real_lun. _plunno)
#define log_ident(x)		(x-> real_lun. _llunno)
#define name_of(x)		(x-> real_lun. _unit_name)
#define kind_of(x)		(x-> real_lun. _flags & KIND_M)

#define wcount(x)		(x-> real_lun. _csc)
#define stcount(x)		(x-> real_lun. _stc)
#define wlist(x,i)		(x-> real_lun. _csv [i])

#define prep_name(x)		(x-> temps. prep_naam)
#define front_name(x)		(x-> temps. frnt_naam)
#define pcc_name(x)		(x-> temps. pcc__naam)
#define opt_name(x)		(x-> temps. opt__naam)
#define ass_name(x)		(x-> temps. ass__naam)
#define load_name(x)		(x-> temps. load_naam)

#define source_name(x)		(x -> real_lun. _names. source. _filename)
#define tree_name(x)		(x -> real_lun. _names. tree. _filename)
#define object_name(x)		(x -> real_lun. _names. object. _filename)
#define exec_name(x)		(x -> real_lun. _names. exec. _filename)
#define secondaries(x)		(x -> real_lun. _names. secs. _filename)

#define source_stamp(x)		(x-> real_lun. _names. source. _stamp)
#define tree_stamp(x)		(x-> real_lun. _names. tree. _stamp)
#define object_stamp(x)		(x-> real_lun. _names. object. _stamp)
#define exec_stamp(x)		(x-> real_lun. _names. exec. _stamp)
#define secs_stamp(x)		(x-> real_lun. _names. secs. _stamp)

/** macros which operate on a loadlist **/

#define head_of(x)	(x-> _unit)	/* returns a LUN */
#define next_of(x)	(x-> _next)	/* returns a loadlist */
#define is_empty(x)	(x == NULL)

#define first_of(x)	(x-> _first)	/* returns a LLIST */
#define last_of(x)	(x-> _last)	/* returns a LLIST */

#define phy_id(x)		(x-> _unit. _plunno)
#define log_id(x)		(x-> _unit. _llunno)
#define tree_file(x)		(x-> _unit. _names. tree. _filename)
#define object_file(x)		(x-> _unit. _names. object. _filename)
#define is_subu(x)		(x-> _unit. _flags & (SU))

/**                                   **/

#define parentmaster(x)		(x -> real_lun. _names. object. _filename)
#define archivefile(x)		(x -> real_lun. _names. tree. _filename)
#define numberofstubs(x)	(x -> real_lun ._csc)
#define currentfile(x)		(x -> currfile)

#define RABLE 4
#define WABLE 2
#define EABLE 1
#define AABLE 0

/* a bug in Unix  if secondaries(x) is "" return is accessable!!!!! */
#define has_secondaries(x)	(!access(secondaries (x), RABLE) && *secondaries(x) != '\0')

#define readable(s)		(ch_access(s, RABLE))
#define writeable(s)		(ch_access(s, WABLE))
#define execable(s)		(ch_access(s, EABLE))
#define reachable(s)		(ch_access(s, AABLE))

#define set_currentfile(x,s)	strncpy (currentfile (x), s, FNAMESIZE)
#define set_libraryname(x,s)	strncpy (library_name (x), s, FNAMESIZE)
