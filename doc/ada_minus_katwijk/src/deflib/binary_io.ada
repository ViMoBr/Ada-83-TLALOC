
with text_io; use text_io;
generic
   type data is private;
package binairy_io is

   procedure get (file:	in file_type;
		  item:	out data);
   procedure get (item:		out data);
   procedure put (file:		in file_type;
		  item:		in data);
   procedure put (item:		in data);
end binairy_io;

package body binairy_io is
-- implementation of generics
--
   procedure get (file:		in file_type;
		  item:		out data) is
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
	if  unix. $fread (data'address, data'size, 1, file. curr_file) /= 1
	then
		raise end_error;
	end if;
   end;

   procedure get (item:		out data) is
   begin
	return get (current_input, item);
   end;

   procedure put (file:		in file_type;
		  item:		in data) is
   begin

	if file = null
	then
		raise status_error;
	elsif file. mode /= out_file
	then
		raise mode_error;
	end if;
	if unix. $fwrite (data'address, data'size, 1, file. curr_file) /= 1
	then
	    raise end_error;
	end if;
   end;

   procedure put (item:		in data) is
   begin
	put (current_output, item);
   end;

end;
