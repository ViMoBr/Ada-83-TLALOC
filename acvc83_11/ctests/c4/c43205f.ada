-- C43205F.ADA

-- CHECK THAT THE BOUNDS OF A POSITIONAL AGGREGATE ARE DETERMINED
-- CORRECTLY. IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN BY
-- 'FIRST OF THE INDEX SUBTYPE WHEN THE POSITIONAL AGGREGATE IS USED AS:

-- AN EXPRESSION ENCLOSED IN PARENTHESES WHEN THE VALUE OF THE
-- EXPRESSION IS THE VALUE OF A RECORD COMPONENT OR ARRAY
-- COMPONENT.

-- EG  01/26/84

WITH REPORT;

PROCEDURE C43205F IS

     USE REPORT;

BEGIN

     TEST("C43205F", "AN EXPRESSION ENCLOSED IN PARENTHESES " &
                     "WHEN THE VALUE OF THE EXPRESSION IS THE VALUE "  &
                     "OF A RECORD COMPONENT OR ARRAY COMPONENT");

     BEGIN

CASE_F :  BEGIN

     CASE_F1 : DECLARE

                    TYPE SF1 IS RANGE 2 .. 6;
                    TYPE BASE IS ARRAY(SF1 RANGE <>) OF INTEGER;
                    SUBTYPE TF1 IS BASE(3 .. 5);
                    TYPE TF2 IS ARRAY(1 .. 2) OF TF1;

                    F1 : TF2;

               BEGIN

                    F1 := (1 .. 2 => ((3, 2, 1)));
                    FAILED ("CASE F1 : CONSTRAINT_ERROR NOT RAISED");

               EXCEPTION

                    WHEN CONSTRAINT_ERROR =>
                         COMMENT ("CASE F1 : CORRECTLY RAISED " &
                                  "CONSTRAINT_ERROR");

                    WHEN OTHERS =>
                         FAILED ("CASE F1 : WRONG EXCEPTION RAISED");

               END CASE_F1;

     CASE_F2 : DECLARE

                    TYPE SF2 IS RANGE 2 .. 6;
                    TYPE BASE IS ARRAY(SF2 RANGE <>) OF INTEGER;
                    SUBTYPE TF1 IS BASE(3 .. 5);
                    TYPE TFR IS
                         RECORD
                              REC : TF1;
                         END RECORD;

                    F2 : TFR;

               BEGIN

                    F2 := (REC => ((3, 2, 1)));
                    FAILED ("CASE F2 : CONSTRAINT_ERROR NOT RAISED");

               EXCEPTION

                    WHEN CONSTRAINT_ERROR =>
                         COMMENT ("CASE F2 : CORRECTLY RAISED " &
                                  "CONSTRAINT_ERROR");

                    WHEN OTHERS =>
                         FAILED ("CASE F2 : WRONG EXCEPTION RAISED");

               END CASE_F2;

     CASE_F3 : DECLARE

                    TYPE TF1 IS ARRAY(3 .. 5) OF INTEGER;
                    TYPE TF2 IS ARRAY(1 .. 2) OF TF1;

                    F3 : TF2;

               BEGIN

                    F3 := (1 .. 2 => ((3, 2, 1)));
                    COMMENT ("CASE F3 : CONSTRAINT_ERROR CORRECTLY " &
                             "NOT RAISED");

               EXCEPTION

                    WHEN CONSTRAINT_ERROR =>
                         FAILED ("CASE F3 : CONSTRAINT_ERROR RAISED");

                    WHEN OTHERS =>
                         FAILED ("CASE F3 : WRONG EXCEPTION RAISED");

               END CASE_F3;

          END CASE_F;

     END;

     RESULT;

END C43205F;
