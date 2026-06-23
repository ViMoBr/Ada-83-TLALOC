--C95022A.ADA

--CHECK THAT IT IS POSSIBLE TO ACCEPT AN ENTRY CALL FROM INSIDE THE
--THE BODY OF AN ACCEPT STATEMENT.

--CHECK THE CASE OF NORMAL ENTRY TERMINATION.

-- JEAN-PIERRE ROSEN 25-FEB-1984
-- JBG 6/1/84

-- FOUR CLIENT TASKS CALL ONE SERVER TASK.  EACH CLIENT CALLS JUST ONE
-- ENTRY OF THE SERVER TASK.  THE TEST CHECKS TO BE SURE THAT CALLS FROM
-- DIFFERENT TASKS ARE NOT MIXED UP.

WITH REPORT; USE REPORT;
PROCEDURE C95022A IS

BEGIN
     TEST("C95022A", "CHECK THAT EMBEDDED RENDEZVOUS ARE PROCESSED " &
                     "CORRECTLY");
     DECLARE

          TASK TYPE CLIENT IS
               ENTRY GET_ID (I : INTEGER);
               ENTRY RESTART;
          END CLIENT;
     
          T_ARR : ARRAY (1..4) OF CLIENT;
     
          TASK SERVER IS
               ENTRY E1 (I : IN OUT INTEGER);
               ENTRY E2 (I : IN OUT INTEGER);
               ENTRY E3 (I : IN OUT INTEGER);
               ENTRY E4 (I : IN OUT INTEGER);
          END SERVER;
     
          TASK BODY SERVER IS
          BEGIN
     
               ACCEPT E1 (I : IN OUT INTEGER) DO
                    ACCEPT E2 (I : IN OUT INTEGER) DO
                         I := IDENT_INT(I);
                         ACCEPT E3 (I : IN OUT INTEGER) DO
                              ACCEPT E4 (I : IN OUT INTEGER) DO
                                   I := IDENT_INT(I);
                              END E4;
                              I := IDENT_INT(I);
                         END E3;
                    END E2;
                    I := IDENT_INT(I);
               END E1;
     
               FOR I IN 1 .. 4 LOOP
                    T_ARR(I).RESTART;
               END LOOP;
          END SERVER;
     
          TASK BODY CLIENT IS
               ID      : INTEGER;
               SAVE_ID : INTEGER;
          BEGIN
               ACCEPT GET_ID (I : INTEGER) DO
                    ID := I;
               END GET_ID;
     
               SAVE_ID := ID;
     
               CASE ID IS
                    WHEN 1      => SERVER.E1(ID);
                    WHEN 2      => SERVER.E2(ID);
                    WHEN 3      => SERVER.E3(ID);
                    WHEN 4      => SERVER.E4(ID);
                    WHEN OTHERS => FAILED("INCORRECT ID");
               END CASE;

               ACCEPT RESTART;  -- WAIT FOR ALL TASKS TO HAVE COMPLETED
                                -- RENDEZVOUS
               IF ID /= SAVE_ID THEN
                    FAILED("SCRAMBLED EMBEDDED RENDEZVOUS");
               END IF;
          EXCEPTION
               WHEN OTHERS => FAILED("EXCEPTION IN CLIENT");
          END CLIENT;
     
     BEGIN
          FOR I IN 1 .. 4 LOOP
               T_ARR(I).GET_ID(I);
          END LOOP;
     END;

     RESULT;

END C95022A;
