-- CD1009M.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENUMERATION REPRESENTATION CLAUSE MAY BE GIVEN IN
--     THE VISIBLE OR PRIVATE PART OF A PACKAGE FOR AN ENUMERATION
--     TYPE DECLARED IN THE VISIBLE PART OF THE SAME PACKAGE.

-- HISTORY:
--     VCL  10/08/87  CREATED ORIGINAL TEST.
--     DHH  03/29/89  CHANGE FROM 'A' TEST TO 'C' TEST AND FROM '.DEP'
--                    '.ADA'.  ADDED CHECK ON REPRESENTATION CLAUSES.

WITH REPORT; USE REPORT;
WITH ENUM_CHECK;                       -- CONTAINS A CALL TO 'FAILED'.
PROCEDURE CD1009M IS
BEGIN
     TEST ("CD1009M", "AN ENUMERATION REPRESENTATION CLAUSE MAY BE " &
                      "GIVEN IN THE VISIBLE OR PRIVATE PART OF A " &
                      "PACKAGE FOR AN ENUMERATION TYPE DECLARED IN " &
                      "THE VISIBLE PART OF THE SAME PACKAGE");
     DECLARE
          PACKAGE PACK IS
               TYPE CHECK_TYPE_1 IS (A0, A2, A4, A8);
               FOR CHECK_TYPE_1 USE (A0 => 0,
                                     A2 => 1,
                                     A4 => 2,
                                     A8 => 3);

               TYPE CHECK_TYPE_2 IS (A0, A2, A4, A8);
               TYPE INT1 IS RANGE 0 .. 3;
               FOR INT1'SIZE USE CHECK_TYPE_1'SIZE;

               TYPE INT2 IS RANGE 2 .. 8;

          PRIVATE
               FOR CHECK_TYPE_2 USE (A0 => 2,
                                     A2 => 4,
                                     A4 => 6,
                                     A8 => 8);
               FOR INT2'SIZE USE CHECK_TYPE_2'SIZE;

               PROCEDURE CHECK_1 IS NEW ENUM_CHECK(CHECK_TYPE_1, INT1);
               PROCEDURE CHECK_2 IS NEW ENUM_CHECK(CHECK_TYPE_2, INT2);

          END PACK;

          PACKAGE BODY PACK IS
          BEGIN
               CHECK_1 (A4, 2, "CHECK_TYPE_1");
               CHECK_2 (A8, 8, "CHECK_TYPE_2");
          END PACK;

          USE PACK;
     BEGIN
          NULL;
     END;

     RESULT;
END CD1009M;
