-- CC3305B.ADA

-- CHECK THAT WHEN A GENERIC FORMAL TYPE IS A SCALAR TYPE, THE BOUNDS OF
-- THE ACTUAL PARAMETER ARE USED WITHIN THE INSTANTIATED UNIT.

-- CHECK WHEN THE SCALAR TYPE IS DEFINED BY RANGE <>.

-- SPS 7/15/82

WITH REPORT;
USE REPORT;

PROCEDURE CC3305B IS
BEGIN

     TEST ("CC3305B", "TEST THE BOUNDS OF GENERIC FORMAL SCALAR " &
           "TYPES OF THE FORM RANGE <>");

     DECLARE
          SUBTYPE INT IS INTEGER RANGE 1 .. 3;

          GENERIC
               TYPE GFT IS RANGE <>;
          PACKAGE PK IS END PK;

          PACKAGE BODY PK IS
          BEGIN
               FOR I IN IDENT_INT(0) .. IDENT_INT(4) LOOP
                    COMMENT ("START OF ITERATION");
                    DECLARE
                         VAR : GFT;
                    BEGIN
                         VAR := GFT(I);
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
               PACKAGE NPI IS NEW PK (INT);
          BEGIN
               NULL;
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED ON INSTANTIATION");
     END;

     RESULT;
END CC3305B;
