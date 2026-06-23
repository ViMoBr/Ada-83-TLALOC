-- C66002G.ADA

-- CHECK THAT OVERLOADED SUBPROGRAM DECLARATIONS
-- ARE PERMITTED IN WHICH THERE IS A MINIMAL
-- DIFFERENCE BETWEEN THE DECLARATIONS.

--     (G) THE RESULT TYPE OF TWO FUNCTION DECLARATIONS IS DIFFERENT.

-- CVP 5/4/81
-- JRK 5/8/81
-- NL 10/13/81
-- SPS 10/26/82

WITH REPORT;
PROCEDURE C66002G IS

     USE REPORT;

BEGIN
     TEST ("C66002G", "SUBPROGRAM OVERLOADING WITH " &
           "MINIMAL DIFFERENCES ALLOWED");

     --------------------------------------------------

     -- THE RESULT TYPES OF TWO FUNCTION
     -- DECLARATIONS ARE DIFFERENT.

     DECLARE
          I : INTEGER;
          B : BOOLEAN;
          S : STRING (1..2) := "12";

          FUNCTION F RETURN INTEGER IS
          BEGIN
               S(1) := 'A';
               RETURN IDENT_INT (0); -- THIS VALUE IS IRRELEVENT.
          END F;

          FUNCTION F RETURN BOOLEAN IS
          BEGIN
               S(2) := 'B';
               RETURN IDENT_BOOL (TRUE); -- THIS VALUE IS IRRELEVANT.
          END F;

     BEGIN
          I := F;
          B := F;

          IF S /= "AB" THEN
               FAILED ("FUNCTIONS DIFFERING ONLY IN " &
                       "BASE TYPE OF RETURNED VALUE " &
                       "CAUSED CONFUSION");
          END IF;
     END;

     --------------------------------------------------

     RESULT;

END C66002G;
