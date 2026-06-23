-- C67003E.ADA

-- CHECK THAT THE PREDEFINED OPERATORS FOR THE PREDEFINED
--   TYPE CHARACTER CAN BE REDEFINED.
-- CHECK THAT THE REDEFINED OPERATOR IS INVOKED WHEN INFIX OR PREFIX
--   NOTATION IS USED.

-- CVP 5/18/81
-- JRK 6/1/81
-- JRK 12/2/82

WITH REPORT;
PROCEDURE C67003E IS

     USE REPORT;

BEGIN

     TEST ("C67003E", "CHECK THAT REDEFINITION OF " &
           "OPERATORS FOR PREDEFINED TYPE CHARACTER WORKS");

     DECLARE

          -- CHARACTER RELATIONAL OPERATORS.

          FUNCTION "<" (X, Y : CHARACTER) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<";

          FUNCTION "<=" (X, Y : CHARACTER) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<=";

          FUNCTION ">" (X, Y : CHARACTER) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">";

          FUNCTION ">=" (X, Y : CHARACTER) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">=";

     BEGIN

          IF IDENT_CHAR ('G') < IDENT_CHAR ('H') THEN
               FAILED ("REDEFINITION OF CHARACTER " &
                       """<"" IS DEFECTIVE");
          END IF;

          IF IDENT_CHAR ('A') <= IDENT_CHAR ('E') THEN
               FAILED ("REDEFINITION OF CHARACTER " &
                       """<="" IS DEFECTIVE");
          END IF;

          IF IDENT_CHAR ('C') > IDENT_CHAR ('B') THEN
               FAILED ("REDEFINITION OF CHARACTER " &
                       """>"" IS DEFECTIVE");
          END IF;

          IF IDENT_CHAR ('F') >= IDENT_CHAR ('D') THEN
               FAILED ("REDEFINITION OF CHARACTER " &
                       """>="" IS DEFECTIVE");
          END IF;

     END;

     RESULT;

END C67003E;
