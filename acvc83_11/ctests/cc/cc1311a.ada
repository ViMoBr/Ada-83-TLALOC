-- CC1311A.ADA

-- OBJECTIVE:
--     CHECK THAT THE DEFAULT EXPRESSIONS OF THE PARAMETERS OF A FORMAL
--     SUBPROGRAM ARE USED INSTEAD OF THE DEFAULTS (IF ANY) OF THE
--     ACTUAL SUBPROGRAM PARAMETER.

-- HISTORY:
--     RJW 06/05/86  CREATED ORIGINAL TEST.
--     VCL 08/18/87  CHANGED A COUPLE OF STATIC DEFAULT EXPRESSIONS FOR
--                   FORMAL SUBPROGRAM PARAMETERS TO DYNAMIC EXPRESSIONS
--                   VIA THE USE OF THE IDENTITY FUNCTION.

WITH REPORT; USE REPORT;

PROCEDURE CC1311A IS

BEGIN
     TEST ("CC1311A", "CHECK THAT THE DEFAULT EXPRESSIONS OF THE " &
                      "PARAMETERS OF A FORMAL SUBPROGRAM ARE USED " &
                      "INSTEAD OF THE DEFAULTS (IF ANY) OF THE " &
                      "ACTUAL SUBPROGRAM PARAMETER" );


     DECLARE
          TYPE NUMBERS IS (ZERO, ONE ,TWO);

          GENERIC
               TYPE T IS (<>);
               WITH FUNCTION F (X : T := T'VAL (0)) RETURN T;
          FUNCTION FUNC1 RETURN BOOLEAN;

          FUNCTION FUNC1 RETURN BOOLEAN IS
          BEGIN
               RETURN F = T'VAL (0);
          END FUNC1;

          GENERIC
               TYPE T IS (<>);
               WITH FUNCTION F (X : T := T'VAL (IDENT_INT(0))) RETURN T;
          PACKAGE PKG1 IS END PKG1;

          PACKAGE BODY PKG1 IS
          BEGIN
               IF F = T'VAL (0) THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT DEFAULT VALUE WITH " &
                             "FUNCTION 'F' AND PACKAGE 'PKG1'" );
               END IF;
          END PKG1;

          GENERIC
               TYPE T IS (<>);
               WITH FUNCTION F (X : T := T'VAL (0)) RETURN T;
          PROCEDURE PROC1;

          PROCEDURE PROC1 IS
          BEGIN
               IF F = T'VAL (0) THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT DEFAULT VALUE WITH " &
                             "FUNCTION 'F' AND PROCEDURE 'PROC1'" );
               END IF;
          END PROC1;

          GENERIC
               TYPE T IS (<>);
               WITH PROCEDURE P (RESULTS : OUT T; X : T := T'VAL (0));
          FUNCTION FUNC2 RETURN BOOLEAN;

          FUNCTION FUNC2 RETURN BOOLEAN IS
               RESULTS : T;
          BEGIN
               P (RESULTS);
               RETURN RESULTS = T'VAL (0);
          END FUNC2;

          GENERIC
               TYPE T IS (<>);
               WITH PROCEDURE P  (RESULTS : OUT T;
                                  X : T := T'VAL (IDENT_INT(0)));
          PACKAGE PKG2 IS END PKG2;

          PACKAGE BODY PKG2 IS
               RESULTS : T;
          BEGIN
               P (RESULTS);
               IF RESULTS = T'VAL (0) THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT DEFAULT VALUE WITH " &
                             "PROCEDURE 'P' AND PACKAGE 'PKG2'" );
               END IF;
          END PKG2;

          GENERIC
               TYPE T IS (<>);
               WITH PROCEDURE P (RESULTS :OUT T; X : T := T'VAL (0));
          PROCEDURE PROC2;

          PROCEDURE PROC2 IS
               RESULTS : T;
          BEGIN
               P (RESULTS);
               IF RESULTS = T'VAL (0) THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT DEFAULT VALUE WITH " &
                             "PROCEDURE 'P' AND PROCEDURE 'PROC2'" );
               END IF;
          END PROC2;

          FUNCTION F1 (A : NUMBERS := ONE) RETURN NUMBERS IS
          BEGIN
               RETURN A;
          END;

          PROCEDURE P2 (OUTVAR : OUT NUMBERS; INVAR : NUMBERS := TWO)
               IS
          BEGIN
               OUTVAR := INVAR;
          END;

          FUNCTION  NFUNC1 IS NEW FUNC1 (NUMBERS, F1);
          PACKAGE   NPKG1  IS NEW PKG1  (NUMBERS, F1);
          PROCEDURE NPROC1 IS NEW PROC1 (NUMBERS, F1);

          FUNCTION  NFUNC2 IS NEW FUNC2 (NUMBERS, P2);
          PACKAGE   NPKG2  IS NEW PKG2  (NUMBERS, P2);
          PROCEDURE NPROC2 IS NEW PROC2 (NUMBERS, P2);

     BEGIN
          IF NFUNC1 THEN
               NULL;
          ELSE
               FAILED ( "INCORRECT DEFAULT VALUE " &
                        "WITH FUNCTION 'NFUNC1'" );
          END IF;

          IF NFUNC2 THEN
               NULL;
          ELSE
               FAILED ( "INCORRECT DEFAULT VALUE " &
                        "WITH FUNCTION 'NFUNC2'" );
          END IF;

          NPROC1;
          NPROC2;
     END;
     RESULT;

END CC1311A;
