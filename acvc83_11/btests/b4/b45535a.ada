-- B45535A.ADA

-- CHECK THAT A PRODUCT OR QUOTIENT OF FIXED POINT VALUES CANNOT BE 
-- USED IN A COMPARISON, MEMBERSHIP OPERATION, OR REAL NUMERIC TYPE 
-- DEFINITION.

-- RJW 2/10/86

PROCEDURE B45535A IS

     TYPE FIXED IS DELTA 0.125  RANGE -1.0 .. 1.0;

     F1, F2  : FIXED           := 1.0;
     FCON1   : CONSTANT FIXED  := 0.1;
     FCON2   : CONSTANT FIXED  := 0.2;

     TYPE NEW_FIXED IS DELTA FCON1 / FCON2 RANGE -1.0 .. 1.0; -- ERROR:
                                                              --   '/'.
     TYPE NEW_FIXED2 IS DELTA FCON1 * FCON2 RANGE -1.0 .. 1.0;-- ERROR:
                                                              --   '*'.
     TYPE NEW_FIXED3 IS DELTA 0.25 RANGE FCON1 / FCON2 .. 1.0;-- ERROR:
                                                              --   '/'.
     TYPE REALTYPE IS DIGITS 5 RANGE 0.0 .. FCON1 * FCON2;    -- ERROR:
                                                              --   '*'.
                                                                    
BEGIN
     IF (FCON1 * FCON2) = F1 THEN                             -- ERROR:
                                                              --   '*'.
          NULL;
     ELSIF (FCON1 / FCON2) = 0.1 THEN                         -- ERROR:
                                                              --   '/'.
          NULL;
     ELSIF (F1 * F2) = (F2 * F1) THEN                         -- ERROR:
                                                              --   '*'.
          NULL;
     ELSIF (F1 / F2) = FCON2 THEN                             -- ERROR:
                                                              --   '/'.
          NULL;
     ELSIF (F1 * F2) NOT IN FIXED THEN                        -- ERROR:
                                                              --   '*'.
          NULL;
     ELSIF (FCON1 / FCON2) IN 1.0 .. 2.0 THEN                 -- ERROR:
                                                              --   '/'.
          NULL;
     END IF;

END B45535A;
