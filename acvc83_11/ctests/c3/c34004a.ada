-- C34004A.ADA

-- OBJECTIVE:
--      CHECK THAT THE REQUIRED PREDEFINED OPERATIONS ARE DECLARED
--      (IMPLICITLY) FOR DERIVED FIXED POINT TYPES.

-- HISTORY:
--      JRK 09/08/86  CREATED ORIGINAL TEST.
--      JET 08/06/87  FIXED BUGS IN DELTAS AND RANGE ERROR.
--      JET 09/22/88  CHANGED USAGE OF X'SIZE.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;

PROCEDURE C34004A IS

     TYPE PARENT IS DELTA 2.0 ** (-7) RANGE -100.0 .. 100.0;

     SUBTYPE SUBPARENT IS PARENT RANGE
               IDENT_INT (1) * (-50.0) ..
               IDENT_INT (1) * ( 50.0);

     TYPE T IS NEW SUBPARENT DELTA 2.0 ** (-4) RANGE
               IDENT_INT (1) * (-30.0) ..
               IDENT_INT (1) * ( 30.0);

     TYPE FIXED IS DELTA 2.0 ** (-4) RANGE -1000.0 .. 1000.0;

     X : T        := -30.0;
     I : INTEGER  := X'SIZE;
     W : PARENT   := -100.0;
     R : CONSTANT := 1.0;
     M : CONSTANT := 100.0;
     B : BOOLEAN  := FALSE;
     F : FLOAT    := 0.0;
     G : FIXED    := 0.0;

     Z : CONSTANT T := 0.0;

     PROCEDURE A (X : ADDRESS) IS
     BEGIN
          B := IDENT_BOOL (TRUE);
     END A;

     FUNCTION IDENT (X : T) RETURN T IS
     BEGIN
          IF EQUAL (3, 3) THEN
               RETURN X;                          -- ALWAYS EXECUTED.
          END IF;
          RETURN T'FIRST;
     END IDENT;

