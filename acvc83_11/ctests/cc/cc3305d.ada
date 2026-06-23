-- CC3305D.ADA

-- CHECK THAT WHEN A GENERIC FORMAL TYPE IS A SCALAR TYPE, THE BOUNDS OF
-- THE ACTUAL PARAMETER ARE USED WITHIN THE INSTANTIATED UNIT.

-- CHECK WHEN THE SCALAR TYPE IS DEFINED BY DELTA <>.

-- SPS 7/15/82

WITH REPORT;
USE REPORT;

PROCEDURE CC3305D IS
BEGIN

     TEST ("CC3305D", "TEST THE BOUNDS OF GENERIC FORMAL SCALAR " &
           "TYPES OF THE FORM DELTA <>");

     DECLARE
          TYPE FX IS DELTA 0.1 RANGE 1.0 .. 3.0;

          GENERIC
               TYPE GFT IS DELTA <>;
          PACKAGE PK IS END PK;

          PACKAGE BODY PK IS
          BEGIN
               FOR I IN IDENT_INT(0) .. IDENT_INT(4) LOOP
                    COMMENT ("START OF ITERATION");
                    DECLARE
                         VAR : GFT;
                    BEGIN
                         VAR := GFT (I);
                         IF I = IDENT_INT(0) OR I = IDENT_INT(4) THEN
                              FAILED ("CONSTRAINT_ERROR NOT RAISED");
                         END IF;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF I /= IDENT_INT(0) AND
                                 I /= IDENT_INT(4) THEN
                                   FAILED ("CONSTRAINT_ERROR RAISED " &
                                      "INAPPROPRIATELY");
                              END IF;
                    END;
               END LOOP;
          END PK;

     BEGIN

          DECLARE
               PACKAGE NP IS NEW PK (FX);
          BEGIN
               NULL;
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED ON INSTANTIATION");
     END;

     RESULT;
END CC3305D;
