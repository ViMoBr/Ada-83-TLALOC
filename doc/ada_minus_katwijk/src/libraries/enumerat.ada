with text_io; use text_io;
generic
   type enum is  (<>);
package enumeration_io is
   DEFAULT_WIDTH:	field:= 0;
   DEFAULT_IS_LC:	boolean := FALSE;
   MAX_ENUM_LENGTH  : constant := 50;
   
   procedure get (file:	in file_type; item:	out enum);
   procedure get (item:		out enum);
   
   procedure put (file:		in file_type;
		  item:		in enum;
		  width:	in field := DEFAULT_WIDTH;
                  lc:		in boolean := DEFAULT_IS_LC);
   procedure put (item:		in enum;
		  width:	in field := DEFAULT_WIDTH;
                  lc:		in boolean := DEFAULT_IS_LC);
   procedure get (from:		in string;
		  item:		out enum;
		  last:		out positive);
   procedure put (to:		out string;
		  item:		in enum;
                  lc:		in boolean := DEFAULT_IS_LC);
end enumeration_io;

package body enumeration_io is
-- implementation of generics
--
    function to_lower_case (ustr    : string) return string;
    
    function is_valid_char (ch  : character) return boolean;
    
    function is_blank (ch   : character) return boolean;
    
    procedure get (file:	in file_type;
                  item:	out enum) is
        estr    : string (0 .. MAX_ENUM_LENGTH);
	t       : character;
	i       : integer range 0 .. MAX_ENUM_LENGTH;
    begin
        loop
            get (file, t);
	    exit when not is_blank (t);
        end loop;

        i := 0;
	while i <= MAX_ENUM_LENGTH
	loop
	    if not is_valid_char (t)
	    then
	        raise data_error;
	    end if;
            estr (i) := t;
            i := i + 1;
            exit when end_of_line (file);
	    get (file, t);
	end loop;
        
        item := enum 'value (estr);        
   exception
	when others => raise data_error;
   end;

   procedure get (item:		out enum) is
   begin
      get (current_input, item);
   end;
   
   procedure put (file:		in file_type;
		  item:		in enum;
		  width:	in field := DEFAULT_WIDTH;
                  lc:		in boolean := DEFAULT_IS_LC) is
        len : integer;
        --
        function length (estr   : string) return integer is
        begin
            return string'length;
        end;
   begin
        if lc then
            put (file, to_lower_case (enum 'image (item)));
        else
            put (file, enum 'image (item));
        end if;
        len := length (enum 'image (item));
        for i in field (len) .. width
        loop
            put (file, ' ');
        end loop;
   end;

   procedure put (item:		in enum;
		  width:	in field := DEFAULT_WIDTH;
                  lc:		in boolean := DEFAULT_IS_LC) is
    begin
        put (current_output, item, width, lc);
    end;

   procedure get (from:		in string;
		  item:		out enum;
		  last:		out positive) is
   begin
        item := enum 'value (from);
   end;

   procedure put (to:		out string;
		  item:		in enum;
                  lc:		in boolean := DEFAULT_IS_LC) is
   begin
        if lc then
            to := to_lower_case (enum 'image (item));
        else
            to := enum 'image (item);
        end if;
   end;

    function is_valid_char (ch   : character) return boolean is
    begin
        return (ch in 'a' .. 'z') or else
           (ch in character range 'A' .. 'Z') or else
           (ch in character range '0' .. '9') or else
           (ch = '_');
    end;
    
    function to_lower_case (ustr    : string) return string is
        lstr    : string (ustr'first  .. ustr'last);
    begin
        for i in ustr'first .. ustr'last
        loop
            if ustr(i) <= 'Z' and then ustr(i) >= 'A'
            then
                lstr (i) := character 'val 
                    (character 'pos (ustr(i)) - character 'pos ('A')
                    + character 'pos ('a'));
            end if;
        end loop;
        return lstr;
    end;        
    
    function is_blank (ch   : character) return boolean is
    begin
        return character' pos (ch) <= character' pos (' ');
    end;


end;
