-- CC3504G.ADA

-- WHEN A GENERIC FORMAL TYPE IS AN ACCESS TYPE, CHECK THAT
-- CONSTRAINT_ERROR IS RAISED WHEN CONSTRAINTS IMPOSED ON ITS DESIGNATED
-- TYPE T ARE NOT THE SAME AS THE CONSTRAINTS ON THE DESIGNATED TYPE OF
-- THE ACTUAL PARAMETER.

-- CHECK WHEN T IS AN ACCESS TYPE.

-- CHECK WHEN T IS A GENERIC FORMAL TYPE APPEARING IN THE SAME FORMAL
-- PART.

-- DAT 9/25/81
-- SPS 6/4/82

WITH REPORT; USE REPORT;

PROCEDURE CC3504G IS
BEGIN
     TEST ("CC3504G", "CONSTRAINT_ERROR WHEN GENERIC ACCESS TYPE"
          &" PARAMETER ACCESSES ACCESS TYPE WITH DIFFERENT CONSTRAINT."
          & "  DESIGNATED TYPE IS A FORMAL GENERIC PARAMETER.");

     DECLARE
          TYPE REC (D : BOOLEAN) IS
          RECORD NULL; END RECORD;
          TYPE AR IS ACCESS REC;
          TYPE AS IS ACCESS STRING;

          GENERIC
               TYPE T IS PRIVATE;
               TYPE FT IS ACCESS T;
          PACKAGE PKG IS END PKG;
     BEGIN
          FOR L IN BOOLEAN LOOP
               COMMENT ("FIRST L LOOP ITERATION");
               FOR R IN BOOLEAN LOOP
                    COMMENT ("FIRST R LOOP ITERATION");
                    BEGIN
                         DECLARE
                              SUBTYPE T1 IS AR (L);
                              TYPE ARR IS ACCESS AR (R);
                              PACKAGE Z1 IS NEW PKG (T1, ARR);
                         BEGIN
                              IF L /= R THEN
                                   FAILED ("ACCESS TO ACCESS " &
                                           "RECORD EXCEPTION " &
                                           "NOT RAISED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF L = R THEN
                                   FAILED ("EXCEPTION ACCESS TO " & 
                                           "RECORD RAISED " &
                                           "INAPPROPRIATELY");
                              END IF;
                    END;
               END LOOP;
          END LOOP;

          DECLARE
               SUBTYPE T2 IS AS (IDENT_INT (1) .. IDENT_INT (2));
               L : INTEGER;
          BEGIN
               FOR LB IN BOOLEAN LOOP
               L := BOOLEAN'POS(LB) * 2 + 1;            -- 1,3
                    COMMENT ("SECOND L LOOP ITERATION");
               FOR R IN 1 .. IDENT_INT (3) LOOP
                    COMMENT ("SECOND R LOOP ITERATION");
                    DECLARE
                         TYPE AAS IS ACCESS AS (L .. R);
                    BEGIN
                         DECLARE
                              PACKAGE Z1 IS NEW PKG (T2, AAS);
                         BEGIN
                              IF L /= IDENT_INT(1) OR R /= 2 THEN
                                   FAILED ("ACCESS TO STRING " &
                                           "CONSTRAINT_ERROR " &
                                           "NOT RAISED");
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
               SUBTYPE T3 IS AS(IDENT_INT(3)..IDENT_INT(1));
          BEGIN
               FOR L IN IDENT_INT(1)..IDENT_INT(3) LOOP
                    COMMENT ("THIRD L LOOP ITERATION");
                    DECLARE
                         TYPE AAS IS ACCESS AS(L..IDENT_INT(1));
                    BEGIN
                         DECLARE
                              PACKAGE PK IS NEW PKG(T3, AAS);
                         BEGIN
                              IF L /= IDENT_INT(3) THEN
                                   FAILED ("ACCESS TO STRING NULL " &
                                           "RANGE CONSTRAINT_ERROR " &
                                           "NOT RAISED");
                              END IF;
                         END;
                    EXCEPTION
                         WHEN CONSTRAINT_ERROR =>
                              IF L = IDENT_INT(3) THEN
                                   FAILED ("ACCESS TO STRING NULL " &
                                           "RANGE CONSTRAINT_ERROR " &
                                           "RAISED INAPPROPRIATELY");
                              END IF;
                         END;
                    END LOOP;
               END;
     END;

     RESULT;
END CC3504G;
