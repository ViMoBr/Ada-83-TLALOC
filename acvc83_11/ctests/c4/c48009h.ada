-- C48009H.ADA

-- FOR ALLOCATORS OF THE FORM "NEW T'(X)", CHECK THAT CONSTRAINT_ERROR
-- IS RAISED IF T IS AN (UNCONSTRAINED) ACCESS TYPE, THE DESIGNATED TYPE
-- FOR T'BASE IS CONSTRAINED, AND THE OBJECT DESIGNATED BY X DOES NOT
-- HAVE DISCRIMINANTS OR INDEX BOUNDS THAT EQUAL THE CORRESPONDING
-- VALUES FOR T'S DESIGNATED TYPE.

-- EG  08/30/84

WITH REPORT;

PROCEDURE C48009H IS

     USE REPORT;

BEGIN

     TEST("C48009H","FOR ALLOCATORS OF THE FORM 'NEW T'(X)', CHECK " &
                    "THAT CONSTRAINT_ERROR IS RAISED WHEN " &
                    "APPROPRIATE - UNCONSTRAINED ACCESS TYPE OF A " &
                    "CONSTRAINED TYPE");

     DECLARE

          TYPE UR(A : INTEGER) IS
               RECORD
                    NULL;
               END RECORD;
          TYPE UA IS ARRAY(INTEGER RANGE <>) OF INTEGER;

          PACKAGE P IS
               TYPE UP(A : INTEGER) IS PRIVATE;
               TYPE UL(A : INTEGER) IS LIMITED PRIVATE;
          PRIVATE
               TYPE UP(A : INTEGER) IS
                    RECORD
                         NULL;
                    END RECORD;
               TYPE UL(A : INTEGER) IS
                    RECORD
                         NULL;
                    END RECORD;
          END P;

          TYPE A_CR IS ACCESS UR(IDENT_INT(2));
          TYPE A_CA IS ACCESS UA(2 .. IDENT_INT(4));
          TYPE A_CP IS ACCESS P.UP(3);
          TYPE A_CL IS ACCESS P.UL(4);

          TYPE AA_CR IS ACCESS A_CR;
          TYPE AA_CA IS ACCESS A_CA;
          TYPE AA_CP IS ACCESS A_CP;
          TYPE AA_CL IS ACCESS A_CL;

          V_AA_CR : AA_CR;
          V_AA_CA : AA_CA;
          V_AA_CP : AA_CP;
          V_AA_CL : AA_CL;

     BEGIN

          BEGIN
               V_AA_CR := NEW A_CR'(NEW UR(3));
               FAILED ("NO EXCEPTION RAISED - CR");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CR");
          END;

          BEGIN
               V_AA_CA := NEW A_CA'(NEW UA(IDENT_INT(3) .. 5));
               FAILED ("NO EXCEPTION RAISED - CA");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CA");
          END;

          BEGIN
               V_AA_CP := NEW A_CP'(NEW P.UP(IDENT_INT(4)));
               FAILED ("NO EXCEPTION RAISED - CP");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CP");
          END;

          BEGIN
               V_AA_CL := NEW A_CL'(NEW P.UL(5));
               FAILED ("NO EXCEPTION RAISED - CL");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED - CL");
          END;

     END;

     RESULT;

END C48009H;
