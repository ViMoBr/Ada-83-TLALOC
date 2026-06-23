-- C37103A.ADA

-- CHECK THAT DISCRIMINANTS MAY BE BOOLEAN, CHARACTER, USER_ENUM,
-- INTEGER, DERIVED CHARACTER, DERIVED USER_ENUM, DERIVED INTEGER,
-- AND DERIVED DERIVED USER_ENUM.

-- DAT 5/18/81
-- SPS 10/25/82

WITH REPORT; USE REPORT;

PROCEDURE C37103A IS
BEGIN
     TEST ("C37103A", "MANY DIFFERENT DISCRIMINANT TYPES");
     DECLARE
          PACKAGE P1 IS
               TYPE ENUM IS (A, Z, Q, 'W', 'A');
          END P1;

          PACKAGE P2 IS
               TYPE E2 IS NEW P1.ENUM;
          END P2;

          PACKAGE P3 IS
               TYPE E3 IS NEW P2.E2;
          END P3;

          USE P1, P2, P3;
          TYPE INT IS NEW INTEGER RANGE -3 .. 7;
          TYPE CHAR IS NEW CHARACTER;
          TYPE R1 (D : ENUM) IS RECORD NULL; END RECORD;
          TYPE R2 (D : INTEGER) IS RECORD NULL; END RECORD;
          TYPE R3 (D : BOOLEAN) IS RECORD NULL; END RECORD;
          TYPE R4 (D : CHARACTER) IS RECORD NULL; END RECORD;
          TYPE R5 (D : CHAR) IS RECORD NULL; END RECORD;
          TYPE R6 (D : E2) IS RECORD NULL; END RECORD;
          TYPE R7 (D : E3) IS RECORD NULL; END RECORD;
          TYPE R8 (D : INT) IS RECORD NULL; END RECORD;
          O1 : R1(A) := (D => A);
          O2 : R2(3) := (D => 3);
          O3 : R3(TRUE) := (D => TRUE);
          O4 : R4(ASCII.NUL) := (D => ASCII.NUL);
          O5 : R5('A') := (D => 'A');
          O6 : R6('A') := (D => 'A');
          O7 : R7(A) := (D => A);
          O8 : R8(2) := (D => 2);
     BEGIN
          IF O1.D /= A
          OR O2.D /= 3
          OR NOT O3.D
          OR O4.D IN 'A' .. 'Z'
          OR O5.D /= 'A'
          OR O6.D /= 'A'
          OR O7.D /= A
          OR O8.D /= 2
          THEN FAILED ("WRONG DISCRIMINANT VALUE");
          END IF;
     END;

     RESULT;
END C37103A;
