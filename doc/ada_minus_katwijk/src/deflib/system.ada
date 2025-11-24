-- package system A.M.J.Hartveld
-- created	16/7/1984 
-- last update	7/9/1984

package system is

	subtype address	is integer;
	type name	is (MICRO_DUTCH, VAX, PDP11, LINUX);

	system_name	: constant name	:= LINUX;

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

