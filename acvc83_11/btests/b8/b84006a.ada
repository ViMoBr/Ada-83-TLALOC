-- B84006A.ADA

-- CHECK THAT IF TWO RENAMING DECLARATIONS (IN DIFFERENT PACKAGES)
-- DECLARE THE SAME IDENTIFIER AND BOTH DECLARATIONS RENAME THE
-- SAME ENTITY, A USE CLAUSE CANNOT MAKE THE IDENTIFIER VISIBLE,
-- UNLESS IT IS A SUBROGRAM.

-- EG  02/15/84

PROCEDURE B84006A IS

BEGIN

     -- RENAMING OF OBJECTS.

     DECLARE

          C1 : INTEGER := 0;

          PACKAGE P1 IS
               U1 : INTEGER RENAMES C1;
          END P1;
          PACKAGE P2 IS
               U1 : INTEGER RENAMES C1;
          END P2;

          USE P1, P2;

     BEGIN

          C1 := U1 + 1;                                -- ERROR:

     END;

     -- RENAMING OF EXCEPTIONS.

     DECLARE

          PACKAGE P1 IS
               C_ER : EXCEPTION RENAMES CONSTRAINT_ERROR;
          END P1;
          PACKAGE P2 IS
               C_ER : EXCEPTION RENAMES CONSTRAINT_ERROR;
          END P2;

          USE P1, P2;

     BEGIN

          RAISE C_ER;                                  -- ERROR:

     EXCEPTION

          WHEN C_ER =>                                 -- ERROR:
               NULL;

     END;

     -- RENAMING OF PACKAGES.

     DECLARE

          PACKAGE P1 IS
               I : INTEGER;
          END P1;
          PACKAGE P2 IS
               PACKAGE P4 RENAMES P1;
          END P2;
          PACKAGE P3 IS
               PACKAGE P4 RENAMES P1;
          END P3;

          USE P2, P3;

     BEGIN

          P4.I := 1;                                   -- ERROR:

     END;

     -- RENAMING OF SUBPROGRAMS.

     DECLARE

          PROCEDURE PROC1;

          PACKAGE P1 IS
               PROCEDURE PROC2 RENAMES PROC1;
          END P1;
          PACKAGE P2 IS
               PROCEDURE PROC2 RENAMES PROC1;
          END P2;

          PROCEDURE PROC1 IS
          BEGIN
               NULL;
          END PROC1;

          USE P1, P2;

     BEGIN

          PROC2;             -- ERROR: AMBIGUITY - TWO VISIBLE PROC2.

     END;

END B84006A;
