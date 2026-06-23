-- A74105B.ADA

-- CHECK THAT THE FULL TYPE DECLARATION OF A PRIVATE TYPE WITHOUT
-- DISCRIMINANTS MAY BE A CONSTRAINED TYPE WITH DISCRIMINANTS.

-- DSJ 4/29/83
-- SPS 10/22/83

WITH REPORT;
PROCEDURE A74105B IS

     USE REPORT;

BEGIN

     TEST ("A74105B", "CHECK THAT THE FULL TYPE DECLARATION OF A " &
                      "PRIVATE TYPE WITHOUT DISCRIMINANTS MAY BE " &
                      "A CONSTRAINED TYPE WITH DISCRIMINANTS");

     DECLARE

          TYPE REC1 (D : INTEGER) IS
               RECORD
                    C1, C2 : INTEGER;
               END RECORD;

          TYPE REC2 (F : INTEGER := 0) IS
               RECORD
                    E1, E2 : INTEGER;
               END RECORD;

          TYPE REC3 IS NEW REC1 (D => 1);

          TYPE REC4 IS NEW REC2 (F => 2);

          PACKAGE PACK1 IS
               TYPE P1 IS PRIVATE;
               TYPE P2 IS PRIVATE;
               TYPE P3 IS PRIVATE;
               TYPE P4 IS PRIVATE;
          PRIVATE
               TYPE P1 IS ACCESS REC1;
               TYPE P2 IS NEW REC4;
               TYPE P3 IS NEW REC1 (D => 5);
               TYPE P4 IS NEW REC2 (F => 7);
          END PACK1;

     BEGIN

          NULL;

     END;

     RESULT;

END A74105B;
