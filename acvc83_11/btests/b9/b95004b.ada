-- B95004B.ADA

-- CHECK THAT AN ACCEPT STATEMENT MAY NOT APPEAR IN A LOCAL
--    SUBPROGRAM, PACKAGE, OR TASK OF A TASK BODY.

-- JRK 10/26/81

PROCEDURE B95004B IS

     TASK T IS
          ENTRY E0;
          ENTRY E1 (I : INTEGER);
          ENTRY E2 (BOOLEAN) (I : INTEGER);
     END T;

     TASK BODY T IS

          PROCEDURE P IS
          BEGIN
               ACCEPT E0;                         -- ERROR: NOT LOCAL.
          END P;

          FUNCTION F RETURN INTEGER IS
          BEGIN
               ACCEPT E1 (I : INTEGER);           -- ERROR: NOT LOCAL.
               RETURN 0;
          END F;

          PACKAGE PKG IS
          END PKG;

          PACKAGE BODY PKG IS
          BEGIN
               ACCEPT E2 (TRUE) (I : INTEGER);    -- ERROR: NOT LOCAL.
          END PKG;

          TASK T1 IS
               ENTRY E;
          END T1;

          TASK BODY T1 IS
          BEGIN
               ACCEPT E;                          -- OK.
               ACCEPT E0;                         -- ERROR: NOT LOCAL.
          END T1;

     BEGIN

          ACCEPT E0;                              -- OK;

          DECLARE

               PROCEDURE P IS
               BEGIN
                    ACCEPT E0;                    -- ERROR: NOT LOCAL.
               END P;

               FUNCTION F RETURN INTEGER IS
               BEGIN
                    ACCEPT E1 (I : INTEGER);      -- ERROR: NOT LOCAL.
                    RETURN 0;
               END F;

               PACKAGE PKG IS
               END PKG;

               PACKAGE BODY PKG IS
               BEGIN
                    ACCEPT E2 (TRUE) (I : INTEGER); -- ERROR: NOT LOCAL.
               END PKG;

               TASK T1 IS
                    ENTRY E;
               END T1;

               TASK BODY T1 IS
               BEGIN
                    ACCEPT E;                     -- OK.
                    ACCEPT E0;                    -- ERROR: NOT LOCAL.
               END T1;

          BEGIN
               ACCEPT E1 (I : INTEGER);           -- OK.
               ACCEPT E2 (TRUE) (I : INTEGER);    -- OK.
          END;

     END T;

BEGIN
     NULL;
END B95004B;
