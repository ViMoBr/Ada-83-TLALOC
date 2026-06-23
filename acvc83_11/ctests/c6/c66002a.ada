-- C66002A.ADA

-- CHECK THAT OVERLOADED SUBPROGRAM DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (A) ONE SUBPROGRAM IS A FUNCTION; THE OTHER IS A PROCEDURE.

-- CVP 5/4/81
-- JRK 5/8/81
-- NL 10/13/81
-- SPS 11/2/82

WITH REPORT;
PROCEDURE C66002A IS

     USE REPORT;

BEGIN
     TEST ("C66002A", "SUBPROGRAM OVERLOADING WITH " &
           "MINIMAL DIFFERENCES ALLOWED");

     --------------------------------------------------

     -- ONE SUBPROGRAM IS A PROCEDURE; THE OTHER IS
     -- A FUNCTION. BOTH PARAMETERIZED AND PARAMETERLESS
     -- SUBPROGRAMS ARE TESTED.

     DECLARE
          I, J, K : INTEGER := 0;
          S : STRING (1..2) := "12";

          PROCEDURE P1 (I1, I2 : INTEGER) IS
          BEGIN
               S(1) := 'A';
          END P1;

          FUNCTION P1 (I1, I2 : INTEGER) RETURN INTEGER IS
          BEGIN
               S(2) := 'B';
               RETURN I1; -- RETURNED VALUE IS IRRELEVENT.
          END P1;

          PROCEDURE P2 IS
          BEGIN
               S(1) := 'C';
          END P2;

          FUNCTION P2 RETURN INTEGER IS
          BEGIN
               S(2) := 'D';
               RETURN I; -- RETURNED VALUE IS IRRELEVENT.
          END P2;

     BEGIN
          P1 (I, J);
          K := P1 (I, J);

          IF S /= "AB" THEN
               FAILED ("PARAMETERIZED OVERLOADED " &
                       "SUBPROGRAMS, ONE A PROCEDURE AND " &
                       "THE OTHER A FUNCTION, CAUSED " &
                       "CONFUSION");
          END IF;

          S := "12";
          P2;
          K := P2 ;

          IF S /= "CD" THEN 
               FAILED ("PARAMETERLESS OVERLOADED " &
                       "SUBPROGRAMS, ONE A PROCEDURE AND " &
                       "THE OTHER A FUNCTION, CAUSED " &
                       "CONFUSION");
          END IF;
     END;

     --------------------------------------------------

     RESULT;

END C66002A;
