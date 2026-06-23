-- B83F04A.ADA

-- CHECK THAT SUBPROGRAM REDECLARATIONS ARE FORBIDDEN.
-- SUBTESTS ARE:
--        (A) ONE DECLARATION IN THE VISIBLE PART OF A PACKAGE
--             AND THE OTHER IN THE PRIVATE PART OR BODY.
--        (B) ONE DECLARATION IN THE PRIVATE PART OF A PACKAGE
--             AND THE OTHER IN THE BODY.

-- DAS 2/3/81

PROCEDURE B83F04A IS
BEGIN

     --------------------------------------------------

     DECLARE   -- (A)

          PACKAGE PKGA IS
               SUBTYPE INT IS INTEGER RANGE 1..10;
               PROCEDURE PA1  (X : IN OUT INTEGER);
               PROCEDURE PA2  (X : IN OUT INTEGER);
               PROCEDURE PA3  (X : IN OUT INTEGER);
               PROCEDURE PA4  (X : IN OUT INTEGER);
               PROCEDURE PA5  (X : IN OUT INTEGER);
               PROCEDURE PA6  (X : IN OUT INTEGER);
               FUNCTION FA1  (X : INTEGER) RETURN INTEGER;
               FUNCTION FA2  (X : INTEGER) RETURN INTEGER;
               FUNCTION FA3  (X : INTEGER) RETURN INTEGER;
               FUNCTION FA4  (X : INTEGER := 1) RETURN INTEGER;
               FUNCTION FA5  (X : INTEGER := 1) RETURN INTEGER;
          PRIVATE
               PROCEDURE PA1  (X : IN OUT INTEGER);   -- ERROR:
                                                      -- REDECLARES PA1
               PROCEDURE PA2  (X : IN INT);           -- ERROR:
                                                      -- REDECLARES PA2
               PROCEDURE PA3  (X : OUT INTEGER);      -- ERROR:
                                                      -- REDECLARES PA3
               FUNCTION FA1 (X : INTEGER) RETURN INTEGER; -- ERROR:
                                                      -- REDECLARES FA1
               FUNCTION FA2 (X : INTEGER) RETURN INT; -- ERROR:
                                                      -- REDECLARES FA2
               FUNCTION FA4 (X : INTEGER := 4) RETURN INTEGER; -- ERROR:
                                                      -- REDECLARES FA4
          END PKGA;

          PACKAGE BODY PKGA IS

               PROCEDURE PA4 (X : IN OUT INTEGER) IS
               BEGIN
                    NULL;
               END PA4;

               PROCEDURE PA5 (X : IN OUT INTEGER) IS
               BEGIN
                    NULL;
               END PA5;

               PROCEDURE PA6 (X : IN OUT INTEGER) IS
               BEGIN
                    NULL;
               END PA6;

               FUNCTION FA3 (X : INTEGER) RETURN INTEGER IS
               BEGIN
                    RETURN 1;
               END FA3;

               FUNCTION FA5 (X : INTEGER := 1) RETURN INTEGER IS
               BEGIN
                    RETURN 2;
               END FA5;

               PROCEDURE PA4 (X : IN OUT INTEGER) IS  -- ERROR:
                                                      -- REDECLARES PA4
               BEGIN
                    NULL;
               END PA4;

               PROCEDURE PA5 (X : IN OUT INT) IS      -- ERROR:
                                                      -- REDECLARES PA5
               BEGIN
                    NULL;
               END PA5;

               PROCEDURE PA6 (X : IN INTEGER) IS      -- ERROR:
                                                      -- REDECLARES PA6
               BEGIN
                    NULL;
               END PA6;

               FUNCTION FA3 (X : INTEGER) RETURN INTEGER IS -- ERROR:
                                                      -- REDECLARES FA3
               BEGIN
                    RETURN 5;
               END FA3;

               FUNCTION FA5(X : INTEGER := 7) RETURN INTEGER IS-- ERROR:
                                                      -- REDECLARES FA5
               BEGIN
                    RETURN 7;
               END FA5;

          END PKGA;

     BEGIN     -- (A)
          NULL;
     END;      -- (A)

     --------------------------------------------------

     DECLARE   -- (B)

          PACKAGE PKGB IS
               SUBTYPE INT IS INTEGER RANGE 1..10;
          PRIVATE
               PROCEDURE PB1 (X : OUT INTEGER);
               PROCEDURE PB2 (X : OUT INTEGER);
               PROCEDURE PB3 (X : OUT INTEGER);
               PROCEDURE PB4 (X : OUT INTEGER);
               FUNCTION FB1 (X : INTEGER) RETURN INTEGER;
               FUNCTION FB2 (X : INTEGER) RETURN INTEGER;
               FUNCTION FB3 (X : INTEGER) RETURN INTEGER;
               FUNCTION FB4 (X : INTEGER := 1) RETURN INTEGER;
               FUNCTION FB5 (X : INTEGER := 1) RETURN INTEGER;
          END PKGB;

          PACKAGE BODY PKGB IS

               PROCEDURE PB1 (X : OUT INTEGER) IS
               BEGIN
                    NULL;
               END PB1;

               FUNCTION FB4 (X : INTEGER := 1) RETURN INTEGER IS
               BEGIN
                    RETURN 2;
               END FB4;

               PROCEDURE PB2 (X : IN OUT INTEGER);    -- ERROR:
                                                      -- REDECLARES PB2

               PROCEDURE PB3 (X : IN OUT INT);        -- ERROR:
                                                      -- REDECLARES PB3

               PROCEDURE PB4 (X : IN INTEGER);        -- ERROR:
                                                      -- REDECLARES PB4

               FUNCTION FB1 (Y : INTEGER) RETURN INTEGER; -- ERROR:
                                                      -- REDECLARES FB1

               FUNCTION FB2 (X : INTEGER) RETURN INTEGER; -- ERROR:
                                                      -- REDECLARES FB2

               FUNCTION FB3 (X : INTEGER) RETURN INT;   -- ERROR:
                                                      -- REDECLARES FB3

               FUNCTION FB5(X : INTEGER := 7) RETURN INTEGER; -- ERROR:
                                                      -- REDECLARES FB5

          END PKGB;  -- OPTIONAL ERROR MESSAGES ABOUT MISSING BODIES.

     BEGIN     -- (B)
          NULL;
     END;      -- (B)

END B83F04A;
