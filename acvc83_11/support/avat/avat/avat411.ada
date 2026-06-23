-- AVAT411.ADA

-- TRAILER COMMENT FOR AVAT PART FIVE.

-- PWB 08/18/87  CREATED ORIGINAL FILE.

WITH DATA_COLLECTION; USE DATA_COLLECTION;

PROCEDURE AVAT411 IS
     TESTED : THINGS_TO_SUPPORT := TRAILER_PART_FIVE;
     LINE1 : CONSTANT STRING := "==================================" &
                                "============";
     LINE2 : CONSTANT STRING := "============  END OF AVAT REPORT  " &
                                "============";
BEGIN
     FEATURE (TESTED) := (3, (1 => (LINE1'LENGTH, LINE1),
                              2 => (LINE2'LENGTH, LINE2),
                              3 => (LINE1'LENGTH, LINE1)));
END AVAT411;
