-- CC3407D.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE CONSTRAINTS ON A
-- FORMAL ARRAY TYPE'S COMPONENT TYPE DO NOT MATCH THOSE OF THE ACTUAL
-- PARAMETER'S COMPONENT TYPE.

-- CHECK WHEN THE COMPONENT TYPES ARE TYPES WITH DISCRIMINANTS.

-- SPS 7/1/82
-- JBG 5/29/85

WITH REPORT;
USE REPORT;

PROCEDURE CC3407D IS
BEGIN
     TEST ("CC3407D", "CONSTRAINT_ERROR RAISED WHEN ARRAY COMPONENT " &
           "TYPE DON'T MATCH.  COMPONENT TYPES ARE TYPES WITH " &
           "DISCRIMINANTS");

     DECLARE
          SUBTYPE NATURAL IS INTEGER RANGE 1..10;
          TYPE REC (D:INTEGER) IS RECORD NULL; END RECORD;
          SUBTYPE SR IS REC(D => 2);
          PACKAGE P IS
               TYPE PV (D:INTEGER) IS PRIVATE;
               TYPE LP (D:INTEGER) IS LIMITED PRIVATE;
          PRIVATE
               TYPE PV (D:INTEGER) IS RECORD NULL; END RECORD;
               TYPE LP (D:INTEGER) IS RECORD NULL; END RECORD;
          END P;
          USE P;
          SUBTYPE SPV IS PV (D=>2);
          SUBTYPE SLP IS LP (D=>2);

          GENERIC
               TYPE AR IS ARRAY (NATURAL) OF SR;
          PACKAGE PSR IS END PSR;

          GENERIC
               TYPE AR IS ARRAY (NATURAL) OF SPV;
          PACKAGE PSPV IS END PSPV;

          GENERIC
               TYPE AR IS ARRAY (NATURAL) OF SLP;
          PACKAGE PSLP IS END PSLP;
     BEGIN
          FOR I IN IDENT_INT(1)..IDENT_INT(3) LOOP
               COMMENT ("START OF ITERATION");
               DECLARE
                    SUBTYPE RS IS REC (D=>I);
                    TYPE ARS IS ARRAY (NATURAL) OF RS;
               BEGIN
                    DECLARE
                         PACKAGE NPSR IS NEW PSR(ARS);
                    BEGIN
                         IF I/=2 THEN
                              FAILED ("CONSTRAINT_ERROR NOT " &
                                      "RAISED ON RECORD");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 2 THEN
                              FAILED ("CONSTRAINT_ERROR RAISED " &
                                      "INAPPROPRIATELY ON RECORD");
                         END IF;
               END;
               DECLARE
                    SUBTYPE PVS IS PV (D=>I);
                    TYPE APVS IS ARRAY (NATURAL) OF PVS;
               BEGIN
                    DECLARE
                         PACKAGE NPSPV IS NEW PSPV(APVS);
                    BEGIN
                         IF I/=2 THEN
                              FAILED ("CONSTRAINT_ERROR NOT RAISED " &
                                      "ON PRIVATE TYPE");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I=2 THEN
                              FAILED ("CONSTRAINT_ERROR " &
                                      "RAISED INAPPROPRIATELY " &
                                      "ON PRIVATE TYPE");
                         END IF;
               END;

               DECLARE
                    SUBTYPE LPS IS LP(D => I);
                    TYPE ALPS IS ARRAY(NATURAL) OF LPS;
               BEGIN
                    DECLARE
                         PACKAGE NPSLP IS NEW PSLP(ALPS);
                    BEGIN
                         IF I /= 2 THEN
                              FAILED ("CONSTRAINT_ERROR NOT " &
                                      "RAISED ON LIMITED " &
                                      "PRIVATE TYPE");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 2 THEN
                              FAILED ("CONSTRAINT_ERROR " &
                                      "RAISED INAPPROPRIATELY " &
                                      "ON LIMITED PRIVATE TYPE");
                         END IF;
               END;
          END LOOP;
     END;
     RESULT;
END CC3407D; 
