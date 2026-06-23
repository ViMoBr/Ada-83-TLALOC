-- C66002D.ADA

-- CHECK THAT OVERLOADED SUBPROGRAM DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (D) THE BASE TYPE OF A PARAMETER IS DIFFERENT FROM THAT
--         OF THE CORRESPONDING ONE.

-- CVP 5/4/81
-- JRK 5/8/81
-- NL 10/13/81

WITH REPORT;
PROCEDURE C66002D IS

     USE REPORT;

BEGIN
     TEST ("C66002D", "SUBPROGRAM OVERLOADING WITH " &
           "MINIMAL DIFFERENCES ALLOWED");

     --------------------------------------------------

     -- THE BASE TYPE OF ONE PARAMETER IS
     -- DIFFERENT FROM THAT OF THE CORRESPONDING
     -- ONE.

     DECLARE
          I, J, K : INTEGER := 0;
          B : BOOLEAN;
          S : STRING (1..2) := "12";

          PROCEDURE P (I1 : INTEGER; BI : OUT BOOLEAN;
                       I2 : IN OUT INTEGER) IS
          BEGIN
               S(1) := 'A';
               BI := TRUE; -- THIS VALUE IS IRRELEVENT.
          END P;

          PROCEDURE P (I1 : INTEGER; BI : OUT INTEGER;
               I2 : IN OUT INTEGER) IS
          BEGIN
               S(2) := 'B';
               BI := 0; -- THIS VALUE IS IRRELEVENT.
          END P;

     BEGIN
          P (I, B, K);
          P (I, J, K);

          IF S /= "AB" THEN
               FAILED ("PROCEDURES DIFFERING ONLY BY " &
                       "THE BASE TYPE OF A PARAMETER " &
                       "CAUSED CONFUSION");
          END IF;
     END;

     --------------------------------------------------

     RESULT;

END C66002D;
