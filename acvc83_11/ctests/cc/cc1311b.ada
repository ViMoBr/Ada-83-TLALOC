-- CC1311B.ADA

-- OBJECTIVE:
--     CHECK THAT IF PARAMETERS OF DEFAULT AND FORMAL SUBPROGRAMS HAVE
--     THE SAME TYPE BUT NOT THE SAME SUBTYPE, THE PARAMETER SUBTYPES OF
--     THE SUBPROGRAM DENOTED BY THE DEFAULT ARE USED INSTEAD OF
--     SUBTYPES SPECIFIED IN THE FORMAL SUBPROGRAM DECLARATION.

-- HISTORY:
--     RJW 06/11/86 CREATED ORIGINAL TEST.
--     DHH 10/20/86 CORRECTED RANGE ERRORS.

WITH REPORT; USE REPORT;

PROCEDURE CC1311B IS

BEGIN
     TEST ("CC1311B", "CHECK THAT IF PARAMETERS OF DEFAULT AND " &
                      "FORMAL SUBPROGRAMS HAVE THE SAME TYPE BUT " &
                      "NOT THE SAME SUBTYPE, THE PARAMETER SUBTYPES " &
                      "OF THE SUBPROGRAM DENOTED BY THE DEFAULT ARE " &
                      "USED INSTEAD OF SUBTYPES SPECIFIED IN THE " &
                      "FORMAL SUBPROGRAM DECLARATION" );

     DECLARE
          TYPE NUMBERS IS (ZERO, ONE ,TWO);
          SUBTYPE ZERO_TWO IS NUMBERS;
          SUBTYPE ZERO_ONE IS NUMBERS RANGE ZERO .. ONE;

          FUNCTION FSUB (X : ZERO_ONE) RETURN ZERO_ONE IS
          BEGIN
               RETURN NUMBERS'VAL (IDENT_INT (NUMBERS'POS (ONE)));
          END FSUB;

          GENERIC
               WITH FUNCTION F (X : ZERO_TWO := TWO) RETURN ZERO_TWO
                    IS FSUB;
          FUNCTION FUNC  RETURN ZERO_TWO;

          FUNCTION FUNC RETURN ZERO_TWO IS
          BEGIN
               RETURN F;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    RETURN ZERO;
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED WITH " &
                             "NFUNC1" );
                    RETURN ZERO;
          END FUNC;

          FUNCTION NFUNC1 IS NEW FUNC;

     BEGIN
          IF NFUNC1 = ONE THEN
               FAILED ( "NO EXCEPTION RAISED WITH NFUNC1" );
          END IF;
     END;

     DECLARE
          TYPE GENDER IS (MALE, FEMALE);

          TYPE PERSON (SEX : GENDER) IS
               RECORD
                   CASE SEX IS
                         WHEN MALE =>
                              BEARDED : BOOLEAN;
                         WHEN FEMALE =>
                              CHILDREN : INTEGER;
                    END CASE;
               END RECORD;

          SUBTYPE MAN IS PERSON (SEX => MALE);
          SUBTYPE TESTWRITER IS PERSON;

          ROSA : TESTWRITER (FEMALE) := (FEMALE, 4);

          FUNCTION F (X : MAN) RETURN PERSON IS
               TOM : PERSON (MALE) := (MALE, FALSE);
          BEGIN
               IF EQUAL (3, 3) THEN
                    RETURN X;
               ELSE
                    RETURN TOM;
               END IF;
          END F;

          GENERIC
               TYPE T IS PRIVATE;
               X1 : T;
               WITH FUNCTION F (X : T) RETURN T IS <> ;
          PACKAGE PKG IS END PKG;

          PACKAGE BODY PKG IS
          BEGIN
               IF F(X1) = X1 THEN
                    FAILED ( "NO EXCEPTION RAISED WITH " &
                             "FUNCTION 'F' AND PACKAGE " &
                             "'PKG' - 1" );
               ELSE
                    FAILED ( "NO EXCEPTION RAISED WITH " &
                             "FUNCTION 'F' AND PACKAGE " &
                             "'PKG' - 2" );
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED WITH " &
                             "FUNCTION 'F' AND PACKAGE 'PKG'" );
          END PKG;

          PACKAGE NPKG IS NEW PKG (TESTWRITER, ROSA);

     BEGIN
          COMMENT ( "PACKAGE BODY ELABORATED - 1" );
     END;

     DECLARE
          TYPE VECTOR IS ARRAY (POSITIVE RANGE <>) OF INTEGER;
          SUBTYPE SUBV1 IS VECTOR (1 .. 5);
          SUBTYPE SUBV2 IS VECTOR (2 .. 6);

          V1 : SUBV1 := (1, 2, 3, 4, 5);

          FUNCTION FSUB (Y : SUBV2) RETURN VECTOR IS
               Z : SUBV2;
          BEGIN
               FOR I IN Y'RANGE LOOP
                    Z (I) := IDENT_INT (Y (I));
               END LOOP;
               RETURN Z;
          END;

          GENERIC
               WITH FUNCTION F (X : SUBV1 := V1) RETURN SUBV1 IS FSUB;
          PROCEDURE PROC;

          PROCEDURE PROC IS
          BEGIN
               IF F = V1 THEN
                    FAILED ( "NO EXCEPTION RAISED WITH " &
                             "FUNCTION 'F' AND PROCEDURE " &
                             "'PROC' - 1" );
               ELSE
                    FAILED ( "NO EXCEPTION RAISED WITH " &
                             "FUNCTION 'F' AND PROCEDURE " &
                             "'PROC' - 2" );
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED WITH " &
                             "FUNCTION 'F' AND PROCEDURE " &
                             "'PROC'" );
          END PROC;

          PROCEDURE NPROC IS NEW PROC;
     BEGIN
          NPROC;
     END;

     DECLARE

          TYPE ACC IS ACCESS STRING;

          SUBTYPE INDEX1 IS INTEGER RANGE 1 .. 5;
          SUBTYPE INDEX2 IS INTEGER RANGE 2 .. 6;

          SUBTYPE ACC1 IS ACC (INDEX1);
          SUBTYPE ACC2 IS ACC (INDEX2);

          AC2 : ACC2 := NEW STRING'(2 .. 6 => 'A');
          AC  : ACC;

          PROCEDURE P (RESULTS : OUT ACC1; X : ACC1) IS
          BEGIN
               RESULTS := NULL;
          END P;

          GENERIC
               WITH PROCEDURE P1 (RESULTS : OUT ACC2; X : ACC2 := AC2)
                    IS P;
          FUNCTION FUNC RETURN ACC;

          FUNCTION FUNC RETURN ACC IS
               RESULTS : ACC;
          BEGIN
               P1 (RESULTS);
               RETURN RESULTS;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    RETURN NEW STRING'("ABCDE");
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED WITH " &
                             "NFUNC2" );
                    RETURN NULL;
          END FUNC;

          FUNCTION NFUNC2 IS NEW FUNC;

     BEGIN
          AC := NFUNC2;
          IF AC = NULL OR ELSE AC.ALL /= "ABCDE" THEN
               FAILED ( "NO OR WRONG EXCEPTION RAISED WITH NFUNC2" );
          END IF;
     END;

     DECLARE
          SUBTYPE FLOAT1 IS FLOAT RANGE -1.0 .. 0.0;
          SUBTYPE FLOAT2 IS FLOAT RANGE  0.0 .. 1.0;

          PROCEDURE PSUB (RESULTS : OUT FLOAT2; X : FLOAT2) IS
          BEGIN
               IF EQUAL (3, 3) THEN
                    RESULTS := X;
               ELSE
                    RESULTS := 0.0;
               END IF;
          END PSUB;

          GENERIC
               WITH PROCEDURE P (RESULTS : OUT FLOAT1;
                                 X : FLOAT1 := -0.0625) IS PSUB;
          PACKAGE PKG IS END PKG;

          PACKAGE BODY PKG IS
               RESULTS : FLOAT1;
          BEGIN
               P (RESULTS);
               IF RESULTS = 1.0 THEN
                    FAILED ( "NO EXCEPTION RAISED WITH " &
                             "PROCEDURE 'P' AND PACKAGE " &
                             "'PKG' - 1" );
               ELSE
                    FAILED ( "NO EXCEPTION RAISED WITH " &
                             "PROCEDURE 'P' AND PACKAGE " &
                             "'PKG' - 2" );
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED WITH " &
                             "PROCEDURE 'P' AND PACKAGE 'PKG'" );
          END PKG;

          PACKAGE NPKG IS NEW PKG;
     BEGIN
          COMMENT ( "PACKAGE BODY ELABORATED - 2" );
     END;

     DECLARE
          TYPE FIXED IS DELTA 0.125 RANGE -1.0 .. 1.0;
          SUBTYPE FIXED1 IS FIXED RANGE -0.5 .. 0.0;
          SUBTYPE FIXED2 IS FIXED RANGE  0.0 .. 0.5;

          PROCEDURE P (RESULTS : OUT FIXED1; X : FIXED1) IS
          BEGIN
               IF EQUAL (3, 3) THEN
                    RESULTS := X;
               ELSE
                    RESULTS := X;
               END IF;
          END P;

          GENERIC
               TYPE F IS DELTA <>;
               F1 : F;
               WITH PROCEDURE P (RESULTS : OUT F; X : F) IS <> ;
          PROCEDURE PROC;

          PROCEDURE PROC IS
               RESULTS : F;
          BEGIN
               P (RESULTS, F1);
               IF RESULTS = 0.0 THEN
                    FAILED ( "NO EXCEPTION RAISED WITH " &
                             "PROCEDURE 'P' AND PROCEDURE " &
                             "'PROC' - 1" );
               ELSE
                    FAILED ( "NO EXCEPTION RAISED WITH " &
                             "PROCEDURE 'P' AND PROCEDURE " &
                             "'PROC' - 2" );
               END IF;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED WITH " &
                             "PROCEDURE 'P' AND PROCEDURE " &
                             "'PROC'" );
          END PROC;

          PROCEDURE NPROC IS NEW PROC (FIXED2, 0.125);

     BEGIN
          NPROC;
     END;

     RESULT;

END CC1311B;
