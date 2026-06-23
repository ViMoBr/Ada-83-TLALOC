-- BC1230A.ADA

-- CHECK THAT THE SCOPE OF THE IDENTIFIER OF A FORMAL TYPE STARTS
-- AT THE POINT WHERE THIS IDENTIFIER FIRST OCCURS IN THE GENERIC
-- PARAMETER DECLARATION.

-- KEI 3/4/82
-- RJK 1/24/84      ADDED TO ACVC
-- TBN 11/25/85     RENAMED FROM BC12ABA-B.ADA.  ADDED AN EXTERNAL
--                  TYPE DECLARATION WITH THE SAME IDENTIFIER.

PROCEDURE BC1230A IS

     TYPE INT IS (ONE, TWO, THREE);

     GENERIC

          INT_1 : INT := ONE;              -- OK.
          TYPE INT IS RANGE <>;            -- OK.
          INT_2 : INT := ONE;              -- ERROR:
          INT_3 : INT := 1;                -- OK.

          I : INTEGER := 10;               -- OK.

          TYPE ARG IS ARRAY (NATURAL RANGE <>) OF NUMBER;  -- ERROR:
          OBJ_ENUM : ENUM;                                 -- ERROR:
          N : NUMBER := 3;                                 -- ERROR:

          TYPE NUMBER IS RANGE <>;         -- OK.
          TYPE ENUM IS (<>);               -- OK.

          PARAM : ENUM;                    -- OK.

     PACKAGE PACK IS
     END PACK;

BEGIN
     NULL;
END BC1230A;
