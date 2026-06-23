-- AVAT031.ADA

-- OBJECTIVE:
--     OUTPUT LIST OF FINE_DELTA INAPPLICABLE TESTS.

-- HISTORY:
--     DHH 07/31/89  CREATED ORIGINAL TEST FILE.

WITH DATA_COLLECTION, SYSTEM;
USE DATA_COLLECTION;

PROCEDURE AVAT031 IS

     TYPE FIXED IS DELTA SYSTEM.FINE_DELTA RANGE -1.0 .. 1.0;
     TESTED : THINGS_TO_SUPPORT := CHECK_FINE_DELTA1;
     LINE1 : CONSTANT STRING := "          THIS INDICATES THAT THE " &
                                "FOLLOWING TESTS ARE INAPPLICABLE:";

BEGIN
     IF SYSTEM.FINE_DELTA > 2.0 ** (-11) THEN
          DECLARE
               LINE2 : CONSTANT STRING := "               " &
                                          "C45531A..P  C45532A..P";
          BEGIN
               FEATURE (TESTED) := (2, ((LINE1'LENGTH, LINE1),
                                        (LINE2'LENGTH, LINE2)));
          END;
     ELSIF SYSTEM.FINE_DELTA > 2.0 ** (-15) THEN
          DECLARE
               LINE2 : CONSTANT STRING := "               " &
                                          "C45531E..P  C45532E..P";
          BEGIN
               FEATURE (TESTED) := (2, ((LINE1'LENGTH, LINE1),
                                        (LINE2'LENGTH, LINE2)));
          END;
     ELSIF SYSTEM.FINE_DELTA > 2.0 ** (-31) THEN
          DECLARE
               LINE2 : CONSTANT STRING := "               " &
                                          "C45531K..P  C45532K..P";
          BEGIN
               FEATURE (TESTED) := (2, ((LINE1'LENGTH, LINE1),
                                        (LINE2'LENGTH, LINE2)));
          END;
     ELSIF SYSTEM.FINE_DELTA > 2.0 ** (-47) THEN
          DECLARE
               LINE2 : CONSTANT STRING := "               " &
                                          "C45531M..P  C45532M..P";
          BEGIN
               FEATURE (TESTED) := (2, ((LINE1'LENGTH, LINE1),
                                        (LINE2'LENGTH, LINE2)));
          END;
     ELSE
          NULL;
     END IF;
END AVAT031;
