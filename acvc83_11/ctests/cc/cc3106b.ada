-- CC3106B.ADA

-- OBJECTIVE:
--     CHECK THAT THE FORMAL PARAMETER DENOTES THE ACTUAL
--     IN AN INSTANTIATION.

-- HISTORY:
--     LDC 06/20/88  CREATED ORIGINAL TEST

WITH REPORT;
USE REPORT;
PROCEDURE CC3106B IS

BEGIN
     TEST("CC3106B","CHECK THAT THE FORMAL PARAMETER DENOTES " &
                    "THE ACTUAL IN AN INSTANTIATION");

     DECLARE
          SUBTYPE SM_INT IS INTEGER RANGE 0..15;
          TYPE PCK_BOL IS ARRAY (5..18) OF BOOLEAN;
          PRAGMA PACK(PCK_BOL);

          TASK TYPE TSK IS
               ENTRY ENT_1;
               ENTRY ENT_2;
               ENTRY ENT_3;
          END TSK;

          GENERIC
               TYPE GEN_TYPE IS (<>);
               GEN_BOLARR : IN OUT PCK_BOL;
               GEN_TYP    : IN OUT GEN_TYPE;
               GEN_TSK    : IN OUT TSK;

          PACKAGE P IS
               PROCEDURE GEN_PROC1;
               PROCEDURE GEN_PROC2;
               PROCEDURE GEN_PROC3;
          END P;

          ACT_BOLARR : PCK_BOL := (OTHERS => FALSE);
          SI         : SM_INT;
          T          : TSK;

          PACKAGE BODY P IS
               PROCEDURE GEN_PROC1 IS
               BEGIN
                   GEN_BOLARR(14) := IDENT_BOOL(TRUE);
                   GEN_TYP := GEN_TYPE'VAL(4);
                   IF ACT_BOLARR(14) /= TRUE OR SI /= IDENT_INT(4)
                        THEN
                             FAILED("VALUES ARE DIFFERENT THAN " &
                                    "INSTANTIATED VALUES");
                   END IF;
               END GEN_PROC1;

               PROCEDURE GEN_PROC2 IS
               BEGIN
                   IF GEN_BOLARR(9) /= IDENT_BOOL(TRUE) OR
                      GEN_TYPE'POS(GEN_TYP) /= IDENT_INT(2)
                        THEN
                             FAILED("VALUES ARE DIFFERENT THAN " &
                                    "VALUES ASSIGNED IN THE MAIN " &
                                    "PROCEDURE");
                   END IF;
                   GEN_BOLARR(18) := TRUE;
                   GEN_TYP := GEN_TYPE'VAL(9);
               END GEN_PROC2;

               PROCEDURE GEN_PROC3 IS
               BEGIN
                    GEN_TSK.ENT_2;
               END GEN_PROC3;
          END P;

          TASK BODY TSK IS
          BEGIN
               ACCEPT ENT_1 DO
                    COMMENT("TASK ENTRY 1 WAS CALLED");
               END;
               ACCEPT ENT_2 DO
                    COMMENT("TASK ENTRY 2 WAS CALLED");
               END;
               ACCEPT ENT_3 DO
                    COMMENT("TASK ENTRY 3 WAS CALLED");
               END;
          END TSK;

          PACKAGE INSTA1 IS NEW P( GEN_TYPE     => SM_INT,
                                   GEN_BOLARR   => ACT_BOLARR,
                                   GEN_TYP      => SI,
                                   GEN_TSK      => T);
     BEGIN
          INSTA1.GEN_PROC1;
          ACT_BOLARR(9) := TRUE;
          SI := 2;
          INSTA1.GEN_PROC2;
          IF ACT_BOLARR(18) /= IDENT_BOOL(TRUE) OR
             SI /= IDENT_INT(9) THEN
               FAILED("VALUES ARE DIFFERENT THAN VALUES ASSIGNED IN " &
                      "THE GENERIC PROCEDURE");
          END IF;

          T.ENT_1;
          INSTA1.GEN_PROC3;
          T.ENT_3;

     END;

     RESULT;

END CC3106B;
