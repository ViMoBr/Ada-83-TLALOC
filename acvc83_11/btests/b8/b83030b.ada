-- B83030B.ADA

-- OBJECTIVE:
--     WITHIN A GENERIC SUBPROGRAM BODY THE USE OF AN IDENIFIER OF A
--     HOMOGRAPHIC SUBPROGRAM DECLARED IN AN OUTER DECLARATIVE REGION
--     IS NOT ALLOWED IF IT WOULD BE ILLEGAL AS A REFERENCE TO THE
--     GENERIC SUBPROGRAM.

-- HISTORY:
--     RJW 11/07/88  CREATED ORIGINAL TEST.

PROCEDURE B83030B IS

BEGIN
     ONE:
     DECLARE
          GENERIC
               Y : INTEGER;
          PROCEDURE P (X : INTEGER);

          PROCEDURE P (X : INTEGER) IS
          BEGIN
               NULL;
          END P;

     BEGIN
          DECLARE
               GENERIC
               PROCEDURE P;

               PROCEDURE P IS
                    A : INTEGER := 2;
                    PROCEDURE NP IS NEW P (A);                -- ERROR:
               BEGIN
                    NULL;
               END P;

          BEGIN
               NULL;
          END;
     END ONE;


     TWO:
     DECLARE
          GENERIC
               WITH PROCEDURE Q;
          FUNCTION P RETURN STRING;

          FUNCTION P RETURN STRING IS
          BEGIN
               RETURN "LET'S HEAR IT FOR THE TESTWRITERS";
          END;
     BEGIN
          DECLARE
               GENERIC
                    TYPE T IS (<>);
               PROCEDURE P (X : T);

               PROCEDURE P (X : T) IS
                    PROCEDURE Q IS
                    BEGIN
                         NULL;
                    END Q;

                    FUNCTION NP IS NEW P (Q);                 -- ERROR:
               BEGIN
                    NULL;
               END P;
          BEGIN
               NULL;
          END;
     END TWO;

     THREE:
     DECLARE

          GENERIC
               TYPE T IS PRIVATE;
          FUNCTION F (X, Y : FLOAT) RETURN BOOLEAN;

          FUNCTION F (X, Y : FLOAT) RETURN BOOLEAN IS
          BEGIN
               RETURN FALSE;
          END F;
     BEGIN
          DECLARE
               GENERIC
               FUNCTION F RETURN INTEGER;

               FUNCTION F RETURN INTEGER IS
                    FUNCTION NF IS NEW F (STRING);            -- ERROR:
               BEGIN
                    RETURN 3;
               END F;

          BEGIN
               NULL;
          END;
     END THREE;

     FOUR:
     DECLARE
          GENERIC
               WITH PROCEDURE P;
          PROCEDURE F (X : INTEGER);

          PROCEDURE F (X : INTEGER) IS
          BEGIN
               NULL;
          END F;

     BEGIN
          DECLARE
               GENERIC
                    TYPE T IS (<>);
               FUNCTION F RETURN T;

               FUNCTION F RETURN T IS
                    PROCEDURE NF IS NEW F (STRING);        -- ERROR:
               BEGIN
                    RETURN T'LAST;
               END F;

          BEGIN
               NULL;
          END;
     END FOUR;

END B83030B;
