-- C66002C.ADA

-- CHECK THAT OVERLOADED SUBPROGRAM DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (C) ONE SUBPROGRAM HAS ONE LESS PARAMETER THAN THE OTHER.

-- CVP 5/4/81
-- JRK 5/8/81
-- NL 10/13/81

WITH REPORT;
PROCEDURE C66002C IS

     USE REPORT;

BEGIN
     TEST ("C66002C", "SUBPROGRAM OVERLOADING WITH " &
           "MINIMAL DIFFERENCES ALLOWED");

     --------------------------------------------------

     -- ONE PROCEDURE HAS ONE MORE PARAMETER
     -- THAN THE OTHER.  THIS IS TESTED IN THE
     -- CASE IN WHICH THAT PARAMETER HAS A DEFAULT
     -- VALUE, AND THE CASE IN WHICH IT DOES NOT.

     DECLARE
          I, J : INTEGER := 0;
          B : BOOLEAN := TRUE;
          S : STRING (1..2) := "12";

          PROCEDURE P1 (I1, I2 : INTEGER; B1 : IN OUT BOOLEAN) IS
          BEGIN
               S(1) := 'A';
          END P1;

          PROCEDURE P1 (I1, I2 : INTEGER) IS
          BEGIN
               S(2) := 'B';
          END P1;

          PROCEDURE P2 (B1 : IN OUT BOOLEAN; I1 : INTEGER := 0) IS
          BEGIN
               S(1) := 'C';
          END P2;

          PROCEDURE P2 (B1 : IN OUT BOOLEAN) IS
          BEGIN
               S(2) := 'D';
          END P2;

     BEGIN
          P1 (I, J, B);
          P1 (I, J);

          IF S /= "AB" THEN
               FAILED ("PROCEDURES DIFFERING ONLY IN " &
                       "NUMBER OF PARAMETERS (NO DEFAULTS) " &
                       "CAUSED CONFUSION");
          END IF;

          S := "12";
          P2 (B, I);
          -- NOTE THAT A CALL TO P2 WITH ONLY
          -- ONE PARAMETER IS AMBIGUOUS.

          IF S /= "C2" THEN
               FAILED ("PROCEDURES DIFFERING ONLY IN " &
                       "EXISTENCE OF ONE PARAMETER (WITH " &
                       "DEFAULT) CAUSED CONFUSION");
          END IF;
     END;

     --------------------------------------------------

     RESULT;

END C66002C;
