-- C49022B.ADA

-- CHECK THAT IN NUMBER DECLARATIONS, IDENTIFIERS CORRECTLY REPRESENT
-- VALUES OF OTHER LITERALS.

-- BAW 29 SEPT 80
-- TBN 10/22/85     RENAMED FROM C4A003A.ADA AND ADDED RELATIONAL 
--                  OPERATORS USING NAMED NUMBERS.


WITH REPORT;
PROCEDURE C49022B IS

     USE REPORT;

     A : CONSTANT := 10;                     -- A =  10
     B : CONSTANT := 25 - (2 * A);           -- B =   5
     C : CONSTANT := A / B;                  -- C =   2
     D : CONSTANT := (C * A) - (B - C);      -- D =  17
     E : CONSTANT := D ** C;                 -- E = 289
     F : CONSTANT := (E MOD A) + 1;          -- F =  10
     G : CONSTANT := A REM B + C + D + E + ABS(-F);  -- G = 318
     H : CONSTANT := BOOLEAN'POS (A > B);    -- H = 1
     I : CONSTANT := BOOLEAN'POS (A < B);    -- I = 0
     J : CONSTANT := BOOLEAN'POS (C >= A);   -- J = 0
     K : CONSTANT := BOOLEAN'POS (B <= B);   -- K = 1
     L : CONSTANT := BOOLEAN'POS (D = A);    -- L = 0
     M : CONSTANT := BOOLEAN'POS (A /= F);   -- M = 0

BEGIN
     TEST("C49022B","CHECK THAT IN NUMBER DECLARATIONS, IDENTIFIERS " &
                    "CORRECTLY REPRESENT VALUES OF OTHER LITERALS");

     IF G /= 318 THEN
          FAILED("USE OF OTHER NUMBER DECLARATIONS GIVES " &
                 "WRONG RESULTS");
     END IF;

     IF H /= 1 OR I /= 0 OR J /= 0 OR K /= 1 THEN
          FAILED("USE OF NAMED NUMBERS AND RELATIONAL OPERATORS " &
                 "GIVES WRONG RESULTS");
     END IF;

     IF L /= 0 OR M /= 0 THEN
          FAILED("USE OF NAMED NUMBERS AND EQUALITY OPERATORS " &
                 "GIVES WRONG RESULTS");
     END IF;

     RESULT;

END C49022B;
