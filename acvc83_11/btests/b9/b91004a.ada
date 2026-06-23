-- B91004A.ADA

-- CHECK THAT THE NAME OF A TASK TYPE CANNOT BE USED AS A TYPE MARK
-- WITHIN ITS OWN BODY.

-- JBG 2/24/84
-- EG  5/30/84

PROCEDURE B91004A IS

     TASK TYPE T IS
     END T;

     TYPE ACC_T IS ACCESS T;

     PROCEDURE P2(TT : T);

     X2 : T;

     TASK BODY T IS
          X : T;                   -- ERROR: USED AS TYPE MARK.
          A : ACC_T := NEW T;      -- ERROR: USED AS TYPE MARK.
          I : INTEGER;

          PROCEDURE P IS
               X : T;              -- ERROR: USED AS TYPE MARK.
               A : ACC_T := NEW T; -- ERROR: USED AS TYPE MARK.
          BEGIN
               NULL;
          END;
     BEGIN
          X := T'(X);              -- ERROR: USED AS TYPE MARK.
          I := T'STORAGE_SIZE;     -- OK. (USED AS OBJECT.)
          P2(T'(X2));              -- ERROR: TYPE NAME USED AS QUALIFIER
     END;

     PROCEDURE P2(TT : T) IS
     BEGIN
          NULL;
     END;

BEGIN
     NULL;
END B91004A;
