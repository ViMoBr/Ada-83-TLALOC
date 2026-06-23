-- B35506C.ADA

-- CHECK THAT THE ARGUMENT TO T'VALUE MUST HAVE THE BASE TYPE STRING.

-- RJW 2/20/86

PROCEDURE  B35506C  IS
     
     TYPE T IS RANGE -1000 .. 1000;
     T1 : T;
     
     STR : STRING (1 .. 20) := (OTHERS => '0');

     SUBTYPE SSTRING IS STRING;
     SUB_STRING : SSTRING (1 .. 20) := (OTHERS => '0');

     TYPE NSTRING IS NEW STRING;
     NEW_STRING : NSTRING (1 .. 20) := (OTHERS => '0');

     TYPE ARR IS ARRAY (POSITIVE RANGE <> ) OF CHARACTER;
     NOT_STRING : ARR (1 .. 20) := (OTHERS => '0');

     T_ARRAY : ARRAY (1 .. 20) OF CHARACTER := (OTHERS => '0');

     CHAR : CHARACTER := '0';
BEGIN
     T1 := T'VALUE (STR);               -- OK.
     T1 := T'VALUE (SUB_STRING);        -- OK.
     T1 := T'VALUE (NOT_STRING);        -- ERROR: ARGUMENT NOT OF 
                                        --        BASE TYPE STRING.
     T1 := T'VALUE (NEW_STRING);        -- ERROR: ARGUMENT NOT OF 
                                        --        BASE TYPE STRING.
     T1 := T'VALUE (T_ARRAY);           -- ERROR: ARGUMENT NOT OF 
                                        --        BASE TYPE STRING.
     T1 := T'VALUE(CHAR);               -- ERROR: ARGUMENT NOT OF
                                        --        BASE TYPE STRING.
END B35506C ;
