-- C35502G.ADA

-- CHECK THAT 'PRED' AND 'SUCC' YIELD THE CORRECT RESULTS WHEN 
-- THE PREFIX IS AN ENUMERATION TYPE OTHER THAN A BOOLEAN OR A 
-- CHARACTER TYPE.

-- RJW 5/27/86

WITH REPORT; USE REPORT;

PROCEDURE C35502G IS

          TYPE ENUM IS (A, BC, ABC, A_B_C, ABCD);
          SUBTYPE SUBENUM IS ENUM RANGE A .. BC;

          TYPE NEWENUM IS NEW ENUM;
          SUBTYPE SUBNEW IS NEWENUM RANGE A .. BC;

BEGIN
     TEST ("C35502G", "CHECK THAT 'PRED' AND 'SUCC' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS AN " &
                      "ENUMERATION TYPE OTHER THAN A CHARACTER " &
                      "OR A BOOLEAN TYPE" );

     BEGIN
          FOR I IN ENUM'VAL (1) .. ENUM'VAL (4) LOOP
               IF SUBENUM'PRED (I) /= 
                  ENUM'VAL (ENUM'POS (I) - 1) THEN
                    FAILED ("INCORRECT SUBENUM'PRED(" &
                             ENUM'IMAGE (I) & ")" );
               END IF;
          END LOOP;

          FOR I IN ENUM'VAL (0) .. ENUM'VAL (3) LOOP
               IF SUBENUM'SUCC (I) /= 
                  ENUM'VAL (ENUM'POS (I) + 1) THEN
                    FAILED ("INCORRECT SUBENUM'SUCC(" &
                             ENUM'IMAGE (I) & ")" );
               END IF;
          END LOOP;
     END;

     BEGIN
          FOR I IN NEWENUM'VAL (1) .. NEWENUM'VAL (4) LOOP
               IF SUBNEW'PRED (I) /= 
                  NEWENUM'VAL (NEWENUM'POS (I) - 1) THEN
                    FAILED ("INCORRECT SUBNEW'PRED(" &
                             NEWENUM'IMAGE (I) & ")" );
               END IF;
          END LOOP;

          FOR I IN NEWENUM'VAL (0) .. NEWENUM'VAL (3) LOOP
               IF SUBNEW'SUCC (I) /= 
                  NEWENUM'VAL (NEWENUM'POS (I) + 1) THEN
                    FAILED ("INCORRECT SUBNEW'SUCC(" &
                             NEWENUM'IMAGE (I) & ")" );
               END IF;
          END LOOP;
     END;

     RESULT;
END C35502G;
