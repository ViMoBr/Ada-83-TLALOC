-- C64104N.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED AT THE PLACE OF THE CALL
-- FOR THE CASE OF A PRIVATE TYPE IMPLEMENTED AS A SCALAR TYPE
-- WHERE THE VALUE OF THE FORMAL PARAMETER DOES NOT BELONG TO THE
-- SUBTYPE OF THE ACTUAL PARAMETER.

-- DAVID A. TAFFS
-- CPP 7/23/84

WITH REPORT; USE REPORT;
PROCEDURE C64104N IS

BEGIN
     TEST ("C64104N", "CHECK THAT PRIVATE TYPE (SCALAR) RAISES " &
           "CONSTRAINT_ERROR WHEN ACTUAL AND FORMAL PARAMETER " &
           "BOUNDS DIFFER");

     DECLARE
          PACKAGE P IS
               TYPE T IS PRIVATE;
               DC : CONSTANT T;

               GENERIC PACKAGE PP IS
               END PP;
          PRIVATE
               TYPE T IS NEW INTEGER;
               DC : CONSTANT T := -1;
          END P;

          PROCEDURE Q (X : OUT P.T) IS
          BEGIN
               X := P.DC;
          END Q;

          GENERIC
               Y : IN OUT P.T;
          PACKAGE CALL IS
          END CALL;

          PACKAGE BODY CALL IS
          BEGIN
               Q (Y);
          END CALL;

-- NOTE CALL HAS VARIABLE OF A PRIVATE TYPE AS AN OUT PARAMETER.  IF WE
-- INTERPRET 6.4.1(9) LITERALLY, THE VALUE OF Y IS CHECKED BEFORE THE
-- CALL AND NOT AFTER THE RETURN. 

          PACKAGE BODY P IS
               Z : T RANGE 0..1 := 0;
               PACKAGE BODY PP IS
                    PACKAGE CALL_Q IS NEW CALL(Z);
               END PP;
          END P;

     BEGIN
          BEGIN
               DECLARE
                    PACKAGE CALL_Q_NOW IS NEW P.PP;    -- EXCEPTION
               BEGIN
                    FAILED ("NO EXCEPTION RAISED");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
          END;

          RESULT;

     END;
END C64104N;
