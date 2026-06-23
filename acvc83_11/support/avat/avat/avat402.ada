-- AVAT402.ADA

-- OBJECTIVE:
--     LIST THE VALUES OF THE TYPE SYSTEM.NAME.

-- HISTORY:
--     PWB 08/20/87  CREATED ORIGINAL TEST.
--     JET 01/18/88  FIXED SECOND NAME_COUNT CONDITIONAL.

WITH DATA_COLLECTION; USE DATA_COLLECTION;
WITH SYSTEM; USE SYSTEM;

PROCEDURE AVAT402 IS
     TESTED : THINGS_TO_SUPPORT := NAME_VALUES;
     NAME_COUNT : CONSTANT NATURAL := 1 + NAME'POS (NAME'LAST);
     NAME_VALUE : NAME;
     SYS_LABEL : CONSTANT STRING := "   -- SYSTEM_NAME";
     LEN : NATURAL;
     LINE1 : CONSTANT STRING := "     TYPE SYSTEM.NAME HAS" &
                                INTEGER'IMAGE(NAME_COUNT) & " VALUES.";
     LINE2,
     LINE3,
     LINE4,
     LINE5,
     LINE6,
     LINE7 : STRING (1..72) := (1..72 => ' ');

     LINE2_LEN,
     LINE3_LEN,
     LINE4_LEN,
     LINE5_LEN,
     LINE6_LEN,
     LINE7_LEN : NATURAL := 0;

BEGIN
     NAME_VALUE := NAME'FIRST;
     LEN := NAME'IMAGE(NAME_VALUE)'LENGTH;
     LINE2_LEN := LEN + 10;
     LINE2 (11 .. LINE2_LEN) := NAME'IMAGE(NAME_VALUE);
     IF NAME_VALUE = SYSTEM_NAME THEN
          LINE2_LEN := LINE2_LEN + SYS_LABEL'LENGTH;
          LINE2 (LEN + 11 .. LINE2_LEN) := SYS_LABEL;
     END IF;

     IF NAME_COUNT = 1 THEN
          FEATURE (TESTED) := (2, ((LINE1'LENGTH, LINE1),
                                   (LINE2_LEN, LINE2(1..LINE2_LEN))));
     END IF;

     IF NAME_COUNT = 2 THEN
          NAME_VALUE := NAME'SUCC (NAME_VALUE);
          LEN := NAME'IMAGE(NAME_VALUE)'LENGTH;
          LINE3_LEN := LEN + 10;
          LINE3 (11 .. LINE3_LEN) := NAME'IMAGE(NAME_VALUE);
          IF NAME_VALUE = SYSTEM_NAME THEN
               LINE3_LEN := LINE3_LEN + SYS_LABEL'LENGTH;
               LINE3 (LEN + 11 .. LINE3_LEN) := SYS_LABEL;
          END IF;
          FEATURE (TESTED) := (3, ((LINE1'LENGTH, LINE1),
                                   (LINE2_LEN, LINE2(1..LINE2_LEN)),
                                   (LINE3_LEN, LINE3(1..LINE3_LEN))));
     END IF;

     IF NAME_COUNT = 3 THEN
          NAME_VALUE := NAME'SUCC (NAME_VALUE);
          LEN := NAME'IMAGE(NAME_VALUE)'LENGTH;
          LINE4_LEN := LEN + 10;
          LINE4 (11 .. LINE4_LEN) := NAME'IMAGE(NAME_VALUE);
          IF NAME_VALUE = SYSTEM_NAME THEN
               LINE4_LEN := LINE4_LEN + SYS_LABEL'LENGTH;
               LINE4 (LEN + 11 .. LINE4_LEN) := SYS_LABEL;
          END IF;
          FEATURE (TESTED) := (4, ((LINE1'LENGTH, LINE1),
                                   (LINE2_LEN, LINE2(1..LINE2_LEN)),
                                   (LINE3_LEN, LINE3(1..LINE3_LEN)),
                                   (LINE4_LEN, LINE4(1..LINE4_LEN))));
     END IF;

     IF NAME_COUNT = 4 THEN
          NAME_VALUE := NAME'SUCC (NAME_VALUE);
          LEN := NAME'IMAGE(NAME_VALUE)'LENGTH;
          LINE5_LEN := LEN + 10;
          LINE5 (11 .. LINE5_LEN) := NAME'IMAGE(NAME_VALUE);
          IF NAME_VALUE = SYSTEM_NAME THEN
               LINE5_LEN := LINE5_LEN + SYS_LABEL'LENGTH;
               LINE5 (LEN + 11 .. LINE5_LEN) := SYS_LABEL;
          END IF;
          FEATURE (TESTED) := (5, ((LINE1'LENGTH, LINE1),
                                   (LINE2_LEN, LINE2(1..LINE2_LEN)),
                                   (LINE3_LEN, LINE3(1..LINE3_LEN)),
                                   (LINE4_LEN, LINE4(1..LINE4_LEN)),
                                   (LINE5_LEN, LINE5(1..LINE5_LEN))));
     END IF;

     IF NAME_COUNT = 5 THEN
          NAME_VALUE := NAME'SUCC (NAME_VALUE);
          LEN := NAME'IMAGE(NAME_VALUE)'LENGTH;
          LINE6_LEN := LEN + 10;
          LINE6 (11 .. LINE6_LEN) := NAME'IMAGE(NAME_VALUE);
          IF NAME_VALUE = SYSTEM_NAME THEN
               LINE6_LEN := LINE6_LEN + SYS_LABEL'LENGTH;
               LINE6 (LEN + 11 .. LINE6_LEN) := SYS_LABEL;
          END IF;
          FEATURE (TESTED) := (6, ((LINE1'LENGTH, LINE1),
                                   (LINE2_LEN, LINE2(1..LINE2_LEN)),
                                   (LINE3_LEN, LINE3(1..LINE3_LEN)),
                                   (LINE4_LEN, LINE4(1..LINE4_LEN)),
                                   (LINE5_LEN, LINE5(1..LINE5_LEN)),
                                   (LINE6_LEN, LINE6(1..LINE6_LEN))));
     END IF;

     IF NAME_COUNT >= 6 THEN
          NAME_VALUE := NAME'SUCC (NAME_VALUE);
          LEN := NAME'IMAGE(NAME_VALUE)'LENGTH;
          LINE7_LEN := LEN + 10;
          LINE7 (11 .. LINE7_LEN) := NAME'IMAGE(NAME_VALUE);
          IF NAME_VALUE = SYSTEM_NAME THEN
               LINE7_LEN := LINE7_LEN + SYS_LABEL'LENGTH;
               LINE7 (LEN + 11 .. LINE7_LEN) := SYS_LABEL;
          END IF;
          FEATURE (TESTED) := (7, ((LINE1'LENGTH, LINE1),
                                   (LINE2_LEN, LINE2(1..LINE2_LEN)),
                                   (LINE3_LEN, LINE3(1..LINE3_LEN)),
                                   (LINE4_LEN, LINE4(1..LINE4_LEN)),
                                   (LINE5_LEN, LINE5(1..LINE5_LEN)),
                                   (LINE6_LEN, LINE6(1..LINE6_LEN)),
                                   (LINE7_LEN, LINE7(1..LINE7_LEN))));
     END IF;

END AVAT402;
