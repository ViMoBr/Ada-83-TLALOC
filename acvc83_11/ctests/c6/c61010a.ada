-- C61010A.ADA

-- CHECK THAT AN IN OR IN OUT FORMAL PARAMETER CAN BE DECLARED WITH A
-- LIMITED PRIVATE TYPE OR A LIMITED COMPOSITE TYPE.

-- DAS  1/22/81
-- JRK  1/20/84  TOTALLY REVISED.

WITH REPORT; USE REPORT;
PROCEDURE C61010A IS

     PACKAGE PKG IS

          TYPE ITYPE IS LIMITED PRIVATE;

          PROCEDURE LOOK_IN_I (X : IN ITYPE; V : INTEGER; M : STRING);

          PROCEDURE LOOK_INOUT_I (X : IN OUT ITYPE; V : INTEGER;
                                  M : STRING);

          PROCEDURE SET_I (X : IN OUT ITYPE; V : INTEGER);

          SUBTYPE INT_0_20 IS INTEGER RANGE 0 .. 20;
          TYPE VRTYPE (C : INT_0_20 := 20) IS LIMITED PRIVATE;

          PROCEDURE LOOK_IN_VR (X : IN VRTYPE; C : INTEGER; I : INTEGER;
                                S : STRING; M : STRING);

          PROCEDURE LOOK_INOUT_VR (X : IN OUT VRTYPE; C : INTEGER;
                                   I : INTEGER; S : STRING;
                                   M : STRING);

          PROCEDURE SET_VR (X : IN OUT VRTYPE; C : INTEGER; I : INTEGER;
                            S : STRING);

     PRIVATE

          TYPE ITYPE IS NEW INTEGER RANGE 0 .. 99;

          TYPE VRTYPE (C : INT_0_20 := 20) IS
               RECORD
                    I : INTEGER;
                    S : STRING (1 .. C);
               END RECORD;

     END PKG;

     USE PKG;

     I1 : ITYPE;

     TYPE ATYPE IS ARRAY (1 .. 3) OF ITYPE;

     A1 : ATYPE;

     VR1 : VRTYPE;

     D : CONSTANT INT_0_20 := 10;

     TYPE RTYPE IS
          RECORD
               J : ITYPE;
               R : VRTYPE (D);
          END RECORD;

     R1 : RTYPE;

     PACKAGE BODY PKG IS

          PROCEDURE LOOK_IN_I (X : IN ITYPE; V : INTEGER; M : STRING) IS
          BEGIN
               IF INTEGER (X) /= V THEN
                    FAILED ("WRONG SCALAR VALUE - " & M);
               END IF;
          END LOOK_IN_I;

          PROCEDURE LOOK_INOUT_I (X : IN OUT ITYPE; V : INTEGER;
                                  M : STRING) IS
          BEGIN
               IF INTEGER (X) /= V THEN
                    FAILED ("WRONG SCALAR VALUE - " & M);
               END IF;
          END LOOK_INOUT_I;

          PROCEDURE SET_I (X : IN OUT ITYPE; V : INTEGER) IS
          BEGIN
               X := ITYPE (IDENT_INT (V));
          END SET_I;

          PROCEDURE LOOK_IN_VR (X : IN VRTYPE; C : INTEGER; I : INTEGER;
                                S : STRING; M : STRING) IS
          BEGIN
               IF (X.C /= C OR X.I /= I) OR ELSE X.S /= S THEN
                    FAILED ("WRONG COMPOSITE VALUE - " & M);
               END IF;
          END LOOK_IN_VR;

          PROCEDURE LOOK_INOUT_VR (X : IN OUT VRTYPE; C : INTEGER;
                                   I : INTEGER; S : STRING;
                                   M : STRING) IS
          BEGIN
               IF (X.C /= C OR X.I /= I) OR ELSE X.S /= S THEN
                    FAILED ("WRONG COMPOSITE VALUE - " & M);
               END IF;
          END LOOK_INOUT_VR;

          PROCEDURE SET_VR (X : IN OUT VRTYPE; C : INTEGER; I : INTEGER;
                            S : STRING) IS
          BEGIN
               X := (IDENT_INT(C), IDENT_INT(I), IDENT_STR(S));
          END SET_VR;

     BEGIN
          I1 := ITYPE (IDENT_INT(2));

          FOR I IN A1'RANGE LOOP
               A1 (I) := ITYPE (3 + IDENT_INT(I));
          END LOOP;

          VR1 := (IDENT_INT(5), IDENT_INT(4), IDENT_STR("01234"));

          R1.J := ITYPE (IDENT_INT(6));
          R1.R := (IDENT_INT(D), IDENT_INT(19),
                   IDENT_STR("ABCDEFGHIJ"));
     END PKG;

     PROCEDURE CHECK_IN_I (X : IN ITYPE; V : INTEGER; M : STRING) IS
     BEGIN
          LOOK_IN_I (X, V, M);
     END CHECK_IN_I;

     PROCEDURE CHECK_INOUT_I (X : IN OUT ITYPE; OV : INTEGER;
                              NV : INTEGER; M : STRING) IS
     BEGIN
          LOOK_INOUT_I (X, OV, M & " - A");
          SET_I (X, NV);
          LOOK_INOUT_I (X, NV, M & " - B");
          LOOK_IN_I (X, NV, M & " - C");
     END CHECK_INOUT_I;

     PROCEDURE CHECK_IN_A (X : IN ATYPE; V : INTEGER; M : STRING) IS
     BEGIN
          FOR I IN X'RANGE LOOP
               LOOK_IN_I (X(I), V+I, M & " -" & INTEGER'IMAGE (I));
          END LOOP;
     END CHECK_IN_A;

     PROCEDURE CHECK_INOUT_A (X : IN OUT ATYPE; OV : INTEGER;
                              NV : INTEGER; M : STRING) IS
     BEGIN
          FOR I IN X'RANGE LOOP
               LOOK_INOUT_I (X(I), OV+I, M & " - A" &
                                         INTEGER'IMAGE (I));
               SET_I (X(I), NV+I);
               LOOK_INOUT_I (X(I), NV+I, M & " - B" &
                                         INTEGER'IMAGE (I));
               LOOK_IN_I (X(I), NV+I, M & " - C" & INTEGER'IMAGE (I));
          END LOOP;
     END CHECK_INOUT_A;

     PROCEDURE CHECK_IN_VR (X : IN VRTYPE; C : INTEGER; I : INTEGER;
                            S : STRING; M : STRING) IS
     BEGIN
          LOOK_IN_VR (X, C, I, S, M);
     END CHECK_IN_VR;

     PROCEDURE CHECK_INOUT_VR (X : IN OUT VRTYPE;
                               OC : INTEGER; OI : INTEGER; OS : STRING;
                               NC : INTEGER; NI : INTEGER; NS : STRING;
                               M : STRING) IS
     BEGIN
          LOOK_INOUT_VR (X, OC, OI, OS, M & " - A");
          SET_VR (X, NC, NI, NS);
          LOOK_INOUT_VR (X, NC, NI, NS, M & " - B");
          LOOK_IN_VR (X, NC, NI, NS, M & " - C");
     END CHECK_INOUT_VR;

     PROCEDURE CHECK_IN_R (X : IN RTYPE; J : INTEGER; C : INTEGER;
                           I : INTEGER; S : STRING; M : STRING) IS
     BEGIN
          LOOK_IN_I (X.J, J, M & " - A");
          LOOK_IN_VR (X.R, C, I, S, M & " - B");
     END CHECK_IN_R;

     PROCEDURE CHECK_INOUT_R (X : IN OUT RTYPE; OJ : INTEGER;
                              OC : INTEGER; OI : INTEGER; OS : STRING;
                              NJ : INTEGER;
                              NC : INTEGER; NI : INTEGER; NS : STRING;
                              M : STRING) IS
     BEGIN
          LOOK_INOUT_I (X.J, OJ, M & " - A");
          LOOK_INOUT_VR (X.R, OC, OI, OS, M & " - B");
          SET_I (X.J, NJ);
          SET_VR (X.R, NC, NI, NS);
          LOOK_INOUT_I (X.J, NJ, M & " - C");
          LOOK_INOUT_VR (X.R, NC, NI, NS, M & " - D");
          LOOK_IN_I (X.J, NJ, M & " - E");
          LOOK_IN_VR (X.R, NC, NI, NS, M & " - F");
     END CHECK_INOUT_R;

BEGIN
     TEST ("C61010A", "CHECK THAT LIMITED PRIVATE/COMPOSITE TYPES " &
                      "CAN BE USED AS IN OR IN OUT FORMAL PARAMETERS");

     CHECK_IN_I (I1, 2, "IN I");

     CHECK_INOUT_I (I1, 2, 5, "INOUT I");

     CHECK_IN_A (A1, 3, "IN A");

     CHECK_INOUT_A (A1, 3, 17, "INOUT A");

     CHECK_IN_VR (VR1, 5, 4, "01234", "IN VR");

     CHECK_INOUT_VR (VR1, 5, 4, "01234", 10, 11, "9876543210",
                     "INOUT VR");

     CHECK_IN_R (R1, 6, D, 19, "ABCDEFGHIJ", "IN R");

     CHECK_INOUT_R (R1, 6, D, 19, "ABCDEFGHIJ", 13, D, 5, "ZYXWVUTSRQ",
                    "INOUT R");

     RESULT;
END C61010A;
