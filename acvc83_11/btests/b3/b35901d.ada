-- B35901D.ADA
 
-- CHECK THAT A FIXED POINT TYPE DEFINITION MUST BE REJECTED IF IT 
-- REQUIRES MORE THAN SYSTEM.MAX_MANTISSA BITS (USING 
-- SYSTEM.FINE_DELTA).
 
-- RJW 2/24/86
 
WITH SYSTEM; USE SYSTEM;

PROCEDURE B35901D IS

     TYPE F1 IS DELTA FINE_DELTA RANGE -1.0 .. 1.0;   -- OK.

     TYPE F2 IS DELTA FINE_DELTA/2 RANGE -1.0 .. 1.0; -- ERROR: TOO 
                                                      --  MANY BITS.

     TYPE F3 IS DELTA FINE_DELTA RANGE -2.0 .. 2.0;   -- ERROR: TOO 
                                                      --  MANY BITS.
                        

BEGIN
     NULL;
END B35901D;
