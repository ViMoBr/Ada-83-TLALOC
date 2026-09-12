PROCEDURE TEST IS

  type OCTET	is range 0 .. 255;
  type GROS_OCTET	is range 0 .. 255; for GROS_OCTET'SIZE use 16;

  O1		: OCTET	:= 255;
  O2		: OCTET;

  GO1		: GROS_OCTET;

BEGIN
  O1 := 128;
  O2 := 255;
  O1 :=  O2 - O1;
  GO1 := 300;

END	TEST;
