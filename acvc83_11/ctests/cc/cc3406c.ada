-- CC3406C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE INDEX SUBTYPES OF AN
-- UNCONSTRAINED FORMAL ARRAY TYPE AND AN UNCONSTRAINED ACTUAL ARRAY
-- TYPE DO NOT HAVE THE SAME CONSTRAINT VALUES.

-- CHECK WHEN THE INDEX SUBTYPE IS A GENERIC FORMAL PARAMETER DECLARED
-- IN AN ENCLOSING GENERIC UNIT.

-- SPS 6/29/82
-- JRK 2/2/83

WITH REPORT;
USE REPORT;

PROCEDURE CC3406C IS
BEGIN
     TEST ("CC3406C", "CONSTRAINT_ERROR RAISED WHEN INDEX SUBTYPES " &
           "DON'T MATCH.  INDEX SUBTYPES ARE GENERIC TYPES IN " &
           "ENCLOSING GENERIC UNIT");

     FOR I IN IDENT_INT (1) .. IDENT_INT (3) LOOP
          COMMENT ("START OF ITERATION");

          DECLARE
               SUBTYPE CI IS INTEGER RANGE IDENT_INT (1) .. 
                                           IDENT_INT (3);
               SUBTYPE NATURAL IS INTEGER RANGE 1 .. INTEGER'LAST;

               GENERIC
                    TYPE T IS RANGE <>;
               PACKAGE GP IS
                    SUBTYPE INT IS T RANGE T (I) .. T (IDENT_INT (3));
                    TYPE ARR IS ARRAY (INT RANGE <>) OF NATURAL;

                    GENERIC
                         TYPE FT IS ARRAY (T RANGE <>) OF NATURAL;
                    PACKAGE P IS END P;
               END GP;

               PACKAGE BODY GP IS
               BEGIN
                    DECLARE
                         PACKAGE NP IS NEW P (ARR);
                    BEGIN
                         IF I > 1 THEN
                              FAILED ("CONSTRAINT_ERROR NOT RAISED");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 1 THEN 
                              FAILED ("CONSTRAINT_ERROR RAISED" &
                                      " INAPPROPRIATELY");
                         END IF;
               END GP;

          BEGIN
               DECLARE
                    PACKAGE NGP IS NEW GP (CI);
               BEGIN
                    NULL;
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    FAILED ("CONSTRAINT_ERROR RAISED ON " &
                            "INSTANTIATION OF GP");
          END;
     END LOOP;

     RESULT;

END CC3406C;
