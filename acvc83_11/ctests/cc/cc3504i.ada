-- CC3504I.ADA

-- WHEN A GENERIC FORMAL TYPE IS AN ACCESS TYPE, CHECK THAT
-- CONSTRAINT_ERROR IS RAISED WHEN CONSTRAINTS IMPOSED ON ITS DESIGNATED
-- TYPE T ARE NOT THE SAME AS THE CONSTRAINTS ON THE DESIGNATED TYPE OF
-- THE ACTUAL PARAMETER.

-- CHECK WHEN THE DESIGNATED TYPE OF THE ACTUAL PARAMETER IS A GENERIC
-- TYPE APPEARING IN AN ENCLOSING GENERIC DECLARATION.

-- DAT 9/24/81
-- SPS 6/3/82

WITH REPORT; USE REPORT;

PROCEDURE CC3504I IS
BEGIN
     TEST ("CC3504I", "CONSTRAINT_ERROR ON TYPES ACCESSED BY"
          & " GENERIC ACCESS TYPE PARAMETERS");

     DECLARE
     SUBTYPE INT IS INTEGER RANGE 0 .. 16;

     GENERIC
          TYPE U IS (<>);
     PACKAGE PACK IS END PACK;

     PACKAGE BODY PACK IS 
     BEGIN
          FOR L IN U'VAL (1) .. U'VAL (4) LOOP
               COMMENT ("LOOP ITERATION");
               DECLARE
                    SUBTYPE I IS U RANGE L .. U'VAL(3); 
                    TYPE AI IS ACCESS I;

                    SUBTYPE IU IS U RANGE U'VAL(2) .. U'VAL(3);

                    GENERIC
                         TYPE A IS ACCESS IU;
                    PACKAGE PI IS END PI;

               BEGIN
                    BEGIN
                         DECLARE
                              PACKAGE I1 IS NEW PI (AI);
                         BEGIN
                              IF L /= U'VAL(2) THEN
                                 FAILED ("CONSTRAINT_ERROR NOT RAISED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF L = U'VAL(2) THEN
                                   FAILED ("CONSTRAINT_ERROR RAISED " &
                                        "INAPPROPRIATELY");
                              END IF;
                    END;
               END;
          END LOOP;
     END PACK;

     BEGIN
          DECLARE
               PACKAGE PK1 IS NEW PACK (INT);
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED ON INSTANTIATION OF "
                    & "PACK");
     END;

     RESULT;
END CC3504I;
