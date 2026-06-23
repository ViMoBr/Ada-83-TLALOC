-- C41204A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF A SLICE'S DISCRETE
--   RANGE IS NOT NULL, AND ITS LOWER OR UPPER BOUND IS NOT A
--   POSSIBLE INDEX FOR THE NAMED ARRAY.

-- WKB 8/4/81

WITH REPORT;
USE REPORT;
PROCEDURE C41204A IS

BEGIN
     TEST ("C41204A", "ILLEGAL UPPER OR LOWER BOUNDS FOR A " &
                      "SLICE RAISES CONSTRAINT_ERROR");

     DECLARE

          TYPE T IS ARRAY (INTEGER RANGE <> ) OF INTEGER;
          A : T (10..15) := (10,11,12,13,14,15);
          B : T (-20..30);

     BEGIN

          BEGIN
               B (9..12) := A (9..12);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - 1");
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
               WHEN OTHERS           => FAILED ("WRONG EXCEPTION - 1");
          END;

          BEGIN
               B (-12..14) := A (-12..14);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - 2");
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
               WHEN OTHERS           => FAILED ("WRONG EXCEPTION - 2");
          END;

          BEGIN
               B (11..16) := A (11..16);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - 3");
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
               WHEN OTHERS           => FAILED ("WRONG EXCEPTION - 3");
          END;

          BEGIN
               B (17..20) := A (17..20);
               FAILED ("CONSTRAINT_ERROR NOT RAISED - 4");
          EXCEPTION
               WHEN CONSTRAINT_ERROR => NULL;
               WHEN OTHERS           => FAILED ("WRONG EXCEPTION - 4");
          END;
     END;

     RESULT;
END C41204A;
