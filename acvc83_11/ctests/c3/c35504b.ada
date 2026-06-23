-- C35504B.ADA

-- CHECK THAT CONSTRAINT_ERROR IS NOT RAISED FOR I'SUCC, I'PRED,
-- I'POS, I'VAL, I'IMAGE, AND I'VALUE FOR INTEGER ARGUMENTS
-- OUTSIDE THE RANGE OF I.

-- DAT 3/30/81
-- SPS 01/13/83

WITH REPORT;
USE REPORT;

PROCEDURE C35504B IS

     SUBTYPE I IS INTEGER RANGE 0 .. 0;

BEGIN
     TEST ("C35504B", "CONSTRAINT_ERROR IS NOT RAISED FOR"
          & " INTEGER SUBTYPE ATTRIBUTES 'SUCC, 'PRED, 'POS, 'VAL,"
          & " 'IMAGE, AND 'VALUE WHOSE ARGUMENTS ARE OUTSIDE THE"
          & " SUBTYPE");

     BEGIN
          IF I'SUCC(-1) /= I'PRED(1)
          THEN
               FAILED ("WRONG ATTRIBUTE VALUE - 1");
          END IF;

          IF I'SUCC (100) /= 101
          THEN
               FAILED ("WRONG ATTRIBUTE VALUE - 2");
          END IF;

          IF I'PRED (100) /= 99
          THEN
               FAILED ("WRONG ATTRIBUTE VALUE - 3");
          END IF;

          IF I'POS (-100) /= -100
          THEN
               FAILED ("WRONG ATTRIBUTE VALUE - 4");
          END IF;

          IF I'VAL(-100) /= -100
          THEN
               FAILED ("WRONG ATTRIBUTE VALUE - 5");
          END IF;

          IF I'IMAGE(1234) /= " 1234"
          THEN
               FAILED ("WRONG ATTRIBUTE VALUE - 6");
          END IF;

          IF I'VALUE("999") /= 999
          THEN
               FAILED ("WRONG ATTRIBUTE VALUE - 7");
          END IF;
     EXCEPTION
          WHEN OTHERS => FAILED ("EXCEPTION RAISED");
     END;

     RESULT;
END C35504B;
