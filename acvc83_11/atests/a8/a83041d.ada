-- A83041D.ADA

-- OBJECTIVE:
--     CHECK THAT ATTRIBUTES FOR ARRAY, RECORD, ACCESS,
--     AND PRIVATE TYPES ARE VISIBLE THROUGHOUT THEIR
--     SCOPE EVEN WHEN THE TYPE IS DECLARED IN THE VISIBLE
--     PART OF A PACKAGE AND NO USE CLAUSE IS GIVEN.

-- HISTORY:
--     SDA 09/19/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
WITH SYSTEM;

PROCEDURE A83041D IS

BEGIN
     TEST ("A83041D", "CHECK THAT ATTRIBUTES FOR ARRAY, RECORD, "&
           "ACCESS, AND PRIVATE TYPES ARE VISIBLE THROUGHOUT THEIR"&
           " SCOPE EVEN WHEN THE TYPE IS DECLARED IN THE VISIBLE "&
           "PART OF A PACKAGE AND NO USE CLAUSE IS GIVEN");

     DECLARE
          PACKAGE P IS
               TYPE A IS ARRAY(INTEGER RANGE 1..10) OF INTEGER;
               TYPE B IS ACCESS INTEGER;
               TYPE C(NUM : POSITIVE := 1) IS PRIVATE;
               TYPE R (NUM : POSITIVE := 1)IS
                    RECORD
                         S : INTEGER;
                         T : B;
                         U : C;
                    END RECORD;
               PRIVATE
                    TYPE C(NUM : POSITIVE := 1) IS
                         RECORD
                              S : INTEGER;
                              T : B;
                         END RECORD;

          END P;

          ADD_L : SYSTEM.ADDRESS;
          BOOL_L : BOOLEAN;
          INT_L : INTEGER;
          REC_L : P.R;
          ARR_L : P.A;
          ACC_L : P.B;
          PRI_L : P.C;

          PACKAGE BODY P IS

               ADD : SYSTEM.ADDRESS;
               ARR : A;
               ACC : B;
               PRI : C;
               REC : R;
               BOOL : BOOLEAN;
               INT : INTEGER;

          BEGIN
               INT := A'SIZE;
               INT := A'BASE'SIZE;
               ADD := ARR'ADDRESS;
               INT := ARR'SIZE;
               ARR(2) := ARR'FIRST;
               ARR(3) := ARR'LAST;
               ARR(4) := ARR'FIRST(1);
               ARR(5) := ARR'LAST(1);
               ARR(6) := ARR'LENGTH;
               ARR(7) := ARR'LENGTH(1);
               FOR I IN ARR'RANGE LOOP
                    NULL;
               END LOOP;
               FOR I IN ARR'RANGE(1) LOOP
                    NULL;
               END LOOP;
               INT := R'SIZE;
               INT := R'BASE'SIZE;
               ADD := REC'ADDRESS;
               INT := REC'SIZE;
               BOOL := REC'CONSTRAINED;
               INT := B'SIZE;
               INT := B'BASE'SIZE;
               INT := B'STORAGE_SIZE;
               INT := ACC'SIZE;
               ADD := ACC'ADDRESS;
               INT := C'BASE'SIZE;
               INT := C'SIZE;
               ADD := PRI'ADDRESS;
               INT := PRI'SIZE;
               BOOL := PRI'CONSTRAINED;
          END P;

     BEGIN
          INT_L := P.A'SIZE;
          INT_L := P.A'BASE'SIZE;
          ADD_L := ARR_L'ADDRESS;
          INT_L := ARR_L'SIZE;
          ARR_L(2) := ARR_L'FIRST;
          ARR_L(3) := ARR_L'LAST;
          ARR_L(4) := ARR_L'FIRST(1);
          ARR_L(5) := ARR_L'LAST(1);
          ARR_L(6) := ARR_L'LENGTH;
          ARR_L(7) := ARR_L'LENGTH(1);
          FOR I IN ARR_L'RANGE LOOP
               NULL;
          END LOOP;
          FOR I IN ARR_L'RANGE(1) LOOP
               NULL;
          END LOOP;
          INT_L := P.R'SIZE;
          INT_L := P.R'BASE'SIZE;
          ADD_L := REC_L'ADDRESS;
          INT_L := REC_L'SIZE;
          BOOL_L := REC_L'CONSTRAINED;
          INT_L := P.B'SIZE;
          INT_L := P.B'BASE'SIZE;
          INT_L := P.B'STORAGE_SIZE;
          INT_L := ACC_L'SIZE;
          ADD_L := ACC_L'ADDRESS;
          INT_L := P.C'BASE'SIZE;
          INT_L := P.C'SIZE;
          ADD_L := PRI_L'ADDRESS;
          INT_L := PRI_L'SIZE;
          BOOL_L := PRI_L'CONSTRAINED;
     END;
     RESULT;
END A83041D;
