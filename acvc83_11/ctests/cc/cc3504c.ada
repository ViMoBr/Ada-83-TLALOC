-- CC3504C.ADA

-- WHEN A GENERIC FORMAL TYPE IS AN ACCESS TYPE, CHECK THAT
-- CONSTRAINT_ERROR IS RAISED WHEN CONSTRAINTS IMPOSED ON ITS DESIGNATED
-- TYPE T ARE NOT THE SAME AS THE CONSTRAINTS ON THE DESIGNATED TYPE OF
-- THE ACTUAL PARAMETER.

-- CHECK WHEN T IS AN ACCESS TYPE.

-- CHECK WHEN T IS NOT A GENERIC FORMAL TYPE.

-- DAT 9/25/81
-- SPS 6/4/82

WITH REPORT; USE REPORT;

PROCEDURE CC3504C IS
BEGIN
     TEST ("CC3504C", "CONSTRAINT_ERROR WHEN GENERIC ACCESS TYPE"
          &" PARAMETER ACCESSES ACCESS TYPE WITH DIFFERENT CONSTRAINT");

     DECLARE
          TYPE REC (D : BOOLEAN) IS
          RECORD NULL; END RECORD;
          TYPE AR IS ACCESS REC;
          TYPE AS IS ACCESS STRING;
     BEGIN
          FOR L IN BOOLEAN LOOP
               COMMENT ("FIRST LOOP L ITERATION");
               FOR R IN BOOLEAN LOOP
                    COMMENT ("FIRST LOOP R ITERATION");
                    BEGIN
                         DECLARE
                              SUBTYPE T IS AR (L);
                              GENERIC
                                   TYPE FT IS ACCESS T;
                              PACKAGE PKG IS END PKG;
                              TYPE ARR IS ACCESS AR (R);
                              PACKAGE Z1 IS NEW PKG (ARR);
                         BEGIN
                              IF L /= R THEN
                                   FAILED ("ACCESS TO ACCESS RECORD "
                                        & "EXCEPTION NOT RAISED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF L = R THEN
                                   FAILED("EXCEPTION ACCESS TO RECORD "
                                        & "RAISED INAPPROPIATELY");
                              END IF;
                    END;
               END LOOP;
          END LOOP;

          DECLARE
               L : INTEGER;
               SUBTYPE T IS AS (IDENT_INT (1) .. IDENT_INT (2));
               GENERIC
                    TYPE FT IS ACCESS T;
               PACKAGE PKG IS END PKG;
          BEGIN
               FOR LB IN BOOLEAN LOOP
               L := BOOLEAN'POS(LB) * 2 + 1;                  -- 1,3
                    COMMENT ("SECOND L LOOP ITERATION");
               FOR R IN 1 .. IDENT_INT (3) LOOP
                    COMMENT ("SECOND R LOOP ITERATION");
                    DECLARE
                         TYPE AAS IS ACCESS AS (L .. R);
                    BEGIN
                         DECLARE
                              PACKAGE Z1 IS NEW PKG (AAS);
                         BEGIN
                              IF L /= IDENT_INT(1) OR R /= 2 THEN
                                   FAILED ("ACCESS TO STRING "
                                       & "CONSTRAINT_ERROR NOT RAISED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF L = IDENT_INT(1) AND R = 2 THEN
                                   FAILED ("ACCESS TO STRING " &
                                           "CONSTRAINT_ERROR " &
                                           "RAISED INAPPROPRIATELY");
                              END IF;
                    END;
               END LOOP;
               END LOOP;
          END;

          DECLARE
               SUBTYPE T IS AS(IDENT_INT(4)..IDENT_INT(2));
               GENERIC
                    TYPE FT IS ACCESS T;
               PACKAGE PKG IS END PKG;
          BEGIN
               FOR L IN IDENT_INT(1)..IDENT_INT(4) LOOP
                    COMMENT ("THIRD L LOOP ITERATION");
                    DECLARE
                         TYPE AAS IS ACCESS AS(L..IDENT_INT(2));
                    BEGIN
                         DECLARE
                              PACKAGE PK IS NEW PKG(AAS);
                         BEGIN
                              IF L /= IDENT_INT(4) THEN
                                   FAILED ("ACCESS TO STRING " &
                                           "NULL RANGE " &
                                           "CONSTRAINT_ERROR " &
                                           "NOT RAISED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF L = IDENT_INT(4) THEN
                                   FAILED ("ACCESS TO STRING " &
                                           "NULL RANGE " &
                                           "CONSTRAINT_ERROR " &
                                           "RAISED INAPPROPRIATELY");
                              END IF;
                    END;
               END LOOP;
          END;
     END;

     RESULT;
END CC3504C;
