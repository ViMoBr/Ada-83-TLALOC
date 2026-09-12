				------
package				PACK_1
is				------

  procedure WRITE_SOMETHING;

end	PACK_1;
	------


with TEXT_IO;
use  TEXT_IO;
				------
package body			PACK_1
is				------

		---------------
  procedure	WRITE_SOMETHING
  is		---------------
  begin
    PUT( " Something " );

  end	WRITE_SOMETHING;
	---------------

	------
end	PACK_1;
	------

with TEXT_IO;
use  TEXT_IO;
			---------
procedure			MAIN_PROG
is			---------

begin
  PUT( " Bonjour " );

end	MAIN_PROG;
	---------
