-- CD1D02A.ADA

-- OBJECTIVE:
--     CHECK THAT A PRAGMA PACK IS IGNORED WHEN ITS ARGUMENT IS AN
--     EXPANDED NAME.

-- HISTORY:
--     RJW 08/12/87 CREATED ORIGINAL TEST.
--     PWB 03/27/89 ADDED CHECK OF OBJECT SIZE.

WITH REPORT; USE REPORT;
PROCEDURE CD1D02A IS

BEGIN

     TEST("CD1D02A", "CHECK THAT A PRAGMA PACK IS IGNORED WHEN " &
                     "ITS ARGUMENT IS AN EXPANDED NAME");

     BLOCK:
     DECLARE
          TYPE T IS RECORD
               B1, B2 : BOOLEAN;
               I1     : INTEGER RANGE 0 .. 15;
               B3     : BOOLEAN;
          END RECORD;

          TYPE PACKED IS RECORD
               B1, B2 : BOOLEAN;
               I1     : INTEGER RANGE 0 .. 15;
               B3     : BOOLEAN;
          END RECORD;

          PRAGMA PACK (BLOCK.PACKED);

          P : PACKED := ( B1 | B2 | B3 => IDENT_BOOL (FALSE),
                          I1 => IDENT_INT(1) );
     BEGIN
          IF T'SIZE /= PACKED'SIZE THEN
               FAILED ("PRAGMA PACK IS NOT IGNORED WHEN THE " &
                       "ARGUMENT IS AN EXPANDED NAME");
          END IF;

          IF P'SIZE < PACKED'SIZE THEN
               FAILED ("OBJECT SIZE LESS THAN TYPE SIZE.  COMPONENT " &
                       "VALUE IS" & INTEGER'IMAGE (P.I1) );
          END IF;

     END BLOCK;

     RESULT;

END CD1D02A;
