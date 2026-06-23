-- C48008B.ADA

-- FOR ALLOCATORS OF THE FORM "NEW T X", CHECK THAT CONSTRAINT_ERROR IS
-- RAISED IF T IS AN UNCONSTRAINED ACCESS TYPE WHOSE DESIGNATED TYPE IS
-- AN UNCONSTRAINED RECORD, PRIVATE, OR LIMITED PRIVATE TYPE WITH
-- DISCRIMINANTS, X IS A DISCRIMINANT CONSTRAINT, AND ONE OF THE VALUES
-- OF X IS OUTSIDE THE RANGE OF THE CORRESPONDING DISCRIMINANT FOR THE
-- DESIGNATED TYPE.

-- EG  08/30/84

WITH REPORT;

PROCEDURE C48008B IS

     USE REPORT;

BEGIN

     TEST("C48008B","FOR ALLOCATORS OF THE FORM 'NEW T X', CHECK " &
                    "THAT CONSTRAINT_ERROR IS RAISED WHEN " &
                    "APPROPRIATE - UNCONSTRAINED ACCESS TYPE " &
                    "OF UNCONSTRAINED RECORD, PRIVATE, OR LIMITED " &
                    "PRIVATE TYPE");

     DECLARE

          TYPE INT IS RANGE 1 .. 5;

          TYPE UR1(A : INT) IS
               RECORD
                    NULL;
               END RECORD;

          PACKAGE P IS
               TYPE UP2(A, B : INT) IS PRIVATE;
               TYPE UL3(A, B, C : INT) IS LIMITED PRIVATE;
          PRIVATE
               TYPE UP2(A, B : INT) IS
                    RECORD
                         NULL;
                    END RECORD;
               TYPE UL3(A, B, C : INT) IS
                    RECORD
                         NULL;
                    END RECORD;
          END P;

          TYPE A_UR1 IS ACCESS UR1;
          TYPE A_UP2 IS ACCESS P.UP2;
          TYPE A_UL3 IS ACCESS P.UL3;

          TYPE AA_UR1 IS ACCESS A_UR1;
          TYPE AA_UP2 IS ACCESS A_UP2;
          TYPE AA_UL3 IS ACCESS A_UL3;

          V_AA_UR1 : AA_UR1;
          V_AA_UP2 : AA_UP2;
          V_AA_UL3 : AA_UL3;

     BEGIN

          BEGIN
               V_AA_UR1 := NEW A_UR1(6);
               FAILED ("NO EXCEPTION RAISED - UR1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - UR1");
          END;

          BEGIN
               V_AA_UP2 := NEW A_UP2(4, INT(IDENT_INT(0)));
               FAILED ("NO EXCEPTION RAISED - UP2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - UP2");
          END;

          BEGIN
               V_AA_UL3 := NEW A_UL3(INT(IDENT_INT(6)), 5, 4);
               FAILED ("NO EXCEPTION RAISED - UL3");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - UL3");
          END;

     END;

     RESULT;

END C48008B;
