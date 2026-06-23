-- C43214B.ADA

-- CHECK THAT THE LOWER BOUND FOR THE STRING LITERAL IS DETERMINED BY
-- THE APPLICABLE INDEX CONSTRAINT, WHEN ONE EXISTS.

-- EG  02/10/84

WITH REPORT;

PROCEDURE C43214B IS

     USE REPORT;

BEGIN

     TEST("C43214B", "SUBPROGRAM WITH CONSTRAINED ARRAY FORMAL " &
                     "PARAMETER");

     BEGIN

CASE_A :  BEGIN

--             COMMENT ("CASE A1 : SUBPROGRAM WITH CONSTRAINED " &
--                      "ONE-DIMENSIONAL ARRAY FORMAL PARAMETER");

     CASE_A1 : DECLARE

                    SUBTYPE STA1 IS STRING(IDENT_INT(11) .. 15);

                    PROCEDURE PROC1 (A : STA1) IS
                    BEGIN
                         IF A'FIRST /= 11 THEN
                              FAILED ("CASE 1 : LOWER BOUND " &
                                      "INCORRECT");
                         ELSIF A'LAST /= 15 THEN
                              FAILED ("CASE 1 : UPPER BOUND " &
                                      "INCORRECT");
                         ELSIF A /= "ABCDE" THEN
                              FAILED ("CASE 1 : ARRAY DOES NOT " &
                                     "CONTAIN THE CORRECT VALUES");
                         END IF;
                    END;

               BEGIN

                    PROC1 ("ABCDE");

               END CASE_A1;

--             COMMENT ("CASE A2 : SUBPROGRAM WITH CONSTRAINED " &
--                      "TWO-DIMENSIONAL ARRAY FORMAL PARAMETER");

     CASE_A2 : DECLARE

                    TYPE TA IS ARRAY (11 .. 12, 10 .. 11) OF CHARACTER;

                    PROCEDURE PROC1 (A : TA) IS
                    BEGIN
                         IF A'FIRST(1) /= 11 OR A'FIRST(2) /= 10 THEN
                              FAILED ("CASE 2 : LOWER BOUND " &
                                      "INCORRECT");
                         ELSIF A'LAST(1) /= 12 OR A'LAST(2) /= 11 THEN
                              FAILED ("CASE 2 : UPPER BOUND " &
                                      "INCORRECT");
                         ELSIF A /= ("AB", "CD") THEN
                              FAILED ("CASE 2 : ARRAY DOES NOT " &
                                      "CONTAIN THE CORRECT VALUES");
                         END IF;
                    END;

               BEGIN

                    PROC1 (("AB", "CD"));

               END CASE_A2;

          END CASE_A;

     END;

     RESULT;

END C43214B;
