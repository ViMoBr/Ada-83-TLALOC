-- C43215A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED FOR A POSITIONAL
-- ARRAY AGGREGATE WHOSE UPPER BOUND EXCEEDS THE UPPER BOUND
-- OF THE INDEX SUBTYPE BUT BELONGS TO THE INDEX BASE TYPE.

-- EG  02/13/84

WITH REPORT;
WITH SYSTEM;

PROCEDURE C43215A IS

     USE REPORT;
     USE SYSTEM;

BEGIN

     TEST("C43215A","CHECK THAT CONSTRAINT_ERROR IS RAISED "      &
                    "FOR A POSITIONAL ARRAY AGGREGATE WHOSE "     &
                    "UPPER BOUND EXCEEDS THE UPPER BOUND OF THE " &
                    "INDEX SUBTYPE BUT BELONGS TO THE INDEX "     &
                    "BASE TYPE");

     BEGIN

CASE_A :  DECLARE

               LOWER_BOUND : CONSTANT  := MAX_INT-3;
               UPPER_BOUND : CONSTANT  := MAX_INT-1;

               TYPE STA IS RANGE LOWER_BOUND .. UPPER_BOUND;

               TYPE TA IS ARRAY(STA RANGE <>) OF INTEGER;

               A1 : TA(STA);
               OK : EXCEPTION;

               FUNCTION FUN1 RETURN TA IS
               BEGIN
                    RETURN (1, 2, 3, 4);
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                    BEGIN
                         COMMENT ("CASE A : CONSTRAINT_ERROR RAISED");
                         RAISE OK;
                    END;
                    WHEN OTHERS =>
                    BEGIN
                         FAILED ("CASE A : EXCEPTION RAISED IN FUN1");
                         RAISE OK;
                    END;
               END FUN1;

          BEGIN

               A1 := FUN1;
               FAILED ("CASE A : CONSTRAINT_ERROR NOT RAISED");

          EXCEPTION

               WHEN OK =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("CASE A : EXCEPTION RAISED");

          END CASE_A;

CASE_B :  DECLARE

               TYPE ENUM IS (A, B, C, D);

               SUBTYPE STB IS ENUM RANGE A .. C;

               TYPE TB IS ARRAY(STB RANGE <>) OF INTEGER;

               B1 : TB(STB);
               OK : EXCEPTION;

               FUNCTION FUN1 RETURN TB IS
               BEGIN
                    RETURN (1, 2, 3, 4);
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                    BEGIN
                         COMMENT ("CASE B : CONSTRAINT_ERROR RAISED");
                         RAISE OK;
                    END;
                    WHEN OTHERS =>
                    BEGIN
                         FAILED ("CASE B : EXCEPTION RAISED IN FUN1");
                         RAISE OK;
                    END;
               END FUN1;

          BEGIN

               B1 := FUN1;
               FAILED ("CASE B : CONSTRAINT_ERROR NOT RAISED");

          EXCEPTION

               WHEN OK =>
                    NULL;

               WHEN OTHERS =>
                    FAILED ("CASE B : EXCEPTION RAISED");

          END CASE_B;

     END;

     RESULT;

END C43215A;
