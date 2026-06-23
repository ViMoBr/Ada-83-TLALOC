-- CD3014F.ADA

-- OBJECTIVE:
--     CHECK THAT AN ENUMERATION REPRESENTATION CLAUSE CAN BE GIVEN
--     IN THE VISIBLE OR PRIVATE PART OF A GENERIC PACKAGE FOR A
--     TYPE DECLARED IN THE VISIBLE PART.

-- HISTORY
--     DHH 09/30/87 CREATED ORIGINAL TEST
--     DHH 03/29/89  CHANGE FROM 'A' TEST TO 'C' TEST AND FROM '.DEP'
--                   '.ADA'.  ADDED CHECK ON REPRESENTATION CLAUSES.

WITH REPORT; USE REPORT;
WITH ENUM_CHECK;                      -- CONTAINS A CALL TO 'FAILED'.
PROCEDURE CD3014F IS

BEGIN

     TEST ("CD3014F", "CHECK THAT AN ENUMERATION REPRESENTATION " &
                      "CLAUSE CAN BE GIVEN IN THE VISIBLE " &
                      "OR PRIVATE PART OF A GENERIC PACKAGE FOR " &
                      "A TYPE DECLARED IN THE VISIBLE PART");

     DECLARE

          GENERIC
          PACKAGE GENPACK IS

               TYPE HUE IS (RED,BLUE,YELLOW,'R','B','Y');
               TYPE NEWHUE IS (RED,BLUE,YELLOW,'R','B','Y');

               FOR HUE USE (RED => 8, BLUE => 9, YELLOW => 10,
                   'R' => 11, 'B' => 12, 'Y' => 13); -- N/A => ERROR.
               A : HUE := BLUE;

               TYPE INT1 IS RANGE 8 .. 13;
               FOR INT1'SIZE USE HUE'SIZE;

          PRIVATE

               FOR NEWHUE USE (RED => 2, BLUE => 4, YELLOW => 6,
                   'R' => 8, 'B' => 10, 'Y' => 12);

               B : NEWHUE := RED;
               TYPE INT2 IS RANGE 2 .. 12;
               FOR INT2'SIZE USE NEWHUE'SIZE;

               PROCEDURE CHECK_1 IS NEW ENUM_CHECK(HUE, INT1);
               PROCEDURE CHECK_2 IS NEW ENUM_CHECK(NEWHUE, INT2);
          END GENPACK;

          PACKAGE BODY GENPACK IS
          BEGIN
               CHECK_1 ('B', 12, "HUE");
               CHECK_2 ('B', 10, "NEWHUE");
          END GENPACK;

          PACKAGE P IS NEW GENPACK;

     BEGIN
          NULL;
     END;

     RESULT;
END CD3014F;
