-- C48012A.ADA

-- CHECK THAT DISCRIMINANTS GOVERNING VARIANT PARTS NEED NOT BE
-- SPECIFIED WITH STATIC VALUES IN AN ALLOCATOR OF THE FORM 
-- "NEW T X".

-- EG  08/30/84

WITH REPORT;

PROCEDURE C48012A IS

     USE REPORT;

BEGIN

     TEST("C48012A","CHECK THAT DISCRIMINANTS GOVERNING VARIANT " &
                    "PARTS NEED NOT BE SPECIFIED WITH STATIC "    &
                    "VALUES IN AN ALLOCATOR OF THE FORM 'NEW T X'");

     DECLARE

          TYPE INT IS RANGE 1 .. 5;
          TYPE ARR IS ARRAY(INT RANGE <>) OF INTEGER;

          TYPE UR(A : INT) IS
               RECORD
                    CASE A IS
                         WHEN 1 =>
                              NULL;
                         WHEN OTHERS =>
                              B : ARR(1 .. A);
                    END CASE;
               END RECORD;

          TYPE A_UR IS ACCESS UR;

          V_A_UR : A_UR;

     BEGIN

          V_A_UR := NEW UR(A => INT(IDENT_INT(2)));
          IF V_A_UR.A /= 2 THEN
               FAILED ("WRONG DISCRIMINANT VALUE");
          ELSIF V_A_UR.B'FIRST /= 1 AND V_A_UR.B'LAST /= 2 THEN
               FAILED ("WRONG BOUNDS IN VARIANT PART");
          END IF;

     END;

     RESULT;

END C48012A;
