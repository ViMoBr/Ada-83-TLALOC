-- C43205I.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- THE LOWER BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE
-- POSITIONAL AGGREGATE IS USED AS:

-- THE RETURN EXPRESSION IN A FUNCTION WHOSE RETURN TYPE IS
-- CONSTRAINED.

-- EG  01/27/84

WITH REPORT;

PROCEDURE C43205I IS

     USE REPORT;

BEGIN

     TEST("C43205I", "CONSTRAINED FUNCTION RESULT TYPE");

     BEGIN

CASE_I :  DECLARE

               SUBTYPE STC IS INTEGER RANGE -2 .. 10;
               TYPE BASE IS ARRAY(STC RANGE <>, STC RANGE <>)OF INTEGER;
               SUBTYPE TC IS BASE(IDENT_INT(-1) .. 0, 7 .. 9);

               FUNCTION FUN1 (A : INTEGER) RETURN TC IS
               BEGIN
                    RETURN ((5, 4, 3), (2, 1, 0));
               END;

          BEGIN

               IF FUN1(5)'FIRST(1) /= -1 THEN
                    FAILED ("CASE I : LOWER BOUND INCORRECT " &
                            "FOR 'FIRST(1)");
               ELSIF FUN1(5)'FIRST(2) /= 7 THEN
                    FAILED ("CASE I : LOWER BOUND INCORRECT " &
                            "FOR 'FIRST(2)");
               ELSIF FUN1(5)'LAST(1) /= 0 THEN
                    FAILED ("CASE I : UPPER BOUND INCORRECT " &
                            "FOR 'LAST(1)");
               ELSIF FUN1(5)'LAST(2) /= 9 THEN
                    FAILED ("CASE I : UPPER BOUND INCORRECT " &
                            "FOR 'LAST(2)");
               ELSIF FUN1(5) /= ((5, 4, 3), (2, 1, 0)) THEN
                    FAILED ("CASE I : FUNCTION DOES NOT " &
                            "RETURN THE CORRECT VALUES");
               END IF;

          END CASE_I;

     END;

     RESULT;

END C43205I;
