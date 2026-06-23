-- AVAT021.ADA

-- OBJECTIVE:
--     CHECK WHETHER SYSTEM.MAX_DIGITS IS AS SPECIFIED.
--     IF A FLOATING POINT TYPE DECLARATION CAN SPECIFY DIGITS
--     SYSTEM.MAX_DIGITS, THEN THIS UNIT WILL REPLACE THE PREVIOUSLY
--     COMPILED AVAT020.
--     IF A FLOATING POINT TYPE DECLARATION WITH DIGITS
--     SYSTEM.MAX_DIGITS + 1 IS REJECTED, AS IT SHOULD BE,
--     THEN THIS UNIT WILL NOT BE REPLACED.

-- HISTORY:
--     PWB 08/11/87  CREATED ORIGINAL TEST FILE.
--     TBN 11/18/87  ADDED CODE TO CREATE INAPPLICABLE LIST.
--     JET 01/18/88  FIXED PROBLEM WITH OVERSIZE STRING CONSTANTS.

WITH DATA_COLLECTION, SYSTEM;
USE DATA_COLLECTION;

PROCEDURE AVAT020 IS

     TYPE FLT IS DIGITS SYSTEM.MAX_DIGITS;
     TESTED : THINGS_TO_SUPPORT := CHECK_MAX_DIGITS;
     LINE1 : CONSTANT STRING := "     SYSTEM.MAX_DIGITS HAS THE " &
                                "SPECIFIED BEHAVIOR";
     LINE2 : CONSTANT STRING := "          VALUE OF " &
                                "SYSTEM.MAX_DIGITS IS " &
                                INTEGER'IMAGE (SYSTEM.MAX_DIGITS);
     LINE3 : CONSTANT STRING := "          TYPE DECLARATION ACCEPTED " &
                                "WITH DIGITS " &
                                INTEGER'IMAGE (SYSTEM.MAX_DIGITS);
     LINE4 : CONSTANT STRING := "          TYPE DECLARATION REJECTED " &
                                "WITH DIGITS " &
                                INTEGER'IMAGE (SYSTEM.MAX_DIGITS+1);
     C : CHARACTER;
BEGIN
     IF SYSTEM.MAX_DIGITS = 28 THEN
          DECLARE
               LINE4 : CONSTANT STRING := "          THIS INDICATES " &
                                          "THAT THE FOLLOWING TESTS " &
                                          "ARE INAPPLICABLE:";
               LINE5 : CONSTANT STRING := "               C24113Y" &
                                          "     C35705Y" &
                                          "     C35706Y" &
                                          "     C35707Y" &
                                          "     C35708Y";
               LINE6 : CONSTANT STRING := "               C35802Y..Z " &
                                          "C45241Y     " &
                                          "C45321Y     " &
                                          "C45421Y     " &
                                          "C45521Y..Z";
               LINE7 : CONSTANT STRING := "               C45524Y..Z" &
                                          "  C45621Y..Z" & "  C45641Y" &
                                          "     C46012Y..Z";
          BEGIN
               FEATURE (TESTED) := (7, ((LINE1'LENGTH, LINE1),
                                        (LINE2'LENGTH, LINE2),
                                        (LINE3'LENGTH, LINE3),
                                        (LINE4'LENGTH, LINE4),
                                        (LINE5'LENGTH, LINE5),
                                        (LINE6'LENGTH, LINE6),
                                        (LINE7'LENGTH, LINE7)));
          END;

     ELSIF SYSTEM.MAX_DIGITS < 29 THEN
          C := CHARACTER'VAL(SYSTEM.MAX_DIGITS + 61);
          DECLARE
               LINE4 : CONSTANT STRING := "          THIS INDICATES " &
                                          "THAT THE FOLLOWING TESTS " &
                                          "ARE INAPPLICABLE:";
               LINE5 : CONSTANT STRING := "              C24113" & C &
                                          "..Y" & "  C35705" & C &
                                          "..Y" & "  C35706" & C &
                                          "..Y" & "  C35707" & C &
                                          "..Y" & "  C35708" & C &
                                          "..Y";
               LINE6 : CONSTANT STRING := "              C35802" & C &
                                          "..Z" & "  C45241" & C &
                                          "..Y" & "  C45321" & C &
                                          "..Y" & "  C45421" & C &
                                          "..Y" & "  C45521" & C &
                                          "..Z";
               LINE7 : CONSTANT STRING := "              C45524" & C &
                                          "..Z" & "  C45621" & C &
                                          "..Z" & "  C45641" & C &
                                          "..Y" & "  C46012" & C &
                                          "..Z";
          BEGIN
               FEATURE (TESTED) := (7, ((LINE1'LENGTH, LINE1),
                                        (LINE2'LENGTH, LINE2),
                                        (LINE3'LENGTH, LINE3),
                                        (LINE4'LENGTH, LINE4),
                                        (LINE5'LENGTH, LINE5),
                                        (LINE6'LENGTH, LINE6),
                                        (LINE7'LENGTH, LINE7)));
          END;

     ELSIF SYSTEM.MAX_DIGITS = 29 THEN

          DECLARE
               LINE5 : CONSTANT STRING := "          THIS INDICATES " &
                                          "THAT THE FOLLOWING TESTS " &
                                          "ARE INAPPLICABLE:";
               LINE6 : CONSTANT STRING := "               C35802Z  " &
                                          "C45521Z  " & "C45524Z  " &
                                          "C45621Z  " & "C46012Z";
          BEGIN
               FEATURE (TESTED) := (6, ((LINE1'LENGTH, LINE1),
                                        (LINE2'LENGTH, LINE2),
                                        (LINE3'LENGTH, LINE3),
                                        (LINE4'LENGTH, LINE4),
                                        (LINE5'LENGTH, LINE5),
                                        (LINE6'LENGTH, LINE6)));
          END;

     ELSIF SYSTEM.MAX_DIGITS > 35 THEN

          DECLARE
               LINE5 : CONSTANT STRING := "          THIS INDICATES " &
                                          "THAT THE FOLLOWING TEST " &
                                          "IS INAPPLICABLE:";
               LINE6 : CONSTANT STRING := "               C4A011A";
          BEGIN
               FEATURE (TESTED) := (6, ((LINE1'LENGTH, LINE1),
                                        (LINE2'LENGTH, LINE2),
                                        (LINE3'LENGTH, LINE3),
                                        (LINE4'LENGTH, LINE4),
                                        (LINE5'LENGTH, LINE5),
                                        (LINE6'LENGTH, LINE6)));
          END;

     ELSE
          FEATURE (TESTED) := (4, ((LINE1'LENGTH, LINE1),
                                   (LINE2'LENGTH, LINE2),
                                   (LINE3'LENGTH, LINE3),
                                   (LINE4'LENGTH, LINE4)));
     END IF;

END AVAT020;
