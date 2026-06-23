-- C48007B.ADA

-- FOR ALLOCATORS OF THE FORM "NEW T", CHECK THAT CONSTRAINT_ERROR IS
-- RAISED IF T IS A CONSTRAINED TYPE WITH DISCRIMINANTS (RECORD, PRIVATE
-- OR LIMITED) AND AT LEAST ONE DISCRIMINANT VALUE SPECIFIED FOR T DOES
-- NOT EQUAL THE CORRESPONDING VALUE SPECIFIED FOR THE ALLOCATOR'S BASE
-- TYPE.

-- EG  08/10/84

WITH REPORT;

PROCEDURE C48007B IS

     USE REPORT;

BEGIN

     TEST("C48007B","FOR ALLOCATORS OF THE FORM 'NEW T' CHECK " &
                    "THAT CONSTRAINT_ERROR IS RAISED WHEN "     &
                    "APPROPRIATE - CONSTRAINED TYPE WITH "      &
                    "DISCRIMINANT");

     DECLARE

          TYPE UR(A, B : INTEGER) IS
               RECORD
                    C : INTEGER;
               END RECORD;

          PACKAGE P IS

               TYPE UP(A, B : INTEGER) IS PRIVATE;
               TYPE UL(A, B : INTEGER) IS LIMITED PRIVATE;

          PRIVATE

               TYPE UP(A, B : INTEGER) IS
                    RECORD
                         C : INTEGER;
                    END RECORD;
               TYPE UL(A, B : INTEGER) IS
                    RECORD
                         C : INTEGER;
                    END RECORD;

          END P;

          USE P;

          SUBTYPE CR IS UR(1, 2);
          SUBTYPE CP IS UP(12, 13);
          SUBTYPE CL IS UL(4, 4);

          TYPE A_UR IS ACCESS UR(1, 9);
          TYPE A_UP IS ACCESS UP(9, 13);
          TYPE A_UL IS ACCESS UL(4, 9);

          VUR : A_UR;
          VUP : A_UP;
          VUL : A_UL;

     BEGIN

          BEGIN -- CR

               VUR := NEW CR;
               FAILED("NO EXCEPTION RAISED - CR");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("WRONG EXCEPTION RAISED - CR");

          END;

          BEGIN -- CP

               VUP := NEW CP;
               FAILED("NO EXCEPTION RAISED - CP");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("WRONG EXCEPTION RAISED - CP");

          END;

          BEGIN -- CL

               VUL := NEW CL;
               FAILED("NO EXCEPTION RAISED - CL");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("WRONG EXCEPTION RAISED - CL");

          END;

     END;

     RESULT;

END C48007B;
