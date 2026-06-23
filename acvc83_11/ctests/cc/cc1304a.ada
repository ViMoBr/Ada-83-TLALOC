-- CC1304A.ADA

-- CHECK THAT GENERIC FORMAL SUBPROGRAMS MAY HAVE A PARAMETER
-- OF A GENERIC FORMAL TYPE, AND MAY RETURN A GENERIC FORMAL
-- TYPE.

-- DAT 8/27/81

WITH REPORT; USE REPORT;

PROCEDURE CC1304A IS
BEGIN
     TEST ("CC1304A", "GENERIC FORMAL SUBPROGRAMS MAY HAVE PARAMETERS"
          & " OF (AND RETURN) A FORMAL TYPE");

     DECLARE
          GENERIC
               TYPE T IS ( <> );
               WITH FUNCTION S (P : T) RETURN T;
               WITH PROCEDURE P (P : T);
          PROCEDURE PR (PARM : T);

          PROCEDURE PR (PARM: T) IS
          BEGIN
               P(P=>S(P=>PARM));
          END PR;
     BEGIN
          DECLARE
               C : CHARACTER := 'A';
               B : BOOLEAN := FALSE;
               I : INTEGER := 5;
               TYPE ENUM IS (E1, E2, E3);
               E : ENUM := E2;

               FUNCTION FC (P : CHARACTER) RETURN CHARACTER IS
               BEGIN
                    RETURN 'B';
               END FC;

               FUNCTION FB (P : BOOLEAN) RETURN BOOLEAN IS
               BEGIN
                    RETURN NOT P;
               END FB;
     
               FUNCTION FI (P : INTEGER) RETURN INTEGER IS
               BEGIN
                    RETURN P + 1;
               END FI;

               FUNCTION FE (P : ENUM) RETURN ENUM IS
               BEGIN
                    RETURN ENUM'SUCC (P);
               END FE;

               PROCEDURE  PC (P : CHARACTER) IS
               BEGIN
                    C := P;
               END PC;

               PROCEDURE PB (P : BOOLEAN) IS
               BEGIN
                    B := P;
               END PB;

               PROCEDURE PI (P : INTEGER) IS
               BEGIN
                   I := P;
               END PI;
 
               PROCEDURE PE (P : ENUM) IS
               BEGIN
                    E := P;
               END PE;

               PACKAGE PKG2 IS
                    PROCEDURE P1 IS NEW PR (CHARACTER, FC, PC);
                    PROCEDURE P2 IS NEW PR (BOOLEAN, FB, PB);
                    PROCEDURE P3 IS NEW PR (INTEGER, FI, PI);
                    PROCEDURE P4 IS NEW PR (ENUM, FE, PE);
               END PKG2;

               PACKAGE BODY PKG2 IS
               BEGIN
                    P1 (C);
                    P2 (B);
                    P3 (I);
                    P4 (E);
               END  PKG2;
          BEGIN
               IF C /= 'B'
               OR B /= TRUE
               OR I /= 6
               OR E /= E3 THEN
                    FAILED ("SUBPROGRAM PARAMETERS OF FORMAL TYPES");
               END IF;
          END;
     END;
     
     RESULT;
END CC1304A;
