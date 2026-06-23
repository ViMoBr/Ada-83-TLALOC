-- CC3408A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE BOUNDS OF A
-- CONSTRAINED FORMAL ARRAY TYPE AND A CONSTRAINED ACTUAL ARRAY
-- TYPE DO NOT HAVE THE SAME VALUES.

-- SPS 7/6/82

WITH REPORT;
USE REPORT;

PROCEDURE CC3408A IS
BEGIN
     TEST("CC3408A", "CONSTRAINT_ERROR RAISED WHEN INDEX CONSTRAINTS " &
                     "DO NOT MATCH");

     DECLARE
          SUBTYPE ST IS INTEGER RANGE IDENT_INT(1)..IDENT_INT(2);
          SUBTYPE NATURAL IS INTEGER RANGE 1..INTEGER'LAST;

          GENERIC
               TYPE FT IS ARRAY(ST) OF NATURAL;
          PACKAGE P IS END P;

     BEGIN
     
          FOR I IN IDENT_INT(1)..IDENT_INT(2) LOOP
               COMMENT ("START OF ITERATION");

               DECLARE
                    SUBTYPE INT IS INTEGER RANGE I..IDENT_INT(2);
                    TYPE ARR IS ARRAY(INT) OF NATURAL;
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

     END;
     RESULT;
END CC3408A;
