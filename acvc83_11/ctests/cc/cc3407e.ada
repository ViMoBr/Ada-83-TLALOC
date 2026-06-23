-- CC3407E.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE CONSTRAINTS ON THE
-- FORMAL ARRAY TYPE'S COMPONENT TYPE DO NOT MATCH THOSE OF THE ACTUAL
-- ARRAY TYPE'S COMPONENT.

-- CHECK WHEN BOTH THE COMPONENT TYPES ARE OF THE SAME FORMAL GENERIC
-- TYPE DECLARED IN AN ENCLOSING GENERIC UNIT.

-- SPS 7/2/82
-- JBG 5/29/85

WITH REPORT;
USE REPORT;

PROCEDURE CC3407E IS

BEGIN
     TEST ("CC3407E", "CONSTRAINT_ERROR RAISED WHEN CONSTRAINTS " &
           "ON COMPONENT SUBTYPES DO NOT MATCH.  COMPONENTS ARE " &
           "GENERIC FORMAL TYPE DECLARED IN ENCLOSING UNIT.");

     DECLARE
          SUBTYPE NATURAL IS INTEGER RANGE 1..10;
          TYPE REC(D : NATURAL) IS RECORD NULL; END RECORD;

          GENERIC
               TYPE COMP(D : NATURAL) IS PRIVATE;
          PACKAGE PK IS
               SUBTYPE F_COMP IS COMP(D => 3);

               GENERIC
                    TYPE AR IS ARRAY(NATURAL) OF F_COMP;
               PACKAGE P IS END P;
          END PK;

          PACKAGE BODY PK IS
               BEGIN
               FOR I IN 1..IDENT_INT(3) LOOP
               COMMENT ("START OF ITERATION");
                    DECLARE
                         SUBTYPE A_COMP IS COMP(D => I);
                         TYPE AR_A IS ARRAY(NATURAL) OF A_COMP;
                    BEGIN
                         DECLARE
                              PACKAGE NP IS NEW P(AR_A);
                         BEGIN     
                              IF I /= 3 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                           "NOT RAISED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF I = 3 THEN
                                   FAILED ("CONSTRAINT_ERROR " &
                                           "RAISED INAPPROPRIATELY");
                              END IF;
                    END;
               END LOOP;
          END PK;
     BEGIN
          DECLARE
               PACKAGE NPK IS NEW PK(REC);
          BEGIN
               NULL;
          END; 
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED UPON " &
                       "INSTANTIATION OF OUTER PACKAGE");
     END;
     RESULT;
END CC3407E;
