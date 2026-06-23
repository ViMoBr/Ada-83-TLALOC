-- AVAT030.ADA

-- OBJECTIVE:
--     OUTPUT LIST OF MAX_MANTISSA INAPPLICABLE TESTS.

-- HISTORY:
--     DHH 07/31/89  CREATED ORIGINAL TEST FILE.

WITH DATA_COLLECTION, SYSTEM;
USE DATA_COLLECTION;

PROCEDURE AVAT030 IS

     TYPE FIXED IS DELTA 2.0 ** (- SYSTEM.MAX_MANTISSA)
                   RANGE -1.0 .. 1.0;
     TESTED : THINGS_TO_SUPPORT := CHECK_MAX_MANTISSA1;
     LINE1 : CONSTANT STRING := "     VALUE OF " &
                                "SYSTEM.MAX_MANTISSA IS " &
                                INTEGER'IMAGE (SYSTEM.MAX_MANTISSA);
     LINE2 : CONSTANT STRING := "          THIS INDICATES THAT THE " &
                                "FOLLOWING TESTS ARE INAPPLICABLE:";

BEGIN
     IF SYSTEM.MAX_MANTISSA < 11 THEN
          DECLARE
               LINE3 : CONSTANT STRING := "               " &
                                          "C45531A..P  C45532A..P";
          BEGIN
               FEATURE (TESTED) := (3, ((LINE1'LENGTH, LINE1),
                                       (LINE2'LENGTH, LINE2),
                                       (LINE3'LENGTH, LINE3)));
          END;
     ELSIF SYSTEM.MAX_MANTISSA < 15 THEN
          DECLARE
               LINE3 : CONSTANT STRING := "               " &
                                          "C45531E..P  C45532E..P";
          BEGIN
               FEATURE (TESTED) := (3, ((LINE1'LENGTH, LINE1),
                                       (LINE2'LENGTH, LINE2),
                                       (LINE3'LENGTH, LINE3)));
          END;
     ELSIF SYSTEM.MAX_MANTISSA < 31 THEN
          DECLARE
               LINE3 : CONSTANT STRING := "               " &
                                          "C45531K..P  C45532K..P";
          BEGIN
               FEATURE (TESTED) := (3, ((LINE1'LENGTH, LINE1),
                                       (LINE2'LENGTH, LINE2),
                                       (LINE3'LENGTH, LINE3)));
          END;
     ELSIF SYSTEM.MAX_MANTISSA < 47 THEN
          DECLARE
               LINE3 : CONSTANT STRING := "               " &
                                          "C45531M..P  C45532M..P";
          BEGIN
               FEATURE (TESTED) := (3, ((LINE1'LENGTH, LINE1),
                                       (LINE2'LENGTH, LINE2),
                                       (LINE3'LENGTH, LINE3)));
          END;
     ELSE
          NULL;
     END IF;
END AVAT030;
