-- CC3406D.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE INDEX SUBTYPES OF AN
-- UNCONSTRAINED FORMAL ARRAY TYPE AND ACTUAL ARRAY TYPE DO NOT HAVE THE
-- SAME CONSTRAINTS.

-- CHECK WHEN A NULL INDEX SUBTYPE.

-- SPS 7/1/82

WITH REPORT;
USE REPORT;

PROCEDURE CC3406D IS
BEGIN
     TEST ("CC3406D", "CONSTRAINT_ERROR RAISED WHEN INDEX CONSTRAINTS" &
           " DON'T MATCH.  NULL INDEX SUBTYPE CHECKED");
     DECLARE
          SUBTYPE NL IS INTEGER RANGE 2..IDENT_INT(1);
          SUBTYPE NATURAL IS INTEGER RANGE 1..INTEGER'LAST;
          
          GENERIC
               TYPE AR IS ARRAY (NL RANGE <>) OF NATURAL;
          PACKAGE P IS END P;
     BEGIN
          FOR I IN IDENT_INT(0)..IDENT_INT(2) LOOP
               COMMENT ("START OF ITERATION");
               BEGIN
                  DECLARE
                       SUBTYPE INDEX IS INTEGER RANGE IDENT_INT(2)..I;
                       TYPE ARR IS ARRAY (INDEX RANGE <>) OF NATURAL;
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
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         FAILED ("RAISED CONSTRAINT_ERROR " &
                                 "FOR NULL RANGE");
               END;
          END LOOP;
     END;
     RESULT;
END CC3406D;
