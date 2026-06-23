-- B41308B.ADA

-- OBJECTIVE:
--     IF F IS THE NAME OF A FUNCTION RETURNING A RECORD WITH
--     COMPONENT X AND X IS ALSO DECLARED WITHIN F, THEN CHECK F.X,
--     WHERE F.X IS WITHIN F, F IS DECLARED WITHIN AN ENCLOSING
--     SUBPROGRAM OR SINGLE ENTRY ACCEPT STATEMENT THAT IS ALSO NAMED F
--     AND HAS A DIFFERENT PROFILE, AND BOTH F'S ARE VISIBLE (F.X IS
--     ILLEGAL).

-- HISTORY:
--     BCB 07/13/88  CREATED ORIGINAL TEST.

PROCEDURE B41308B IS

     TYPE REC IS RECORD
          X : INTEGER;
     END RECORD;

     FUNCTION F RETURN FLOAT IS
          Z : FLOAT := 1.0;

          FUNCTION F RETURN REC IS
               X : INTEGER := 1;
               Y : INTEGER := F.X;                     -- ERROR:
               A : REC := (X => 1);
          BEGIN
               RETURN A;
          END F;
     BEGIN
          RETURN Z;
     END F;

     TASK T IS
          ENTRY F;
     END T;

     TASK BODY T IS
     BEGIN
          ACCEPT F DO
              DECLARE
                   FUNCTION F RETURN REC IS
                        X : INTEGER := 1;
                        Y : INTEGER := F.X;
                        A : REC := (X => 1);
                   BEGIN
                        RETURN A;
                   END F;
              BEGIN
                   NULL;
              END;
          END F;
     END T;

BEGIN
     NULL;
END B41308B;
