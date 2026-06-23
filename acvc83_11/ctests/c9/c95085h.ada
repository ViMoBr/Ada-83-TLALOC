-- C95085H.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED UNDER THE APPROPRIATE
-- CIRCUMSTANCES FOR ACCESS PARAMETERS IN ENTRY CALLS, NAMELY WHEN
-- THE ACTUAL INDEX BOUNDS OR DISCRIMINANTS ARE NOT EQUAL
-- TO THE FORMAL CONSTRAINTS BEFORE THE CALL (FOR IN AND IN OUT
-- MODES), AND WHEN THE FORMAL CONSTRAINTS ARE NOT EQUAL TO THE
-- ACTUAL CONSTRAINTS UPON RETURN (FOR IN OUT AND OUT MODES).

--       (E) AFTER RETURN, IN OUT MODE, STATIC LIMITED PRIVATE
--           DISCRIMINANTS.

-- JWC 10/23/85

WITH REPORT; USE REPORT;
PROCEDURE C95085H IS

BEGIN
     TEST ("C95085H", "CHECK THAT CONSTRAINT_ERROR IS RAISED " &
                      "APPROPRIATELY FOR ACCESS PARAMETERS");

     --------------------------------------------------

     DECLARE

          CALLED : BOOLEAN := FALSE;

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

          TYPE A IS ACCESS T;

          V : A (2,'B') := NEW T (2,'B');

          TASK TSK IS
               ENTRY E (X : IN OUT A);
          END TSK;

          TASK BODY TSK IS
          BEGIN
               SELECT
                    ACCEPT E (X : IN OUT A) DO
                         CALLED := TRUE;
                         X := NEW T (2,'A');
                    END E;
               OR
                    TERMINATE;
               END SELECT;
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN TASK BODY");
          END TSK;

     BEGIN

          TSK.E (V);
          FAILED ("EXCEPTION NOT RAISED AFTER RETURN");

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL");
               END IF;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED");
     END;

     --------------------------------------------------

     RESULT;
END C95085H;
