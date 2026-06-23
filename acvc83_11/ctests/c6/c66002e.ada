-- C66002E.ADA

-- CHECK THAT OVERLOADED SUBPROGRAM DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (E) ONE SUBPROGRAM IS DECLARED IN AN OUTER DECLARATIVE
--         PART, THE OTHER IN AN INNER PART, AND THE PARAMETERS ARE 
--         ORDERED DIFFERENTLY.

-- CVP 5/4/81
-- JRK 5/8/81
-- NL 10/13/81

WITH REPORT;
PROCEDURE C66002E IS

     USE REPORT;

BEGIN
     TEST ("C66002E", "SUBPROGRAM OVERLOADING WITH " &
           "MINIMAL DIFFERENCES ALLOWED");

     --------------------------------------------------

     -- ONE SUBPROGRAM IS DECLARED IN AN OUTER
     -- DECLARATIVE PART, THE OTHER IN AN INNER
     -- PART, AND THE PARAMETERS ARE ORDERED
     -- DIFFERENTLY.

     DECLARE
          S : STRING (1..2) := "12";

          PROCEDURE P (I1 : INTEGER; I2 : IN OUT INTEGER;
                       B1 : BOOLEAN) IS
          BEGIN
               S(1) := 'A';
          END P;

     BEGIN
          DECLARE
               I : INTEGER := 0;

               PROCEDURE P (B1 : BOOLEAN; I1 : INTEGER;
                            I2 : IN OUT INTEGER) IS
               BEGIN
                    S(2) := 'B';
               END P;

          BEGIN
               P (5, I, TRUE);
               P (TRUE, 5, I);
               -- NOTE THAT A CALL IN WHICH ALL ACTUAL PARAMETERS 
               -- ARE NAMED_ASSOCIATIONS IS AMBIGUOUS.

               IF S /= "AB" THEN
                    FAILED ("PROCEDURES IN " &
                            "ENCLOSING-ENCLOSED SCOPES " &
                            "DIFFERING ONLY IN PARAMETER " &
                            "TYPE ORDER CAUSED CONFUSION");
               END IF;
          END;
     END;

     --------------------------------------------------

     RESULT;

END C66002E;
