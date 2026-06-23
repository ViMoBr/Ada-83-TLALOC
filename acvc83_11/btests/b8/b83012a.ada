-- B83012A.ADA

-- OBJECTIVE:
--     CHECK THAT WITHIN A SUBPROGRAM SPECIFICATION (APPEARING AS A
--     SUBPROGRAM DECLARATION, RENAMING DECLARATION, OR GENERIC FORMAL
--     SUBPROGRAM PARAMETER) NO DECLARATION OF THE DESIGNATOR OF THE
--     DECLARED SUBPROGRAM IS VISIBLE, EITHER DIRECTLY OR BY SELECTION.

-- HISTORY:
--     JET 07/14/88  CREATED ORIGINAL TEST.

PROCEDURE B83012A IS
BEGIN
     ----- AS SUBPROGRAM DECLARATIONS:
     DECLARE
          PACKAGE DPACK IS
               TYPE DFUNC1 IS RANGE -100 .. 100;
               TYPE DPROC1 IS NEW INTEGER;
               SUBTYPE PROC2 IS INTEGER;
               PROC8 : INTEGER;
               TYPE PROC9 IS NEW INTEGER;
          END DPACK;

          TYPE DREC IS RECORD
               DPROC2 : INTEGER;
               DPROC3 : INTEGER;
          END RECORD;

          DR : DREC;

          GENERIC
               DPROC5 : INTEGER := 0;
          PROCEDURE DPROC5G;

          PACKAGE DPROC6 IS
               TYPE T IS RANGE -100 .. 100;
          END DPROC6;

          FUNCTION DFUNC1 (I: INTEGER) RETURN DPACK.DFUNC1 IS
                                         -- ERROR: DFUNC1 NOT VISIBLE.
          BEGIN
               RETURN 0;
          END DFUNC1;

          PROCEDURE DPROC1 (I : DPACK.DPROC1) IS
                                        -- ERROR: DPROC1 NOT VISIBLE.
          BEGIN
               NULL;
          END DPROC1;

          PROCEDURE DPROC2 (I : INTEGER := DR.DPROC2) IS
                                        -- ERROR: DPROC2 NOT VISIBLE.
          BEGIN
               NULL;
          END DPROC2;

          PROCEDURE DPROC3 (R : DREC := (1, DPROC3 => 2)) IS
                                        -- ERROR: DPROC3 NOT VISIBLE.
          BEGIN
               NULL;
          END DPROC3;

          FUNCTION XPROC4 (DPROC4 : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END XPROC4;

          PROCEDURE DPROC4 (I : INTEGER := XPROC4(DPROC4 => 1)) IS
                                        -- ERROR: DPROC4 NOT VISIBLE.
          BEGIN
               NULL;
          END DPROC4;

          FUNCTION DFUNC2 (X,Y : INTEGER) RETURN INTEGER IS
               FUNCTION DFUNC2 (I : INTEGER := DFUNC2(0,1))
                    RETURN INTEGER IS
                                         -- ERROR: DFUNC2 NOT VISIBLE.
               BEGIN
                    RETURN X+Y;
               END DFUNC2;
          BEGIN
               RETURN 0;
          END DFUNC2;

          PROCEDURE DPROC5G IS
          BEGIN
               NULL;
          END DPROC5G;

          PROCEDURE DPROC5 IS NEW DPROC5G (DPROC5 => 1);
                                        -- ERROR: DPROC5 NOT VISIBLE.

          PACKAGE BODY DPROC6 IS
               PROCEDURE DPROC6 (I : DPROC6.T) IS
                                        -- ERROR: DPROC6 NOT VISIBLE.
               BEGIN
                    NULL;
               END DPROC6;
          END DPROC6;

     BEGIN
          NULL;
     END;

     ----- AS RENAMING DECLARATIONS:
     DECLARE
          PACKAGE RPACK IS
               TYPE RPROC1 IS NEW INTEGER;
               RPROC2 : INTEGER := 0;
               TYPE RFUNC1 IS RANGE -100 .. 100;
               PROCEDURE XPROC1 (I : RPROC1);
               PROCEDURE XPROC2 (I : INTEGER := RPROC2);
               FUNCTION XFUNC1 RETURN RFUNC1;
               FUNCTION XFUNC5 (RPROC5 : INTEGER) RETURN INTEGER;
          END RPACK;

          USE RPACK;

          TYPE RREC IS RECORD
               RPROC3 : INTEGER := 3;
               RPROC4 : INTEGER := 4;
          END RECORD;

          RR : RREC;

          PROCEDURE XPROC3 (I : INTEGER := RR.RPROC3);
          PROCEDURE XPROC4 (I : RREC := (1, RPROC4 => 2));
          PROCEDURE XPROC5 (I : INTEGER := RPACK.XFUNC5(RPROC5 => 0));

          PROCEDURE RPROC1 (I : RPACK.RPROC1) RENAMES RPACK.XPROC1;
                                         -- ERROR: RPROC1 NOT VISIBLE.

          PROCEDURE RPROC2 (I : INTEGER := RPROC2) RENAMES RPACK.XPROC2;
                                         -- ERROR: RPROC2 NOT VISIBLE.

          PROCEDURE RPROC3 (I : INTEGER := RR.RPROC3) RENAMES XPROC3;
                                         -- ERROR: RPROC3 NOT VISIBLE.

          PROCEDURE RPROC4 (I : RREC := (1, RPROC4 => 2))
               RENAMES XPROC4;
                                         -- ERROR: RPROC4 NOT VISIBLE.

          PROCEDURE RPROC5 (I : INTEGER := RPACK.XFUNC5(RPROC5 => 0))
               RENAMES XPROC5;
                                         -- ERROR: RPROC5 NOT VISIBLE.

          FUNCTION RFUNC1 RETURN RFUNC1 RENAMES RPACK.XFUNC1;
                                         -- ERROR: RFUNC1 NOT VISIBLE.

          PACKAGE RFUNC2 IS
               TYPE T IS RANGE -100 .. 100;
               FUNCTION XFUNC2 RETURN T;
               FUNCTION RFUNC2 RETURN RFUNC2.T RENAMES XFUNC2;
                                         -- ERROR: RFUNC2 NOT VISIBLE.
          END RFUNC2;

          FUNCTION "+" (L, R : INTEGER) RETURN INTEGER RENAMES "+";
                                         -- ERROR: "+" NOT VISIBLE.

          FUNCTION "-" (R : INTEGER) RETURN INTEGER RENAMES "-";
                                         -- ERROR: "-" NOT VISIBLE.

          PACKAGE BODY RFUNC2 IS
               FUNCTION XFUNC2 RETURN T IS
               BEGIN
                    RETURN 0;
               END XFUNC2;
          END RFUNC2;

          PACKAGE BODY RPACK IS
               PROCEDURE XPROC1 (I : RPROC1) IS
               BEGIN
                    NULL;
               END XPROC1;

               PROCEDURE XPROC2 (I : INTEGER := RPROC2) IS
               BEGIN
                    NULL;
               END XPROC2;

               FUNCTION XFUNC1 RETURN RFUNC1 IS
               BEGIN
                    RETURN 0;
               END XFUNC1;

               FUNCTION XFUNC5 (RPROC5 : INTEGER) RETURN INTEGER IS
               BEGIN
                    RETURN RPROC5;
               END XFUNC5;
          END RPACK;

          PROCEDURE XPROC3 (I : INTEGER := RR.RPROC3) IS
          BEGIN
               NULL;
          END XPROC3;

          PROCEDURE XPROC4 (I : RREC := (1, RPROC4 => 2)) IS
          BEGIN
               NULL;
          END XPROC4;

          PROCEDURE XPROC5 (I : INTEGER := RPACK.XFUNC5(RPROC5 => 0)) IS
          BEGIN
               NULL;
          END XPROC5;
     BEGIN
          NULL;
     END;

     ----- AS GENERIC FORMAL SUBPROGRAM PARAMETERS:
     DECLARE
          TYPE GPROC1 IS RANGE -100 .. 100;
          TYPE GPROC2 IS NEW INTEGER;

          PACKAGE GPACK IS
               SUBTYPE GPROC3 IS INTEGER;
          END GPACK;

          GPROC4 : INTEGER;

          TYPE GREC IS RECORD
               GPROC5 : INTEGER := 5;
               GPROC6 : INTEGER := 6;
          END RECORD;

          GR : GREC;

          FUNCTION XFUNC7 (GPROC7 : INTEGER) RETURN INTEGER;

          GENERIC
               WITH PROCEDURE GPROC1 (I : GPROC1);
                                        -- ERROR: GPROC1 NOT VISIBLE.
               WITH FUNCTION GPROC2 RETURN GPROC2;
                                        -- ERROR: GPROC2 NOT VISIBLE.
               WITH PROCEDURE GPROC3 (I : GPACK.GPROC3);
                                        -- ERROR: GPROC3 NOT VISIBLE.
               WITH PROCEDURE GPROC4 (I : INTEGER := GPROC4);
                                        -- ERROR: GPROC4 NOT VISIBLE.
               WITH PROCEDURE GPROC5 (I : INTEGER := GR.GPROC5);
                                        -- ERROR: GPROC5 NOT VISIBLE.
               WITH PROCEDURE GPROC6 (R : GREC := (1, GPROC6 => 2));
                                        -- ERROR: GPROC6 NOT VISIBLE.
               WITH PROCEDURE GPROC7 (I : INTEGER :=
                                                XFUNC7(GPROC7 => 0));
                                        -- ERROR: GPROC7 NOT VISIBLE.
          PROCEDURE GEN_PROC;

          PACKAGE GPROC8 IS
               TYPE T IS NEW INTEGER;
               GENERIC
                    WITH PROCEDURE GPROC8 (I : GPROC8.T);
                                        -- ERROR: GPROC8 NOT VISIBLE.
               PROCEDURE XPROC8;
          END GPROC8;

          PACKAGE BODY GPROC8 IS
               PROCEDURE XPROC8 IS
               BEGIN
                    NULL;
               END XPROC8;
          END GPROC8;

          FUNCTION XFUNC7 (GPROC7 : INTEGER) RETURN INTEGER IS
          BEGIN
               RETURN 0;
          END XFUNC7;

          PROCEDURE GEN_PROC IS
          BEGIN
               NULL;
          END GEN_PROC;

     BEGIN
          NULL;
     END;
END B83012A;
