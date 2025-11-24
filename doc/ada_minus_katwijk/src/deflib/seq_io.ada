
--
-- package sequential_io vlg LRM 14.2.3 
--
-- Ton Biegstraaten, abi@dutinfd
-- januari 1988
--
--
with text_io;
with file_constants; use file_constants;
with unix;
with system;
with io_exceptions;
generic
    type element_type is private;
package sequential_io is

    type file_type is limited private;
    
    type file_mode is (IN_FILE, OUT_FILE);
    
   
    -- File management
    
   
    procedure create (file      : in out file_type;
                      mode      : in file_mode := OUT_FILE;
                      name      : in string    := "";
                      form      : in string    := "");
                      
    procedure open (file        : in out file_type;
                    mode        : in file_mode;
                    name        : in string;
                    form        : in string    := "");
                    
    procedure close  (file      : in out file_type);
    procedure delete (file      : in out file_type);
    procedure reset  (file      : in out file_type;
                      mode      : in file_mode);
    procedure reset  (file      : in out file_type);
    
    function mode    (file      : in file_type) return file_mode;
    function name    (file      : in file_type) return string;
    function form    (file      : in file_type) return string;
    
    function is_open (file      : in file_type) return boolean;
    
    -- Input and output operations
    
    procedure read  (file       : in out file_type;
                     item       : out element_type);
    procedure write (file       : in out file_type;
                     item       : in element_type);
                     
    function end_of_file (file  : file_type) return boolean;
    
    -- exceptions
    
    status_error:	exception renames io_exceptions. status_error;
    mode_error  :	exception renames io_exceptions. mode_error;
    name_error  :	exception renames io_exceptions. name_error;
    use_error   :	exception renames io_exceptions. use_error;
    device_error:	exception renames io_exceptions. device_error;
    end_error   :	exception renames io_exceptions. status_error;
    data_error  :	exception renames io_exceptions. status_error;



    private
        type filedata;
        type file_type is access filedata;
end sequential_io;
--
-- body of sequential_io
--
-- Ton Biegstraaten, abi@dutinfd
--
-- januari 1988
--

package body sequential_io is

--
-- datastructures
--
   subtype filename	is string (1 .. FULLNAMESIZE);

   type filedata is record
      curr_name:	filename;
      curr_file:	unix. stream;	-- unix file descriptor
      curr_form:        formstring;     -- form string
      mode:		file_mode;	-- reading/writing
   end record;

--
-- internally used functions and procedures
--
   function new_file (s:	long;	-- unix filedescriptor
		      f:	string;
		      m:	file_mode) return file_type is
   t : file_type;
   begin
	t := new filedata;
	t. curr_file	:= s;
	t. mode		:= m;
	t. curr_name (1 .. f' last) := f;
	t. curr_name (f' last + 1) := ASCII. NUL;

	return t;
   exception
	when constraint_error =>	-- filename does not fit
			t. curr_name := f (1 .. t. curr_name' last - 1);
			t. curr_name (t. curr_name' last) := ASCII. NUL;
   end;


--
--	make a string into a c string
--
   function c_name (s:	string) return string is
   t : string (s' first .. s' last + 1);
   begin
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
	if (file = NULL)
	then
		raise status_error;
	end if;
        unix. $unlink (file. curr_name);
        close (file);
   end;

    procedure reset (file   : in out file_type;
                     mode   : in file_mode ) is
    begin
	if (file = NULL)
	then
		raise status_error;
	end if;
        if file. mode = mode then
            reset (file);
        else
            close (file);
            open (file, mode, file. curr_name, file. curr_form);
        end if;
    end;
    
    procedure reset (file   : in out file_type) is
        d   : long := 0;
    begin
        d := unix. $fseek (file. curr_file, d, d);
    end;
    
   function mode (file:		in file_type) return file_mode is
   begin
	if (file = NULL)
	then
		raise status_error;
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

   function form (file:		in file_type) return string is
   begin
	if file = NULL
	then
            raise name_error;
        end if;
        return file. curr_form;
   end;

   function is_open (file:	in file_type) return boolean is
   begin
	return file /= NULL;
   end;

    procedure read (file    : in out file_type;
                    item    : out element_type) is
	d : long;
   begin
	if file = null
	then
		raise status_error;
	elsif file. mode /= in_file
	then
		raise mode_error;
	end if;
	-- leave reading to unix
	--
	d := unix. $fread (item' address,
--	            item' size/system. Storage_Unit, long (1), file. curr_file);
	            item' size, long (1), file. curr_file);
	if d = 0
	then
		raise end_error;
	end if;
    end;
    
    procedure write (file    : in out file_type;
                     item    : in element_type) is
        d : long;
    begin
	if file = null
	then
		raise status_error;
	elsif file. mode /= out_file
	then
		raise mode_error;
	end if;
	d := unix. $fwrite (item' address,
--	           item' size/system. Storage_Unit,long (1), file. curr_file);
	           item' size,long (1), file. curr_file);
        text_io. put (integer' image (item' size));
	if d = 0
	then
		raise device_error;
	end if;
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

begin
    null;
end;
