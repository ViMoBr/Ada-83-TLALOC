-- CC3408D.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE BOUNDS OF A
-- CONSTRAINED FORMAL ARRAY TYPE AND ACTUAL ARRAY TYPE DO NOT HAVE THE
-- SAME VALUES.

-- CHECK NULL BOUNDS.

-- SPS 7/6/82

WITH REPORT;
USE REPORT;

PROCEDURE CC3408D IS
BEGIN
     TEST ("CC3408D", "CONSTRAINT_ERROR RAISED WHEN ARRAY BOUNDS" &
           " DO NOT MATCH.  NULL BOUNDS CHECKED");
     DECLARE
          SUBTYPE NL IS INTEGER RANGE IDENT_INT(2)..IDENT_INT(1);
          SUBTYPE NATURAL IS INTEGER RANGE 1..INTEGER'LAST;
          
          GENERIC
               TYPE AR IS ARRAY (NL) OF NATURAL;
          PACKAGE P IS END P;
     BEGIN
          FOR I IN IDENT_INT(0)..IDENT_INT(2) LOOP
               COMMENT ("START OF ITERATION");
               DECLARE
                    SUBTYPE INDEX IS INTEGER RANGE IDENT_INT(2)..I;
                    TYPE ARR IS ARRAY (INDEX) OF NATURAL;
               BEGIN
                    DECLARE
                         PACKAGE NP IS NEW P(ARR);
                    BEGIN
                         IF I/=1 THEN
                              FAILED ("CONSTRAINT_ERROR NOT RAISED");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I=1 THEN
                              FAILED ("CONSTRAINT_ERROR RAISED " &
                                      "INAPPROPRIATELY");
                         END IF;
               END;
          END LOOP;
     EXCEPTION 
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED ON DECLARATION OF " &
                       "NULL RANGE");
     END;
     RESULT;
END CC3408D;
