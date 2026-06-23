-- AVAT002.ADA

-- CHECK WHETHER SHORT_INTEGER IS SUPPORTED.
-- IF SO, THIS UNIT WILL BE REPLACED.

-- PWB 01/15/87  CREATED ORIGINAL TEST.
-- TBN 03/20/87  CHANGED FORMAT.

WITH DATA_COLLECTION; USE DATA_COLLECTION;

PROCEDURE AVAT002 IS
     X : INTEGER;
     TESTED : THINGS_TO_SUPPORT := SHORT_INT;
     LINE1 : CONSTANT STRING := "     SHORT_INTEGER IS NOT SUPPORTED.";
     LINE2 : CONSTANT STRING := "          THIS INDICATES THAT THE " &
                                "FOLLOWING TESTS ARE INAPPLICABLE:";
     LINE3 : CONSTANT STRING := "               B36105C  B52004E  " &
                                "B55B09D  B86001V  C35404B";
     LINE4 : CONSTANT STRING := "               C45231B  C45304B  " &
                                "C45411B  C45412B  C45502B";
     LINE5 : CONSTANT STRING := "               C45503B  C45504B  " &
                                "C45504E  C45611B  C45612B";
     LINE6 : CONSTANT STRING := "               C45613B  C45614B  " &
                                "C45631B  C45632B  C55B07B";
     LINE7 : CONSTANT STRING := "               C86006D  CD7101E";
BEGIN
     FEATURE (TESTED) := (7, ((LINE1'LENGTH, LINE1),
                              (LINE2'LENGTH, LINE2),
                              (LINE3'LENGTH, LINE3),
                              (LINE4'LENGTH, LINE4),
                              (LINE5'LENGTH, LINE5),
                              (LINE6'LENGTH, LINE6),
                              (LINE7'LENGTH, LINE7)));
END AVAT002;
