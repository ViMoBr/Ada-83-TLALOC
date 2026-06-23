-- CD5012B.ADA

-- OBJECTIVE:
--     CHECK THAT AN ADDRESS CLAUSE CAN BE GIVEN FOR A VARIABLE OF AN
--     INTEGER TYPE IN THE DECLARATIVE PART OF A GENERIC PACKAGE BODY.

-- HISTORY:
--     DHH 09/16/87  CREATED ORIGINAL TEST.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
WITH SPPRT13;
PROCEDURE CD5012B IS

BEGIN

     TEST ("CD5012B", "AN ADDRESS CLAUSE CAN BE " &
                      "GIVEN FOR A VARIABLE OF AN INTEGER " &
                      "TYPE IN THE DECLARATIVE PART OF A " &
                      "GENERIC PACKAGE BODY");

     DECLARE

          GENERIC
          PACKAGE GENPACK IS
          END GENPACK;

          PACKAGE BODY GENPACK IS

               INT2 : INTEGER :=2;

               FOR INT2 USE AT
                      SPPRT13.VARIABLE_ADDRESS;

          BEGIN
               IF EQUAL (3, 3) THEN
                    INT2 := 1;
               END IF;
               IF INT2 /= 1 THEN
                    FAILED ("WRONG VALUE FOR VARIABLE IN " &
                            "A GENERIC PACKAGE BODY");
               END IF;
               IF INT2'ADDRESS /= SPPRT13.VARIABLE_ADDRESS THEN
                    FAILED ("WRONG ADDRESS FOR VARIABLE " &
                            "IN A GENERIC PACKAGE BODY");
               END IF;
          END GENPACK;

          PACKAGE PACK IS NEW GENPACK;
     BEGIN
          NULL;
     END;
     RESULT;
END CD5012B;
