with system; use system;
package c_lib is
--
--	interface to standard C library
--
--	j van katwijk
--	december 1985
--
--
subtype stream is long;
EOF:	constant 	:= -1;
EOS:	constant character	:= ASCII. NUL;

RABLE:	constant	:= 4;
WABLE:	constant	:= 2;
EABLE:	constant	:= 1;
newline:	constant character	:= ASCII. LF;

subtype xs is string (1 .. 100);	-- sorry

type stat_buffer is record
	st_dev, st_ino:					short;
	st_mode, st_nlink, st_uid, st_gid, st_rdev :	short;
	st_size:					long;
	st_atime, st_mtime, st_ctime:			long;
end record;
type tbuffer is record
	proc_user_time:		long;
	proc_system_time:	long;
	child_user_time:	long;
	child_system_time:	long;
end record;

procedure $abort;

--procedure $times (t: in out tbuffer);
function $atoi (s : string) return long;
function atoi (s : string) return long renames $atoi;

function $atol (s : string) return long;
function atol (s : string) return long renames $atol;

function $time	(x : long := 0) return long;
function time	(x : long := 0) return long renames $time;

--
--	careful, the longs are addresses
--
function $ctime (t : long) return xs;
function ctime  (t : long) return xs renames $ctime;

--	input output functions and procedures
--
--


function $termin	return stream;
function $termout	return stream;

procedure $close	(x : stream);
procedure  close	(x : stream) renames $close;

function $fopen		(x : string;
		         y : string) return stream;
function fopen		(x : string;
			 y : string) return stream renames $fopen;

function $freopen	(x : string;
			 y : string;
			 z : stream) return stream;

function freopen	(x : string;
			 y : string;
			 z : stream) return stream renames $freopen;

function $fdopen	(x : long;
			 y : string) return stream;
function fdopen		(x : long;
			 y : string) return stream renames $fdopen;

function $fread		(x : address;
			 y : long := 1;	-- itemsize
			 z : long := 1;	-- nitems
			 a : stream := $termin) return long;
function fread		(x : address;
			 y : long := 1;	-- itemsize
			 z : long := 1;	-- nitems
			 a : stream  := $termin) return long
					         renames $fread;

function $fwrite	(x : address;
			 y : long := 1;
			 z : long := 1;	-- nitems
			 a : stream  := $termout) return long;
function fwrite		(x : address;
			 y : long := 1;
			 z : long := 1;
			 a : stream  := $termout) return long
						  renames $fwrite;

procedure $fseek	(x : stream;
			 y : long;
			 z : long);
procedure fseek		(x : stream;
			 y : long;
			 z : long) renames $fseek;

function $fgetc	(x : stream := $termin) return long;
function fgetc	(x : stream := $termin) return long
						renames $fgetc;

function $getw	(x : stream := $termin) return long;
function getw	(x : stream := $termin) return long renames $getw;

function $gets	(s : string) return string;
function gets	(s : string) return string renames $gets;

function $fgets	(s : string;
		 n : long;
		 x : stream) return string;
function fgets	(s : string;
		 n : long;
		 x : stream) return string renames $fgets;


procedure $fprintf	(x : stream;
			 f : string;
			 a : $_any_int := 1);
procedure $fprintf	(x : stream;
			 f : string;
			 a : float);

procedure $fprintf	(x : stream;
			 f : string;
			 a, b : $_any_int);


procedure fprintf	(x : stream;
			 f : string;
			 a : $_any_int := 1) renames $fprintf;
procedure fprintf	(x : stream;
			 f : string;
			 a : float) renames $fprintf;
procedure fprintf	(x : stream;
			 f : string;
			 a, b : $_any_int) renames $fprintf;

procedure $fputc	(x :character;
			 y : stream);

procedure fputc		(x : character;
			 y : stream) renames $fputc;

procedure $fputw	(x : long;
			 y : stream);
procedure fputw		(x : long;
			 y : stream) renames $fputw;

function $ungetc	(c : character;
			 s : stream) return character;
function ungetc		(c : character;
			 s : stream) return character renames $ungetc;
function $getenv	(n : string) return string;
function getenv		(n : string) return string renames $getenv;

function $getlogin	             return string;
function getlogin	             return string renames $getlogin;

function $getpass	(s : string) return string;
function getpass	(s : string) return string renames $getpass;

function $getpw		(uid : long;
			 buf : string) return boolean;

function $malloc	(n : long) return address;
function malloc		(n : long) return address renames $malloc;

procedure $free		(n : long);
procedure free		(n : long) renames $free;

function $realloc	(n : address;
			 s : long) return address;
function realloc	(n : address;
			 s : long) return address renames $realloc;

function $calloc	(n : long;
			 e : long) return address;
function calloc		(n : long;
			 e : long) return address renames $calloc;

function $mktemp	(s : string) return string;
function mktemp		(s : string) return string renames $mktemp;

type jmp_buf is array (1 .. 20) of long;
procedure $setjmp (b : jmp_buf);
procedure setjmp	(b : jmp_buf) renames $setjmp;

procedure $longjmp	(b : jmp_buf;
			 v : address);
procedure longjump	(b : jmp_buf;
			 v : address) renames $longjmp;

procedure $sleep	(n : long);
procedure sleep		(n : long) renames $sleep;

procedure $swab		(from:	address;
			 to :	address;
			 n :	long);
procedure swab		(from :	address;
			 to :	address;
			 n :	long) renames $swab;

function $access	(s :	string;
			 m :	long) return integer;

function accessible	(s :	string;
			 m :	long) return integer renames $access;

procedure $stat		(s :	string;
			 b :	out stat_buffer);
procedure stat		(s :	string;
			 b :	out stat_buffer) renames $stat;
procedure $system	(s :	string);
procedure system	(s :	string) renames $system;

function $num_pars	return long;
function num_pars	return long renames $num_pars;

procedure $get_par	(n : long;
			 s : out string;
			 l : out long);
procedure get_par	(n : long;
			 s : out string;
			 l : out long) renames $get_par;

procedure $exit;
end;
