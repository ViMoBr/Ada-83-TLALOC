-- BB3002A.ADA

-- CHECK THAT A NON-SPECIFIC RAISE STATEMENT FOUND OUTSIDE
--    AN EXCEPTION HANDLER IS FORBIDDEN.

-- DCB 04/01/80
-- JRK 11/19/80
-- SPS 3/23/83

PROCEDURE BB3002A IS

BEGIN
     BEGIN
          RAISE;          -- ERROR: NON-SPECIFIC RAISE OUTSIDE HANDLER.
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>

               DECLARE
                    PROCEDURE P IS
                    BEGIN
                         RAISE;  -- ERROR: 'RAISE;' IN PROCEDURE.
                    END P;

                    PACKAGE Q IS
                         I : INTEGER;
                    END Q;

                    PACKAGE BODY Q IS
                    BEGIN
                          RAISE;  -- ERROR: 'RAISE;' IN PACKAGE.
                    END Q;
               BEGIN
                    NULL;
               END ;
     END ;

END BB3002A;
