-- CC3407C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE CONSTRAINTS ON A 
-- FORMAL ARRAY TYPE'S COMPONENT TYPE DO NOT MATCH THE ACTUAL
-- PARAMETER'S COMPONENT TYPE.

-- CHECK WHEN THE COMPONENT TYPES ARE ARRAY TYPES.

-- SPS 6/29/82
-- JBG 2/13/84

WITH REPORT;
USE REPORT;

PROCEDURE CC3407C IS
BEGIN
     TEST ("CC3407C", "CONSTRAINT_ERROR RAISED WHEN ARRAY COMPONENT " &
           "TYPES DO NOT MATCH.  COMPONENT TYPES ARE ARRAY TYPES");

     DECLARE
          SUBTYPE SMALL IS INTEGER RANGE 1..10;
          TYPE ARR IS ARRAY (INTEGER RANGE <>) OF SMALL;
          SUBTYPE COM_AR IS ARR (1..IDENT_INT(3));
          SUBTYPE COM_ST IS STRING (1..3);

     BEGIN
          FOR I IN IDENT_INT(1)..IDENT_INT(3) LOOP
               COMMENT ("START OF ITERATION");

               DECLARE
                    SUBTYPE AR IS ARR (I..IDENT_INT(3));
                    SUBTYPE ST IS STRING(I..3);
                    TYPE AR_AR IS ARRAY (SMALL) OF AR;
                    TYPE AR_ST IS ARRAY (SMALL) OF ST;
                    
                    GENERIC
                         TYPE AR IS ARRAY (SMALL) OF COM_AR;
                    PACKAGE PAR IS END PAR;

                    GENERIC
                         TYPE AR IS ARRAY (SMALL) OF COM_ST;
                    PACKAGE PST IS END PST;

               BEGIN
                    BEGIN
                         DECLARE
                              PACKAGE NPAR IS NEW PAR(AR_AR);
                         BEGIN
                              IF I>1 THEN
                                   FAILED ("CONSTRAINT_ERROR NOT " &
                                           "RAISED ON ARRAY OF " &
                                           "INTEGER");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF I=1 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                           "RAISED INAPPROPRIATELY " &
                                           "ON ARRAY OF INTEGER");
                              END IF;
                    END;
                    BEGIN
                         DECLARE
                              PACKAGE NPST IS NEW PST(AR_ST);
                         BEGIN
                              IF I>1 THEN
                                   FAILED ("CONSTRAINT_ERROR NOT " &
                                           "RAISED ON STRING");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF I=1 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                           "RAISED INAPPROPRIATELY " &
                                           "ON STRING");
                              END IF;
                    END;
               END;
          END LOOP;
     END;
     RESULT;
END CC3407C;
