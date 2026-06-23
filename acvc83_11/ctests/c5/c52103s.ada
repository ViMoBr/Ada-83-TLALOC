-- C52103S.ADA

-- CHECK THAT ARRAY ASSIGNMENTS WITH MATCHING LENGTHS DO NOT RAISE
-- CONSTRAINT_ERROR AND ARE PERFORMED CORRECTLY.
-- CASE THAT A NULL ARRAY CAN BE ASSIGNED TO A NULL OBJECT

-- PK  02/21/84
-- EG  05/30/84

WITH REPORT;
USE REPORT;

PROCEDURE C52103S IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 3;

BEGIN

     TEST("C52103S","CHECK THAT ARRAY ASSIGNMENTS WITH MATCHING " &
                    "LENGTHS DO NOT RAISE CONSTRAINT_ERROR AND "  &
                    "ARE PERFORMED CORRECTLY");

     DECLARE

          TYPE A1 IS ARRAY(INT RANGE <>) OF INTEGER;
          T1 : A1(2 .. IDENT_INT(1));

     BEGIN

          T1 := (IDENT_INT(3) .. 2 => IDENT_INT(1));

     EXCEPTION

          WHEN OTHERS => 
               FAILED ("A1 - EXCEPTION RAISED");

     END;

     DECLARE

          TYPE A2 IS ARRAY(INT RANGE <>, INT RANGE <>) OF INTEGER;
          T2 : A2(1 .. IDENT_INT(2), IDENT_INT(3) .. IDENT_INT(2));

     BEGIN

          T2 := A2'(IDENT_INT(2) .. 3 => 
                    (IDENT_INT(2) .. IDENT_INT(1) =>  IDENT_INT(1)));
          T2 := A2'(IDENT_INT(3) .. 2 => 
                    (IDENT_INT(1) .. IDENT_INT(3) =>  IDENT_INT(1)));

     EXCEPTION

          WHEN OTHERS => 
               FAILED ("A2 - EXCEPTION RAISED");

     END;

     DECLARE

          TYPE A3 IS ARRAY(INT RANGE <>, INT RANGE <>, INT RANGE <>) OF
                         INTEGER;
          T3 : A3(1 .. IDENT_INT(2), IDENT_INT(1) .. IDENT_INT(3),
                  IDENT_INT(3) .. IDENT_INT(2));

     BEGIN

          T3 := A3'(IDENT_INT(1) .. 3 => 
                    (IDENT_INT(1) .. IDENT_INT(2) =>  
                     (IDENT_INT(3) .. IDENT_INT(2) => IDENT_INT(1))));

     EXCEPTION

          WHEN OTHERS => 
               FAILED ("A3 - EXCEPTION RAISED");

     END;

     DECLARE

          SUBTYPE S IS STRING(IDENT_INT(5) .. 4);
          V : S;

     BEGIN

          V := "";
          V := (OTHERS => 'X');
          V := (S'RANGE => 'Y');
          V := (IDENT_INT(1) .. 0 => 'Z');
          V(6 .. 3) := "";
          V(6 .. 3) := (OTHERS => 'X');
          V(IDENT_INT(6) .. IDENT_INT(3)) := "";
          V(IDENT_INT(6) .. IDENT_INT(3)) := (OTHERS => 'Y');

     EXCEPTION

          WHEN OTHERS => 
               FAILED ("STRINGS - EXCEPTION RAISED");

     END;

     RESULT;

END C52103S;
