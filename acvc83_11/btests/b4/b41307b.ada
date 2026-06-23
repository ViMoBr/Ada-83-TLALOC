-- B41307B.ADA

-- OBJECTIVE:
--     CHECK THAT IF L IS A PACKAGE DECLARED BY A RENAMING DECLARATION
--     AND D IS THE PACKAGE DENOTED BY L:
--          B) L.R IS ILLEGAL IF R IS DECLARED IMMEDIATELY WITHIN THE
--             PRIVATE PART OR BODY OF D.

-- HISTORY:
--     TBN 12/17/86  CREATED ORIGINAL TEST.

PROCEDURE B41307B IS

BEGIN
     DECLARE
          PACKAGE D IS
          PRIVATE
               R : INTEGER := 0;
          END D;

          PACKAGE L RENAMES D;

          INT : INTEGER := L.R;                                -- ERROR:

          PACKAGE BODY D IS
               A : INTEGER := 0;
               B : INTEGER := L.A;                             -- ERROR:
               C : INTEGER := L.R;                             -- ERROR:
          BEGIN
               A := L.R;                                       -- ERROR:
          END D;
     BEGIN
          NULL;
     END;

     DECLARE
          PACKAGE D IS
               PACKAGE L RENAMES D;
          PRIVATE
               R : INTEGER := 1;
               A : INTEGER := L.R;                             -- ERROR:
          END D;

          INT : INTEGER := D.L.R;                              -- ERROR:

          PACKAGE BODY D IS
               B : INTEGER := 2;
               G : INTEGER := L.R;                             -- ERROR:
               H : INTEGER := L.B;                             -- ERROR:
          BEGIN
               B := L.R;                                       -- ERROR:
          END D;
     BEGIN
          NULL;
     END;

END B41307B;
