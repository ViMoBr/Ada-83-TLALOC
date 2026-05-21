-- TEST INCLUSION DE RUNTIME VIA BODY STANDARD

				--------
package body			_standrd
is				--------

			-----
  function		WIDTH	( BIT_SIZE :INTEGER )	return INTEGER
  is			-----
  begin
    if  BIT_SIZE <= 8  then  return 4;									-- +255
    elsif  BIT_SIZE <= 16  then  return 6;								-- +32767
    elsif  BIT_SIZE <= 32  then  return 11;								-- +4294967295
    elsif  BIT_SIZE <= 64  then  return 21;								-- +1,844674407371E19
    else  return 40;										-- 128 bits 3,4028236692094E38
    end if;

  end	WIDTH;
	-----

	--------
end	_standrd;
	--------
