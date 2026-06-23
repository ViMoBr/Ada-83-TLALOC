-- CD1009G.ADA

-- OBJECTIVE:
--     CHECK THAT A 'SIZE' SPECIFICATION MAY BE GIVEN IN THE VISIBLE
--     OR PRIVATE PART OF A PACKAGE FOR A RECORD TYPE DECLARED IN
--     THE VISIBLE PART OF THE SAME PACKAGE.

-- HISTORY:
--     PWB 03/25/89  MODIFIED METHOD OF CHECKING OBJECT SIZE AGAINST
--                   TYPE SIZE; CHANGED EXTENSION FROM '.ADA' TO '.DEP'.
--     VCL  10/07/87  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CD1009G IS
BEGIN
     TEST ("CD1009G", "A 'SIZE' CLAUSE MAY BE GIVEN IN THE VISIBLE " &
                      "OR PRIVATE PART OF A PACKAGE FOR A " &
                      "RECORD TYPE DECLARED IN THE " &
                      "VISIBLE PART OF THE SAME PACKAGE");
     DECLARE
          PACKAGE PACK IS
               SPECIFIED_SIZE : CONSTANT := INTEGER'SIZE;

               TYPE CHECK_TYPE_1 IS
                    RECORD
                         I : INTEGER;
                    END RECORD;
               FOR CHECK_TYPE_1'SIZE
                              USE SPECIFIED_SIZE;
               X : CHECK_TYPE_1 := ( I => IDENT_INT (1) );

               TYPE CHECK_TYPE_2 IS
                    RECORD
                         I : INTEGER;
                    END RECORD;
          PRIVATE
               FOR CHECK_TYPE_2'SIZE USE SPECIFIED_SIZE;
          END PACK;

          USE PACK;

               Y : CHECK_TYPE_2 := ( I => IDENT_INT (5) );
     BEGIN
          IF CHECK_TYPE_1'SIZE /= SPECIFIED_SIZE THEN
               FAILED ("CHECK_TYPE_1'SIZE IS INCORRECT");
          END IF;

          IF X'SIZE < SPECIFIED_SIZE THEN
               FAILED ("OBJECT SIZE TOO SMALL -- CHECK_TYPE_1.  " &
                       "VALUE IS"  & INTEGER'IMAGE( IDENT_INT( X.I) ) );
          END IF;

          IF CHECK_TYPE_2'SIZE /= SPECIFIED_SIZE THEN
               FAILED ("CHECK_TYPE_2'SIZE IS INCORRECT");
          END IF;

          IF Y'SIZE < SPECIFIED_SIZE THEN
               FAILED ("OBJECT SIZE TOO SMALL -- CHECK_TYPE_2.  " &
                       "VALUE IS"  & INTEGER'IMAGE( IDENT_INT(Y.I) ) );
          END IF;
     END;

     RESULT;
END CD1009G;
