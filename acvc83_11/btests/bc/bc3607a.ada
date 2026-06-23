-- BC3607A.ADA

-- OBJECTIVE:
--     CHECK THAT IF A DEFAULT SUBPROGRAM IS SPECIFIED WITH
--     A BOX, THE MODES OF CORRESPONDING PARAMETERS MUST
--     MATCH.

-- HISTORY:
--     LDC 08/17/88  CREATED ORIGINAL TEST

PROCEDURE BC3607A IS

BEGIN
     DECLARE
          GENERIC
               TYPE PERSONAL_LIFE IS PRIVATE;
          PACKAGE LLZ_LDC IS
               GENERIC
                    WITH PROCEDURE LORI (LYNN : OUT PERSONAL_LIFE)
                         IS <>;

               PACKAGE ZWINK IS
               END ZWINK;

               GENERIC
                    WITH PROCEDURE LORI_2 (LYNN : BOOLEAN) IS <>;

               PACKAGE ZWINK_2 IS
               END ZWINK_2;

               GENERIC
                    WITH PROCEDURE LORI_3 (LYNN : INTEGER) IS <>;

               PACKAGE ZWINK_3 IS
               END ZWINK_3;

               PROCEDURE LORI   (LYNN  : PERSONAL_LIFE);
               PROCEDURE LORI_2 (LYNN  : OUT BOOLEAN);
               PROCEDURE LORI_3 (LYNN  : IN OUT INTEGER);

               PACKAGE CROCKETT IS NEW ZWINK;          -- ERROR: MODES
                                                       --   ARE NOT THE
                                                       --   SAME

               PACKAGE CROCKETT_2 IS NEW ZWINK_2;      -- ERROR: MODES
                                                       --   ARE NOT THE
                                                       --   SAME

               PACKAGE CROCKETT_3 IS NEW ZWINK_3;      -- ERROR: MODES
                                                       --   ARE NOT THE
                                                       --   SAME
          END LLZ_LDC;

          PACKAGE BODY LLZ_LDC IS
               PROCEDURE LORI (LYNN : PERSONAL_LIFE) IS
               BEGIN
                    NULL;
               END LORI;

               PROCEDURE LORI_2 (LYNN  : OUT BOOLEAN) IS
               BEGIN
                    LYNN := TRUE;
               END LORI_2;

               PROCEDURE LORI_3 (LYNN  : IN OUT INTEGER) IS
               BEGIN
                    NULL;
               END LORI_3;

          END LLZ_LDC;

     BEGIN
          NULL;
     END;
END BC3607A;
