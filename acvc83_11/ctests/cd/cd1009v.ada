-- CD1009V.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENUMERATION REPRESENTATION CLAUSE MAY BE GIVEN IN
--     THE PRIVATE PART OF A PACKAGE FOR AN INCOMPLETE TYPE, WHOSE
--     FULL TYPE DECLARATION IS AN ENUMERATION TYPE DECLARED IN THE
--     VISIBLE PART OF THE SAME PACKAGE.

-- HISTORY:
--     VCL  10/21/87  CREATED ORIGINAL TEST.
--     DHH  03/29/89  CHANGE FROM 'A' TEST TO 'C' TEST AND FROM '.DEP'
--                    '.ADA'.  ADDED CHECK ON REPRESENTATION CLAUSES.

WITH REPORT; USE REPORT;
WITH ENUM_CHECK;                        -- CONTAINS A CALL TO 'FAILED'.
PROCEDURE CD1009V IS
BEGIN
     TEST ("CD1009V", "AN ENUMERATION REPRESENTATION CLAUSE MAY BE " &
                      "GIVEN IN THE PRIVATE PART OF A " &
                      "PACKAGE FOR AN INCOMPLETE TYPE, WHOSE FULL " &
                      "TYPE DECLARATION IS AN ENUMERATION TYPE, " &
                      "DECLARED IN THE VISIBLE PART OF THE SAME " &
                      "PACKAGE");
     DECLARE
          PACKAGE PACK IS
               TYPE CHECK_TYPE_1;
               TYPE ACC IS ACCESS CHECK_TYPE_1;

               TYPE CHECK_TYPE_1 IS (A0, A2, A4, A8);
          PRIVATE

               FOR CHECK_TYPE_1 USE (A0 => 9,
                                     A2 => 13,
                                     A4 => 15,
                                     A8 => 18);
               TYPE INT1 IS RANGE 9 .. 18;
               FOR INT1'SIZE USE CHECK_TYPE_1'SIZE;

               PROCEDURE CHECK_1 IS NEW ENUM_CHECK(CHECK_TYPE_1, INT1);

          END PACK;

          PACKAGE BODY PACK IS
          BEGIN
               CHECK_1 (A2, 13, "CHECK_TYPE_1");
          END PACK;

          USE PACK;
     BEGIN
          NULL;
     END;

     RESULT;
END CD1009V;
