-- Printcdb prints a listing of the central database of the Ada- programlibrary
--
-- Ton Biegstraaten
-- abi@dutinfd.UUCP
-- 27-10-87
with text_io; use text_io;
with integer_io;
with getargs; use getargs;
with strings; use strings;

with ProgLibConsts; use ProgLibConsts;

-- record definition of the database
with cdb; use cdb;

procedure PrintCdb is
    -- Hoofd procedure to print database
    fd		: file_type;	-- filedescriptor for cdb file
    nargs	: integer;
    arglength	: integer;
    argument	: string (1 .. FULLNAMESIZE);
    cdb		: CdbRecord;

    procedure get ( cdb	: out	CdbRecord) is
    begin
	get (fd, cdb .c_viewname);
	put_line (cdb .c_viewname);
	get (fd, cdb .c_username);
	put_line (cdb .c_username);
	get (fd, cdb .c_libname);
	put_line (cdb .c_libname);
    end;

    procedure put ( cdb	: in	CdbRecord) is
    begin
	put ("viewname :");
	put_line (cdb .c_viewname);
	put ("username :");
	put_line (cdb .c_username);
	put ("libname  :");
	put_line (cdb .c_libname);
    end;

    package int_io is new integer_io (integer);
    use int_io;
begin
null;
    nargs := NumArgs;
    put ("nargs ");
    put (nargs);
    new_line;
    if nargs > 1 then
	GetArg (1, argument, arglength);
	put_line (argument (0 .. arglength));
    end if;

    open (fd, in_file, FromRecString (CDBNAME));

    loop
	put_line ("in loop");
	get (cdb);
	if nargs > 1 then
	    if cdb .c_username = argument then
		put (cdb);
	    end if;

        else
	    put (cdb);
        end if;
    end loop;
end;
