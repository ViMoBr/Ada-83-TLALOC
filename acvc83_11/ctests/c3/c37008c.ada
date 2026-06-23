-- C37008C.ADA

-- CHECK THAT SLIDING DOES NOT OCCUR FOR ARRAY INITIALIZATIONS
-- OF RECORD COMPONENTS.

-- DAT 5/18/81
-- CPP 5/25/84
-- JWC 6/28/85   RENAMED FROM C37011A-B.ADA

WITH REPORT; USE REPORT;
PROCEDURE C37008C IS

     SUBTYPE S IS STRING (1..3);
     C : CONSTANT STRING (2..4) := "XYZ";

BEGIN
     TEST("C37008C", "NO SLIDING IN RECORD COMPONENT INITIALIZATIONS");

 A : BEGIN

          DECLARE
               V : S := C;    -- SLIDING OK.

               TYPE R IS RECORD
                    X : S := C;
               END RECORD;

          BEGIN
               DECLARE
                    REC : R;   -- SHOULD RAISE CONSTRAINT_ERROR.
               BEGIN
                    FAILED ("CONSTRAINT_ERROR NOT RAISED - A");
               EXCEPTION
                    WHEN OTHERS => FAILED ("WRONG HANDLER - A");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
               WHEN OTHERS => FAILED ("WRONG EXCEPTION RAISED - A");
          END;

      EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED - A");
      END A;

 B : BEGIN
          DECLARE

               SUBTYPE INT IS INTEGER RANGE 1..10;
               TYPE R (D : INT) IS RECORD
                    X : STRING (1..D) := C;
               END RECORD;

          BEGIN
               DECLARE
                    O : R(3);   -- SHOULD RAISE CONSTRAINT_ERROR.
               BEGIN
                    FAILED ("CONSTRAINT_ERROR NOT RAISED - B");
               EXCEPTION
                    WHEN OTHERS => FAILED ("WRONG HANDLER - B");
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
               WHEN OTHERS => FAILED ("WRONG EXCEPTION RAISED - B");
          END;

     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED - B");
     END B;

     RESULT;
END C37008C;
