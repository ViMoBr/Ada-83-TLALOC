-- C43214A.ADA

-- FOR A MULTIDIMENSIONAL AGGREGATE OF THE FORM (F..G => ""), CHECK
-- THAT CONSTRAINT_ERROR IS RAISED IF F..G IS NON-NULL AND
-- F OR G DO NOT BELONG TO THE INDEX SUBTYPE.

-- EG  02/10/1984
-- JBG 12/6/84

WITH REPORT;

PROCEDURE C43214A IS

     USE REPORT;

BEGIN

     TEST("C43214A", "FOR A MULTIDIMENSIONAL AGGREGATE OF THE FORM " &
                     "(F..G => """"), CHECK THAT CONSTRAINT ERROR "  &
                     "IS RAISED IF F..G IS NON-NULL AND NOT IN THE " &
                     "INDEX SUBTYPE");

     DECLARE

          SUBTYPE STA IS INTEGER RANGE 4 .. 7;
          TYPE TA IS ARRAY(STA RANGE 5 .. 6, 
                           STA RANGE 6 .. IDENT_INT(4)) OF CHARACTER;

          A : TA := (5 .. 6 => "");

     BEGIN

CASE_A :  BEGIN

               IF (6 .. IDENT_INT(8) => "") = A THEN
                    FAILED ("CASE A : CONSTRAINT_ERROR NOT RAISED");
               END IF;
               FAILED ("CASE A : CONSTRAINT_ERROR NOT RAISED - 2");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("CASE A : WRONG EXCEPTION RAISED");

          END CASE_A;

CASE_B :  BEGIN

               A := (IDENT_INT(3) .. 4 => "");
               FAILED ("CASE B : CONSTRAINT_ERROR NOT RAISED");

          EXCEPTION

               WHEN CONSTRAINT_ERROR =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("CASE B : WRONG EXCEPTION RAISED");

          END CASE_B;

     END;

     RESULT;

END C43214A;
