-- D56001B.ADA

-- CHECK THAT BLOCKS CAN BE EMBEDDED UP TO AN ARBITRARY LEVEL (65).
 
-- ASL 8/6/81
 
WITH REPORT;
PROCEDURE D56001B IS
 
     USE REPORT;
 
     X : INTEGER := 0;
BEGIN
     TEST ("D56001B","ARBITRARY LEVEL OF EMBEDDED BLOCKS");
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
     BEGIN
          X := 1;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
     END;
 
     IF X /= 1 THEN
          FAILED ("ASSIGNMENT AT HEART OF EMBEDDED BLOCKS NOT MADE");
     END IF;
 
     RESULT;
END D56001B;
