-- C67003B.ADA

-- CHECK THAT THE PREDEFINED OPERATORS FOR THE PREDEFINED TYPE FLOAT
--   CAN BE REDEFINED.
-- CHECK THAT THE REDEFINED OPERATOR IS INVOKED WHEN INFIX
--   NOTATION IS USED.

-- CVP 5/19/81
-- JRK 7/17/81
-- CPP 6/27/84

WITH REPORT;
PROCEDURE C67003B IS

     USE REPORT;

     -- NOTE THAT ALL LITERAL VALUES USED SHOULD BE
     --   REPRESENTABLE EXACTLY.

     FUNCTION IDENT_FLOAT (X : FLOAT) RETURN FLOAT IS
          I : INTEGER := INTEGER (X);
     BEGIN
          IF EQUAL (I, I) THEN          -- ALWAYS EQUAL.
               RETURN X;
          END IF;
          RETURN 0.0;
     END IDENT_FLOAT;

BEGIN
     TEST ("C67003B", "CHECK THAT REDEFINITION OF OPERATORS " &
                      "FOR FLOAT TYPE WORKS");

     DECLARE

          -- FLOAT INFIX OPERATORS.

          FUNCTION "+" (X, Y : FLOAT) RETURN FLOAT IS
          BEGIN
               IF X /= Y THEN
                    RETURN 1.0;
               ELSE RETURN 0.0;
               END IF;
          END "+";

          FUNCTION "-" (X, Y : FLOAT) RETURN FLOAT IS
          BEGIN
               IF X /= Y THEN
                    RETURN 2.0;
               ELSE RETURN 0.0;
               END IF;
          END "-";

          FUNCTION "*" (X, Y : FLOAT) RETURN FLOAT IS
          BEGIN
               IF X /= Y THEN
                    RETURN 3.0;
               ELSE RETURN 0.0;
               END IF;
          END "*";

          FUNCTION "/" (X, Y : FLOAT) RETURN FLOAT IS
          BEGIN
               IF X /= Y THEN
                    RETURN 4.0;
               ELSE RETURN 0.0;
               END IF;
          END "/";

          FUNCTION "**" (X : FLOAT; Y : INTEGER) RETURN FLOAT IS
          BEGIN
               IF INTEGER (X) /= Y THEN
                    RETURN 5.0;
               ELSE RETURN 0.0;
               END IF;
          END "**";

          -- FLOAT PREFIX OPERATORS.

          FUNCTION "+" (X : FLOAT) RETURN FLOAT IS
          BEGIN
               IF X /= 0.0 THEN
                    RETURN 6.0;
               ELSE RETURN 0.0;
               END IF;
          END "+";

          FUNCTION "-" (X : FLOAT) RETURN FLOAT IS
          BEGIN
               IF X /= 0.0 THEN
                    RETURN 7.0;
               ELSE RETURN 0.0;
               END IF;
          END "-";

          FUNCTION "ABS" (X : FLOAT) RETURN FLOAT IS
          BEGIN
               IF X /= 0.0 THEN
                    RETURN 8.0;
               ELSE RETURN 0.0;
               END IF;
          END "ABS";

          -- FLOAT RELATIONAL OPERATORS.

          FUNCTION "<" (X, Y : FLOAT) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<";

          FUNCTION "<=" (X, Y : FLOAT) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END "<=";

          FUNCTION ">" (X, Y : FLOAT) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">";

          FUNCTION ">=" (X, Y : FLOAT) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END ">=";

     BEGIN

          IF IDENT_FLOAT (1.0) + IDENT_FLOAT (30.0) /= 1.0 THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """+"" IS DEFECTIVE");
          END IF;

          IF IDENT_FLOAT (50.0) - IDENT_FLOAT (100.0) /= 2.0 THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """-"" IS DEFECTIVE");
          END IF;

          IF IDENT_FLOAT (3.0) * IDENT_FLOAT (5.0) /= 3.0 THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """*"" IS DEFECTIVE");
          END IF;

          IF IDENT_FLOAT (5.0) / IDENT_FLOAT (1.0) /= 4.0 THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """/"" IS DEFECTIVE");
          END IF;

          IF IDENT_FLOAT (3.0) ** IDENT_INT (2) /= 5.0 THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """**"" IS DEFECTIVE");
          END IF;

          IF +(IDENT_FLOAT (10.0)) /= 6.0 THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       "UNARY ""+"" IS DEFECTIVE");
          END IF;

          IF -(IDENT_FLOAT (5.0)) /= 7.0 THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       "UNARY ""-"" IS DEFECTIVE");
          END IF;

          IF ABS(IDENT_FLOAT (3.0)) /= 8.0 THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       "UNARY ""ABS"" IS DEFECTIVE");
          END IF;

          IF IDENT_FLOAT (7.0) < IDENT_FLOAT (8.0) THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """<"" IS DEFECTIVE");
          END IF;

          IF IDENT_FLOAT (1.0) <= IDENT_FLOAT (5.0) THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """<="" IS DEFECTIVE");
          END IF;

          IF IDENT_FLOAT (3.0) > IDENT_FLOAT (2.0) THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """>"" IS DEFECTIVE");
          END IF;

          IF IDENT_FLOAT (6.0) >= IDENT_FLOAT (4.0) THEN
               FAILED ("REDEFINITION OF FLOAT " &
                       """>="" IS DEFECTIVE");
          END IF;

     END;

     RESULT;
END C67003B;
