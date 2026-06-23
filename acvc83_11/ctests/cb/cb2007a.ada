-- CB2007A.ADA

-- CHECK THAT AN EXIT STATEMENT IN A HANDLER CAN TRANSFER CONTROL
-- OUT OF A LOOP.

-- DAT 4/13/81
--  RM 4/30/81
-- SPS 3/23/83

WITH REPORT; USE REPORT;

PROCEDURE CB2007A IS
BEGIN
     TEST ("CB2007A", "EXIT STATEMENTS IN EXCEPTION HANDLERS");

     DECLARE
          FLOW_INDEX : INTEGER := 0 ;
     BEGIN

          FOR I IN 1 .. 10 LOOP
               BEGIN
                    IF I = 1 THEN
                         RAISE CONSTRAINT_ERROR;
                    END IF;
                    FAILED ("WRONG CONTROL FLOW 1");
               EXCEPTION
                    WHEN CONSTRAINT_ERROR => EXIT;
               END;
               FAILED ("WRONG CONTROL FLOW 2");
               EXIT;
          END LOOP;

          FOR AAA IN 1..1 LOOP
               FOR BBB IN 1..1 LOOP
                    FOR I IN 1 .. 10 LOOP
                         BEGIN
                              IF I = 1 THEN
                                   RAISE CONSTRAINT_ERROR;
                              END IF;
                              FAILED ("WRONG CONTROL FLOW A1");
                         EXCEPTION
                              WHEN CONSTRAINT_ERROR => EXIT;
                         END;
                         FAILED ("WRONG CONTROL FLOW A2");
                         EXIT;
                    END LOOP;

                    FLOW_INDEX := FLOW_INDEX + 1 ;
               END LOOP;
          END LOOP;

          LOOP1 :
          FOR AAA IN 1..1 LOOP
               LOOP2 :
               FOR BBB IN 1..1 LOOP
                    LOOP3 :
                    FOR I IN 1 .. 10 LOOP
                         BEGIN
                              IF I = 1 THEN
                                   RAISE CONSTRAINT_ERROR;
                              END IF;
                              FAILED ("WRONG CONTROL FLOW B1");
                         EXCEPTION
                              WHEN CONSTRAINT_ERROR => EXIT LOOP2 ;
                         END;
                         FAILED ("WRONG CONTROL FLOW B2");
                         EXIT LOOP2 ;
                    END LOOP  LOOP3 ;

                    FAILED ("WRONG CONTROL FLOW B3");
               END LOOP  LOOP2 ;

               FLOW_INDEX := FLOW_INDEX + 1 ;
          END LOOP  LOOP1 ;

          IF  FLOW_INDEX /= 2  THEN  FAILED( "WRONG FLOW OF CONTROL" );
          END IF;

     END ;

     RESULT;
END CB2007A;
