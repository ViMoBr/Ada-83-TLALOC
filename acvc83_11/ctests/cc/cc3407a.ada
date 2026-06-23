-- CC3407A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE CONSTRAINTS IMPOSED ON A
-- FORMAL ARRAY TYPE'S COMPONENT TYPE DO NOT MATCH THOSE OF THE ACTUAL
-- PARAMETER'S COMPONENT TYPE.

-- SPS 6/29/82
-- VKG 2/16/83
-- JBG 5/29/85

WITH REPORT;
USE REPORT;

PROCEDURE CC3407A IS
BEGIN
     TEST ("CC3407A", "CONSTRAINT_ERROR RAISED WHEN ARRAY COMPONENT " &
           "TYPES DON'T MATCH");

     DECLARE
          TYPE ENUM IS (E1, E2, E3, E4, E5, E6);
          SUBTYPE INT IS INTEGER RANGE IDENT_INT(3)..IDENT_INT(6);
          SUBTYPE EN IS ENUM RANGE E3..E6;
          SUBTYPE NATURAL IS INTEGER RANGE 1..10;

     BEGIN
          FOR I IN IDENT_INT(3)..4 LOOP
               COMMENT ("START OF ITERATION");

               DECLARE
                    SUBTYPE SI IS INTEGER RANGE I..IDENT_INT(6);
                    SUBTYPE SE IS ENUM RANGE
                         ENUM'VAL(I-1)..E6;
                    TYPE AR_I IS ARRAY(NATURAL) OF SI;
                    TYPE AR_E IS ARRAY(NATURAL) OF SE;

                    GENERIC
                         TYPE AR IS ARRAY(NATURAL) OF INT;
                    PACKAGE PINT IS END PINT;

                    GENERIC
                         TYPE AR IS ARRAY(NATURAL) OF EN;
                    PACKAGE PEN IS END PEN;

               BEGIN
                    BEGIN
                         DECLARE
                              PACKAGE NPINT IS NEW PINT(AR_I);

                         BEGIN
                              IF I/=3 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                   "NOT RAISED ON INTEGER");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF I=3 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                           "RAISED INAPPROPRIATELY " & 
                                           "ON INTEGER");
                              END IF;
                    END;
                    BEGIN
                         DECLARE
                              PACKAGE NPEN IS NEW PEN(AR_E);
                         BEGIN
                              IF I/=3 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                   "NOT RAISED ON ENUM");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF I=3 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                   "RAISED INAPPROPRIATELY " &
                                   "ON ENUM");
                              END IF;
                    END;
               END;
          END LOOP;
     END;
     RESULT;
END CC3407A; 
