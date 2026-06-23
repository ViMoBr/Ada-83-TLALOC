-- BD2D03A.ADA

-- OBJECTIVE:
--     CHECK THAT A 'SMALL SPECIFICATION CANNOT BE GIVEN IN A PACKAGE
--     SPECIFICATION FOR A TYPE DECLARED IN AN INNER PACKAGE
--     SPECIFICATION; IN A PACKAGE OR TASK SPECIFICATION FOR A TYPE
--     DECLARED IN AN ENCLOSING PACKAGE SPECIFICATION OR DECLARATIVE
--     PART; IN A PACKAGE BODY FOR A TYPE DECLARED IN THE CORRESPONDING
--     SPECIFICATION; OR AFTER THE OCCURRENCE OF A BODY IN A DECLARATIVE
--     PART.

-- HISTORY:
--     BCB 04/05/88  CREATED ORIGINAL TEST.

PROCEDURE BD2D03A IS

     CHECK_SMALL : CONSTANT := 0.25;

     PACKAGE P IS
          TYPE PFIX IS DELTA 2.0**(-1) RANGE -1.0 .. 1.0;
          TYPE PTFIX IS DELTA 2.0**(-1) RANGE -1.0 .. 1.0;
          TYPE PSFIX IS DELTA 2.0**(-1) RANGE -1.0 .. 1.0;

          PACKAGE Q IS
               TYPE QFIX IS DELTA 2.0**(-1) RANGE -1.0 .. 1.0;

               FOR PFIX'SMALL USE CHECK_SMALL;  -- ERROR: TYPE DECLARED
                                                -- IN ENCLOSING PACKAGE.
          END Q;
          USE Q;

          TASK T IS
               FOR PTFIX'SMALL USE CHECK_SMALL; -- ERROR: TYPE DECLARED
                                                -- IN ENCLOSING PACKAGE.
          END T;

          FOR QFIX'SMALL USE CHECK_SMALL;       -- ERROR: TYPE DECLARED
                                                -- IN INNER PACKAGE.
     END P;

     PACKAGE BODY P IS
          FOR PSFIX'SMALL USE CHECK_SMALL;    -- ERROR: TYPE DECLARED IN
                                              -- PACKAGE SPECIFICATION.

          TASK BODY T IS
          BEGIN
               NULL;
          END T;

     BEGIN
          NULL;
     END P;

BEGIN
     DECLARE
          TYPE DFIX IS DELTA 2.0**(-1) RANGE -1.0 .. 1.0;
          TYPE DTFIX IS DELTA 2.0**(-1) RANGE -1.0 .. 1.0;
          TYPE DBFIX IS DELTA 2.0**(-1) RANGE -1.0 .. 1.0;

          PACKAGE D IS
               FOR DFIX'SMALL USE CHECK_SMALL; -- ERROR: TYPE DECLARED
                                               -- IN ENCLOSING
                                               -- DECLARATIVE PART.
          END D;

          TASK DT IS
               FOR DTFIX'SMALL USE CHECK_SMALL; -- ERROR: TYPE DECLARED
                                                -- IN ENCLOSING
                                                -- DECLARATIVE PART.
          END DT;

          TASK BODY DT IS
          BEGIN
               NULL;
          END DT;

          FOR DBFIX'SMALL USE CHECK_SMALL;  -- ERROR: CLAUSE GIVEN AFTER
                                            -- BODY IN DECLARATIVE PART.
     BEGIN
          NULL;
     END;

END BD2D03A;
