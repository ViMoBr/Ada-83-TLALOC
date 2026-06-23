-- CC3504F.ADA

-- WHEN A GENERIC FORMAL TYPE IS AN ACCESS TYPE, CHECK THAT 
-- CONSTRAINT_ERROR IS RAISED WHEN CONSTRAINTS IMPOSED ON ITS DESIGNATED
-- TYPE T ARE NOT THE SAME AS THE CONSTRAINTS ON THE DESIGNATED TYPE OF
-- THE ACTUAL PARAMETER.

-- CHECK INDEX AND DISCRIMINANT CONSTRAINTS.

-- CHECK WHEN T IS A GENERIC FORMAL TYPE APPEARING IN THE SAME FORMAL
-- PART.

-- DAT 9/25/81
-- SPS 6/4/82
-- VKG 2/16/83

WITH REPORT; USE REPORT;

PROCEDURE CC3504F IS
BEGIN
     TEST ("CC3504F", "GENERIC ACCESS TYPE PARAMETER: CONSTRAINT"
          & "_ERROR FOR DIFFERENT INDEX AND DISCRIMINANT"
          & " CONSTRAINTS ON ACCESSED SUBTYPES");

     DECLARE

          TYPE REC (D : INTEGER) IS
          RECORD NULL; END RECORD;
          PACKAGE PRIV IS
               TYPE PV (D : INTEGER) IS PRIVATE;
          PRIVATE
               TYPE PV (D: INTEGER) IS 
               RECORD NULL; END RECORD;
          END PRIV;

          USE PRIV;

          SUBTYPE R IS REC (D => IDENT_INT(2));
          SUBTYPE S IS STRING (IDENT_INT (2) .. 4);
          SUBTYPE PT IS PV (D => IDENT_INT(2));

          GENERIC
               TYPE T IS PRIVATE;
               TYPE FT IS ACCESS T;
          PACKAGE PK IS END PK;

     BEGIN
          FOR I IN IDENT_INT(1) .. 3 LOOP
               COMMENT ("LOOP ITERATION");
               BEGIN
                    DECLARE
                         TYPE AS IS ACCESS  STRING (I .. 2 * I);
                         PACKAGE P1 IS NEW PK (S, AS);
                    BEGIN
                         IF I /= 2 THEN
                              FAILED ("INDEX CONSTRAINT_ERROR "
                                   & "NOT RAISED");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 2 THEN
                              FAILED ("INDEX CONSTRAINT_ERROR "
                                   & "RAISED INAPPROPIATELY");
                         END IF;
               END;

               BEGIN
                    DECLARE
                         TYPE AR IS ACCESS REC (D => IDENT_INT (I));
                         PACKAGE P2 IS NEW PK (R, AR);
                    BEGIN
                         IF I /= 2 THEN
                              FAILED ("RECORD CONSTRAINT_ERROR "
                                   & "NOT RAISED");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 2 THEN
                              FAILED ("RECORD CONSTRAINT_ERROR "
                                   & "RAISED INAPPROPIATELY");
                         END IF;
               END;

               BEGIN
                    DECLARE
                         TYPE AP IS ACCESS PV (D => IDENT_INT (I));
                         PACKAGE PK1 IS NEW PK (PT, AP);
                    BEGIN
                         IF I /= 2 THEN
                              FAILED ("PRIVATE CONSTRAINT_ERROR "
                                   & "NOT RAISED");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         IF I = 2 THEN
                              FAILED ("PRIVATE CONSTRAINT_ERROR "
                                   & "RAISED INAPPROPIATELY");
                         END IF;
               END;
          END LOOP;
     END;

     RESULT;
END CC3504F;
