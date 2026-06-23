-- C66002F.ADA

-- CHECK THAT OVERLOADED SUBPROGRAM DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (F) ONE SUBPROGRAM IS DECLARED IN AN OUTER DECLARATIVE PART,
--         THE OTHER IN AN INNER PART, AND ONE HAS ONE MORE PARAMETER
--         THAN THE OTHER; THE OMITTED PARAMETER HAS A DEFAULT VALUE.

-- CVP 5/4/81
-- JRK 5/8/81
-- NL 10/13/81

WITH REPORT;
PROCEDURE C66002F IS

     USE REPORT;

BEGIN
     TEST ("C66002F", "SUBPROGRAM OVERLOADING WITH " &
           "MINIMAL DIFFERENCES ALLOWED");

     --------------------------------------------------

     -- ONE SUBPROGRAM IS IN AN OUTER DECLARATIVE 
     -- PART, THE OTHER IN AN INNER PART, AND ONE
     -- HAS ONE MORE PARAMETER (WITH A DEFAULT
     -- VALUE) THAN THE OTHER.

     BF : 
     DECLARE
          S : STRING (1..3) := "123";

          PROCEDURE P (I1, I2, I3 : INTEGER := 1) IS
               C : CONSTANT STRING := "CXA";
          BEGIN
               S(I3) := C(I3);
          END P;

          PROCEDURE ENCLOSE IS
 
               PROCEDURE P (I1, I2 : INTEGER := 1) IS
               BEGIN
                    S(2) := 'B';
               END P;

          BEGIN -- ENCLOSE
               P (1, 2, 3);
               ENCLOSE.P (1, 2); -- NOTE THAT THESE CALLS
               BF.P (1, 2);      -- MUST BE DISAMBIGUATED.

               IF S /= "CBA" THEN
                    FAILED ("PROCEDURES IN ENCLOSING-" &
                            "ENCLOSED SCOPES DIFFERING " &
                            "ONLY IN EXISTENCE OF ONE " &
                            "DEFAULT-VALUED PARAMETER CAUSED " &
                            "CONFUSION");
               END IF;
          END ENCLOSE;

     BEGIN
          ENCLOSE;
     END BF;

     --------------------------------------------------

     RESULT;

END C66002F;
