-- B74003A.ADA

-- CHECK THAT NO CONSTRAINT IS ALLOWED IN THE DECLARATION OF A DEFERRED
-- CONSTANT. 

-- JBG 9/21/83

PROCEDURE B74003A IS
BEGIN
     DECLARE
          PACKAGE P IS
               TYPE T  (D : INTEGER) IS PRIVATE;
               TYPE LT (D : INTEGER) IS LIMITED PRIVATE;

               CT  : CONSTANT T(3);               -- ERROR: CONSTRAINT.
               CLT : CONSTANT LT(3);              -- ERROR: CONSTRAINT.
          PRIVATE
               TYPE T (D : INTEGER) IS
                    RECORD NULL; END RECORD;
               TYPE LT (D : INTEGER) IS
                    RECORD NULL; END RECORD;
               CT  : CONSTANT T(3) := (D => 3);
               CLT : CONSTANT LT(3) := (D => 3);
          END P;
     BEGIN
          NULL;
     END;
END B74003A;
