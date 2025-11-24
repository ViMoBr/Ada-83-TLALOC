   -- C interface, low level
   -- Interface to standard io library
   --
   package unix is
   	type static_string is access string (1 .. 64);
   	subtype stream is long;	-- actual: address
   --
   --	useful constants
   --
   	eof:	constant	:= -1;
   	dlf:	constant	:= character' pos (ASCII. LF);
        dff:    constant        := character' pos (ASCII. FF);
   	eos:	constant	:= character' pos (ASCII. NUL);
   
   	function $termin	return stream;
   	function $termout	return stream;
   	procedure $abort;
   --	function $atof (s:	 string) return float;
   	function $atoi (s:	 string) return integer;
   	function $atol (s:	 string) return long;
   	function $crypt (key:	string;
   		        salt:	string) return static_string;
   	procedure $encrypt (s:	in out string);
   --
   --	cheating
   --	the parameter to the next functions are, in terms of
   --	c a long *, call them with the address attribute
   --	The time function itself is borrowed from unix low-level interfaces
   --
	function $time  (cl:	long := 0) return long;
   	function $ctime (cl:	long) return static_string;
   	type tm is record
   		tm_sec:		long;
   		tm_min:		long;
   		tm_hour:	long;
   		tm_mday:	long;
   		tm_mon:		long;
   		tm_year:	long;
   		tm_wday:	long;
   		tm_yday:	long;
   		tm_isdst:	long;
   	end record;
   	type a_tm is access tm;
   	
   	function $localtim (clock:	long) return a_tm;
   	function $gmtime   (clock:	long := $time (0)) return a_tm;
   	function $asctime  (clock:	a_tm) return static_string;
   	function $timezone (zone:	long;
   		            dst:	long) return static_string;
   
   	function $fclose (s:	stream) return long;
   	procedure $fflush (s:	stream);
   
   	function $fopen (s:	string;
   		         t:	string) return stream;
   	function $freopen (s:	string;
   		           t:	string;
   			   st:	stream) return stream;
   	function $fdopen (f:	integer;
   			  t:	string) return stream;
   
   	function $fread (b:	long;
   		         bs:	integer;	-- buffer size
   		         nitems:	long;	-- number of items
   		         s:	stream) return long;
   	function $fwrite (b:	long;	-- use buffer' address
   		          bs:	integer;	-- buffer size
   		          nitems:	long;	-- number of items
   		          s:	stream) return long;
   	function $fseek (s:	stream;
   		         o:	long;		-- offsdet
   		         ptr:	long) return long;
   	function $ftell (s:	stream) return long;
   
   	function $fgetc  (s:	stream) return long;
   	function $getenv (s:	string) return static_string;
   
   	function $getlogin return static_string;
   	function $getpass (pr:	string) return static_string;
   	function $getpw  (uid:	integer;
   		           s:	string) return long;
   	function $get     (s:	string) return string;
   	function $fgets   (s:	string;
   		           n:	integer;
   		           st:	stream) return static_string;
   	function $malloc (n:	long) return long;	-- address
   
   	procedure $free  (n:	long);	-- ...'address
   	procedure $mktemp (s:	in out string);
   
   	procedure $fputc  (c:	character;
   		           s:	stream);
   	procedure $fputw  (d:	long;
   		           s:	stream);
   
   	procedure $fputs  (s:	string;
   		          st:	stream);
   	procedure $sleep (d:	long);
   	procedure $swab  (from, to:	long;	-- read: ...'address
   		          nb:	long);
   	function $system (s:	string) return long;
   	function $ttyname (fd:	long) return static_string;
        function $ttyslot (fd:  long) return long;
   	procedure $ungetc  (c:	long;
   		           st:	stream);
   end;
