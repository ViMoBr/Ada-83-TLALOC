-- C43205C.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- 'FIRST OF THE INDEX SUBTYPE WHEN THE POSITIONAL AGGREGATE IS USED AS:

--   C) THE RETURN EXPRESSION IN A FUNCTION WHOSE RETURN TYPE IS
--      UNCONSTRAINED.

-- EG  01/26/84

WITH REPORT;

PROCEDURE C43205C IS

     USE REPORT;

BEGIN

     TEST("C43205C", "CASE C : UNCONSTRAINED FUNCTION RESULT TYPE");

     BEGIN

CASE_C :  DECLARE

               SUBTYPE STC1 IS INTEGER RANGE -2 .. 3;
               SUBTYPE STC2 IS INTEGER RANGE 7 .. 20;
               TYPE TC IS ARRAY (STC1 RANGE <>, STC2 RANGE <>)
                                                        OF INTEGER;

               FUNCTION FUN1 (A : INTEGER) RETURN TC IS
               BEGIN
                    RETURN ((5, 4, 3), (2, IDENT_INT(1), 0));
               END;

          BEGIN

               IF FUN1(5)'FIRST(1) /= -2 THEN
                    FAILED ("CASE C : LOWER BOUND INCORRECTLY " &
                            "GIVEN BY 'FIRST(1)");
               ELSIF FUN1(5)'FIRST(2) /= 7 THEN
                    FAILED ("CASE C : LOWER BOUND INCORRECTLY " &
                            "GIVEN BY 'FIRST(2)");
               ELSIF FUN1(5)'LAST(1) /= -1 THEN
                    FAILED ("CASE C : UPPER BOUND INCORRECTLY " &
                            "GIVEN BY 'LAST(1)");
               ELSIF FUN1(5)'LAST(2) /= 9 THEN
                    FAILED ("CASE C : UPPER BOUND INCORRECTLY " &
                            "GIVEN BY 'LAST(2)");
               ELSIF FUN1(5) /= ((5, 4, 3), (2, 1, 0)) THEN
                    FAILED ("CASE C : FUNCTION DOES NOT " &
                            "RETURN THE CORRECT VALUES");
               END IF;

          END CASE_C;

     END;

     RESULT;

END C43205C;
