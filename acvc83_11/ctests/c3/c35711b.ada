-- C35711B.ADA

-- OBJECTIVE:
--     CHECK THAT INCOMPATIBLE FLOATING POINT CONSTRAINTS RAISE
--     CONSTRAINT_ERROR FOR GENERIC FORMAL TYPES.

-- HISTORY:
--     RJW 08/25/86  CREATED ORIGINAL TEST.
--     VCL 08/18/87  MOVED THE 3 EXCEPTION BLOCKS TO INSIDE THE
--                   PRECEDING DECLARE BLOCKS.
--                   ADDED A NEW EXCEPTION BLOCK AFTER EACH DECLARE
--                   BLOCK TO INDICATE AN INCORRECT EXCEPTION ON
--                   PROCEDURE INSTANTIATION.
--                   ADDED A 4TH CASE (FPT4) IN WHICH ALL CONSTRAINTS
--                   ARE WITHIN LIMITS AND NO EXCEPTIONS SHOULD BE
--                   RAISED.

WITH REPORT; USE REPORT;
PROCEDURE C35711B IS

     GENERIC
          TYPE FPT IS DIGITS <>;
     PROCEDURE GP1 (STR : STRING);

     PROCEDURE GP1 (STR : STRING) IS
          SUBTYPE SFPT IS FPT DIGITS 4 RANGE -2.0 .. 2.0;
          SFP : SFPT;
     BEGIN
          SFP := 0.0;
          FAILED ( "NO EXCEPTION RAISED FOR " & STR);
     END GP1;

BEGIN

     TEST ( "C35711B", "CHECK THAT INCOMPATIBLE FLOATING POINT " &
                       "CONSTRAINTS RAISE CONSTRAINT_ERROR " &
                       "FOR GENERIC FORMAL TYPES" );


-- TEST FOR INCOMPATIBLE FLOATING POINT CONSTRAINT IN A  SUBTYPE
-- DEFINITION.

     BEGIN

          DECLARE

               TYPE FPT1 IS DIGITS 3
                         RANGE -2.0 .. 2.0;   -- DIGITS IS LARGER IN
                                              -- SUBTYPE THAN IN TYPE
                                              -- DEFINITION.

               PROCEDURE P1 IS NEW GP1 (FPT1);
          BEGIN
               P1 ( "INCOMPATIBLE DIGITS" );

          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "INCORRECT EXCEPTION RAISED WHILE " &
                             "CHECKING DIGITS CONSTRAINT" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "EXCEPTION RAISED WHILE " &
                         "INSTANTIATING 'P1'");
     END;

-- TEST THAT CONSTRAINT_ERROR IS RAISED FOR A RANGE VIOLATION.

     BEGIN

          DECLARE

               TYPE FPT2 IS DIGITS 4 RANGE -1.0 .. 2.0;  -- LOWER
                                                         -- BOUND.

               PROCEDURE P2 IS NEW GP1 (FPT2);
          BEGIN
               P2 ( "FLOATING POINT LOWER BOUND CONSTRAINT " &
                    "VIOLATION" );
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "INCORRECT EXCEPTION RAISED WHILE " &
                             "CHECKING LOWER BOUND FLOATING POINT " &
                             "CONSTRAINT" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "EXCEPTION RAISED WHILE " &
                         "INSTANTIATING 'P2'");
     END;

-- TEST THAT CONSTRAINT_ERROR IS RAISED FOR A RANGE VIOLATION.

     BEGIN

          DECLARE

               TYPE FPT3 IS DIGITS 4 RANGE -2.0 .. 1.0;  -- UPPER
                                                         -- BOUND.

               PROCEDURE P3 IS NEW GP1 (FPT3);
          BEGIN
               P3 ( "FLOATING POINT UPPER BOUND CONSTRAINT " &
                    "VIOLATION" );
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "INCORRECT EXCEPTION RAISED WHILE " &
                             "CHECKING UPPER BOUND FLOATING POINT " &
                             "CONSTRAINT" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "EXCEPTION RAISED WHILE " &
                         "INSTANTIATING 'P3'");
     END;

-- TEST THAT NO EXCEPTIONS ARE RAISED WHEN ALL CONSTRAINTS ARE WITHIN
-- LIMITS.

     BEGIN

          DECLARE

               TYPE FPT4 IS DIGITS 5 RANGE -3.0 .. 3.0;

               GENERIC
                    TYPE FPT IS DIGITS <>;
               PROCEDURE GP2;

               PROCEDURE GP2 IS
                    SUBTYPE SFPT IS FPT DIGITS 4 RANGE -2.0 .. 2.0;
                    SFP : SFPT;
               BEGIN
                    SFP := 0.0;
               END GP2;

               PROCEDURE P4 IS NEW GP2 (FPT4);
          BEGIN
               P4;

          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "EXCEPTION RAISED BY 'P4' WHEN ALL " &
                             "CONSTRAINTS ARE WITHIN LIMITS" );
          END;

     EXCEPTION
          WHEN OTHERS =>
               FAILED ( "EXCEPTION RAISED WHILE INSTANTIATING 'P4'" );
     END;

     RESULT;

END C35711B;
