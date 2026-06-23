-- C67003C.ADA

-- CHECK THAT THE PREDEFINED OPERATORS FOR THE PREDEFINED
--   TYPE BOOLEAN CAN BE REDEFINED.
-- CHECK THAT THE REDEFINED OPERATOR IS INVOKED WHEN INFIX OR PREFIX
--   NOTATION IS USED.

-- CVP 5/18/81
-- JRK 6/1/81
-- JRK 12/2/82

WITH REPORT;
PROCEDURE C67003C IS

     USE REPORT;

BEGIN

     TEST ("C67003C", "CHECK THAT REDEFINITION OF " &
           "OPERATORS FOR PREDEFINED TYPE BOOLEAN WORKS");

     DECLARE

          -- LOGICAL OPERATORS.

          FUNCTION "NOT" (X : BOOLEAN) RETURN BOOLEAN IS
          BEGIN
               RETURN X;
          END "NOT";

          FUNCTION "AND" (X, Y : BOOLEAN) RETURN BOOLEAN IS
          BEGIN
               IF X AND THEN Y THEN
                    RETURN FALSE;
               ELSE RETURN TRUE;
               END IF;
          END "AND";

          FUNCTION "OR" (X, Y : BOOLEAN) RETURN BOOLEAN IS
          BEGIN
               IF X OR ELSE Y THEN
                    RETURN FALSE;
               ELSE RETURN TRUE;
               END IF;
          END "OR";

          FUNCTION "XOR" (X, Y : BOOLEAN) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "XOR";

          -- BOOLEAN RELATIONAL OPERATORS.

          FUNCTION "<" (X, Y : BOOLEAN) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<";

          FUNCTION "<=" (X, Y : BOOLEAN) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<=";

          FUNCTION ">" (X, Y : BOOLEAN) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">";

          FUNCTION ">=" (X, Y : BOOLEAN) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">=";

     BEGIN

          IF NOT (IDENT_BOOL (FALSE)) THEN
               FAILED ("REDEFINITION OF ""NOT"" IS " &
                       "DEFECTIVE");
          END IF;

          IF IDENT_BOOL (TRUE) AND IDENT_BOOL (TRUE) THEN
               FAILED ("REDEFINITION OF ""AND"" IS " &
                       "DEFECTIVE");
          END IF;

          IF IDENT_BOOL (FALSE) OR IDENT_BOOL (TRUE) THEN
               FAILED ("REDEFINITION OF ""OR"" IS " &
                       "DEFECTIVE");
          END IF;

          IF IDENT_BOOL (TRUE) XOR IDENT_BOOL (FALSE) THEN
               FAILED ("REDEFINITION OF ""XOR"" IS " &
                       "DEFECTIVE");
          END IF;

          IF IDENT_BOOL (FALSE) < IDENT_BOOL (TRUE) THEN
               FAILED ("REDEFINITION OF BOOLEAN " &
                       """<"" IS DEFECTIVE");
          END IF;

          IF IDENT_BOOL (FALSE) <= IDENT_BOOL (TRUE) THEN
               FAILED ("REDEFINITION OF BOOLEAN " &
                       """<="" IS DEFECTIVE");
          END IF;

          IF IDENT_BOOL (TRUE) > IDENT_BOOL (FALSE) THEN
               FAILED ("REDEFINITION OF BOOLEAN " &
                       """>"" IS DEFECTIVE");
          END IF;

          IF IDENT_BOOL (TRUE) >= IDENT_BOOL (FALSE) THEN
               FAILED ("REDEFINITION OF BOOLEAN " &
                       """>="" IS DEFECTIVE");
          END IF;

     END;

     RESULT;

END C67003C;
