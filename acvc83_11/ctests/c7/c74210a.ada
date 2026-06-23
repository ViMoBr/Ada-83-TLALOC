-- C74210A.ADA

-- CHECK THAT OPERATOR SYMBOLS OVERLOADED IN A PACKAGE ARE
--   USED AND DERIVED IN PREFERENCE TO THOSE OF THE PARENT OF A DERIVED
--   PRIVATE TYPE. 

-- CHECK THAT OPERATOR DEFINITIONS FOR A PRIVATE TYPE MAY BE
--   OVERLOADED OUTSIDE THE PACKAGE.

-- CHECK THAT EQUALITY CAN BE DEFINED FOR LIMITED TYPES AND COMPOSITE
--   TYPES WITH LIMITED COMPONENTS. 

-- DAT 5/11/81

WITH REPORT; USE REPORT;

PROCEDURE C74210A IS
BEGIN
     TEST ("C74210A", "OVERLOADED OPERATORS FOR PRIVATE TYPES");

     DECLARE
          PACKAGE P IS
               TYPE T IS PRIVATE;
               FUNCTION "+" (X, Y : T) RETURN T;
               ONE, TWO : CONSTANT T;

               TYPE L IS LIMITED PRIVATE;
               TYPE A IS ARRAY (0 .. 0) OF L;
               TYPE R IS RECORD
                    C : L;
               END RECORD;
               FUNCTION "=" (X, Y : L) RETURN BOOLEAN;
          PRIVATE
               TYPE T IS NEW INTEGER;
               ONE : CONSTANT T := T(IDENT_INT(1));
               TWO : CONSTANT T := T(IDENT_INT(2));
               TYPE L IS (ENUM);
          END P;
          USE P;

          VR : R;
          VA : A;

          PACKAGE BODY P IS
               FUNCTION "+" (X, Y : T) RETURN T IS
               BEGIN
                    RETURN 1;
               END "+";

               FUNCTION "=" (X, Y : L) RETURN BOOLEAN IS
               BEGIN
                    RETURN IDENT_BOOL(FALSE);
               END "=";
          BEGIN
               VR := (C => ENUM);
               VA := (0 => VR.C);
          END P;
     BEGIN
          IF ONE + TWO /= ONE THEN
               FAILED ("WRONG ""+"" OPERATOR");
          END IF;

          DECLARE
               TYPE NEW_T IS NEW T;

               FUNCTION "=" (X, Y : A) RETURN BOOLEAN;
               FUNCTION "=" (X, Y : R) RETURN BOOLEAN;

               FUNCTION "+" (X, Y : T) RETURN T IS
               BEGIN
                    RETURN TWO;
               END "+";

               FUNCTION "=" (X, Y : A) RETURN BOOLEAN IS
               BEGIN
                    RETURN X(0) = Y(0);
               END "=";

               FUNCTION "=" (X, Y : R) RETURN BOOLEAN IS
               BEGIN
                    RETURN X.C = Y.C;
               END "=";
          BEGIN
               IF ONE + TWO /= TWO THEN
                    FAILED ("WRONG DERIVED ""+"" OPERATOR");
               END IF;

               IF VR = VR OR VA = VA THEN
                    FAILED ("CANNOT OVERLOAD ""="" CORRECTLY");
               END IF;
          END;
     END;

     RESULT;
END C74210A;
