-- AVAT017.ADA

-- CHECK WHETHER SYSTEM.MAX_MANTISSA IS AS SPECIFIED.
-- IF SO, THIS UNIT WILL BE REPLACED.

-- PWB 08/11/87  CREATED ORIGINAL TEST FILE.

WITH DATA_COLLECTION, SYSTEM;
USE DATA_COLLECTION;

PROCEDURE AVAT017 IS

     TYPE FIXED IS DELTA 0.25 RANGE -1.0 .. 0.75;
     TESTED : THINGS_TO_SUPPORT := CHECK_MAX_MANTISSA;
     LINE1 : CONSTANT STRING := "     SYSTEM.MAX_MANTISSA DOES NOT " &
                                " HAVE SPECIFIED BEHAVIOR";
     LINE2 : CONSTANT STRING := "          VALUE OF " &
                                "SYSTEM.MAX_MANTISSA IS " &
                                INTEGER'IMAGE (SYSTEM.MAX_MANTISSA);
     LINE3 : CONSTANT STRING := "          TYPE DECLARATION REJECTED " &
                                "WITH DELTA ";
     LINE4 : CONSTANT STRING := "          2.0 ** (" &
                                INTEGER'IMAGE (-SYSTEM.MAX_MANTISSA+1) &
                                ") AND RANGE -1.0 .. 1.0";
BEGIN
     FEATURE (TESTED) := (4, ((LINE1'LENGTH, LINE1),
                              (LINE2'LENGTH, LINE2),
                              (LINE3'LENGTH, LINE3),
                              (LINE4'LENGTH, LINE4)));
END AVAT017;
