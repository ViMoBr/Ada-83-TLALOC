-- C43107A.ADA

-- CHECK THAT AN EXPRESSION ASSOCIATED WITH MORE THAN ONE RECORD
-- COMPONENT IS EVALUATED ONCE FOR EACH ASSOCIATED COMPONENT.

-- EG  02/14/84

WITH REPORT;

PROCEDURE C43107A IS

     USE REPORT;

BEGIN

     TEST("C43107A","CHECK THAT AN EXPRESSION WITH MORE THAN ONE " &
                    "RECORD COMPONENT IS EVALUATED ONCE FOR EACH " &
                    "ASSOCIATED COMPONENT");

     BEGIN

CASE_A :  DECLARE

               TYPE T1 IS ARRAY(1 .. 2) OF INTEGER;
               TYPE R1 IS
                    RECORD
                         A : T1;
                         B : INTEGER;
                         C : T1;
                         D : INTEGER;
                         E : INTEGER;
                    END RECORD;

               A1   : R1;
               CNTR : INTEGER := 0;

               FUNCTION FUN1 (A : T1) RETURN T1 IS
               BEGIN
                    CNTR := IDENT_INT(CNTR+1);
                    RETURN A;
               END FUN1;

               FUNCTION FUN2 (A : INTEGER) RETURN INTEGER IS
               BEGIN
                    CNTR := CNTR+1;
                    RETURN IDENT_INT(A);
               END FUN2;

          BEGIN

               A1 := (A | C => FUN1((-1, -2)), OTHERS => FUN2(-3)+1);
               IF CNTR /= 5 THEN
                    FAILED ("CASE A : INCORRECT NUMBER OF EVALUATIONS" &
                            " OF RECORD ASSOCIATED COMPONENTS");
               END IF;
               IF A1.A /= (-1, -2) OR A1.C /= (-1, -2) OR
                  A1.B /= -2 OR A1.D /= -2 OR A1.E /= -2 THEN
                    FAILED ("CASE A : INCORRECT VALUES IN RECORD");
               END IF;

          END CASE_A;

CASE_B :  DECLARE

               TYPE T2 IS ACCESS INTEGER;
               TYPE R2 IS
                    RECORD
                         A : T2;
                         B : INTEGER;
                         C : T2;
                         D : INTEGER;
                         E : INTEGER;
                    END RECORD;

               B1   : R2;
               CNTR : INTEGER := 0;

               FUNCTION FUN3 RETURN INTEGER IS
               BEGIN
                    CNTR := CNTR+1;
                    RETURN IDENT_INT(2);
               END FUN3;

          BEGIN

               B1 := (A | C => NEW INTEGER'(-1),
                      B | D | E => FUN3);
               IF B1.A = B1.C OR CNTR /= 3 THEN
                    FAILED ("CASE B : INCORRECT NUMBER OF EVALUATION" &
                            " OF RECORD ASSOCIATED COMPONENTS");
               END IF;
               IF B1.B /= 2 OR B1.D /= 2 OR B1.E /= 2 OR
                  B1.A = NULL OR B1.C = NULL OR B1.A = B1.C THEN
                    FAILED ("CASE B : INCORRECT VALUES IN RECORD");
               END IF;

          END CASE_B;

     END;

     RESULT;

END C43107A;
