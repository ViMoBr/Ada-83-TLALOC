-- C55B09A.ADA

-- CHECK THAT UNIVERSAL_INTEGER LOOPS RESULT IN A LOOP INDEX
-- OF TYPE INTEGER.

-- DAT 3/26/81
-- SPS 3/2/83
-- JBG 10/5/83

WITH REPORT; USE REPORT;

PROCEDURE C55B09A IS

     A : ARRAY (INTEGER RANGE 0 .. 2) OF INTEGER;

     TYPE D IS NEW INTEGER;

     J : INTEGER;

     C1 : CONSTANT := 1 + 1 - 1;
     C2 : CONSTANT := C1 + 1;
     N3 : CONSTANT := -3;

     PROCEDURE P(I : D) IS
     BEGIN
          FAILED ("WRONG PROCEDURE CALLED");
     END P;

     PROCEDURE P (I : INTEGER) IS
     BEGIN
          A (I MOD 3) := I;
     END P;

BEGIN
     TEST ("C55B09A", "UNIVERSAL_INTEGER LOOPS ARE INTEGER");

     FOR K IN 1 .. 2 LOOP
          A(K) := K;
          J := K;
          P(K);
     END LOOP;

     FOR INDEX IN N3 .. 0 LOOP
          A (INDEX MOD 3) := INDEX;
          J := INDEX;
          P(INDEX);
     END LOOP;

     FOR I IN C1 .. C2 LOOP
          A(I) := I;
          J := I;
          P(I);
     END LOOP;

     FOR I IN 1 .. C2 LOOP
          A(I) := I;
          J := I;
          P(I);
     END LOOP;

     A(C1) := C2;
     J := C1 + C2;
     P(INTEGER(C1));

     RESULT;
END C55B09A;
