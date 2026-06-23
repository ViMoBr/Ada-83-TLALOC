-- C34009J.ADA

-- OBJECTIVE:
--     CHECK THAT THE REQUIRED PREDEFINED OPERATIONS ARE DECLARED
--     (IMPLICITLY) FOR DERIVED LIMITED PRIVATE TYPES WITH
--     DISCRIMINANTS.

-- HISTORY:
--     JRK 09/01/87  CREATED ORIGINAL TEST.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;

PROCEDURE C34009J IS

     PACKAGE PKG IS

          MAX_LEN : CONSTANT := 10;

          SUBTYPE LENGTH IS NATURAL RANGE 0 .. MAX_LEN;

          TYPE PARENT (B : BOOLEAN := TRUE; L : LENGTH := 3) IS
                      LIMITED PRIVATE;

          FUNCTION CREATE ( B : BOOLEAN;
                            L : LENGTH;
                            I : INTEGER;
                            S : STRING;
                            J : INTEGER;
                            F : FLOAT;
                            X : PARENT  -- TO RESOLVE OVERLOADING.
                          ) RETURN PARENT;

          FUNCTION CON ( B : BOOLEAN;
                         L : LENGTH;
                         I : INTEGER;
                         S : STRING;
                         J : INTEGER
                       ) RETURN PARENT;

          FUNCTION CON ( B : BOOLEAN;
                         L : LENGTH;
                         I : INTEGER;
                         F : FLOAT
                       ) RETURN PARENT;

          FUNCTION EQUAL (X, Y : PARENT) RETURN BOOLEAN;

          PROCEDURE ASSIGN (X : OUT PARENT; Y : PARENT);

     PRIVATE

          TYPE PARENT (B : BOOLEAN := TRUE; L : LENGTH := 3) IS
               RECORD
                    I : INTEGER := 2;
                    CASE B IS
                         WHEN TRUE =>
                              S : STRING (1 .. L) := (1 .. L => 'A');
                              J : INTEGER := 2;
                         WHEN FALSE =>
                              F : FLOAT := 5.0;
                    END CASE;
               END RECORD;

     END PKG;

     USE PKG;

     TYPE T IS NEW PARENT (IDENT_BOOL (TRUE), IDENT_INT (3));

     X : T;
     W : PARENT;
     B : BOOLEAN := FALSE;

     PROCEDURE A (X : ADDRESS) IS
     BEGIN
          B := IDENT_BOOL (TRUE);
     END A;

     PACKAGE BODY PKG IS

          FUNCTION CREATE
             ( B : BOOLEAN;
               L : LENGTH;
               I : INTEGER;
               S : STRING;
               J : INTEGER;
               F : FLOAT;
               X : PARENT
             ) RETURN PARENT
          IS
          BEGIN
               CASE B IS
                    WHEN TRUE =>
                         RETURN (TRUE, L, I, S, J);
                    WHEN FALSE =>
                         RETURN (FALSE, L, I, F);
               END CASE;
          END CREATE;

          FUNCTION CON
             ( B : BOOLEAN;
               L : LENGTH;
               I : INTEGER;
               S : STRING;
               J : INTEGER
             ) RETURN PARENT
          IS
          BEGIN
               RETURN (TRUE, L, I, S, J);
          END CON;

          FUNCTION CON
             ( B : BOOLEAN;
               L : LENGTH;
               I : INTEGER;
               F : FLOAT
             ) RETURN PARENT
          IS
          BEGIN
               RETURN (FALSE, L, I, F);
          END CON;

          FUNCTION EQUAL (X, Y : PARENT) RETURN BOOLEAN IS
          BEGIN
               RETURN X = Y;
          END EQUAL;

          PROCEDURE ASSIGN (X : OUT PARENT; Y : PARENT) IS
          BEGIN
               X := Y;
          END ASSIGN;

     END PKG;

BEGIN
     TEST ("C34009J", "CHECK THAT THE REQUIRED PREDEFINED OPERATIONS " &
                      "ARE DECLARED (IMPLICITLY) FOR DERIVED " &
                      "LIMITED PRIVATE TYPES WITH DISCRIMINANTS");

     IF EQUAL (3, 3) THEN
          ASSIGN (X, CON (TRUE, 3, 1, "ABC", 4));
     END IF;
     IF NOT EQUAL (T'(X), CON (TRUE, 3, 1, "ABC", 4)) THEN
          FAILED ("INCORRECT QUALIFICATION");
     END IF;

     IF NOT EQUAL (T (X), CON (TRUE, 3, 1, "ABC", 4)) THEN
          FAILED ("INCORRECT SELF CONVERSION");
     END IF;

     IF EQUAL (3, 3) THEN
          ASSIGN (W, CON (TRUE, 3, 1, "ABC", 4));
     END IF;
     IF NOT EQUAL (T (W), CON (TRUE, 3, 1, "ABC", 4)) THEN
          FAILED ("INCORRECT CONVERSION FROM PARENT");
     END IF;

     IF NOT EQUAL (PARENT (X), CON (TRUE, 3, 1, "ABC", 4)) OR
        NOT EQUAL (PARENT (CREATE (FALSE, 2, 3, "XX", 5, 6.0, X)),
                   CON (FALSE, 2, 3, 6.0)) THEN
          FAILED ("INCORRECT CONVERSION TO PARENT");
     END IF;

     IF X.B /= TRUE OR X.L /= 3 OR
        CREATE (FALSE, 2, 3, "XX", 5, 6.0, X) . B /= FALSE OR
        CREATE (FALSE, 2, 3, "XX", 5, 6.0, X) . L /= 2 THEN
          FAILED ("INCORRECT SELECTION (DISCRIMINANT)");
     END IF;

     IF NOT (X IN T) OR CON (FALSE, 2, 3, 6.0) IN T THEN
          FAILED ("INCORRECT ""IN""");
     END IF;

     IF X NOT IN T OR NOT (CON (FALSE, 2, 3, 6.0) NOT IN T) THEN
          FAILED ("INCORRECT ""NOT IN""");
     END IF;

     B := FALSE;
     A (X'ADDRESS);
     IF NOT B THEN
          FAILED ("INCORRECT 'ADDRESS");
     END IF;

     DECLARE
          VTS : CONSTANT := MAX_LEN * CHARACTER'SIZE + INTEGER'SIZE;
          VFS : CONSTANT := FLOAT'SIZE;
          VS  : CONSTANT := BOOLEAN'POS (VTS >= VFS) * VTS +
                            BOOLEAN'POS (VFS >  VTS) * VFS;
     BEGIN
          IF T'BASE'SIZE < BOOLEAN'SIZE + LENGTH'SIZE +
                           INTEGER'SIZE + VS THEN
               FAILED ("INCORRECT 'BASE'SIZE");
          END IF;
     END;

     IF NOT T'CONSTRAINED THEN
          FAILED ("INCORRECT TYPE'CONSTRAINED");
     END IF;

     IF NOT X'CONSTRAINED THEN
          FAILED ("INCORRECT OBJECT'CONSTRAINED");
     END IF;

     IF T'SIZE < BOOLEAN'SIZE + LENGTH'SIZE + INTEGER'SIZE +
                 3 * CHARACTER'SIZE + INTEGER'SIZE THEN
          FAILED ("INCORRECT TYPE'SIZE");
     END IF;

     IF X'SIZE   < T'SIZE OR
        X.B'SIZE < BOOLEAN'SIZE OR
        X.L'SIZE < LENGTH'SIZE THEN
          FAILED ("INCORRECT OBJECT'SIZE");
     END IF;

     RESULT;
END C34009J;
