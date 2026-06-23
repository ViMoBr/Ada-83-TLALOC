-- C42007F.ADA

-- OBJECTIVE:
--     CHECK THAT THE BOUNDS OF A STRING LITERAL ARE DETERMINED
--     CORRECTLY.  IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
--     'FIRST OF THE INDEX SUBTYPE WHEN THE STRING LITERAL IS USED AS:

--     AN EXPRESSION ENCLOSED IN PARENTHESES WHEN THE VALUE OF THE
--     EXPRESSION IS THE VALUE OF A RECORD COMPONENT OR AN ARRAY
--     COMPONENT.

-- HISTORY:
--     TBN 07/29/86  CREATED ORIGINAL TEST.
--     BCB 08/18/87  CHANGED HEADER TO STANDARD HEADER FORMAT.  CHANGED
--                   F1 AND F2 TO PREVENT DEAD VARIABLE OPTIMIZATION.

WITH REPORT; USE REPORT;
PROCEDURE C42007F IS

BEGIN

     TEST("C42007F", "CHECK THE BOUNDS OF A STRING LITERAL WHEN USED " &
                     "AS AN EXPRESSION ENCLOSED IN PARENTHESIS WHEN " &
                     "THE VALUE IS A STRING LITERAL");

     BEGIN

CASE_F :  BEGIN

     CASE_F1 : DECLARE

                    TYPE SF1 IS RANGE 2 .. 6;
                    TYPE BASE IS ARRAY(SF1 RANGE <>) OF CHARACTER;
                    SUBTYPE TF1 IS BASE(3 .. 5);
                    TYPE TF2 IS ARRAY(1 .. 2) OF TF1;

                    F1 : TF2;

               BEGIN

                    F1 := (1 .. 2 => ("WHO"));
                    IF F1(1)(3) = 'W' THEN
                         FAILED ("CONSTRAINT_ERROR NOT RAISED - 1A");
                    ELSE
                         FAILED ("CONSTRAINT_ERROR NOT RAISED - 1B");
                    END IF;

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 1");

               END CASE_F1;

     CASE_F2 : DECLARE

                    TYPE SF2 IS RANGE 2 .. 6;
                    TYPE BASE IS ARRAY(SF2 RANGE <>) OF CHARACTER;
                    SUBTYPE TF1 IS BASE(3 .. 5);
                    TYPE TFR IS
                         RECORD
                              REC : TF1;
                         END RECORD;

                    F2 : TFR;

               BEGIN

                    F2 := (REC => ("WHY"));
                    IF F2.REC(3) = 'W' THEN
                         FAILED ("CONSTRAINT_ERROR NOT RAISED - 2A");
                    ELSE
                         FAILED ("CONSTRAINT_ERROR NOT RAISED - 2B");
                    END IF;

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 2");

               END CASE_F2;

     CASE_F3 : DECLARE

                    TYPE TF1 IS ARRAY(3 .. 6) OF CHARACTER;
                    TYPE TF2 IS ARRAY(1 .. 2) OF TF1;

                    F3 : TF2;

               BEGIN

                    F3 := (1 .. 2 => ("WHAT"));

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         FAILED ("CONSTRAINT_ERROR RAISED - 3");
                    WHEN OTHERS =>
                         FAILED ("UNEXPECTED EXCEPTION RAISED - 3");

               END CASE_F3;

          END CASE_F;

     END;

     RESULT;

END C42007F;
