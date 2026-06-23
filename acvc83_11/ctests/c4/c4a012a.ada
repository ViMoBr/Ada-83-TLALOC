-- C4A012A.ADA

-- OBJECTIVE:
--     CHECK THAT UNIVERSAL REAL EXPRESSIONS RAISE NUMERIC_ERROR OR
--     CONSTRAINT_ERROR FOR DIVISION BY ZERO.

-- HISTORY:
-- JBG 05/03/85
-- EG  10/28/85  FIX NUMERIC_ERROR/CONSTRAINT_ERROR ACCORDING TO
--               AI-00387; PREVENT DEAD VARIABLE OPTIMIZATION.
-- JET 01/06/88  UPDATED HEADER FORMAT.

WITH REPORT; USE REPORT;
PROCEDURE C4A012A IS
BEGIN

     TEST ("C4A012A", "UNIV REAL DIVISION BY ZERO RAISES " &
                      "NUMERIC_ERROR/CONSTRAINT_ERROR");

     BEGIN
          DECLARE
               X : BOOLEAN := 1.0 = 1.0/0.0;
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- STATIC REAL DIV");
               IF X /= IDENT_BOOL(X) THEN
                    FAILED ("WRONG RESULT - STATIC REAL DIV");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION IN WRONG PLACE - STATIC REAL " &
                            "DIV");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - STATIC REAL DIV");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - STATIC REAL DIV");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - STATIC REAL DIV");
     END;

     BEGIN
          DECLARE
               X : BOOLEAN := 1.0 = 1.0/0;
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- STATIC INT DIV");
               IF X /= IDENT_BOOL(X) THEN
                    FAILED ("WRONG RESULT - STATIC INT DIV");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION IN WRONG PLACE - STATIC INT " &
                            "DIV");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - STATIC INT DIV");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - STATIC INT DIV");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - STATIC INT DIV");
     END;

     BEGIN
          DECLARE
               X : BOOLEAN := 1.0 = 1.0/(INTEGER'POS(IDENT_INT(0))*1.0);
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- NONSTATIC REAL DIV");
               IF X /= IDENT_BOOL(X) THEN
                    FAILED ("WRONG RESULT - NONSTATIC REAL DIV");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION IN WRONG PLACE - NONSTATIC " &
                            "REAL DIV");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - NONSTATIC REAL DIV");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - NONSTATIC REAL DIV");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - NONSTATIC REAL DIV");
     END;

     BEGIN
          DECLARE
               X : BOOLEAN := 1.0 = 1.0/INTEGER'POS(IDENT_INT(0));
          BEGIN
               FAILED ("NUMERIC_ERROR/CONSTRAINT_ERROR NOT RAISED " &
                       "- NONSTATIC INT DIV");
               IF X /= IDENT_BOOL(X) THEN
                    FAILED ("WRONG RESULT - NONSTATIC INT DIV");
               END IF;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION IN WRONG PLACE - NONSTATIC " &
                            "INT DIV");
          END;
     EXCEPTION
          WHEN NUMERIC_ERROR =>
               COMMENT ("NUMERIC_ERROR RAISED - NONSTATIC INT DIV");
          WHEN CONSTRAINT_ERROR =>
               COMMENT ("CONSTRAINT_ERROR RAISED - NONSTATIC INT DIV");
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED - NONSTATIC INT DIV");
     END;

     RESULT;

END C4A012A;
