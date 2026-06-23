-- CD1D03A.ADA

-- OBJECTIVE:
--     CHECK THAT THE PRAGMA 'PACK' IS IGNORED AFTER A FORCING
--     OCCURENCE.

-- HISTORY:
--     VCL  09/15/87  CREATED ORIGINAL TEST.
--     PWB  03/27/89  ADDED CHECK OF OBJECT SIZE.

WITH REPORT; USE REPORT;
PROCEDURE CD1D03A IS
BEGIN
     TEST ("CD1D03A", "THE PRAGMA 'PACK' IS IGNORED AFTER A " &
                      "FORCING OCCURENCE");

     DECLARE
          TYPE T1 IS
               RECORD
                    B1, B2 : BOOLEAN;
                    I1     : INTEGER RANGE 0 .. 15;
                    B3     : BOOLEAN;
               END RECORD;

          TYPE T2 IS
               RECORD
                    B1, B2 : BOOLEAN;
                    I1     : INTEGER RANGE 0 .. 15;
                    B3     : BOOLEAN;
               END RECORD;

          REC1 : T1;
          REC2 : T2 := (I1 => IDENT_INT (1),
                        OTHERS => IDENT_BOOL(TRUE) );

          PRAGMA PACK (T1);
     BEGIN

          IF T1'SIZE /= T2'SIZE THEN
               FAILED ("T1'SIZE DOES NOT MATCH T2'SIZE");
          END IF;

          IF REC2'SIZE < T2'SIZE THEN
               FAILED ("OBJECT SIZE IS LESS THAN TYPE SIZE.  A COMPONENT " &
                       "VALUE IS" & INTEGER'IMAGE (REC2.I1));
          END IF;

     END;

     RESULT;
END CD1D03A;
