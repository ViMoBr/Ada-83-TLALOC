--
--	input/output package for Ada-  compiler
--
--	j van katwijk
--	september 1987
--
package io_exceptions is
	status_error:	exception;
	mode_error:	exception;
	name_error:	exception;
	use_error:	exception;
	device_error:	exception;
	end_error:	exception;
	data_error:	exception;
	layout_error:	exception;
	not_yet_implemented:	exception;
end io_exceptions;

--	TEXT_IO according to LRM
--	j van katwijk
--
with io_exceptions;
package text_io is
   type file_type is limited private;
   type file_mode is (in_file, out_file);

   type count is range 0 .. 511;
   subtype positive_count is count range 1 .. count' last;
   unbounded : constant count := 0;

   subtype field	is integer range 0 .. 127;
   subtype number_base  is integer range 2 .. 16;

   type type_set is (lower_case, upper_case);

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
   	eos:	constant	:= character' pos (ASCII. NUL);
   
   	function $termin	return stream;
   	function $termout	return stream;
   	procedure $abort;
   	function $atof (s:	 string) return float;
   	function $atoi (s:	 string) return integer;
   	function $atol (s:	 string) return long;
   	function $crypt (key:	string;
   		        salt:	string) return static_string;
   	procedure $encrypt (s:	in out string);
   --
   --	cheating
   --	the parameter to the next functions are, in terms of
   --	c a long *, call them with the address attribute
   --
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
   	function $gmtime   (clock:	long) return a_tm;
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
   	procedure $ungetc  (c:	long;
   		           st:	stream);
   end;

   --- limited file management

   procedure create (file:	in out file_type;
		     mode:	in file_mode;
		     name:	in string;
		     form:	in string    := " ");

   procedure open   (file:	in out file_type;
		     mode:	in file_mode;
		     name:	in string;
		     form:	in string    := " ");

   procedure close  (file:	in out file_type);
   procedure delete (file:	in out file_type);

   function mode    (file:	in file_type) return file_mode;
   function name    (file:	in file_type) return string;
   function is_open (file:	in file_type) return boolean;

   ---

   procedure set_input (file:	in file_type);
   procedure set_output (file:	in file_type);

   function standard_input return file_type;
   function standard_output return file_type;

   function current_input return file_type;
   function current_output return file_type;
--
--
   procedure set_line_length (file:	in file_type;
			      to:	in count);
   procedure set_line_length (to:	in count);
--
   procedure set_page_length (file:	in file_type;
		              to:	in count);

   procedure set_page_length (to:	in count);
--
   function line_length      (file:	in file_type) return count;
   function line_length   return count;
--
   function page_length      (file:	in file_type) return count;
   function page_length   return count;
--
   procedure new_line (file:	in file_type;
		       spacing:	in positive_count := 1);
   procedure new_line (spacing:	in positive_count := 1);
--
   procedure skip_line (file:	in file_type; spacing : in positive_count := 1);
   procedure skip_line (spacing:	in positive_count := 1);
--
   function end_of_line (file:	in file_type) return boolean;
   function end_of_line return boolean;
--
   procedure new_page    (file:	in file_type);
   procedure new_page;
--
   procedure skip_page (file:	in file_type);
   procedure skip_page;
--
   function end_of_page (file:	in file_type) return boolean;
   function end_of_page return boolean;
--
   function end_of_file (file:	in file_type) return boolean;
   function end_of_file return boolean;
--
   procedure set_col (file:	in file_type; to:	in positive_count);
   procedure set_col (to:	in positive_count);
--
   procedure set_line (file:	in file_type; to:	in positive_count);
   procedure set_line (to:	in positive_count);
--
   function col (file:		in file_type) return positive_count;
   function col return positive_count;
--
   function line (file:		in file_type) return positive_count;
   function line return positive_count;
--
   function page (file:		in file_type) return positive_count;
   function page return positive_count;
--
--
   procedure get (file:	in file_type; item:	out character);
   procedure get (item:	out character);
--
   procedure put (file:		in file_type;
		  item:		in character);
   procedure put (item:		in character);
--
   procedure get (file:	in file_type;	item:	out string);
   procedure get (item:	out string);
--
   procedure put (file:	in file_type;	item:	in string);
   procedure put (item:	in string);
--
   procedure get_line (file:	in file_type;
		       item:	out string;
		       last:	out natural);
   procedure get_line (item:	out string;
		       last:	out natural);
--
   procedure put_line (file:	in file_type;
		       item:	in string);
   procedure put_line (item:	in string);

