-- AVAT004.ADA

-- CHECK WHETHER LONG_INTEGER IS SUPPORTED
-- IF SO, THIS UNIT WILL BE REPLACED

-- PWB 01/15/87  CREATED ORIGINAL TEST.
-- TBN 03/23/87  CHANGED FORMAT.

WITH DATA_COLLECTION; USE DATA_COLLECTION;

PROCEDURE AVAT004 IS
     X : INTEGER;
     TESTED : THINGS_TO_SUPPORT := LONG_INT;
     LINE1 : CONSTANT STRING := "     LONG_INTEGER IS NOT SUPPORTED";
     LINE2 : CONSTANT STRING := "          THIS INDICATES THAT THE " &
                                "FOLLOWING TESTS ARE INAPPLICABLE:";
     LINE3 : CONSTANT STRING := "               B52004D  B55B09C  " &
                                "B86001W  C35404C  C45231C";
     LINE4 : CONSTANT STRING := "               C45304C  C45411C  " &
                                "C45412C  C45502C  C45503C";
     LINE5 : CONSTANT STRING := "               C45504C  C45504F  " &
                                "C45611C  C45612C  C45613C";
     LINE6 : CONSTANT STRING := "               C45614C  C45631C  " &
                                "C45632C  C55B07A  C86006C";
     LINE7 : CONSTANT STRING := "               CD7101F";
BEGIN
     FEATURE(TESTED) := (7, ((LINE1'LENGTH, LINE1),
                             (LINE2'LENGTH, LINE2),
                             (LINE3'LENGTH, LINE3),
                             (LINE4'LENGTH, LINE4),
                             (LINE5'LENGTH, LINE5),
                             (LINE6'LENGTH, LINE6),
                             (LINE7'LENGTH, LINE7)));
END AVAT004;
