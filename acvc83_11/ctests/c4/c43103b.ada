-- C43103B.ADA

-- CHECK THAT IF A DISCRIMINANT DOES NOT GOVERN A VARIANT PART, ITS
-- VALUE CAN BE GIVEN BY A NONSTATIC EXPRESSION.
-- ADDITIONAL CASES OF USE OF A DISCRIMINANT THAT IS USED AS AN
-- ARRAY INDEX BOUND.

-- PK  02/21/84
-- EG  05/30/84
-- EG  11/02/84

WITH REPORT;
USE REPORT;

PROCEDURE C43103B IS

     SUBTYPE INT IS INTEGER RANGE 1 .. 3;

     TYPE A2 IS ARRAY(INT RANGE <>, INT RANGE <>) OF INTEGER;

     SUBTYPE DINT IS INTEGER RANGE 0 .. 10;
          
     TYPE REC(D, E : DINT := IDENT_INT(1)) IS RECORD
          U : A2(1 .. D, E .. 3) := (1 .. D =>
                                     (E .. 3 => IDENT_INT(1)));
     END RECORD;

BEGIN

     TEST("C43103B","CHECK THAT IF A DISCRIMINANT DOES NOT GOVERN " &
                    "A VARIANT PART, ITS VALUE CAN BE GIVEN BY A "  &
                    "NONSTATIC EXPRESSION");

-- SIMPLE DECLARATIONS

     BEGIN

          DECLARE

               L : REC(IDENT_INT(2), IDENT_INT(2));
               K : REC(IDENT_INT(0), IDENT_INT(1));
               M : REC(IDENT_INT(3), IDENT_INT(4));

          BEGIN
               IF L.U'FIRST(1) /= IDENT_INT(1) OR
                  L.U'LAST(1)  /= IDENT_INT(2) OR
                  L.U'FIRST(2) /= IDENT_INT(2) OR
                  L.U'LAST(2)  /= IDENT_INT(3) THEN
                    FAILED("1.1 - INCORRECT BOUNDS");
               END IF;
               IF K.U'FIRST(1) /= IDENT_INT(1) OR
                  K.U'LAST(1)  /= IDENT_INT(0) OR
                  K.U'FIRST(2) /= IDENT_INT(1) OR
                  K.U'LAST(2)  /= IDENT_INT(3) THEN
                    FAILED("1.2 - INCORRECT BOUNDS");
               END IF;
               IF M.U'FIRST(1) /= IDENT_INT(1) OR
                  M.U'LAST(1)  /= IDENT_INT(3) OR
                  M.U'FIRST(2) /= IDENT_INT(4) OR
                  M.U'LAST(2)  /= IDENT_INT(3) THEN
                    FAILED("1.3 - INCORRECT BOUNDS");
               END IF;
               IF M.U'LENGTH(1) /= 3 OR M.U'LENGTH(2) /= 0 THEN
                    FAILED("1.4 - INCORRECT ARRAY LENGTH");
               END IF;
          END;

     EXCEPTION

          WHEN OTHERS => 
               FAILED ("1.5 - EXCEPTION RAISED");

     END;

-- EXPLICIT INITIAL VALUE - OK

     BEGIN

          DECLARE
               O : CONSTANT REC := (IDENT_INT(2), IDENT_INT(2),
                        ((1, IDENT_INT(2)), (IDENT_INT(2), 3)));
          BEGIN
               IF O.U'FIRST(1) /= IDENT_INT(1) OR
                  O.U'LAST(1)  /= IDENT_INT(2) OR
                  O.U'FIRST(2) /= IDENT_INT(2) OR
                  O.U'LAST(2)  /= IDENT_INT(3) THEN
                    FAILED("2.1 - INCORRECT BOUNDS");
               END IF;
          END;

     EXCEPTION

          WHEN OTHERS => 
               FAILED ("2.2 - EXCEPTION RAISED");
     END;

-- EXPLICIT INITIAL VALUE: NULL ARRAY WITH WRONG BOUNDS

     BEGIN

          DECLARE
               P : CONSTANT REC := (IDENT_INT(0), IDENT_INT(2),
                                    (IDENT_INT(3) .. IDENT_INT(0) =>
                                     (IDENT_INT(2), 3)));
          BEGIN
               FAILED ("3.1 NO EXCEPTION RAISED");
          END;

     EXCEPTION

          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => 
               FAILED ("3.2 -  WRONG EXCEPTION RAISED");
     END;

-- EXPLICIT INITIAL VALUE: NULL ARRAY WITH WRONG BOUNDS

     BEGIN

          DECLARE
               P : CONSTANT REC := (IDENT_INT(0), IDENT_INT(2),
                                    (IDENT_INT(3) .. IDENT_INT(0) =>
                                     (OTHERS => IDENT_INT(2))));
          BEGIN
               FAILED ("4.1 NO EXCEPTION RAISED");
          END;

     EXCEPTION

          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => 
               FAILED ("4.2 - WRONG EXCEPTION RAISED");

     END;

-- EXPLICIT INITIAL VALUE: NULL ARRAY WITH WRONG BOUNDS 2ND DIM.

     BEGIN

          DECLARE
               P : CONSTANT REC := (IDENT_INT(0), IDENT_INT(2),
                                    (IDENT_INT(1) .. IDENT_INT(0) =>
                                     (IDENT_INT(1) .. IDENT_INT(2) =>
                                      1)));
          BEGIN
               FAILED ("5.1 NO EXCEPTION RAISED");
          END;

     EXCEPTION

          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS => 
               FAILED ("5.2 - WRONG EXCEPTION RAISED");

     END;

     RESULT;

END C43103B;
