-- B62001A.ADA

-- CHECK THAT A FORMAL IN PARAMETER CANNOT BE USED AS THE TARGET OF AN
--   ASSIGNMENT STATEMENT OR AS AN ACTUAL PARAMETER WHOSE MODE IS OUT
--   OR IN OUT.

-- DAS 1/23/81
-- JRK 3/16/81

PROCEDURE B62001A IS

     TYPE TABLE IS ARRAY (1..3) OF INTEGER;

     TYPE REC IS
          RECORD
               I    : INTEGER;
               A    : TABLE;
          END RECORD;

     TYPE PTR IS ACCESS INTEGER;

     PROCEDURE P0 (I : IN INTEGER; T : IN TABLE; R : IN REC;
                      P : IN PTR) IS

          PROCEDURE P1 (I : IN OUT INTEGER) IS
          BEGIN
               NULL;
          END P1;

          PROCEDURE P2 (I : OUT INTEGER) IS
          BEGIN
               NULL;
          END P2;

          PROCEDURE P3 (T : IN OUT TABLE) IS
          BEGIN
               NULL;
          END P3;

          PROCEDURE P4 (T : OUT TABLE) IS
          BEGIN
               NULL;
          END P4;

          PROCEDURE P5 (R : IN OUT REC) IS
          BEGIN
               NULL;
          END P5;

          PROCEDURE P6 (R : OUT REC) IS
          BEGIN
               NULL;
          END P6;

          PROCEDURE P7 (P : IN OUT PTR) IS
          BEGIN
               NULL;
          END P7;

          PROCEDURE P8 (P : OUT PTR) IS
          BEGIN
               NULL;
          END P8;

     BEGIN

          I := 3;             -- ERROR: IN PARAMETER ASSIGNED TO.
          P1 (I);             -- ERROR: IN PARAMETER USED AS IN OUT.
          P2 (I);             -- ERROR: IN PARAMETER USED AS OUT.

          T := (1,2,3);       -- ERROR: IN PARAMETER ASSIGNED TO.
          P3 (T);             -- ERROR: IN PARAMETER USED AS IN OUT.
          P4 (T);             -- ERROR: IN PARAMETER USED AS OUT.

          T(1) := 3;          -- ERROR: IN PARAMETER ASSIGNED TO. 
          P1 (T(1));          -- ERROR: IN PARAMETER USED AS IN OUT.
          P2 (T(1));          -- ERROR: IN PARAMETER USED AS OUT.

          R := (1,(1,2,3));   -- ERROR: IN PARAMETER ASSIGNED TO.
          P5 (R);             -- ERROR: IN PARAMETER USED AS IN OUT.
          P6 (R);             -- ERROR: IN PARAMETER USED AS OUT.

          R.I := 3;           -- ERROR: IN PARAMETER ASSIGNED TO.
          P1 (R.I);           -- ERROR: IN PARAMETER USED AS IN OUT.
          P2 (R.I);           -- ERROR: IN PARAMETER USED AS OUT.

          P := NULL;          -- ERROR: IN PARAMETER ASSIGNED TO.
          P7 (P);             -- ERROR: IN PARAMETER USED AS IN OUT.
          P8 (P);             -- ERROR: IN PARAMETER USED AS OUT.
     END P0;

BEGIN
     NULL;
END B62001A;
