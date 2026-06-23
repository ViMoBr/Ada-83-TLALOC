-- B85012A.ADA

-- CHECK THAT:

--   A) A RENAMING IS ILLEGAL IF THE PARAMETER MODES ARE NOT THE SAME.

--   B) THE MODES ARE NOT USED TO HELP RESOLVE WHICH SUBPROGRAM OR
--      ENTRY IS BEING RENAMED.

-- EG  02/17/84

PROCEDURE B85012A IS

BEGIN

     DECLARE

          PROCEDURE P1 (A : IN OUT INTEGER);
          PROCEDURE P1A (B : IN OUT INTEGER) RENAMES P1; -- OK.
          PROCEDURE P1B (C : IN INTEGER) RENAMES P1;     -- ERROR: A.
          PROCEDURE P1C (D : OUT INTEGER) RENAMES P1;    -- ERROR: A.

          PROCEDURE P2 (A : IN INTEGER);
          PROCEDURE P2A (B : IN OUT INTEGER) RENAMES P2; -- ERROR: A.
          PROCEDURE P2B (C : IN INTEGER) RENAMES P2;     -- OK.
          PROCEDURE P2C (D : OUT INTEGER) RENAMES P2;    -- ERROR: A.

          PROCEDURE P3 (A :  OUT INTEGER);
          PROCEDURE P3A (B : IN OUT INTEGER) RENAMES P3; -- ERROR: A.
          PROCEDURE P3B (C : IN INTEGER) RENAMES P3;     -- ERROR: A.
          PROCEDURE P3C (D : OUT INTEGER) RENAMES P3;    -- OK.

          PROCEDURE P1 (A : IN OUT INTEGER) IS
          BEGIN
               NULL;
          END P1;

          PROCEDURE P2 (A : IN INTEGER) IS
          BEGIN
               NULL;
          END P2;

          PROCEDURE P3 (A :  OUT INTEGER) IS
          BEGIN
               NULL;
          END P3;

     BEGIN

          NULL;

     END;

     DECLARE

          PACKAGE P1 IS
               PROCEDURE PROC1 (A : INTEGER);
          END P1;

          PACKAGE P2 IS
               PROCEDURE PROC1 (A : IN OUT INTEGER);
          END P2;

          USE P1, P2;

          PROCEDURE PROC2 (A : INTEGER) RENAMES PROC1; -- ERROR: B.
          PROCEDURE PROC3 (A : IN OUT INTEGER)
                                        RENAMES PROC1; -- ERROR: B.
          PACKAGE BODY P1 IS
               PROCEDURE PROC1 (A : INTEGER) IS
               BEGIN
                    NULL;
               END PROC1;
          END P1;

          PACKAGE BODY P2 IS
               PROCEDURE PROC1 (A : IN OUT INTEGER) IS
               BEGIN
                    NULL;
               END PROC1;
          END P2;

     BEGIN

          NULL;

     END;

     DECLARE

          TASK TYPE T1 IS
               ENTRY E (A : INTEGER);
               ENTRY E;
          END T1;

          TASK TYPE T2 IS
               ENTRY E (A : IN OUT INTEGER);
          END T2;

          TSK1 : T1;
          TSK2 : T2;

          FUNCTION FUN RETURN T1;
          FUNCTION FUN RETURN T2;

          PROCEDURE PROC1(A : INTEGER) RENAMES FUN.E;  -- ERROR: B.
          PROCEDURE PROC2 RENAMES FUN.E;               -- OK.

          TASK BODY T1 IS
          BEGIN
               NULL;
          END T1;

          TASK BODY T2 IS
          BEGIN
               NULL;
          END T2;

          FUNCTION FUN RETURN T1 IS
          BEGIN
               RETURN TSK1;
          END FUN;

          FUNCTION FUN RETURN T2 IS
          BEGIN
               RETURN TSK2;
          END FUN;

     BEGIN

          NULL;

     END;

END B85012A;
