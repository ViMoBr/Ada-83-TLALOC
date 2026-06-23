-- C55B05A.ADA

-- CHECK THAT LOOPS WITH BOUNDS INTEGER'LAST OR
-- INTEGER'FIRST DO NOT RAISE INVALID EXCEPTIONS.

-- DAT 3/26/81
-- SPS 3/2/83

WITH REPORT; USE REPORT;

PROCEDURE C55B05A IS
BEGIN
     TEST ("C55B05A", "LOOPS WITH INTEGER'FIRST AND 'LAST AS BOUNDS");

     DECLARE

          COUNT : INTEGER := 0;

          PROCEDURE C IS
          BEGIN
               COUNT := COUNT + 1;
          END C;

     BEGIN
          FOR I IN INTEGER'LAST .. INTEGER'FIRST LOOP
               FAILED ("WRONG NULL RANGE LOOP EXECUTION");
               EXIT;
          END LOOP;
          FOR I IN INTEGER'FIRST .. INTEGER'FIRST LOOP
               C;
          END LOOP;
          FOR I IN INTEGER'FIRST .. INTEGER'FIRST + 2 LOOP
               C; C;
          END LOOP;
          FOR I IN INTEGER'FIRST + 1 .. INTEGER'FIRST LOOP
               FAILED ("NULL RANGE ERROR 2");
               EXIT;
          END LOOP;
          FOR I IN INTEGER'FIRST .. INTEGER'LAST LOOP
               C;
               EXIT;
          END LOOP;
          FOR I IN INTEGER LOOP
               C;
               EXIT;
          END LOOP;
          FOR I IN INTEGER'LAST - 2 .. INTEGER'LAST LOOP
               C; C; C;
          END LOOP;
          FOR I IN INTEGER'LAST - 2 .. INTEGER'LAST - 1 LOOP
               C;
          END LOOP;
          FOR I IN 0 .. INTEGER'FIRST LOOP
               FAILED ("NULL LOOP ERROR 3");
               EXIT;
          END LOOP;
          FOR I IN -1 .. INTEGER'FIRST LOOP
               FAILED ("NULL LOOP ERROR 4");
               EXIT;
          END LOOP;
          FOR I IN -3 .. IDENT_INT(0) LOOP
               FOR J IN INTEGER'FIRST .. INTEGER'FIRST - I LOOP
                    C; C; C; C;
               END LOOP;
               FOR J IN INTEGER'FIRST - I .. INTEGER'FIRST + 3 - I LOOP
                    C; C; C; C;
               END LOOP;
               FOR J IN INTEGER'LAST - 3 .. INTEGER'LAST + I LOOP
                    C; C; C; C;
               END LOOP;
               FOR J IN INTEGER'LAST + I .. INTEGER'LAST LOOP
                    C; C; C; C;
               END LOOP;
          END LOOP;

          FOR I IN REVERSE INTEGER'LAST .. INTEGER'FIRST LOOP
               FAILED ("REVERSE WRONG NULL RANGE LOOP EXECUTION");
               EXIT;
          END LOOP;
          FOR I IN REVERSE INTEGER'FIRST .. INTEGER'FIRST LOOP
               C;
          END LOOP;
          FOR I IN REVERSE INTEGER'FIRST .. INTEGER'FIRST + 2 LOOP
               C; C;
          END LOOP;
          FOR I IN REVERSE INTEGER'FIRST + 1 .. INTEGER'FIRST LOOP
               FAILED ("NULL RANGE ERROR 8");
               EXIT;
          END LOOP;
          FOR I IN REVERSE INTEGER'FIRST .. INTEGER'LAST LOOP
               C;
               EXIT;
          END LOOP;
          FOR I IN REVERSE INTEGER LOOP
               C;
               EXIT;
          END LOOP;
          FOR I IN REVERSE INTEGER'LAST - 2 .. INTEGER'LAST LOOP
               C; C; C;
          END LOOP;
          FOR I IN REVERSE INTEGER'LAST - 2 .. INTEGER'LAST - 1 LOOP
               C;
          END LOOP;
          FOR I IN REVERSE 0 .. INTEGER'FIRST LOOP
               FAILED ("NULL LOOP ERROR 9");
               EXIT;
          END LOOP;
          FOR I IN REVERSE -1 .. INTEGER'FIRST LOOP
               FAILED ("NULL LOOP ERROR 7");
               EXIT;
          END LOOP;
          FOR I IN REVERSE -3 .. IDENT_INT(0) LOOP
               FOR J IN REVERSE INTEGER'FIRST .. INTEGER'FIRST - I LOOP
                    C; C; C; C;
               END LOOP;
               FOR J IN REVERSE INTEGER'FIRST - I
                    .. INTEGER'FIRST + 3 - I
               LOOP
                    C; C; C; C;
               END LOOP;
               FOR J IN REVERSE INTEGER'LAST - 3 .. INTEGER'LAST + I
               LOOP
                    C; C; C; C;
               END LOOP;
               FOR J IN REVERSE INTEGER'LAST + I .. INTEGER'LAST LOOP
                    C; C; C; C;
               END LOOP;
          END LOOP;

          IF COUNT /= 408 THEN
               FAILED ("WRONG LOOP EXECUTION COUNT");
          END IF;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED INCORRECTLY");
          WHEN NUMERIC_ERROR =>
               FAILED ("NUMERIC_ERROR RAISED INCORRECTLY");
          WHEN OTHERS =>
               FAILED ("UNKNOWN EXCEPTION RAISED INCORRECTLY");
     END;

     RESULT;
END C55B05A;
