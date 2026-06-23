-- CC3504K.ADA

-- WHEN A GENERIC FORMAL TYPE IS AN ACCESS TYPE, CHECK THAT
-- CONSTRAINT_ERROR IS RAISED WHEN CONSTRAINTS IMPOSED ON ITS DESIGNATED
-- TYPE T ARE NOT THE SAME AS THE CONSTRAINTS ON THE DESIGNATED TYPE OF
-- THE ACTUAL PARAMETER.

-- CHECK WHEN THE DESIGNATED TYPE OF THE ACTUAL PARAMETER IS A GENERIC
-- TYPE APPEARING IN AN ENCLOSING GENERIC DECLARATION.

-- CHECK WHEN THE DESIGNATED TYPE HAS DISCRIMINANTS.

-- DAT 9/24/81
-- SPS 7/7/82

WITH REPORT; USE REPORT;

PROCEDURE CC3504K IS
BEGIN
     TEST ("CC3504K", "CONSTRAINT_ERROR ON TYPES ACCESSED BY"
          & " GENERIC ACCESS TYPE PARAMETERS");

     DECLARE
     TYPE REC (D : INTEGER :=3) IS RECORD NULL; END RECORD;

     GENERIC
          TYPE U (D : INTEGER) IS PRIVATE;
     PACKAGE PACK IS END PACK;

     PACKAGE BODY PACK IS 
     BEGIN
          FOR L IN 2..3 LOOP
               COMMENT ("LOOP ITERATION");
               DECLARE
                    SUBTYPE I IS U (D => L); 
                    TYPE AI IS ACCESS I;

                    SUBTYPE IU IS U (D => 3);

                    GENERIC
                         TYPE A IS ACCESS IU;
                    PACKAGE PI IS END PI;

               BEGIN
                    BEGIN
                         DECLARE
                              PACKAGE I1 IS NEW PI (AI);
                         BEGIN
                              IF L /= 3 THEN
                                 FAILED ("CONSTRAINT_ERROR NOT RAISED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF L = 3 THEN
                                   FAILED ("CONSTRAINT_ERROR RAISED " &
                                           "INAPPROPRIATELY");
                              END IF;
                    END;
               END;
          END LOOP;
     END PACK;

     BEGIN
          DECLARE
               PACKAGE PK1 IS NEW PACK (REC);
          BEGIN
               NULL;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED ("CONSTRAINT_ERROR RAISED ON INSTANTIATION OF "
                    & "PACK");
     END;

     RESULT;
END CC3504K;
