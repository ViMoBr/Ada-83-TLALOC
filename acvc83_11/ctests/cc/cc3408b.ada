-- CC3408B.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE BOUNDS OF A
-- CONSTRAINED FORMAL ARRAY TYPE AND A CONSTRAINED ACTUAL ARRAY
-- TYPE DO NOT HAVE THE SAME VALUES.

-- CHECK WHEN THE INDEX IS A GENERIC FORMAL PARAMETER DECLARED
-- IN THE SAME GENERIC FORMAL PART AS THE ARRAY TYPE.

-- SPS 7/6/82

WITH REPORT;
USE REPORT;

PROCEDURE CC3408B IS
BEGIN
     TEST ("CC3408B", "CONSTRAINT_ERROR RAISED WHEN BOUNDS OF ARRAYS " &
           "DO NOT MATCH.  BOUNDS GIVEN BY A GENERIC TYPE.");

     DECLARE
          SUBTYPE ST IS INTEGER RANGE IDENT_INT(1)..IDENT_INT(3);
          SUBTYPE NATURAL IS INTEGER RANGE 1..INTEGER'LAST;

          GENERIC
               TYPE T IS (<>);
               TYPE FT IS ARRAY(T) OF NATURAL;
          PACKAGE P IS END P;

     BEGIN
          FOR I IN IDENT_INT(1)..IDENT_INT(3) LOOP
               COMMENT ("START OF ITERATION");

               DECLARE
                    SUBTYPE INT IS INTEGER RANGE I..IDENT_INT(3);
                    TYPE ARR IS ARRAY(INT) OF NATURAL;
               BEGIN
                    DECLARE
                         PACKAGE NP IS NEW P(ST,ARR);
                    BEGIN
                         IF I/=1 THEN
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
END CC3408B;
