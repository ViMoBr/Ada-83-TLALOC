-- A62006D.ADA

-- CHECK THAT 'FIRST, 'LAST, 'LENGTH, 'RANGE, 'ADDRESS, 'CONSTRAINED,
-- 'SIZE, 'POSITION, 'FIRST_BIT, AND 'LAST_BIT CAN BE APPLIED TO
-- NON-ACCESS OUT FORMAL PARAMETERS AND COMPONENTS OF NON-ACCESS OUT
-- PARAMETERS.

-- NOTE: THE NON-ARRAY ATTRIBUTES CAN BE USED BECAUSE EVALUATION OF THE
-- PREFIX DOES NOT REQUIRE READING THE VALUE OF THE PREFIX, ONLY
-- DETERMINING THE ENTITY DENOTED BY THE NAME (4.1(9)).

-- SPS 2/21/84
-- JBG 3/30/84

WITH REPORT; USE REPORT;
WITH SYSTEM;
PROCEDURE A62006D IS
BEGIN

     TEST ("A62006D", "CHECK THAT ATTRIBUTES MAY BE APPLIED TO " &
           "NON-ACCESS FORMAL OUT PARAMETERS");

     DECLARE

          TYPE ARR IS ARRAY (1 .. 2) OF BOOLEAN;
          TYPE REC (D : INTEGER := 1) IS RECORD
               Y : BOOLEAN;
               X : ARR;
          END RECORD;

          PROCEDURE P (C1 : SYSTEM.ADDRESS;
                       C2 : OUT ARR;
                       C3 : OUT REC) IS
               X : SYSTEM.ADDRESS;
               I : INTEGER;
          BEGIN
               FOR I IN C2'FIRST .. C2'LAST LOOP
                    NULL;
               END LOOP;

               I := C2'LENGTH;
               IF FALSE THEN
                    P (C3.Y'ADDRESS, C2, C3);
               END IF;
               C3.Y := C3'CONSTRAINED;
               I := C2'SIZE;

               FOR I IN C2'RANGE LOOP
                    NULL;
               END LOOP;

               I := C3.X'LENGTH;
               X := C3.Y'ADDRESS;
               I := C3.Y'SIZE;
               I := C3.X'POSITION;
               I := C3.Y'FIRST_BIT;
               I := C3.Y'LAST_BIT;

               FOR J IN C3.X'RANGE LOOP
                    NULL;
               END LOOP;
          END P;

     BEGIN
          NULL;
     END;

     RESULT;

END A62006D;
