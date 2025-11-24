with text_io; use text_io;
generic
   type num is range <>;
package integer_io is
   default_width:	field:= num' width;
   default_base:	number_base := 10;

   procedure get (file:	in file_type;
		  item:	out num;
		  width:	in field := 0);
   procedure get (item:		out num;
		  width:	in field := 0);
   procedure put (file:		in file_type;
		  item:		in num;
		  width:	in field := default_width;
		  base:		in number_base := default_base);
   procedure put (item:		in num;
		  width:	in field := default_width;
		  base:		in number_base := default_base);
   procedure get (from:		in string;
		  item:		out num;
		  last:		out positive);
   procedure put (to:		out string;
		  item:		in num;
		  base:		in number_base := default_base);
end integer_io;

package body integer_io is
-- implementation of generics
--
   function is_blank (a:	character) return boolean is
   begin
		return character' pos (a) <= character' pos (' ');
   end;

   function is_digit (a:	character) return boolean is
   begin
		return '0' <= a and then a <= '9';
   end;

   procedure get (file:		in file_type;
		  item:		out num;
		  width:	in field := 0) is
	t : character;
	number : num	:= 0;
	neg:	num	:= 1;
   begin
        loop
            get (file, t);
	    exit when not is_blank (t);
	end loop;
	if t /= '-' and then not is_digit (t)
	then
		raise data_error;
	end if;
	if t = '-'
	then
		neg := - neg;
		get (file, t);
	end if;
	while is_digit (t)
	loop
		number := 10 * number + num (character' pos (t)
		                            - character 'pos ('0'));
                exit when end_of_line (file);
		get (file, t);
	end loop;
	item := neg * number;
   exception
	when others => raise data_error;
   end;

   procedure get (item:		out num;
		  width:	in field := 0) is
   begin
	get (current_input, item, width);
   end;

   procedure put (file:		in file_type;
		  item:		in num;
		  width:	in field:=	default_width;
		  base:		in number_base := default_base) is
   begin
	put (file, num' image (item));
--      if item < 0
--	then
--	   p2 (file, long (-item), width, base, true);
--	else
--	   p2 (file, long (item), width, base, false);
--	end if;
   end;

   procedure put (item:		in num;
		  width:	in field:=	default_width;
		  base:		in number_base:= default_base) is
   begin
	put (current_output, item, width, base);
   end;

--	Incompleet, declaraties voor get/put op strings
--	ontbreken
   procedure put (to:	out string;
		  item:	in num;
		  base:	in number_base := default_base) is
   procedure h (s: string) is
	size : integer;
   begin
	null;
   end;
   begin
	h (num' image (item));
   end;
end;
