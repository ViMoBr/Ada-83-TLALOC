-- C67003D.ADA

-- CHECK THAT THE PREDEFINED OPERATORS FOR THE PREDEFINED
--   TYPE STRING CAN BE REDEFINED.
-- CHECK THAT THE REDEFINED OPERATOR IS INVOKED WHEN INFIX OR PREFIX
--   NOTATION IS USED.

-- CVP 5/18/81
-- JRK 6/1/81
-- JRK 12/2/82

WITH REPORT;
PROCEDURE C67003D IS

     USE REPORT;

BEGIN

     TEST ("C67003D", "CHECK THAT REDEFINITION OF " &
           "OPERATORS FOR PREDEFINED TYPE STRING WORKS");

     DECLARE

          S1 : STRING (1..2) := "A" & IDENT_CHAR ('B');
          S2 : STRING (1..2) := "C" & IDENT_CHAR ('D');

          -- STRING CONCATENATION OPERATORS.

          FUNCTION "&" (X, Y : STRING) RETURN STRING IS
               Z : STRING (1 .. X'LENGTH + Y'LENGTH);
          BEGIN
               Z (1 .. Y'LENGTH) := Y;
               Z (Y'LENGTH + 1 .. Z'LAST) := X;
               RETURN Z;
          END "&";

          FUNCTION "&" (X : STRING; Y : CHARACTER) RETURN STRING IS
               Z : STRING (1 .. X'LENGTH + 1);
          BEGIN
               Z (1) := Y;
               Z (2 .. Z'LAST) := X;
               RETURN Z;
          END "&";

          FUNCTION "&" (X : CHARACTER; Y : STRING) RETURN STRING IS
               Z : STRING (1 .. Y'LENGTH + 1);
          BEGIN
               Z (1 .. Y'LENGTH) := Y;
               Z (Z'LAST) := X;
               RETURN Z;
          END "&";

          FUNCTION "&" (X, Y : CHARACTER) RETURN STRING IS
               Z : STRING (1 .. 2);
          BEGIN
               Z (1) := Y;
               Z (2) := X;
               RETURN Z;
          END "&";

          -- STRING RELATIONAL OPERATORS.

          FUNCTION "<" (X, Y : STRING) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<";

          FUNCTION "<=" (X, Y : STRING) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<=";

          FUNCTION ">" (X, Y : STRING) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">";

          FUNCTION ">=" (X, Y : STRING) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">=";

     BEGIN

          IF S1 & S2 /= "CDAB" THEN
               FAILED ("BAD REDEFINITION OF ""&"" (S,S)");
          END IF;

          IF S1 & IDENT_CHAR ('C') /= "CAB" THEN
               FAILED ("BAD REDEFINITION OF ""&"" (S,C)");
          END IF;

          IF IDENT_CHAR ('C') & S1 /= "ABC" THEN
               FAILED ("BAD REDEFINITION OF ""&"" (C,S)");
          END IF;

          IF IDENT_CHAR ('A') & IDENT_CHAR ('B') /= "BA" THEN
               FAILED ("BAD REDEFINITION OF ""&"" (C,C)");
          END IF;

          IF S1 < S2 THEN
               FAILED ("BAD REDEFINITION OF STRING ""<""");
          END IF;

          IF S1 <= S2 THEN
               FAILED ("BAD REDEFINITION OF STRING ""<=""");
          END IF;

          IF S2 > S1 THEN
               FAILED ("BAD REDEFINITION OF STRING "">""");
          END IF;

          IF S2 >= S1 THEN
               FAILED ("BAD REDEFINITION OF STRING "">=""");
          END IF;

     END;

     RESULT;

END C67003D;
