-- C64104O.ADA

-- OBJECTIVE
--    CHECK THAT CONSTRAINT_ERROR IS RAISED AT THE PLACE OF THE CALL
--    FOR THE CASE OF A PRIVATE TYPE IMPLEMENTED AS AN ACCESS TYPE WHERE
--    THE ACTUAL BOUNDS OR DISCRIMINANTS OF THE DESIGNATED OBJECT DIFFER
--    FROM THOSE OF THE FORMAL.

-- HISTORY
--    CPP 7/23/84 CREATED ORIGINAL TEST.
--    DHH 8/31/87 ADDED COMMENT IN PROCEDURE Q SO THAT CODE WILL NOT BE
--                OPTIMIZED OUT OF EXISTENCE.


WITH REPORT;  USE REPORT;
PROCEDURE C64104O IS

BEGIN

     TEST ("C64104O", "CHECK THAT PRIVATE TYPE (ACCESS) RAISES " &
           "CONSTRAINT_ERROR WHEN ACTUAL AND FORMAL PARAMETER BOUNDS " &
           "DIFFER");

     DECLARE


          CALLED : BOOLEAN := FALSE;

          PACKAGE P IS
               TYPE T IS PRIVATE;
               DC : CONSTANT T;
               GENERIC PACKAGE PP IS
               END PP;
          PRIVATE
               TYPE T IS ACCESS STRING;
               DC : CONSTANT T := NEW STRING'("AAA");
          END P;

          PROCEDURE Q (X : IN OUT P.T) IS

          BEGIN

               CALLED := TRUE;
               X := P.DC;
               IF P. "=" (X, P.DC) THEN
                    COMMENT("PROCEDURE Q WAS CALLED");
               END IF;

          EXCEPTION
               WHEN OTHERS =>
                    FAILED ("EXCEPTION RAISED INSIDE SUBPROGRAM");
          END Q;

          GENERIC
               Y : IN OUT P.T;
          PACKAGE CALL IS
          END CALL;

          PACKAGE BODY CALL IS
          BEGIN
               Q(Y);
          END CALL;

          PACKAGE BODY P IS
               Z : T(1..5) := NEW STRING'("CCCCC");
               PACKAGE BODY PP IS
                    PACKAGE CALL_Q IS NEW CALL(Z);
               END PP;
          END P;

     BEGIN
          BEGIN
               DECLARE
                    PACKAGE CALL_Q_NOW IS NEW P.PP;
               BEGIN
                    FAILED ("NO EXCEPTION RAISED");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    IF NOT CALLED THEN
                         FAILED ("SUBPROGRAM Q WAS NOT CALLED");
                    END IF;
               WHEN OTHERS =>
                    FAILED ("WRONG EXCEPTION RAISED");
          END;

          RESULT;
     END;

END C64104O;
