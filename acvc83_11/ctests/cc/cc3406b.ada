-- CC3406B.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE INDEX SUBTYPES OF AN
-- UNCONSTRAINED FORMAL ARRAY TYPE AND AN UNCONSTRAINED ACTUAL ARRAY
-- TYPE DO NOT HAVE THE SAME CONSTRAINT VALUES.

-- CHECK WHEN THE INDEX SUBTYPE IS A GENERIC FORMAL PARAMETER DECLARED
-- IN THE SAME GENERIC FORMAL PART AS THE ARRAY TYPE.

-- SPS 6/28/82

WITH REPORT;
USE REPORT;

PROCEDURE CC3406B IS
BEGIN
     TEST ("CC3406B", "CONSTRAINT_ERROR RAISED WHEN CONSTRAINTS ON " &
           "INDEX SUBTYPES DO NOT MATCH.  INDEX SUBTYPE IS A GENERIC " &
           "TYPE.");

     DECLARE
          SUBTYPE CI IS INTEGER RANGE 1..IDENT_INT(3);
          SUBTYPE NATURAL IS INTEGER RANGE 1..INTEGER'LAST;

          GENERIC
               TYPE T IS (<>);
               TYPE FT IS ARRAY(T RANGE <>) OF NATURAL;
          PACKAGE P IS END P;

     BEGIN
          FOR I IN 1..IDENT_INT(3) LOOP
               COMMENT ("START OF ITERATION");

               DECLARE
                    SUBTYPE INT IS INTEGER RANGE I..IDENT_INT(3);
                    TYPE ARR IS ARRAY(INT RANGE<>) OF NATURAL;
               BEGIN
                    DECLARE
                         PACKAGE NP IS NEW P(CI,ARR);

                    BEGIN
                         IF I>1 THEN
                              FAILED ("CONSTRAINT_ERROR NOT RAISED");
                         END IF;
                    END;

               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>

                         IF I=1 THEN
                              FAILED ("CONSTRAINT_ERROR RAISED" &
                                   " INAPPROPRIATELY");
                         END IF;

               END;
          END LOOP;

     END;
     RESULT;
END CC3406B;
