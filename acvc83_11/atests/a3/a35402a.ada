-- A35402A.ADA

-- CHECK THAT THE BOUNDS OF AN INTEGER TYPE DEFINITION NEED NOT 
-- HAVE THE SAME INTEGER TYPE.

-- RJW 2/20/86

WITH REPORT; USE REPORT;

PROCEDURE A35402A IS

BEGIN

     TEST ( "A35402A", "CHECK THAT THE BOUNDS OF AN INTEGER " &
                       "TYPE DEFINITION NEED NOT HAVE THE SAME " &
                       "INTEGER TYPE" );

     DECLARE     
          TYPE INT1 IS RANGE 1 .. 10;
          TYPE INT2 IS RANGE 2 .. 8;
          TYPE INT3 IS NEW INTEGER;
     
          I  : CONSTANT INTEGER   := 5;
          I1 : CONSTANT INT1      := 5;
          I2 : CONSTANT INT2      := 5;
          I3 : CONSTANT INT3      := 5;
     
          TYPE INTRANGE1 IS RANGE I  .. I1;          -- OK.

          TYPE INTRANGE2 IS RANGE I1 .. I2;          -- OK.

          TYPE INTRANGE3 IS RANGE I2 .. I3;          -- OK.
          
          TYPE INTRANGE4 IS RANGE I3 .. I;           -- OK.
     BEGIN
          NULL;
     END;

     RESULT;

END A35402A;
