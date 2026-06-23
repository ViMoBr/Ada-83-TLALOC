-- CC3407B.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED IF THE CONSTRAINTS IMPOSED ON A
-- FORMAL ARRAY TYPE'S COMPONENT TYPE DO NOT MATCH THOSE OF THE ACTUAL
-- PARAMETER'S COMPONENT TYPE.

-- CHECK FOR FIXED AND FLOAT TYPES.

-- SPS 6/29/82
-- JBG 2/13/84

WITH REPORT;
USE REPORT;

PROCEDURE CC3407B IS
BEGIN

     TEST ("CC3407B", "CONSTRAINT_ERROR RAISED WHEN ARRAY COMPONENT " &
          "TYPES DO NOT MATCH.  COMPONENT TYPE FIXED & FLOAT");

     DECLARE
          TYPE FIX IS DELTA 0.1 RANGE 1.0..3.0;
          SUBTYPE FL IS FLOAT RANGE -1.0..1.0;
          SUBTYPE SMALL IS INTEGER RANGE 1..5;

     BEGIN
          FOR I IN 1..IDENT_INT(3) LOOP
               COMMENT ("START OF ITERATION");

               DECLARE
                    SUBTYPE SFX IS FIX RANGE FIX(I)..3.0;
                    SUBTYPE SFL IS FLOAT RANGE -1.0 .. FLOAT(I);
                    TYPE AR_FX IS ARRAY(SMALL) OF SFX;
                    TYPE AR_FL IS ARRAY(SMALL) OF SFL;

                    GENERIC
                         TYPE AR IS ARRAY(SMALL) OF FIX;
                    PACKAGE PFX IS END PFX;

                    GENERIC
                         TYPE AR IS ARRAY(SMALL) OF FL;
                    PACKAGE PFL IS END PFL;

               BEGIN
                    BEGIN
                         DECLARE
                              PACKAGE NPFX IS NEW PFX(AR_FX);
                         BEGIN
                              IF I>1 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                           "NOT RAISED FIXED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF I<1 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                   "RAISED INAPPROPRIATELY FIXED");
                              END IF;
                    END;
                    BEGIN
                         DECLARE
                              PACKAGE NPFL IS NEW PFL(AR_FL);
                         BEGIN
                              IF I>1 THEN
                                   FAILED ("CONSTRAINT_ERROR NOT " &
                                           "RAISED FLOAT");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF I=1 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                   "RAISED INAPPROPRIATELY FLOAT");
                              END IF;
                    END;
               END;  
          END LOOP;
     END;
     RESULT;
END CC3407B;
