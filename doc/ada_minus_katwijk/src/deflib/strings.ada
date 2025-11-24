-- package strings makes a clean interface between Ada and C type strings
-- using unconstrained records with the string as well as the length of the
-- string
--
-- Ton Biegstraaten (abi@dutinfd)
-- 3-11-87
--
--with text_io;
--use text_io;

package strings is
--
    type RecString (MaxLength	: positive) is private;

    --
    -- ToRecString makes a record RecString from a normal Ada string
    --
    function ToRecString (s		: in string;
			  length	: positive )
						return RecString;

    --
    -- FromRecString returns the Adastring out of a RecString
    --
    function FromRecString (rs		: in RecString;
			    length	: positive := 0)
					return string;

    --
    -- ToCstring receives a adastring or a record string type
    -- and returns the string as string for the C language
    --
    function ToCstring (s	: in string) return string;

    procedure ToCstring (rs	: in out RecString) ;

    -- Other useful functions may follow

private

    type RecString (MaxLength 	: positive) is
	record
	    string	: string (1 .. MaxLength);
	    length	: positive;
	end record;

end;

package body strings is

    function ToRecString (s		: in string;
			  length	: positive := s'length + 1)
						return RecString is
	rs	: RecString (length);
    begin
	rs. length := s'length;
	rs. string (1 .. s'length) := s;
	return rs;
    end;

    function FromRecString (rs		: in RecString;
			    length	: positive := 0)
					return string is
    begin
	if length = 0
	then
	    return rs. string (1 .. rs. length);
	else
	    return rs. string (1 .. length);
	end if;
    end;

    function ToCstring (s	: in string) return string is
	cs	: string (1 .. s'last+1);
    begin
	if s (s'last) = ASCII.NUL
	then
	    return s;
	else
	    cs (1 .. s'last) := s;
	    cs (s'last + 1) := ASCII.NUL;
	    return cs;
	end if;
    end;

    procedure ToCstring (rs	: in out RecString) is
    begin
	if rs. string (rs. length) /= ASCII.NUL
	then
	    rs. string (rs. length + 1) := ASCII.NUL;
	    rs. length := rs. length + 1;
	end if;
    end;

begin
    null;
end;
