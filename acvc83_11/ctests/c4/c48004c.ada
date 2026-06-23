-- C48004C.ADA

-- CHECK THAT THE FORM "NEW T" IS PERMITTED IF T IS AN UNCONSTRAINED
-- RECORD, PRIVATE, OR LIMITED TYPE WHOSE DISCRIMINANTS HAVE DEFAULT
-- VALUES.

-- EG  08/03/84

WITH REPORT;

PROCEDURE C48004C IS

     USE REPORT;

BEGIN

     TEST("C48004C","CHECK THAT THE FORM 'NEW T' IS PERMITTED IF "   &
                    "T IS AN UNCONSTRAINED RECORD, PRIVATE, OR "     &
                    "LIMITED TYPE WHOSE DISCRIMINANTS HAVE DEFAULT " &
                    "VALUES");

     DECLARE

          TYPE  UR(A : INTEGER := 1; B : INTEGER := 2)  IS
               RECORD
                    C : INTEGER := 7;
               END RECORD;

          PACKAGE  P  IS

               TYPE UP(A : INTEGER := 12; B : INTEGER := 13) IS PRIVATE;
               TYPE UL(A, B : INTEGER := 1) IS LIMITED PRIVATE;

          PRIVATE

               TYPE UP(A : INTEGER := 12; B : INTEGER := 13) IS
                    RECORD
                         Q : INTEGER;
                    END RECORD;
               TYPE UL(A, B : INTEGER := 1) IS
                    RECORD
                         Q : INTEGER;
                    END RECORD;

          END P;
     
          USE P;

          TYPE A_UR IS ACCESS UR;
          TYPE A_UP IS ACCESS UP;
          TYPE A_UL IS ACCESS UL;

          V_UR : A_UR;
          V_UP : A_UP;
          V_UL : A_UL;

     BEGIN

          V_UR := NEW UR;
          IF ( V_UR.A /= IDENT_INT(1) OR V_UR.B /= 2 OR
               V_UR.C /= 7 ) THEN 
               FAILED("WRONG VALUES - UR");
          END IF;

          V_UP := NEW UP;
          IF ( V_UP.A /= IDENT_INT(12) OR V_UP.B /= 13 ) THEN
               FAILED("WRONG VALUES - UP");
          END IF;
          
          V_UL := NEW UL;
          IF ( V_UL.A /= IDENT_INT(1) OR V_UL.B /= 1 ) THEN
               FAILED("WRONG VALUES - UL");
          END IF;

     END;

     RESULT;

END C48004C;
