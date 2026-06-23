-- C64104H.ADA

-- OBJECTIVE:
--     CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
--     CIRCUMSTANCES FOR ACCESS PARAMETERS, NAMELY WHEN THE
--     ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
--     TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
--     MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE
--     ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--         (E) AFTER RETURN, IN OUT MODE, STATIC LIMITED PRIVATE
--             DISCRIMINANTS.

-- HISTORY:
--     JRK 03/18/81  CREATED ORIGINAL TEST.
--     NL  10/13/81
--     LB  11/25/86  ADDED CODE TO ENSURE THAT SUBPROGRAMS ARE
--                   ACTUALLY BEING CALLED.
--     BCB 11/12/87  CHANGED HEADER TO STANDARD FORMAT.


WITH REPORT;
PROCEDURE C64104H IS

     USE REPORT;

BEGIN
     TEST ("C64104H", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
           "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE

          PACKAGE PKG IS
               SUBTYPE INT IS INTEGER RANGE 0..10;
               SUBTYPE CHAR IS CHARACTER RANGE 'A' .. 'C';
               TYPE T (I : INT := 0; C : CHAR := 'A') IS
                    LIMITED PRIVATE;
          PRIVATE
               TYPE T (I : INT := 0; C : CHAR := 'A') IS
                    RECORD
                         J : INTEGER;
                         CASE C IS
                              WHEN 'A' =>
                                   K : INTEGER;
                              WHEN 'B' =>
                                   S : STRING (1..I);
                              WHEN OTHERS =>
                                   NULL;
                         END CASE;
                    END RECORD;
          END PKG;
          USE PKG;

          CALLED : BOOLEAN;
          TYPE A IS ACCESS T;

          V : A (2,'B') := NEW T (2,'B');

          PROCEDURE P (X : IN OUT A) IS
          BEGIN
               CALLED := TRUE;
               X := NEW T (2,'A');
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE");
          END P;

     BEGIN

          CALLED := FALSE;
          P (V);
          FAILED ("EXCEPTION NOT RAISED AFTER RETURN");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("SUBPROGRAM P WAS NOT CALLED");
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED");
     END;

     --------------------------------------------------

     RESULT;

END C64104H;
