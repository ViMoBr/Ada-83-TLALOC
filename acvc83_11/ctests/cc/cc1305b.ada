-- CC1305B.ADA

-- CHECK THAT DEFAULT FORMAL SUBPROGRAMS MAY BE INSTANCES OF GENERICS.

-- DAT 8/27/81

WITH REPORT; USE REPORT;

PROCEDURE CC1305B IS
BEGIN
     TEST ("CC1305B", "GENERIC DEFAULT SUBPROGRAMS MAY BE GENERIC"
          & " INSTANCES");

     DECLARE
          GENERIC
               TYPE T IS ( <> );
          PROCEDURE GP1 (P : IN OUT T);

          GENERIC
               TYPE T IS ( <> );
          FUNCTION GF1 (P : T) RETURN T;

          PROCEDURE GP1  (P : IN OUT T) IS
               FUNCTION F IS NEW GF1 (T);
          BEGIN
               P := F (P);
          END GP1;

          FUNCTION GF1 (P : T) RETURN T IS
          BEGIN
               IF P = T'LAST THEN
                    RETURN T'FIRST;
               ELSE
                    RETURN T'SUCC (P);
               END IF;
          END GF1;
     BEGIN
          DECLARE
               PROCEDURE P IS NEW GP1 (INTEGER);
               PROCEDURE P IS NEW GP1 (BOOLEAN);
               PROCEDURE P IS NEW GP1 (CHARACTER);
               TYPE NEWCHAR IS NEW CHARACTER;
               PROCEDURE P IS NEW GP1 (NEWCHAR);
               FUNCTION F IS NEW GF1 (INTEGER);
               FUNCTION F IS NEW GF1 (BOOLEAN);
               FUNCTION F IS NEW GF1 (CHARACTER);
               FUNCTION F IS NEW GF1 (NEWCHAR);
               TYPE ENUM IS (E1, E2, E3, E4);
               PROCEDURE P IS NEW GP1 (ENUM);
               FUNCTION F IS NEW GF1 (ENUM);

               GENERIC 
                    TYPE T IS ( <> );
                    WITH FUNCTION F1 (P : T) RETURN T IS <> ;
                    WITH PROCEDURE P1 (P : IN OUT T) IS <> ;
               PACKAGE GPK1 IS
                    X : T := F1 (T'FIRST);
               END GPK1;

               GENERIC
                    WITH PROCEDURE P1 (P : IN OUT INTEGER) IS P;
                    WITH PROCEDURE P1 (P : IN OUT BOOLEAN) IS P;
                    WITH PROCEDURE P1 (P : IN OUT CHARACTER) IS P;
                    WITH PROCEDURE P1 (P : IN OUT NEWCHAR) IS P;
                    WITH PROCEDURE P1 (P : IN OUT ENUM) IS P;
                    WITH FUNCTION F1 (P : INTEGER) RETURN INTEGER IS F;
                    WITH FUNCTION F1 (P : BOOLEAN) RETURN BOOLEAN IS F;
                    WITH FUNCTION F1 (P : CHARACTER) RETURN CHARACTER
                         IS F;
                    WITH FUNCTION F1 (P : NEWCHAR) RETURN NEWCHAR IS F;
                    WITH FUNCTION F1 (P : ENUM) RETURN ENUM IS F;
               PACKAGE GPK2 IS END GPK2;

               PACKAGE BODY GPK2 IS
                    PACKAGE X1 IS NEW GPK1 (INTEGER);
                    PACKAGE X2 IS NEW GPK1 (BOOLEAN);
                    PACKAGE X3 IS NEW GPK1 (CHARACTER);
                    PACKAGE X4 IS NEW GPK1 (NEWCHAR);
                    PACKAGE X5 IS NEW GPK1 (ENUM);
               BEGIN
                    P1 (X1.X);
                    P1 (X2.X);
                    P1 (X3.X);
                    P1 (X4.X);
                    P1 (X5.X);
                    IF X1.X /= F1(F1(F1(INTEGER'FIRST)))
                    OR X2.X /= F1(F1(F1(FALSE)))
                    OR X3.X /= CHARACTER'VAL (3)
                    OR X4.X /= NEWCHAR (X3.X)
                    OR X5.X /= E4 THEN
                         FAILED ("WRONG DEFAULT GENERIC SUBPGM");
                    END IF;
               END GPK2;

               PACKAGE BODY GPK1 IS
               BEGIN
                    P1 (X);
               END GPK1;

               PACKAGE PK2 IS NEW GPK2;
          BEGIN
               NULL;
          END;
     END;

     RESULT;
END CC1305B;
