-- C41205A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE NAME PART OF A
--   SLICE DENOTES AN ACCESS OBJECT WHOSE VALUE IS NULL, AND
--   ALSO IF THE NAME IS A FUNCTION CALL DELIVERING NULL.

-- WKB 8/6/81
-- SPS 10/26/82

WITH REPORT;
USE REPORT;
PROCEDURE C41205A IS

BEGIN
     TEST ("C41205A", "CONSTRAINT_ERROR WHEN THE NAME PART OF A " &
                      "SLICE DENOTES A NULL ACCESS OBJECT OR A " &
                      "FUNCTION CALL DELIVERING NULL");

     DECLARE

          TYPE T IS ARRAY (INTEGER RANGE <> ) OF INTEGER;
          SUBTYPE T1 IS T (1..5);
          TYPE A1 IS ACCESS T1;
          B : A1 := NEW T1' (1,2,3,4,5);
          I : T (2..3);

     BEGIN

          IF EQUAL (3,3) THEN
               B := NULL;
          END IF;

          I := B(2..3);
          FAILED ("CONSTRAINT_ERROR NOT RAISED - 1");

     EXCEPTION

          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS           => FAILED ("WRONG EXCEPTION - 1");

     END;

     DECLARE

          TYPE T IS ARRAY (INTEGER RANGE <> ) OF INTEGER;
          SUBTYPE T2 IS T (1..5);
          TYPE A2 IS ACCESS T2;
          I : T (2..5);

          FUNCTION F RETURN A2 IS
          BEGIN
               IF EQUAL (3,3) THEN
                    RETURN NULL;
               END IF;
               RETURN NEW T2' (1,2,3,4,5);
          END F;

     BEGIN

          I := F(2..5);
          FAILED ("CONSTRAINT_ERROR NOT RAISED - 2");

     EXCEPTION

          WHEN CONSTRAINT_ERROR => NULL;
          WHEN OTHERS           => FAILED ("WRONG EXCEPTION - 2");

     END;

     RESULT;
END C41205A;
