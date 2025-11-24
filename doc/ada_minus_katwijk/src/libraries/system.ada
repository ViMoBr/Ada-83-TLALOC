-- j van katwijk
-- created	16/7/1984 
-- last update  10/4/1988

package system is

	subtype address	is integer;
	type name	is (GEMINIX, VAX, PDP11);
	type compiler	is (DAS, ADA);
	system_name	: constant name	:= GEMINIX;
	compiler_name	: constant compiler := ADA;

	storage_unit	: constant	:= 8;
	memory_size	: constant	:= 2_097_152;

	-- System dependent Named Numbers;
	
	min_int		: constant	:= -2_147_483_648;
	max_int		: constant	:=  2_147_483_647;
	max_digits	: constant	:= 7;
	max_mantissa	: constant	:= 0;
	fine_delta	: constant	:= 0;
	tick		: constant	:= 0;

end system;

