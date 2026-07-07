-- TEST INCLUSION DE RUNTIME VIA BODY STANDARD

				--------
package body			_standrd
is				--------

  type ENUM_USE_INFO	is record
			  SIZ		: NATURAL;
			  FST, LST	: INTEGER;
			end record;

  type FIXED_USE_INFO	is record
			  SIZ		: NATURAL;
			  FST, LST	: LONG_INTEGER;
			  NUMER, DENOM	: LONG_INTEGER;
			end record;


				-- EXCEPTIONS SERVICE

  EXCEPTIONS_TOP_CTX	: LONG_INTEGER;								-- PILIER 11 : sommet de la pile des contextes de reprise
  EXCEPTIONS_CURRENT	: LONG_INTEGER;								-- identite (@doublet STR) de l'exception en cours

  type FP_ARRAY		is array ( 0 .. 31 ) of LONG_INTEGER;
  type EXCEPTION_CONTEXT	is record
			  PREV_CTX, DISPATCH,
			  RBP, RSP, R13, R14,
			  NXT_LVL			: LONG_INTEGER;
			  FRAME_POINTERS		: FP_ARRAY;
			end record;
  EXC_CTX0		: EXCEPTION_CONTEXT;							-- contexte-sentinelle : 7 qwords d'en-tete + FP(0)

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


			-------------
  function		INTEGER_IMAGE	( ITEM :INTEGER )	return STRING
  is

    LEN	: INTEGER;

  begin
		-------------------
		INTEGER_IMAGE_WIDTH:
    declare
      N	: INTEGER	:= ITEM;

    begin
      LEN := 1;
      if N = 0 then
        LEN := 2;

      else
        if N > 0 then
	N := -N;
        end if;

        while N /= 0 loop
	LEN := LEN + 1;
	N := N / 10;
        end loop;

      end if;

    end	INTEGER_IMAGE_WIDTH;
	-------------------
    declare
      BUF : STRING (1 .. LEN);
      POS : INTEGER := LEN;
      N   : INTEGER := ITEM;
      DIG : INTEGER;
    begin
      if N = 0 then
        BUF(POS) := '0';
        POS := POS - 1;

      else
    -- On travaille en négatif pour éviter le cas INTEGER'FIRST.
        if N > 0 then
	N := -N;
        end if;

        while N /= 0 loop
	DIG := -(N rem 10);
	BUF(POS) := CHARACTER'VAL(CHARACTER'POS('0') + DIG);
	POS := POS - 1;
	N := N / 10;
        end loop;
      end if;

      if ITEM < 0 then
        BUF(POS) := '-';
      else
        BUF(POS) := ' ';
      end if;

      return BUF;
    end;

  end	INTEGER_IMAGE;
	-------------

	--------
end	_standrd;
	--------
