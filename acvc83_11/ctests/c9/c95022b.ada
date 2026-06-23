-- C95022B.ADA

-- CHECK THAT IT IS POSSIBLE TO ACCEPT AN ENTRY CALL FROM INSIDE
-- THE BODY OF AN ACCEPT STATEMENT.

-- CHECK THE CASE OF ABORT DURING THE INNERMOST ACCEPT.

-- JEAN-PIERRE ROSEN 25-FEB-1984
-- JBG 6/1/84

WITH REPORT; USE REPORT;
PROCEDURE C95022B IS

BEGIN

     TEST("C95022B", "CHECK THAT EMBEDDED RENDEZVOUS ARE PROCESSED " &
                     "CORRECTLY (ABORT CASE)");
     DECLARE
          TASK TYPE CLIENT IS
               ENTRY GET_ID (I : INTEGER);
          END CLIENT;
     
          T_ARR : ARRAY (1..4) OF CLIENT;
     
          TASK KILL IS
               ENTRY ME;
          END KILL;
     
          TASK SERVER IS
               ENTRY E1;
               ENTRY E2;
               ENTRY E3;
               ENTRY E4;
          END SERVER;
     
          TASK BODY SERVER IS
          BEGIN
     
               ACCEPT E1 DO
                    ACCEPT E2 DO
                         ACCEPT E3 DO
                              ACCEPT E4 DO
                                   KILL.ME;
                                   E1;  -- WILL DEADLOCK UNTIL ABORT.
                              END E4;
                         END E3;
                    END E2;
               END E1;
     
          END SERVER;
     
          TASK BODY KILL IS
          BEGIN
               ACCEPT ME;
               ABORT SERVER;
          END;

          TASK BODY CLIENT IS
               ID : INTEGER;
          BEGIN
               ACCEPT GET_ID( I : INTEGER) DO
                    ID := I;
               END GET_ID;
     
               CASE ID IS
                    WHEN 1      => SERVER.E1;
                    WHEN 2      => SERVER.E2;
                    WHEN 3      => SERVER.E3;
                    WHEN 4      => SERVER.E4;
                    WHEN OTHERS => FAILED ("INCORRECT ID");
               END CASE;
     
               FAILED ("TASKING_ERROR NOT RAISED IN CLIENT" & 
                       INTEGER'IMAGE(ID));
     
          EXCEPTION
               WHEN TASKING_ERROR => 
                    NULL;
               WHEN OTHERS => 
                    FAILED("EXCEPTION IN CLIENT" & INTEGER'IMAGE(ID));
          END CLIENT;
     BEGIN
          FOR I IN 1 .. 4 LOOP
               T_ARR(I).GET_ID(I);
          END LOOP;
     END;

     RESULT;

END C95022B;
