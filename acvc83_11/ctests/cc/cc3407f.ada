-- CC3407F.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE CONSTRAINTS ON THE
-- FORMAL ARRAY TYPE'S COMPONENT TYPE DO NOT MATCH THOSE OF THE ACTUAL
-- ARRAY TYPE'S COMPONENT.

-- CHECK WHEN THE COMPONENT TYPE RANGE IS NULL.

-- SPS 7/2/82
-- JBG 5/29/85

WITH REPORT;
USE REPORT;

PROCEDURE CC3407F IS
BEGIN
     TEST ("CC3407F", "CONSTRAINT_ERROR RAISED WHEN CONSTRAINTS ON " &
           "COMPONENT SUBTYPES DO NOT MATCH.  COMPONENT SUBTYPE " &
           "RANGE IS NULL");
     DECLARE
          SUBTYPE NATURAL IS INTEGER RANGE 1..10;
          SUBTYPE NI IS INTEGER RANGE IDENT_INT(2)..IDENT_INT(1);

          GENERIC
               TYPE AR IS ARRAY (NATURAL) OF NI;
          PACKAGE P IS END P;
     BEGIN
          FOR I IN IDENT_INT(0)..IDENT_INT(2) LOOP
               COMMENT ("START OF ITERATION");
               DECLARE
                    SUBTYPE SI IS INTEGER RANGE IDENT_INT(2)..I;
                    TYPE AR_S IS ARRAY (NATURAL) OF SI;
               BEGIN
                    DECLARE
                         PACKAGE NP IS NEW P(AR_S);
                    BEGIN     
                         IF I /= 1 THEN
                              FAILED ("CONSTRAINT_ERROR " &
                                      "NOT RAISED");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I=1 THEN
                              FAILED ("CONSTRAINT_ERROR " &
                                      "RAISED INAPPROPRIATELY");
                         END IF;
               END;
          END LOOP;
     END;
     RESULT;
END CC3407F;