-- exceptions
   status_error:	exception renames io_exceptions. status_error;
   mode_error:		exception renames io_exceptions. mode_error;
   name_error:		exception renames io_exceptions. name_error;
   use_error:		exception renames io_exceptions. use_error;
   device_error:	exception renames io_exceptions. device_error;
   end_error:		exception renames io_exceptions. status_error;
   data_error:		exception renames io_exceptions. status_error;
   layout_error:	exception renames io_exceptions. status_error;
--
--the following routines are there for integer_io
--
   function digvalue (x:	long;
		      y:	integer) return character;
   procedure p2 (file:	in file_type;
	         item:	in long;
	         width:	in field;
		 base:	in number_base;
		 neg:	in boolean);
private
   type filedata;
   type file_type is access filedata;
end text_io;

--
--	body of text_io
--
--	j van katwijk
--
with io_exceptions;
package body text_io is
--
--	preliminary implementation of some text io functions
--	J van Katwijk
--
--	This (very preliminary) implementation heavily relies
--	on the buffering mechanism of the standard io library
--
--
--	data structure definitions
--
   subtype filename	is string (1 .. 50);	-- ??

   type filedata is record
      curr_name:	filename;
      curr_file:	unix. stream;	-- unix file descriptor
      curr_max:		count;	-- max line size
      curr_pnt:		count;	-- curr character pointer
      curr_line:	count;	-- current line indication
      curr_page:	count;	-- current page indication
	mode:		file_mode;	-- reading/writing
   end record;

   std_inp :	file_type;	-- standard input channel
   std_outp:	file_type;	-- standard output channel

   curr_inp:	file_type;	-- current input channel
   curr_outp:	file_type;	-- current output channel

--
-- internally used functions and procedures
--
   function new_file (s: long;	-- unix filename
		      f: string := " ";
		      m: file_mode) return file_type;

   function digvalue (x:	long;
		      y:	integer) return character is
   begin
	if x < 10
	then
		return character' val (character' pos ('0') + x);
	else
		return character' val (character' pos ('a') + x - 10);
	end if;
   end;

   procedure p2 (file:	in file_type;
		 item:	long;
		 width:	field;
		 base:	number_base;
		 neg:	boolean) is
   begin
	if item < long (base)
	then
		for i in 1 .. width - 1 loop
		   put (file, ' ');
		end loop;
		if neg
		then
		   put (file, '-');
		else
		   put (file, ' ');
		end if;
		put (file, digvalue (item, base));
	else
		p2 (file, item / 10, width - 1, base, neg);
		put (file, digvalue (item rem 10, base));
	end if;
	end;

   procedure close   (file:	in out file_type) is
   begin
	if file = null
	then
		raise io_exceptions. status_error;
	end if;

	if (unix. $fclose (file. curr_file) = unix. eof)
	then
		raise io_exceptions. status_error;
	end if;
	$deallocate (file);
   end;

   procedure delete (file:	in out file_type) is
   begin
	raise io_exceptions. not_yet_implemented;
   end;

