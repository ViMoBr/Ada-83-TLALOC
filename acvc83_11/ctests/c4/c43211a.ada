-- C43211A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF A BOUND IN A NON-NULL
-- RANGE OF A NON-NULL AGGREGATE DOES NOT BELONG TO THE INDEX SUBTYPE.

-- EG  02/06/84
-- EG  05/08/85

WITH REPORT;

PROCEDURE C43211A IS

     USE REPORT;

BEGIN

     TEST("C43211A","CHECK THAT CONSTRAINT_ERROR IS RAISED IF A " &
                    "BOUND IN A NON-NULL RANGE OF A NON-NULL "    &
                    "AGGREGATE DOES NOT BELONG TO THE INDEX "     &
                    "SUBTYPE");

     DECLARE

          SUBTYPE ST IS INTEGER RANGE 4 .. 8;
          TYPE BASE IS ARRAY(ST RANGE <>, ST RANGE <>) OF INTEGER;
          SUBTYPE T IS BASE(5 .. 7, 5 .. 7);

          A    : T;

     BEGIN

CASE_A :  BEGIN

               A := (6 .. 8 => (4 .. 6 => 0));
               IF A /= (6 .. 8 => (4 .. 6 => 0)) THEN
                    FAILED ("CASE A : INCORRECT VALUES");
               END IF;

          EXCEPTION

               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED: CASE A");

          END CASE_A;

CASE_B :  BEGIN

               A := (6 .. IDENT_INT(8) =>
                     (IDENT_INT(4) .. 6 => 1));
               IF A /= (6 .. IDENT_INT(8) =>
                        (IDENT_INT(4) .. 6 => 1)) THEN
                    FAILED ("CASE B : INCORRECT VALUES");
               END IF;

          EXCEPTION

               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED: CASE B");

          END CASE_B;

CASE_C :  BEGIN

               A := (7 .. 9 => (5 .. 7 => 2));
               FAILED ("CONSTRAINT_ERROR NOT RAISED: CASE C");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED: CASE C");

          END CASE_C;

CASE_D :  BEGIN

               A := (5 .. 7 => (3 .. 5 => 3));
               FAILED ("CONSTRAINT_ERROR NOT RAISED: CASE D");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED: CASE D");

          END CASE_D;

CASE_E :  BEGIN

               A := (7 .. IDENT_INT(9) => (5 .. 7 => 4));
               FAILED ("CONSTRAINT_ERROR NOT RAISED: CASE E");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("CASE E : EXCEPTION RAISED");

          END CASE_E;

CASE_F :  BEGIN

               A := (5 .. 7 => (IDENT_INT(3) .. 5 => 5));
               FAILED ("CONSTRAINT_ERROR NOT RAISED: CASE F");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED: CASE F");

          END CASE_F;

CASE_G :  BEGIN

               A := (7 .. 8 => (5 .. 7 => 6), 9 => (5 .. 7 => 6));
               FAILED ("CONSTRAINT_ERROR NOT RAISED: CASE G");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED: CASE G");

          END CASE_G;

     END;

     RESULT;

END C43211A;
