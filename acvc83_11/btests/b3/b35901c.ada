-- B35901C.ADA
 
-- CHECK THAT A FIXED POINT TYPE DEFINITION MUST BE REJECTED IF IT 
-- REQUIRES MORE THAN SYSTEM.MAX_MANTISSA BITS.
 
-- RJW 2/24/86
 
WITH SYSTEM; USE SYSTEM;

PROCEDURE B35901C IS

     TYPE FIXED_TYPE1 IS DELTA 2.0 ** (-MAX_MANTISSA)       -- OK.
                        RANGE -1.0 .. 1.0;

     TYPE FIXED_TYPE2 IS DELTA 2.0 ** (-(MAX_MANTISSA + 1)) -- ERROR: 
                        RANGE -1.0 .. 1.0;                  -- TOO 
                                                            -- MANY 
                                                            -- BITS.
     TYPE FIXED_TYPE3 IS DELTA 1.0 
               RANGE -10.0 .. 2.0 ** MAX_MANTISSA;          -- OK.

     TYPE FIXED_TYPE4 IS DELTA 1.0 
               RANGE -10.0 .. 2.0 ** MAX_MANTISSA + 1.0;    -- ERROR: 
                                                            -- TOO
                                                            -- MANY 
                                                            -- BITS

BEGIN
     NULL;
END B35901C;
