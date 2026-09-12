			---------------
procedure			TEST_EXCEPTIONS
is			---------------

  EXCEP_1, EXCEP_2, EXCEP_3	: exception;

begin
  null;
exception
  when EXCEP_1 => null;
  when EXCEP_2 | EXCEP_3 => null;
  when others => null;

end	TEST_EXCEPTIONS;
	---------------
