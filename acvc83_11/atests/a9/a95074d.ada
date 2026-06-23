-- A95074D.ADA

-- CHECK THAT 'ADDRESS, 'CONSTRAINED, 'SIZE, 'POSITION, 'FIRST_BIT,
-- AND 'LAST_BIT CAN BE APPLIED TO AN OUT PARAMETER OR OUT PARAMETER
-- SUBCOMPONENT THAT DOES NOT HAVE AN ACCESS TYPE.

-- JWC 6/25/85

WITH REPORT; USE REPORT;
WITH SYSTEM;
PROCEDURE A95074D IS
BEGIN

     TEST ("A95074D", "CHECK THAT ATTRIBUTES MAY BE APPLIED TO " &
           "NON-ACCESS FORMAL OUT PARAMETERS");

     DECLARE

          TYPE ARR IS ARRAY (1 .. 2) OF BOOLEAN;

          TYPE REC (D : INTEGER := 1) IS RECORD
               Y : BOOLEAN;
               X : ARR;
          END RECORD;

          TASK T IS
               ENTRY E (C1 : OUT ARR; C2 : OUT REC);
          END T;

          TASK BODY T IS
               X : SYSTEM.ADDRESS;
               I : INTEGER;
          BEGIN
               IF IDENT_BOOL (FALSE) THEN
                    ACCEPT E (C1 : OUT ARR; C2 : OUT REC) DO

                         C2.Y := C2'CONSTRAINED;

                         X := C1'ADDRESS;
                         X := C1(1)'ADDRESS;
                         X := C2'ADDRESS;
                         X := C2.Y'ADDRESS;

                         I := C1'SIZE;
                         I := C2.Y'SIZE;

                         I := C2.X'POSITION;
                         I := C2.Y'FIRST_BIT;
                         I := C2.Y'LAST_BIT;
                    END E;
               END IF;
          END T;

     BEGIN
          NULL;
     END;

     RESULT;

END A95074D;
