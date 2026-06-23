-- CC3602A.ADA

-- OBJECTIVE:
--     CHECK THAT ENTRIES MAY BE PASSED AS GENERIC SUBPROGRAM
--     PARAMETERS.

-- HISTORY:
--     DAT 9/25/81     CREATED ORIGINAL TEST.
--     LDC 10/6/88     REVISED; CHECKED THAT DEFAULT NAME CAN BE
--                     IDENTIFIED WITH ENTRY.


WITH REPORT; USE REPORT;

PROCEDURE CC3602A IS
     COUNTER : INTEGER := 0;
BEGIN
     TEST ("CC3602A", "ENTRIES AS GENERIC SUBPROGRAM PARAMETERS");

     DECLARE
          TASK TSK IS
               ENTRY ENT;
          END TSK;

          GENERIC
               WITH PROCEDURE P;
          PROCEDURE GP;

          GENERIC
               WITH PROCEDURE P;
          PACKAGE PK IS END PK;


          PROCEDURE E1 RENAMES TSK.ENT;

          GENERIC
               WITH PROCEDURE P IS TSK.ENT;
          PROCEDURE GP_DEF1;

          GENERIC
               WITH PROCEDURE P IS E1;
          PROCEDURE GP_DEF2;

          GENERIC
               WITH PROCEDURE P IS TSK.ENT;
          PACKAGE PK_DEF1 IS END PK_DEF1;

          GENERIC
               WITH PROCEDURE P IS E1;
          PACKAGE PK_DEF2 IS END PK_DEF2;

          PROCEDURE GP IS
          BEGIN
               P;
          END GP;

          PACKAGE BODY PK IS
          BEGIN
               P;
          END PK;


          PROCEDURE GP_DEF1 IS
          BEGIN
               P;
          END GP_DEF1;

          PROCEDURE GP_DEF2 IS
          BEGIN
               P;
          END GP_DEF2;

          PACKAGE BODY PK_DEF1 IS
          BEGIN
               P;
          END PK_DEF1;

          PACKAGE BODY PK_DEF2 IS
          BEGIN
               P;
          END PK_DEF2;

          TASK BODY TSK IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT ENT DO
                              COUNTER := COUNTER + 1;
                         END ENT;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END TSK;

     BEGIN
          DECLARE
               PROCEDURE P1 IS NEW GP (TSK.ENT);
               PROCEDURE E RENAMES TSK.ENT;
               PROCEDURE P2 IS NEW GP (E);
               PACKAGE PK1 IS NEW PK (TSK.ENT);
               PACKAGE PK2 IS NEW PK (E);

               PROCEDURE P3 IS NEW GP_DEF1;
               PROCEDURE P4 IS NEW GP_DEF2;
               PACKAGE PK3 IS NEW PK_DEF1;
               PACKAGE PK4 IS NEW PK_DEF2;
          BEGIN
               P1;
               P2;
               TSK.ENT;
               E;
               P3;
               P4;
          END;
          TSK.ENT;
     END;

     IF COUNTER /= 11 THEN
          FAILED ("INCORRECT CALL OF ENTRY AS GENERIC PARAMETER");
     END IF;

     RESULT;
END CC3602A;
