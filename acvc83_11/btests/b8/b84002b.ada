-- B84002B.ADA

-- CHECK THAT THE EFFECT OF "USE P" CAN BE TO MAKE P INVISIBLE.

-- EG  02/16/84

PROCEDURE B84002B IS

BEGIN

     DECLARE

          PACKAGE P1 IS
               PACKAGE P IS
                    P : INTEGER := 15;
               END P;
          END P1;

          PACKAGE P2 IS
               USE P1;
               A : INTEGER := P.P;
          END P2;

          PACKAGE P3 IS
               USE P1.P;
               B : INTEGER := P;
          END P3;

          PACKAGE P4 IS
               USE P1;
               USE P;
               C : INTEGER := P;                       -- ERROR:
          END P4;

     BEGIN

          NULL;

     END;

END B84002B;
