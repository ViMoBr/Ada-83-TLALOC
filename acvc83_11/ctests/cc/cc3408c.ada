-- CC3408C.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE BOUNDS OF A
-- CONSTRAINED FORMAL ARRAY TYPE AND A CONSTRAINED ACTUAL ARRAY
-- TYPE DO NOT HAVE THE SAME VALUES.

-- CHECK WHEN THE INDEX IS A GENERIC FORMAL PARAMETER DECLARED
-- IN AN ENCLOSING GENERIC UNIT.

-- SPS 7/6/82
-- TJW 11/9/82
-- VKG 2/16/83

WITH REPORT;
USE REPORT;

PROCEDURE CC3408C IS
BEGIN
     TEST ("CC3408C", "CONSTRAINT_ERROR RAISED WHEN BOUNDS OF ARRAYS " &
           "DO NOT MATCH.  BOUNDS DEFINED BY GENERIC TYPES OF " &
           "ENCLOSING GENERIC UNIT");

     FOR I IN IDENT_INT (1) .. IDENT_INT (3) LOOP
          COMMENT ("START OF ITERATION");

          DECLARE
               SUBTYPE ST IS INTEGER RANGE IDENT_INT (1) .. 
                                           IDENT_INT (3);
               SUBTYPE NATURAL IS INTEGER RANGE 1 .. INTEGER'LAST;

               GENERIC
                    TYPE T IS (<>);
               PACKAGE GP IS
                    SUBTYPE INT IS T RANGE T'VAL(I) .. 
                                   T'VAL(IDENT_INT (3));
                    TYPE ARR IS ARRAY (INT) OF NATURAL;

                    GENERIC
                         TYPE FT IS ARRAY (T) OF NATURAL;
                    PACKAGE P IS END P;
               END GP;

               PACKAGE BODY GP IS
               BEGIN
                    DECLARE
                         PACKAGE NP IS NEW P (ARR);
                    BEGIN
                         IF I/=1 THEN
                              FAILED ("CONSTRAINT_ERROR NOT " &
                                      "RAISED");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 1 THEN 
                              FAILED ("CONSTRAINT_ERROR RAISED " &
                                      "INAPPROPRIATELY");
                         END IF;
               END GP;

          BEGIN
               DECLARE
                    PACKAGE NGP IS NEW GP (ST);
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

END CC3408C;
