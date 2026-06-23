-- C42007G.ADA

-- OBJECTIVE:
--     CHECK THAT THE BOUNDS OF A STRING LITERAL ARE DETERMINED
--     CORRECTLY.  IN PARTICULAR, CHECK THAT THE LOWER BOUND IS GIVEN
--     BY THE LOWER BOUND OF THE APPLICABLE INDEX CONSTRAINT WHEN THE
--     STRING LITERAL IS USED AS AN ACTUAL PARAMETER IN A SUBPROGRAM,
--     AND THE FORMAL PARAMETER IS CONSTRAINED.

-- HISTORY:
--     TBN  07/30/86  CREATED ORIGINAL TEST.
--     VCL  08/18/87  MODIFIED THE FAILED MESSAGES FOR CASE_G1 TO
--                    INCLUDE REFERENCE TO VARIABLE 'NAME'.
--                    CHANGED VARIABLE 'A' IN CASE_G2 TO 'TWO_STRS'.
--                    MODIFIED THE IF-STRUCTURE IN CASE_G2 SO THAT
--                    TWO_STRS(11) AND TWO_STRS(12) ARE REFERENCED
--                    ONLY IF TWO_STRS'FIRST AND TWO_STRS'LAST ARE
--                    CORRECT.


WITH REPORT; USE REPORT;
PROCEDURE C42007G IS

BEGIN

     TEST("C42007G", "CHECK THE BOUNDS OF A STRING LITERAL WHEN USED " &
                     "AS AN ACTUAL PARAMETER IN A SUBPROGRAM, AND " &
                     "THE FORMAL PARAMETER IS CONSTRAINED");

     CASE_G1 : DECLARE

                    SUBTYPE STR IS STRING (IDENT_INT(11) .. 15);

                    PROCEDURE PROC1 (NAME : STR) IS
                    BEGIN
                         IF NAME'FIRST /= IDENT_INT(11) THEN
                              FAILED ("LOWER BOUND OF 'NAME' " &
                                      "INCORRECTLY DETERMINED");
                         END IF;

                         IF NAME'LAST /= IDENT_INT(15) THEN
                              FAILED ("UPPER BOUND OF 'NAME'" &
                                      "INCORRECTLY DETERMINED");
                         END IF;

                         IF NAME /= "MIKEY" THEN
                              FAILED ("STRING LITERAL FOR 'NAME' " &
                                      "INCORRECT");
                         END IF;
                    END PROC1;

               BEGIN
                    PROC1 ("MIKEY");
               END CASE_G1;

     CASE_G2 : DECLARE

                    SUBTYPE STR IS STRING (10 .. IDENT_INT(11));
                    TYPE ARRAY_STR IS ARRAY
                                           (IDENT_INT(11) .. 12) OF STR;

                    PROCEDURE PROC2 (TWO_STRS : ARRAY_STR) IS
                    BEGIN
                         IF TWO_STRS'FIRST = 11 AND
                            TWO_STRS'LAST  = 12 THEN

                              IF TWO_STRS(11)'FIRST /= 10 OR
                                 TWO_STRS(12)'FIRST /= 10 THEN
                                   FAILED ("LOWER BOUND OF " &
                                           "'TWO_STRS(11)' OR " &
                                           "'TWO_STRS(12)' " &
                                           " INCORRECTLY DETERMINED");
                              END IF;

                              IF TWO_STRS(11)'LAST /= 11 OR
                                 TWO_STRS(12)'LAST /= 11 THEN
                                   FAILED ("UPPER BOUND OF " &
                                           "'TWO_STRS(11)' OR " &
                                           "'TWO_STRS(12)' " &
                                           "INCORRECTLY DETERMINED");
                              END IF;

                         ELSE
                              FAILED ("UPPER OR LOWER BOUND OF " &
                                      "'TWO_STRS' INCORRECTLY " &
                                      "DETERMINED");
                         END IF;

                         IF TWO_STRS /= ("HI", "HO") THEN
                              FAILED ("STRING LITERAL FOR 'TWO_STRS' " &
                                      "INCORRECT");
                         END IF;
                    END PROC2;

               BEGIN
                    PROC2 (("HI", "HO"));
               END CASE_G2;

     RESULT;

END C42007G;
