-- C64105D.ADA

-- CHECK THAT CONSTRAINT_ERROR IS NOT RAISED FOR ACCESS PARAMETERS
--   IN THE FOLLOWING CIRCUMSTANCES:
--       (1)
--       (2)
--       (3) BEFORE OR AFTER THE CALL, WHEN AN UNCONSTRAINED ACTUAL 
--           OUT ACCESS PARAMETER DESIGNATES AN OBJECT (PRIOR TO THE
--           CALL) WITH CONSTRAINTS DIFFERENT FROM THE FORMAL
--           PARAMETER.
--   SUBTESTS ARE:
--       (G) CASE 3, STATIC LIMITED PRIVATE DISCRIMINANT.
--       (H) CASE 3, DYNAMIC ONE DIMENSIONAL BOUNDS.

-- JRK 3/20/81
-- SPS 10/26/82

WITH REPORT;
PROCEDURE C64105D IS

     USE REPORT;

BEGIN
     TEST ("C64105D", "CHECK THAT CONSTRAINT_ERROR IS NOT RAISED " &
           "BEFORE AND AFTER THE CALL, WHEN AN UNCONSTRAINED ACTUAL " &
           "OUT ACCESS PARAMETER DESIGNATES AN OBJECT (PRIOR TO THE " &
           "CALL) WITH CONSTRAINTS DIFFERENT FROM THE FORMAL " &
           "PARAMETER" );

     --------------------------------------------------

     DECLARE -- (G)

          PACKAGE PKG IS
               SUBTYPE INT IS INTEGER RANGE 0..5;
               TYPE T (I : INT := 0) IS LIMITED PRIVATE; 
          PRIVATE          
               TYPE ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;
               TYPE T (I : INT := 0) IS 
                    RECORD
                         J : INTEGER;
                         A : ARR (1..I);
                    END RECORD;
          END PKG;
          USE PKG;

          TYPE A IS ACCESS T;
          SUBTYPE SA IS A(3);
          V : A := NEW T (2);
          CALLED : BOOLEAN := FALSE;

          PROCEDURE P (X : OUT SA) IS
          BEGIN
               CALLED := TRUE;
               X := NEW T (3);
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (G)");
          END P;

     BEGIN -- (G)
 
          P (V);

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (G)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (G)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (G)");
     END; -- (G)

     --------------------------------------------------

     DECLARE -- (H)

          TYPE A IS ACCESS STRING;
          SUBTYPE SA IS A (1..2);
          V : A := NEW STRING (IDENT_INT(5) .. IDENT_INT(7));
          CALLED : BOOLEAN := FALSE;

          PROCEDURE P (X : OUT SA) IS
          BEGIN
               CALLED := TRUE;
               X := NEW STRING (IDENT_INT(1) .. IDENT_INT(2));
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED IN PROCEDURE - (H)");
          END P;

     BEGIN -- (H)

          P (V);

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF NOT CALLED THEN
                    FAILED ("EXCEPTION RAISED BEFORE CALL - (H)");
               ELSE
                    FAILED ("EXCEPTION RAISED ON RETURN - (H)");
               END IF;
          WHEN OTHERS =>
               FAILED ("EXCEPTION RAISED - (H)");
     END; -- (H)

     --------------------------------------------------

     RESULT;
END C64105D;
