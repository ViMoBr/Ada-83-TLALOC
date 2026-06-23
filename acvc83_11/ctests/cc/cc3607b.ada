-- CC3607B.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN A DEFAULT SUBPROGRAM IS SPECIFIED WITH A BOX, A
--     SUBPROGRAM DIRECTLY VISIBLE AT THE POINT OF INSTANTIATION
--     IS USED.

-- HISTORY:
--     LDC 08/23/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CC3607B IS

BEGIN
     TEST ("CC3607B", "CHECK THAT WHEN A DEFAULT SUBPROGRAM IS " &
                      "SPECIFIED WITH A BOX, A SUBPROGRAM DIRECTLY " &
                      "VISIBLE AT THE POINT OF INSTANTIATION IS USED");
     DECLARE
          PACKAGE PROC_PACK IS
               PROCEDURE PROC;

               GENERIC
                    WITH PROCEDURE PROC IS <>;
               PACKAGE GEN_PACK IS
                    PROCEDURE DO_PROC;
               END GEN_PACK;
          END PROC_PACK;
          USE PROC_PACK;

          PACKAGE BODY PROC_PACK IS
               PROCEDURE PROC IS
               BEGIN
                    FAILED("WRONG SUBPROGRAM WAS USED");
               END PROC;

               PACKAGE BODY GEN_PACK IS
                    PROCEDURE DO_PROC IS
                    BEGIN
                         PROC;
                    END DO_PROC;
               END GEN_PACK;
          END PROC_PACK;

          PROCEDURE PROC IS
          BEGIN
               COMMENT ("SUBPROGRAM VISIBLE AT INSTANTIATION WAS " &
                        "USED");
          END PROC;

          PACKAGE NEW_PACK IS NEW GEN_PACK;

     BEGIN
          NEW_PACK.DO_PROC;
     END;

     RESULT;
END CC3607B;
