-- C45345A.ADA


-- CHECK THAT  CONSTRAINT_ERROR  IS RAISED IF THE RESULT OF CATENATION
--     HAS LENGTH GREATER THAN THAT PERMITTED BY THE INDEX SUBTYPE.

-- RM  2/26/82
-- BHS 7/25/84

WITH REPORT;
USE REPORT;
PROCEDURE C45345A IS


BEGIN

     TEST ( "C45345A" , "CHECK THAT  CONSTRAINT_ERROR  IS RAISED IF " &
                        "THE RESULT OF CATENATION HAS LENGTH GREATER " &
                        "THAN THAT PERMITTED BY THE INDEX SUBTYPE" );


     -------------------------------------------------------------------
     -----------------  STRG_LIT & STRG_LIT  ---------------------------

     DECLARE

          SUBTYPE  SMALL      IS INTEGER RANGE 1..5;
          TYPE  SMALL_STRING  IS ARRAY( SMALL RANGE <> ) OF CHARACTER;

     BEGIN

          IF  SMALL_STRING'( "ABCD" ) & "EF" = "ABCD" & "EF"  THEN
               FAILED ("EXCEPTION NOT RAISED FOR CATENATION OF " &
                       "STRING LITERALS - 1");
          END IF;
          FAILED ("EXCEPTION NOT RAISED FOR CATENATION OF " &
                  "STRING LITERALS - 2");

     EXCEPTION

          WHEN  CONSTRAINT_ERROR =>
               NULL;

          WHEN  OTHERS =>
               FAILED ("'STRING & STRING' RAISED WRONG EXCEPTION");

     END;


     -------------------------------------------------------------------
     -----------------  STRG_LIT & CHARACTER  --------------------------

     DECLARE

          SUBTYPE  SMALL      IS INTEGER RANGE 1..5;
          TYPE  SMALL_STRING  IS ARRAY( SMALL RANGE <> ) OF CHARACTER;

     BEGIN

          IF  SMALL_STRING'( "ABCDE" ) & 'X' = "ABCDE" & 'X'  THEN
               FAILED ("EXCEPTION NOT RAISED FOR CATENATION OF " &
                       "STRING LITERAL AND CHARACTER - 1");
          END IF;
          FAILED ("EXCEPTION NOT RAISED FOR CATENATION OF STRING " &
                  "LITERAL AND CHARACTER - 2");

     EXCEPTION

          WHEN  CONSTRAINT_ERROR =>
               NULL;

          WHEN  OTHERS =>
               FAILED( "'STRING & CHAR' RAISED WRONG EXCEPTION");

     END;


     -------------------------------------------------------------------
     -----------------  STRG_VAR & STRG_VAR  ---------------------------

     DECLARE

          SUBTYPE  SMALL      IS INTEGER RANGE 1..5;
          TYPE  SMALL_STRING  IS ARRAY( SMALL RANGE <> ) OF CHARACTER;
          X :          SMALL_STRING(1..5)
                                := SMALL_STRING( IDENT_STR("KLMNO") );
          A : CONSTANT SMALL_STRING    := SMALL_STRING(IDENT_STR("A"));
          B :          SMALL_STRING(1..5) := "BCDEX";

     BEGIN

          IF  A & B  =  X  THEN
               FAILED ("EXCEPTION NOT RAISED FOR CATENATION OF " &
                       "STRING VARIABLES - 1");
          END IF;
          FAILED ("EXCEPTION NOT RAISED FOR CATENATION OF STRING " &
                  "VARIABLES - 2");

     EXCEPTION


          WHEN  CONSTRAINT_ERROR =>
              NULL;

          WHEN  OTHERS =>
               FAILED( "'STRVAR & STRVAR' RAISED WRONG EXCEPTION");

     END;

     -------------------------------------------------------------------


     RESULT;


END C45345A;
