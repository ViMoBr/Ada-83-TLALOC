-- C67003A.ADA

-- CHECK THAT THE PREDEFINED OPERATORS FOR THE PREDEFINED
--   TYPE INTEGER CAN BE REDEFINED.
-- CHECK THAT THE REDEFINED OPERATOR IS INVOKED WHEN INFIX OR PREFIX
--   NOTATION IS USED.

-- CVP 5/18/81
-- JRK 6/1/81
-- JRK 12/2/82

WITH REPORT;
PROCEDURE C67003A IS

     USE REPORT;

BEGIN

     TEST ("C67003A", "CHECK THAT REDEFINITION OF " &
           "OPERATORS FOR PREDEFINED TYPE INTEGER WORKS");

     DECLARE

          -- INTEGER INFIX OPERATORS.

          FUNCTION "*" (X, Y : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= Y THEN
                    RETURN 1;
               ELSE RETURN 0;
               END IF;
          END "*";

          FUNCTION "/" (X, Y : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= Y THEN
                    RETURN 2;
               ELSE RETURN 0;
               END IF;
          END "/";
     
          FUNCTION "+" (X, Y : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= Y THEN
                    RETURN 3;
               ELSE RETURN 0;
               END IF;
          END "+";
     
          FUNCTION "-" (X, Y : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= Y THEN
                    RETURN 4;
               ELSE RETURN 0;
               END IF;
          END "-";
     
          FUNCTION "REM" (X, Y : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= Y THEN
                    RETURN 5;
               ELSE RETURN 0;
               END IF;
          END "REM";
     
          FUNCTION "MOD" (X, Y : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= Y THEN
                    RETURN 6;
               ELSE RETURN 0;
               END IF;
          END "MOD";

          FUNCTION "**" (X, Y : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= Y THEN
                    RETURN 7;
               ELSE RETURN 0;
               END IF;
          END "**";

          -- INTEGER PREFIX OPERATORS.

          FUNCTION "+" (X : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= 0 THEN
                    RETURN 8;
               ELSE RETURN 0;
               END IF;
          END "+";

          FUNCTION "-" (X : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= 0 THEN
                    RETURN 9;
               ELSE RETURN 0;
               END IF;
          END "-";

          FUNCTION "ABS" (X : INTEGER) RETURN INTEGER IS
          BEGIN
               IF X /= 0 THEN
                    RETURN 10;
               ELSE RETURN 0;
               END IF;
          END "ABS";

          -- INTEGER RELATIONAL OPERATORS.

          FUNCTION "<" (X, Y : INTEGER) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<";

          FUNCTION "<=" (X, Y : INTEGER) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<=";

          FUNCTION ">" (X, Y : INTEGER) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">";

          FUNCTION ">=" (X, Y : INTEGER) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">=";

     BEGIN

          IF IDENT_INT (3) * IDENT_INT (5) /= 1 THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """*"" IS DEFECTIVE");
          END IF;

          IF IDENT_INT (5) / IDENT_INT (1) /= 2 THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """/"" IS DEFECTIVE");
          END IF;

          IF IDENT_INT (1) + IDENT_INT (30) /= 3 THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """+"" IS DEFECTIVE");
          END IF;

          IF IDENT_INT (50) - IDENT_INT (100) /= 4 THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """-"" IS DEFECTIVE");
          END IF;

          IF IDENT_INT (7) REM IDENT_INT (8) /= 5 THEN
               FAILED ("REDEFINITION OF ""REM"" IS " &
                       "DEFECTIVE");
          END IF;

          IF IDENT_INT (10) MOD IDENT_INT (3) /= 6 THEN
               FAILED ("REDEFINITION OF ""MOD"" IS " &
                       "DEFECTIVE");
          END IF;

          IF IDENT_INT (3) ** IDENT_INT (2) /= 7 THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """**"" IS DEFECTIVE");
          END IF;

          IF + (IDENT_INT (10)) /= 8 THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       "UNARY ""+"" IS DEFECTIVE");
          END IF;

          IF - (IDENT_INT (5)) /= 9 THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       "UNARY ""-"" IS DEFECTIVE");
          END IF;

          IF ABS (IDENT_INT (2)) /= 10 THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """ABS"" IS DEFECTIVE");
          END IF;

          IF IDENT_INT (7) < IDENT_INT (8) THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """<"" IS DEFECTIVE");
          END IF;

          IF IDENT_INT (1) <= IDENT_INT (5) THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """<="" IS DEFECTIVE");
          END IF;

          IF IDENT_INT (3) > IDENT_INT (2) THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """>"" IS DEFECTIVE");
          END IF;

          IF IDENT_INT (6) >= IDENT_INT (4) THEN
               FAILED ("REDEFINITION OF INTEGER " &
                       """>="" IS DEFECTIVE");
          END IF;

     END;

     RESULT;

END C67003A;
