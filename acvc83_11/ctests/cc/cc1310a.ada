-- CC1310A.ADA

-- CHECK THAT DEFAULT GENERIC SUBPROGRAM PARAMETERS MAY BE ENTRIES.

-- DAT 9/8/81
-- SPS 2/7/83

WITH REPORT; USE REPORT;

PROCEDURE CC1310A IS
BEGIN
     TEST ("CC1310A", "DEFAULT GENERIC SUBPROGRAM PARAMETERS MAY BE"
          & " ENTRIES");

     DECLARE
          TASK T IS
               ENTRY ENT1;
               ENTRY ENT2 (I : IN INTEGER);
          END T;

          PROCEDURE P1 RENAMES T.ENT1;
          
          PROCEDURE P4 (I : IN INTEGER) RENAMES T.ENT2;

          INT : INTEGER := 0;

          TASK BODY T IS
          BEGIN
               ACCEPT ENT1;
               ACCEPT ENT2 (I : IN INTEGER) DO
                    INT := INT + I;
               END ENT2;
               ACCEPT ENT2 (I : IN INTEGER) DO
                    INT := INT + I;
               END ENT2;
               ACCEPT ENT1;
          END T;

     BEGIN
          DECLARE
               GENERIC 
                    WITH PROCEDURE P1 IS <> ;
                    WITH PROCEDURE P2 IS T.ENT1;
                    WITH PROCEDURE P3 (I : IN INTEGER) IS T.ENT2;
                    WITH PROCEDURE P4 (I : IN INTEGER) IS <> ;
               PACKAGE PKG IS END PKG;

               PACKAGE BODY PKG IS
               BEGIN
                    P1;
                    P4 (3);
                    P3 (6);
                    P2;
               END PKG;

               PACKAGE PP IS NEW PKG;

          BEGIN
               IF INT /= 9 THEN
                    FAILED ("ENTRIES AS DEFAULT GENERIC PARAMETERS");
               END IF;
          END;
     END;

     RESULT;
END CC1310A;
