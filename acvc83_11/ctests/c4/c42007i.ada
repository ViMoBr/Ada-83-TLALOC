-- C42007I.ADA

-- CHECK THAT THE BOUNDS OF A STRING LITERAL ARE DETERMINED CORRECTLY.
-- IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY THE LOWER
-- BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE STRING LITERAL
-- IS USED AS:

--      THE RETURN EXPRESSION IN A FUNCTION WHOSE RETURN TYPE IS
--      CONSTRAINED.

-- TBN  7/30/86

WITH REPORT; USE REPORT;
PROCEDURE C42007I IS

BEGIN

     TEST("C42007I", "CHECK THE BOUNDS OF A STRING LITERAL WHEN USED " &
                     "AS THE RETURN EXPRESSION IN A FUNCTION WHOSE " &
                     "RETURN TYPE IS CONSTRAINED");
     BEGIN

CASE_I :  DECLARE

               SUBTYPE STC IS INTEGER RANGE -2 .. 10;
               TYPE STR IS
                       ARRAY (STC RANGE IDENT_INT(3) .. 5) OF CHARACTER;
               TYPE BASE IS
                        ARRAY (STC RANGE <>, STC RANGE <>) OF CHARACTER;
               SUBTYPE TC IS
                           BASE (IDENT_INT(-1) .. 0, 7 .. IDENT_INT(9));

               FUNCTION FUN1 RETURN STR IS
               BEGIN
                    IF EQUAL (3, 3) THEN
                         RETURN "WHO";
                    ELSE
                         RETURN "WHY";
                    END IF;
               END FUN1;

               FUNCTION FUN2 (A : INTEGER) RETURN TC IS
               BEGIN
                    RETURN ("WHO", "WHY");
               END FUN2;

          BEGIN

               IF FUN1'FIRST /= IDENT_INT(3) THEN
                    FAILED ("LOWER BOUND INCORRECT FOR FUN1");
               END IF;
               IF FUN1'LAST /= IDENT_INT(5) THEN
                    FAILED ("UPPER BOUND INCORRECT FOR FUN1");
               END IF;
               IF FUN1 /= "WHO" THEN
                    FAILED ("INCORRECT STRING LITERAL RETURNED FOR " &
                            "FUN1");
               END IF;

               IF FUN2(5)'FIRST(1) /= -1 THEN
                    FAILED ("LOWER BOUND INCORRECT FOR 'FIRST(1)");
               END IF;
               IF FUN2(5)'FIRST(2) /= 7 THEN
                    FAILED ("LOWER BOUND INCORRECT FOR 'FIRST(2)");
               END IF;
               IF FUN2(5)'LAST(1) /= 0 THEN
                    FAILED ("UPPER BOUND INCORRECT FOR 'LAST(1)");
               END IF;
               IF FUN2(5)'LAST(2) /= 9 THEN
                    FAILED ("UPPER BOUND INCORRECT FOR 'LAST(2)");
               END IF;
               IF FUN2(5) /= ("WHO", "WHY") THEN
                    FAILED ("INCORRECT STRING LITERAL RETURNED FOR " &
                            "FUN2");
               END IF;

          END CASE_I;

     END;

     RESULT;

END C42007I;
