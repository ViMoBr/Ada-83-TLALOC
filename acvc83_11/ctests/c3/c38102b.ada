-- C38102B.ADA

-- CHECK THAT INCOMPLETE TYPES CAN BE FLOAT.

-- DAT 3/24/81
-- SPS 10/25/82

WITH REPORT; USE REPORT;

PROCEDURE C38102B IS

BEGIN
     TEST ("C38102B", "INCOMPLETE TYPE CAN BE FLOAT");
     
     DECLARE

          TYPE F;
          TYPE G;
          TYPE AF IS ACCESS F;
          TYPE F IS DIGITS 2;
          TYPE G IS NEW F RANGE 1.0 .. 1.5;
          TYPE AG IS ACCESS G RANGE 1.0 .. 1.3;
     
          XF : AF := NEW F' (2.0);
          XG : AG := NEW G' (G (XF.ALL/2.0));

     BEGIN
          IF XG.ALL NOT IN G THEN
               FAILED ("ACCESS TO FLOAT");
          END IF;
     END;
     
     RESULT;
END C38102B;
