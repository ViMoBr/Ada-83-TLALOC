-- C4A005A.ADA

-- OBJECTIVE:
--     CHECK THAT A UNIVERSAL INTEGER EXPRESSION RAISES NUMERIC_ERROR OR
--     CONSTRAINT_ERROR IF DIVISION BY ZERO IS ATTEMPTED OR IF THE
--     SECOND OPERAND OF REM OR MOD IS ZERO.  THIS TESTS EXPRESSIONS
--     CONTAINING STATIC OPERANDS.

-- HISTORY:
--     JBG 05/02/85  CREATED ORIGINAL TEST.
--     EG  10/24/85  FIXED NUMERIC_ERROR/CONSTRAINT_ERROR ACCORDING TO
--                   AI-00387; PREVENT DEAD VARIABLE OPTIMIZATION.
--     JET 01/06/88  UPDATED HEADER FORMAT AND REVISED CODE FOR MOD.

WITH REPORT; USE REPORT;
PROCEDURE C4A005A IS

     EXCEPTION_RAISED : BOOLEAN;

BEGIN
     TEST("C4A005A", "CHECK NUMERIC_ERROR/CONSTRAINT_ERROR FOR " &
                     "DIVISION BY ZERO - STATIC OPERANDS");
     BEGIN
          DECLARE
               X : BOOLEAN := 1 = 1/0;
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- DIV");
               IF X /= IDENT_BOOL(X) THEN
                    COMMENT ("NO EXCEPTION RAISED");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION IN WRONG PLACE - DIV");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED FOR / BY 0");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR / BY 0");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - DIV");
     END;

     BEGIN
          DECLARE
               X : BOOLEAN := 1 = 1 REM 0;
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- REM");
               IF X /= IDENT_BOOL(X) THEN
                    COMMENT ("NO EXCEPTION RAISED");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION IN WRONG PLACE - REM");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED FOR REM BY 0");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR REM BY 0");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - REM");
     END;

     BEGIN
          DECLARE
               X : CONSTANT INTEGER := 1 MOD 0;
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR 1 MOD 0");
               EXCEPTION_RAISED := FALSE;
               IF X /= IDENT_INT(X) THEN
                    FAILED ("SHOULDN'T BE HERE");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION AT WRONG POINT FOR 1 MOD 0");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               EXCEPTION_RAISED := TRUE;
               COMMENT ("EXCEPTION RAISED FOR 1 MOD 0 AS VALUE " &
                        "FOR CONSTANT");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION FOR 1 MOD 0 AS VALUE FOR " &
                       "CONSTANT");
     END;

     BEGIN
          DECLARE
               X : BOOLEAN := 1 = 1 MOD 0;
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- MOD");
               IF EXCEPTION_RAISED THEN
                    FAILED ("INCONSISTENT HANDLING OF 1 MOD 0 -- A");
               END IF;
               IF X /= IDENT_BOOL(X) THEN
                    COMMENT ("DON'T OPTIMIZE THIS");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION IN WRONG PLACE - MOD");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR | CONSTRAINT_ERROR =>
               COMMENT ("EXCEPTION RAISED FOR MOD BY 0 IN " &
                        "BOOLEAN EXPRESSION");
               IF NOT EXCEPTION_RAISED THEN
                    FAILED ("INCONSISTENT HANDLING OF 1 MOD 0 -- B");
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - MOD");
     END;

     RESULT;

END C4A005A;