BEGIN
     TEST ("C34004A", "CHECK THAT THE REQUIRED PREDEFINED OPERATIONS " &
                      "ARE DECLARED (IMPLICITLY) FOR DERIVED " &
                      "FIXED POINT TYPES");

     X := IDENT (30.0);
     IF X /= 30.0 THEN
          FAILED ("INCORRECT :=");
     END IF;

     IF T'(X) /= 30.0 THEN
          FAILED ("INCORRECT QUALIFICATION");
     END IF;

     IF T (X) /= 30.0 THEN
          FAILED ("INCORRECT SELF CONVERSION");
     END IF;

     IF EQUAL (3, 3) THEN
          W := -30.0;
     END IF;
     IF T (W) /= -30.0 THEN
          FAILED ("INCORRECT CONVERSION FROM PARENT");
     END IF;

     IF PARENT (X) /= 30.0 OR PARENT (Z - 100.0) /= -100.0 THEN
          FAILED ("INCORRECT CONVERSION TO PARENT");
     END IF;

     IF T (IDENT_INT (-30)) /= -30.0 THEN
          FAILED ("INCORRECT CONVERSION FROM INTEGER");
     END IF;

     IF INTEGER (X) /= 30 OR INTEGER (Z - 100.0) /= -100 THEN
          FAILED ("INCORRECT CONVERSION TO INTEGER");
     END IF;

     IF EQUAL (3, 3) THEN
          F := -30.0;
     END IF;
     IF T (F) /= -30.0 THEN
          FAILED ("INCORRECT CONVERSION FROM FLOAT");
     END IF;

     IF FLOAT (X) /= 30.0 OR FLOAT (Z - 100.0) /= -100.0 THEN
          FAILED ("INCORRECT CONVERSION TO FLOAT");
     END IF;

     IF EQUAL (3, 3) THEN
          G := -30.0;
     END IF;
     IF T (G) /= -30.0 THEN
          FAILED ("INCORRECT CONVERSION FROM FIXED");
     END IF;

     IF FIXED (X) /= 30.0 OR FIXED (Z - 100.0) /= -100.0 THEN
          FAILED ("INCORRECT CONVERSION TO FIXED");
     END IF;

     IF IDENT (R) /= 1.0 OR X = M THEN
          FAILED ("INCORRECT IMPLICIT CONVERSION");
     END IF;

     IF IDENT (30.0) /= 30.0 OR X = 100.0 THEN
          FAILED ("INCORRECT REAL LITERAL");
     END IF;

     IF X = IDENT (0.0) OR X = 100.0 THEN
          FAILED ("INCORRECT =");
     END IF;

     IF X /= IDENT (30.0) OR NOT (X /= 100.0) THEN
          FAILED ("INCORRECT /=");
     END IF;

     IF X < IDENT (30.0) OR 100.0 < X THEN
          FAILED ("INCORRECT <");
     END IF;

     IF X > IDENT (30.0) OR X > 100.0 THEN
          FAILED ("INCORRECT >");
     END IF;

     IF X <= IDENT (0.0) OR 100.0 <= X THEN
          FAILED ("INCORRECT <=");
     END IF;

     IF IDENT (0.0) >= X OR X >= 100.0 THEN
          FAILED ("INCORRECT >=");
     END IF;

     IF NOT (X IN T) OR 100.0 IN T THEN
          FAILED ("INCORRECT ""IN""");
     END IF;

     IF X NOT IN T OR NOT (100.0 NOT IN T) THEN
          FAILED ("INCORRECT ""NOT IN""");
     END IF;

     IF +X /= 30.0 OR +(Z - 100.0) /= -100.0 THEN
          FAILED ("INCORRECT UNARY +");
     END IF;

     IF -X /= 0.0 - 30.0 OR -(Z - 100.0) /= 100.0 THEN
          FAILED ("INCORRECT UNARY -");
     END IF;

     IF ABS X /= 30.0 OR ABS (Z - 100.0) /= 100.0 THEN
          FAILED ("INCORRECT ABS");
     END IF;

     IF X + IDENT (-1.0) /= 29.0 OR X + 70.0 /= 100.0 THEN
          FAILED ("INCORRECT BINARY +");
     END IF;

     IF X - IDENT (30.0) /= 0.0 OR X - 100.0 /= -70.0 THEN
          FAILED ("INCORRECT BINARY -");
     END IF;

     IF T (X * IDENT (-1.0)) /= -30.0 OR
        T (IDENT (2.0) * (Z + 15.0)) /= 30.0 THEN
          FAILED ("INCORRECT * (FIXED, FIXED)");
     END IF;

     IF X * IDENT_INT (-1) /= -30.0 OR (Z + 50.0) * 2 /= 100.0 THEN
          FAILED ("INCORRECT * (FIXED, INTEGER)");
     END IF;

     IF IDENT_INT (-1) * X /= -30.0 OR 2 * (Z + 50.0) /= 100.0 THEN
          FAILED ("INCORRECT * (INTEGER, FIXED)");
     END IF;

     IF T (X / IDENT (3.0)) /= 10.0 OR T ((Z + 90.0) / X) /= 3.0 THEN
          FAILED ("INCORRECT / (FIXED, FIXED)");
     END IF;

     IF X / IDENT_INT (3) /= 10.0 OR (Z + 90.0) / 30 /= 3.0 THEN
          FAILED ("INCORRECT / (FIXED, INTEGER)");
     END IF;

     B := FALSE;
     A (X'ADDRESS);
     IF NOT B THEN
          FAILED ("INCORRECT 'ADDRESS");
     END IF;

     IF T'AFT /= 2 OR T'BASE'AFT < 3 THEN
          FAILED ("INCORRECT 'AFT");
     END IF;

     IF T'BASE'SIZE < 15 THEN
          FAILED ("INCORRECT 'BASE'SIZE");
     END IF;

     IF T'DELTA /= 2.0 ** (-4) OR T'BASE'DELTA > 2.0 ** (-7) THEN
          FAILED ("INCORRECT 'DELTA");
     END IF;

     IF T'FIRST /= -30.0 OR T'BASE'FIRST > -PARENT'SAFE_LARGE THEN
          FAILED ("INCORRECT 'FIRST");
     END IF;

     IF T'FORE /= 3 OR T'BASE'FORE < 4 THEN
          FAILED ("INCORRECT 'FORE");
     END IF;

     DECLARE
          BL : CONSTANT := BOOLEAN'POS (T'BASE'LARGE =
                         (2 ** (T'BASE'MANTISSA - 1) - 1 +
                          2 ** (T'BASE'MANTISSA - 1)) * T'BASE'SMALL);
     BEGIN
          IF T'LARGE /= (2 ** T'MANTISSA - 1) * T'SMALL OR BL = 0 THEN
               FAILED ("INCORRECT 'LARGE");
          END IF;
     END;

     IF T'LAST /= 30.0 OR T'BASE'LAST < PARENT'SAFE_LARGE THEN
          FAILED ("INCORRECT 'LAST");
     END IF;

     IF T'MACHINE_OVERFLOWS /= T'BASE'MACHINE_OVERFLOWS THEN
          FAILED ("INCORRECT 'MACHINE_OVERFLOWS");
     END IF;

     IF T'MACHINE_ROUNDS /= T'BASE'MACHINE_ROUNDS THEN
          FAILED ("INCORRECT 'MACHINE_ROUNDS");
     END IF;

     IF T'MANTISSA /= 9 OR T'BASE'MANTISSA < 14 THEN
          FAILED ("INCORRECT 'MANTISSA");
     END IF;

     IF T'SAFE_LARGE /= T'BASE'LARGE OR
        T'BASE'SAFE_LARGE /= T'SAFE_LARGE THEN
          FAILED ("INCORRECT 'SAFE_LARGE");
     END IF;

     IF T'SAFE_SMALL /= T'BASE'SMALL OR
        T'BASE'SAFE_SMALL /= T'SAFE_SMALL THEN
          FAILED ("INCORRECT 'SAFE_SMALL");
     END IF;

     IF T'SIZE < 10 THEN
          FAILED ("INCORRECT TYPE'SIZE");
     END IF;

     IF T'SMALL /= 2.0 ** (-4) OR T'BASE'SMALL > 2.0 ** (-7) THEN
          FAILED ("INCORRECT 'SMALL");
     END IF;

     RESULT;
END C34004A;
