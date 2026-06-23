-- C98001B.ADA

-- CHECK THAT NO EXCEPTION IS RAISED IF THE EXPRESSION IN A PRAGMA
-- PRIORITY IS STATIC AND THE VALUE OF THE EXPRESSION IS OUTSIDE THE
-- RANGE OF THE SUBTYPE PRIORITY, IF THE PRAGMA IS LOCATED IN A TASK
-- SPECIFICATION.

-- TBN  12/18/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE C98001B IS

BEGIN
     TEST ("C98001B", "CHECK THAT NO EXCEPTION IS RAISED IF THE " &
                      "EXPRESSION IN A PRAGMA PRIORITY IS STATIC AND " &
                      "THE VALUE OF THE EXPRESSION IS OUTSIDE THE " &
                      "RANGE OF THE SUBTYPE PRIORITY, IF THE PRAGMA " &
                      "IS LOCATED IN A TASK SPECIFICATION");
     BEGIN
          DECLARE
               TASK T IS
                    ENTRY E;
                    PRAGMA PRIORITY (PRIORITY'FIRST - 1);
               END T;

               TASK BODY T IS
               BEGIN
                    ACCEPT E DO
                         IF EQUAL(3, 4) THEN
                              FAILED ("INCORRECT RESULT FROM EQUAL " &
                                      "FUNCTION");
                         END IF;
                    END E;
               END T;
          BEGIN
               T.E;
          END;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 1");
     END;
     -------------------------------------------------------------------

     BEGIN
          DECLARE
               TASK TYPE T IS
                    ENTRY E;
                    PRAGMA PRIORITY (PRIORITY'LAST + 1);
               END T;

               OBJ_T : T;

               TASK BODY T IS
               BEGIN
                    ACCEPT E DO
                         IF EQUAL(3, 4) THEN
                              FAILED ("INCORRECT RESULT FROM EQUAL " &
                                      "FUNCTION");
                         END IF;
                    END E;
               END T;
          BEGIN
               OBJ_T.E;
          END;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("UNEXPECTED EXCEPTION RAISED - 2");
     END;

     RESULT;
END C98001B;
