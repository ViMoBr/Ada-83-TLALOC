-- C55B06A.ADA

-- CHECK THAT LOOPS MAY BE SPECIFIED FOR BOOLEAN, INTEGER,
-- CHARACTER, ENUMERATION, AND DERIVED TYPES, INCLUDING
-- TYPES DERIVED FROM DERIVED TYPES. DERIVED BOOLEAN IS NOT
-- TESTED IN THIS TEST.

-- DAT 3/26/81
-- JBG 9/29/82
-- SPS 3/11/83
-- JBG 10/5/83

WITH REPORT; USE REPORT;

PROCEDURE C55B06A IS

     TYPE ENUM IS ('A', 'B', 'D', 'C', Z, X, D, A, C);

     TYPE D1 IS NEW CHARACTER RANGE 'A' .. 'Z';
     TYPE D2 IS NEW INTEGER;
     TYPE D3 IS NEW ENUM;
     TYPE D4 IS NEW D1;
     TYPE D5 IS NEW D2;
     TYPE D6 IS NEW D3;

     ONE : INTEGER := IDENT_INT(1);
     COUNT : INTEGER := 0;
     OLDCOUNT : INTEGER := 0;

     PROCEDURE Q IS
     BEGIN
          COUNT := COUNT + ONE;
     END Q;

BEGIN
     TEST ("C55B06A", "TEST LOOPS FOR ALL DISCRETE TYPES");

     FOR I IN BOOLEAN LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(2) /= COUNT THEN
          FAILED ("LOOP 1");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN FALSE .. TRUE LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(2) /= COUNT THEN
          FAILED ("LOOP 2");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN BOOLEAN RANGE FALSE .. TRUE LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(2) /= COUNT THEN
          FAILED ("LOOP 3");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN INTEGER LOOP
          Q;
          EXIT WHEN I = INTEGER'FIRST + 2;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(3) /= COUNT THEN
          FAILED ("LOOP 4");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN 3 .. IDENT_INT (5) LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(3) /= COUNT THEN
          FAILED ("LOOP 5");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN INTEGER RANGE -2 .. -1 LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(2) /= COUNT THEN
          FAILED ("LOOP 6");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN INTEGER RANGE INTEGER'FIRST .. INTEGER'FIRST + 1 LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(2) /= COUNT THEN
          FAILED ("LOOP 7");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN CHARACTER LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(128) /= COUNT THEN
          FAILED ("LOOP 8");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN 'A' .. CHARACTER'('Z') LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(26) /= COUNT THEN
          FAILED ("LOOP 9");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN CHARACTER RANGE 'A' .. 'D' LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(4) /= COUNT THEN
          FAILED ("LOOP 10");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN ENUM LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(9) /= COUNT THEN
          FAILED ("LOOP 11");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN ENUM RANGE D .. C LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(3) /= COUNT THEN
          FAILED ("LOOP 12");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN 'A' .. ENUM'(Z) LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(5) /= COUNT THEN
          FAILED ("LOOP 13");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D1 LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(26) /= COUNT THEN
          FAILED ("LOOP 14");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D1 RANGE 'A' .. 'Z' LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(26) /= COUNT THEN
          FAILED ("LOOP 15");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D1'('A') .. 'D' LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(4) /= COUNT THEN
          FAILED ("LOOP 16");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D2 LOOP
          Q;
          IF I > D2'FIRST + 3 THEN
               EXIT;
          END IF;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(5) /= COUNT THEN
          FAILED ("LOOP 17");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D2 RANGE -100 .. -99 LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(2) /= COUNT THEN
          FAILED ("LOOP 18");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D2'(1) .. 2 LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(2) /= COUNT THEN
          FAILED ("LOOP 19");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D3 LOOP
          IF I IN 'A' .. 'C' THEN
               Q;        -- 4
          ELSE
               Q; Q;     -- 10
          END IF;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(14) /= COUNT THEN
          FAILED ("LOOP 20");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D3 RANGE 'A' .. Z LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(5) /= COUNT THEN
          FAILED ("LOOP 21");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN 'A' .. D3'(Z) LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(5) /= COUNT THEN
          FAILED ("LOOP 22");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D4 LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(26) /= COUNT THEN
          FAILED ("LOOP 23");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D4'('A') .. 'Z' LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(26) /= COUNT THEN
          FAILED ("LOOP 24");
     END IF;
     OLDCOUNT := COUNT;

     FOR I IN D4 RANGE 'B' .. 'D' LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(3) /= COUNT THEN
          FAILED ("LOOP 25");
     END IF;
     OLDCOUNT := COUNT;

     FOR J IN D5 LOOP
          Q;        -- 4
          EXIT WHEN J = D5(INTEGER'FIRST) + 3;
          Q;        -- 3
     END LOOP;
     IF OLDCOUNT + IDENT_INT(7) /= COUNT THEN
          FAILED ("LOOP 26");
     END IF;
     OLDCOUNT := COUNT;

     FOR J IN D5 RANGE -2 .. -1 LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(2) /= COUNT THEN
          FAILED ("LOOP 27");
     END IF;
     OLDCOUNT := COUNT;

     FOR  J IN D5'(-10) .. D5'(-6) LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(5) /= COUNT THEN
          FAILED ("LOOP 28");
     END IF;
     OLDCOUNT := COUNT;

     FOR J IN D6 LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(9) /= COUNT THEN
          FAILED ("LOOP 29");
     END IF;
     OLDCOUNT := COUNT;

     FOR J IN D6 RANGE Z .. A LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(4) /= COUNT THEN
          FAILED ("LOOP 30");
     END IF;
     OLDCOUNT := COUNT;

     FOR J IN D6'('D') .. D LOOP
          Q;
     END LOOP;
     IF OLDCOUNT + IDENT_INT(5) /= COUNT THEN
          FAILED ("LOOP 31");
     END IF;
     OLDCOUNT := COUNT;


     RESULT;
END C55B06A;
