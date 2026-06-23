-- CC3504H.ADA

-- WHEN A GENERIC FORMAL TYPE IS AN ACCESS TYPE, CHECK THAT
-- CONSTRAINT_ERROR IS RAISED WHEN THE CONSTRAINTS IMPOSED ON ITS
-- DESIGNATED TYPE T IS NOT THE SAME AS THE CONSTRAINTS ON THE
-- DESIGNATED TYPE OF THE ACTUAL PARAMETER.

-- CHECK FOR FIXED AND FLOAT ACCESSED TYPES.

-- CHECK WHEN T IS A GENERIC FORMAL TYPE APPEARING IN THE SAME FORMAL
-- PART.

-- DAT 9/24/81
-- SPS 6/4/82

WITH REPORT; USE REPORT;

PROCEDURE CC3504H IS
BEGIN
     TEST ("CC3504H", "CONSTRAINT_ERROR ON FIXED AND FLOAT TYPES "
          & "ACCESSED BY GENERIC ACCESS TYPE PARAMETERS.  DESIGNATED"
          & " TYPE IS A GENERIC FORMAL TYPE.");

     FOR L IN IDENT_INT (1) .. IDENT_INT (4) LOOP
          COMMENT ("LOOP ITERATION");
          DECLARE
               TYPE FIX IS DELTA 0.125 RANGE 0.0 .. 5.0;
               SUBTYPE SFIX IS FIX RANGE FIX(L) .. FIX(3);
               SUBTYPE SFLOAT IS FLOAT DIGITS FLOAT'DIGITS RANGE
                    FLOAT (L) .. FLOAT (3);
               TYPE AF IS ACCESS SFIX;
               TYPE AFL IS ACCESS SFLOAT;
               SUBTYPE FX IS FIX RANGE 2.0 .. 3.0;
               SUBTYPE FL IS FLOAT DIGITS FLOAT'DIGITS RANGE 2.0 .. 3.0;

               GENERIC
                    TYPE T IS DELTA <>;
                    TYPE FT IS ACCESS T;
               PACKAGE PF IS END PF;

               GENERIC
                    TYPE T IS DIGITS <>;
                    TYPE FT IS ACCESS T;
               PACKAGE PFL IS END PFL;
          BEGIN
               BEGIN
                    DECLARE
                         PACKAGE I1 IS NEW PF (FX, AF);
                    BEGIN
                         IF L /= 2 THEN
                              FAILED ("FIXED CONSTRAINT_ERROR");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF L = 2 THEN
                              FAILED ("FIXED CONSTRAINT_ERROR RAISED "
                                   & "INAPPROPRIATELY");
                         END IF;
               END;

               BEGIN
                    DECLARE
                         PACKAGE I1 IS NEW PFL (FL, AFL);
                    BEGIN
                         IF L /= 2 THEN
                              FAILED ("FLOAT CONSTRAINT_ERROR");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF L = 2 THEN 
                              FAILED ("FLOAT CONSTRAINT_ERROR RAISED "
                                   & "INAPPROPRIATELY");
                         END IF;
               END;
          END;
     END LOOP;

     RESULT;
END CC3504H;
