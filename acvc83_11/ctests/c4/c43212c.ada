-- C43212C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF ALL SUBAGGREGATES FOR
-- A PARTICULAR DIMENSION DO NOT HAVE THE SAME BOUNDS.
-- ADDITIONAL CASES FOR THE THIRD DIMENSION AND FOR THE NULL ARRAYS.

-- PK  02/21/84
-- EG  05/30/84

WITH REPORT;
USE REPORT;

PROCEDURE C43212C IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 3;

BEGIN

     TEST("C43212C","CHECK THAT CONSTRAINT_ERROR IS RAISED IF ALL " &
                    "SUBAGGREGATES FOR A PARTICULAR DIMENSION DO "  &
                    "NOT HAVE THE SAME BOUNDS");

     DECLARE
          TYPE A3 IS ARRAY(INT RANGE <>, INT RANGE <>, INT RANGE <>)
                         OF INTEGER;
     BEGIN
          IF A3'(((IDENT_INT(1) .. IDENT_INT(2) => IDENT_INT(1)),
                      (1 .. IDENT_INT(2) => IDENT_INT(1))),
                     ((IDENT_INT(2) .. IDENT_INT(3) => IDENT_INT(1)),
                      (IDENT_INT(2) .. IDENT_INT(3) => IDENT_INT(1)))) 
            =
             A3'(((IDENT_INT(1) .. IDENT_INT(2) => IDENT_INT(1)),
                      (1 .. IDENT_INT(2) => IDENT_INT(1))),
                     ((IDENT_INT(2) .. IDENT_INT(3) => IDENT_INT(1)),
                      (IDENT_INT(2) .. IDENT_INT(3) => IDENT_INT(1)))) 
          THEN
                FAILED ("A3 - EXCEPTION NOT RAISED, ARRAYS EQUAL");
          END IF;
          FAILED ("A3 - EXCEPTION NOT RAISED, ARRAYS NOT EQUAL");

     EXCEPTION

          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => 
               FAILED ("A3 - WRONG EXCEPTION RAISED");

     END;

     DECLARE

          TYPE B3 IS ARRAY(INT RANGE <>, INT RANGE <>, INT RANGE <>)
                         OF INTEGER;

     BEGIN

          IF B3'(((IDENT_INT(2) .. IDENT_INT(1) => IDENT_INT(1)),
                      (2 .. IDENT_INT(1) => IDENT_INT(1))),
                     ((IDENT_INT(3) .. IDENT_INT(1) => IDENT_INT(1)),
                      (IDENT_INT(3) .. IDENT_INT(1) => IDENT_INT(1)))) 
            =
             B3'(((IDENT_INT(2) .. IDENT_INT(1) => IDENT_INT(1)),
                      (2 .. IDENT_INT(1) => IDENT_INT(1))),
                     ((IDENT_INT(3) .. IDENT_INT(1) => IDENT_INT(1)),
                      (IDENT_INT(3) .. IDENT_INT(1) => IDENT_INT(1)))) 
          THEN
                FAILED ("B3 - EXCEPTION NOT RAISED, ARRAYS EQUAL");
          END IF;
          FAILED ("B3 - EXCEPTION NOT RAISED, ARRAYS NOT EQUAL");

     EXCEPTION

          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => 
                FAILED ("B3 - WRONG EXCEPTION RAISED");

     END;

     RESULT;

END C43212C;
