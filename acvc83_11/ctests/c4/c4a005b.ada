-- C4A005B.ADA

-- CHECK THAT A NONSTATIC UNIVERSAL INTEGER EXPRESSION RAISES
-- NUMERIC_ERROR OR CONSTRAINT_ERROR IF DIVISION BY ZERO IS ATTEMPTED
-- OR IF THE SECOND OPERAND OF REM OR MOD IS ZERO.

-- JBG 5/2/85
-- EG  10/24/85  FIX NUMERIC_ERROR/CONSTRAINT_ERROR ACCORDING TO
--               AI-00387; PREVENT DEAD VARIABLE OPTIMIZATION

WITH REPORT; USE REPORT;
PROCEDURE C4A005B IS
BEGIN
     TEST("C4A005B", "CHECK NUMERIC_ERROR OR CONSTRAINT_ERROR FOR " &
                     "NONSTATIC UNIVERSAL " &
                     "INTEGER EXPRESSIONS - DIVISION BY ZERO");
     BEGIN
          DECLARE
               X : BOOLEAN := 1 = 1/INTEGER'POS(IDENT_INT(0));
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- DIV");
               IF X /= IDENT_BOOL(X) THEN
                    FAILED ("WRONG RESULT - DIV");
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
               X : BOOLEAN := 1 = 1 REM INTEGER'POS(IDENT_INT(0));
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- REM");
               IF X /= IDENT_BOOL(X) THEN
                    FAILED ("WRONG RESULT - REM");
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
               X : BOOLEAN := 1 = INTEGER'POS(IDENT_INT(1)) MOD 0;
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- MOD");
               IF X /= IDENT_BOOL(X) THEN
                    FAILED ("WRONG RESULT - MOD");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION IN WRONG PLACE - MOD");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED FOR MOD BY 0");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED FOR MOD BY 0");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - MOD");
     END;

     RESULT;

END C4A005B;