--
--	make a string into a c string
--
   function c_name (s:	string) return string is
   t : string (s' first .. s' last + 1);
   begin
	put_line(s);
	put_line(integer'image(s'length));
	t (s' range) := s;
	t (t' last)  := ASCII. NUL;
	return t;
   end;

   procedure create (file:	in out file_type;
		     mode:	in file_mode;
		     name:	in string;
		     form:	in string    := " ") is
   x : long;
   begin
	if (file /= NULL)	-- already existing
	then
		close (file);
	end if;
	if mode = in_file
	then
		x := unix. $fopen (c_name (name), "r");
	else
		x := unix. $fopen (c_name (name), "w");
	end if;
	if (x = unix. eof)
	then
		raise io_exceptions. name_error;
	end if;
	file := new_file (x, name, mode);
   end;

   procedure open (file:	in out file_type;
		   mode:	in file_mode;
		   name:	in string;
		   form:	in string := " ") is
	x : long;
   begin
	if file /= NULL
	then
	   close (file);
	end if;
	create (file, mode, name, form);
   end;

   function mode (file:		in file_type) return file_mode is
   begin
	if (file = NULL)
	then
		raise io_exceptions. mode_error;
	end if;
	return file. mode;
   end;

   function name (file:		in file_type) return string is
   begin
	if file = NULL
	then
		raise io_exceptions. name_error;
        end if;
	return file. curr_name;
   end;

   function is_open (file:	in file_type) return boolean is
   begin
	return file /= NULL;
   end;

   procedure set_input (file:	in file_type) is
   begin
	if file = null
	then
		raise io_exceptions. status_error;
	end if;
	curr_inp := file;
   end;

   procedure set_output (file:	in file_type) is
   begin
	if file = null
	then
		raise io_exceptions. status_error;
	end if;
	curr_outp := file;
   end;

   function standard_input return file_type is
   begin
	return std_inp;
   end;

   function standard_output return file_type is
   begin
	return std_outp;
   end;

   function current_input return file_type is
   begin
	return curr_inp;
   end;

   function current_output return file_type is
   begin
	return curr_outp;
   end;

   procedure set_line_length (file:	in file_type;
			      to:	in count) is
   begin
	if (file = NULL)
	then
		raise io_exceptions. status_error;
	end if;
	if file. mode /= out_file
	then
		if file. curr_pnt > to
		then
			new_line (file);
		end if;	
		file. curr_max := to;
	end if;
   end;

   procedure set_line_length (to:	in count) is
   begin
	set_line_length (curr_outp, to);
   end;

   procedure set_page_length (file:	in file_type;
		              to:	in count) is
   begin
      raise io_exceptions. not_yet_implemented;
   end;

   procedure set_page_length (to:	in count) is
   begin
      set_page_length (curr_outp, to);
   end;

   function line_length (file:	in file_type) return count is
   begin
	if file = null
	then
		raise status_error;
	elsif file. mode /= out_file
	then
		raise mode_error;
	end if;
	return count (file. curr_line);
   end;

   function line_length return count is
   begin
	return line_length (curr_outp);
   end;

   function page_length (file:	in file_type) return count is
   begin
	raise io_exceptions. not_yet_implemented;
   end;

   function page_length return count is
   begin
	return page_length (curr_outp);
   end;

   procedure new_line (file:	in file_type;
		       spacing:	in positive_count := 1) is
   begin
	if file = null
	then
		raise status_error;
	end if;
	if file. mode /= out_file
	then
		raise mode_error;
	end if;
	for i in 1 .. spacing loop
	   file. curr_pnt := 1;
	   file. curr_line := file. curr_line + 1;
	   unix. $fputc (ASCII. LF, file. curr_file);
	end loop;
   end;

   procedure new_line (spacing:	in positive_count := 1) is
   begin
	new_line (curr_outp, spacing);
   end;

   procedure skip_line (file:	in file_type;
		        spacing:	in positive_count := 1) is
   c: character;
   begin
	if file = null
	then
		raise status_error;
	elsif file. mode /= in_file
	then
		raise mode_error;
	end if;

	for i in 1 .. spacing loop
		c := ASCII. NUL;
		while c /= ASCII. LF loop
		   get (file, c);
		end loop;
		file. curr_line := file. curr_line + 1;
		file. curr_pnt := 1;
	end loop;
   end;

   procedure skip_line (spacing:	in positive_count := 1) is
   begin
      skip_line (curr_inp, spacing);
   end;

   function end_of_line (file:	in file_type) return boolean is
	c : long;
   begin
	if file = null
	then
		raise status_error;
	elsif file. mode /= in_file
	then
		raise mode_error;
	end if;
	c := unix. $fgetc (file. curr_file);
	unix. $ungetc (c, file. curr_file);
	return c = unix. dlf;
   end;

   function end_of_line return boolean is
   begin
	return end_of_line (curr_inp);
   end;

   procedure new_page (file:	in file_type) is
   begin
	raise io_exceptions. not_yet_implemented;
   end;

   procedure new_page is
   begin
	new_page (curr_outp);
   end;

   procedure skip_page (file:	in file_type) is
   begin
	raise io_exceptions. not_yet_implemented;
   end;

   procedure skip_page is
   begin
	skip_page (curr_inp);
   end;

   function end_of_page (file:	in file_type) return boolean is
   begin
	raise io_exceptions. not_yet_implemented;
   end;

   function end_of_page return boolean is
   begin
	return end_of_page (curr_inp);
   end;

   function end_of_file (file:	in file_type) return boolean is
	c : long;
   begin
	if file = null
	then
		raise status_error;
	elsif file. mode /= in_file
	then
		raise mode_error;
	end if;
	c := unix. $fgetc (file. curr_file);
	unix. $ungetc (c, file. curr_file);

	return c = unix. eof;
   end;

   function end_of_file return boolean is
   begin
	return end_of_file (curr_inp);
   end;

   procedure set_col (file:	in file_type;
		      to:	positive_count) is
	c : character;
   begin
	if file = null
	then
		raise status_error;
	end if;

	if file. mode = out_file
	then
	   if to < file. curr_pnt
	   then
	      new_line;
	   end if;
	   for i in file. curr_pnt .. to loop
	      put (file, ' ');
	   end loop;	-- get and put take care of setting curr_pnt
	else
	   for i in file. curr_pnt .. to loop
	      get (file, c);
	   end loop;
	end if;
   end;

   procedure set_col (to:	positive_count) is
   begin
	set_col (curr_outp, to);
   end;

   procedure set_line (file:	in file_type; to:	in positive_count) is
   begin
	raise io_exceptions. not_yet_implemented;
   end;

   procedure set_line (to:	in positive_count) is
   begin
	set_line (curr_inp, to);
   end;

   function col (file:		in file_type) return positive_count is
   begin
	if file = null
	then
		raise status_error;
	end if;
	return positive_count (file. curr_pnt);
   end;

   function col return positive_count is
   begin
	return col (curr_outp);
   end;

   function line (file:	in file_type) return positive_count is
   begin
	if file = null
	then
		raise status_error;
	end if;
	return file. curr_line;
   end;

   function line return positive_count is
   begin
	return line (curr_outp);
   end;

   function page (file:	in file_type) return positive_count is
   begin
	if file = null
	then
		raise status_error;
	end if;
	return file. curr_page;
   end;

   function page return positive_count is
   begin
	return page (curr_outp);
   end;

   procedure get (file:	in file_type; item:	out character) is
	d : long;
   begin
	if file = null
	then
		raise status_error;
	elsif file. mode /= in_file
	then
		raise mode_error;
	end if;
	-- leave reading characters to unix
	--
	d := unix. $fgetc (file. curr_file);
	if d = unix. eof
	then
		raise end_error;
	end if;
	if d = unix. dlf	-- linefeed
	then
		file. curr_line := file. curr_line + 1;
		file. curr_pnt  := 1;
		get (file, item);
		return;
	end if;
	file. curr_pnt := file. curr_pnt + 1;
	item := character 'val (d);
   end;

   procedure get (item:	out character) is
   begin
	get (curr_inp, item);
   end;

   procedure put (file:	in file_type; item:	in character) is
   begin
	if file = null
	then
		raise status_error;
	elsif file. mode /= out_file
	then
		raise mode_error;
	end if;
	unix. $fputc (item, file. curr_file);
	if item = ASCII. LF
	then
		file. curr_pnt := 1;
		file. curr_line := file. curr_line + 1;
	elsif file. curr_pnt >= file. curr_max
	then
		new_line (file);
	else
		file. curr_pnt := file. curr_pnt + 1;
	end if;
   end;

   procedure put (item:	in character) is
   begin
	put (curr_outp, item);
   end;

   procedure get (file:	in file_type;
		  item:	out string) is
   begin
	for i in item' range loop
		get (file, item (i));
	end loop;
   end;

   procedure get (item:	out string) is
   begin
	for i in item' range loop
		get (curr_inp, item (i));
	end loop;
   end;

   procedure put (file:	in file_type;
		  item:	in string) is
   begin
	for i in item' range loop
		put (file, item (i));
	end loop;
   end;

   procedure put (item:	in string) is
   begin
	for i in item' range loop
		put (curr_outp, item (i));
	end loop;
   end;

   procedure get_line (file:	in file_type;
		       item:	out string;
		       last:	out natural) is
   c : character;
   begin
	for i in item' range loop
	   get (file, c);
	   exit when c = ASCII. LF;
	   item (i) := c;
	   last := i;
	end loop;
   end;

   procedure get_line (item:	out string;
		       last:	out natural) is
   begin
	get_line (curr_inp, item, last);
   end;

   procedure put_line (file:	in file_type;
		       item:	in string) is
   begin
	put (file, item);
	new_line (file);
   end;

   procedure put_line (item:	in string) is
   begin
	put_line (curr_outp, item);
   end;

   function new_file (s:	long;	-- unix filename
		      f:	string;
		      m:	file_mode) return file_type is
   t : file_type;
   begin
	t := new filedata;
	t. curr_file	:= s;
	if m = in_file
	then
		t. curr_max := 0;	-- force reading
	else
		t. curr_max := 72;
	end if;
	t. curr_pnt	:= 1;
	t. curr_line	:= 0;
	t. curr_page	:= 0;
	t. mode		:= m;
	t. curr_name (1 .. f' last) := f;
	t. curr_name (f' last + 1) := ASCII. NUL;

	return t;
   exception
	when constraint_error =>	-- filename does not fit
			t. curr_name := f (1 .. t. curr_name' last - 1);
			t. curr_name (t. curr_name' last) := ASCII. NUL;
   end;
begin
	std_inp:= new_file (unix. $termin, "standard_input", in_file);
	std_outp:= new_file (unix. $termout, "standard_output", out_file);
	curr_inp := std_inp;
	curr_outp := std_outp;
end;

