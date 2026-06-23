-- C36004A.ADA

-- CHECK THAT THE INDEX SUBTYPE OF AN ARRAY IS CORRECTLY DETERMINED
-- FOR CONSTRAINED AND UNCONSTRAINED ARRAY TYPES.

-- L.BROWN  7/24/86

WITH REPORT; USE REPORT;

PROCEDURE C36004A IS

BEGIN
     TEST("C36004A", "INDEX SUBTYPE IS CORRECTLY DETERMINED " &
          "OR NOT FOR CONSTRAINED AND UNCONSTRAINED ARRAY TYPES");

     DECLARE
          TYPE A IS ARRAY(INTEGER RANGE <>) OF INTEGER;
          SUBTYPE A0 IS A(1 .. 3);
          SUBTYPE AR1_3 IS INTEGER RANGE 1 .. 3;
          TYPE A1 IS ARRAY(1 .. 3) OF INTEGER;
          TYPE A2 IS ARRAY(INTEGER RANGE 1 .. 3) OF INTEGER;
          TYPE A3 IS ARRAY(AR1_3 RANGE <>) OF INTEGER;
          TYPE A4 IS ARRAY(A0'RANGE) OF INTEGER;

          OBJ_A1 : A1;
          OBJ_A2 : A2;
          OBJ_A3 : A3(1 .. 3);
          OBJ_A4 : A4;
     BEGIN
          BEGIN
               OBJ_A1 := (2 .. 4 => 0);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE A1 WITH INTEGER INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE A1 WITH AN INTEGER " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_A2 := (0 .. 2 => 0);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE A2 WITH INTEGER INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE A2 WITH AN INTEGER " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_A3 := (2 .. 4 => 0);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE A3 WITH INTEGER INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE A3 WITH AN INTEGER " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_A4 := (0 .. 2 => 0);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE A4 WITH INTEGER INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE A4 WITH AN INTEGER " &
                           "INDEX TYPE");
          END;
     END;
     DECLARE
          TYPE ENUM IS ('A','B','C','D','E',OFF,ON,'X','Y','Z');
          TYPE B IS ARRAY(ENUM RANGE <>) OF BOOLEAN;
          SUBTYPE B0 IS B('B' .. 'D');
          SUBTYPE BRA_D IS ENUM RANGE 'B' .. 'D';
          TYPE B1 IS ARRAY (ENUM'('B') .. ENUM'('D')) OF BOOLEAN;
          TYPE B2 IS ARRAY(ENUM RANGE 'B' .. 'D') OF BOOLEAN;
          TYPE B3 IS ARRAY(BRA_D RANGE <>) OF BOOLEAN;
          TYPE B4 IS ARRAY(B0'RANGE) OF BOOLEAN;

          OBJ_B1 : B1;
          OBJ_B2 : B2;
          OBJ_B3 : B3('B' .. 'D');
          OBJ_B4 : B4;
     BEGIN
          BEGIN
               OBJ_B1 := ('C' .. 'E' => TRUE);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE B1 WITH ENUM INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE B1 WITH AN ENUM " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_B2 := ('A' .. 'C' => FALSE);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE B2 WITH ENUM INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE B2 WITH AN ENUM " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_B3 := ('C' .. 'E' => TRUE);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE B3 WITH ENUM INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE B3 WITH AN ENUM " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_B4 := ('A' .. 'C' => FALSE);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE B4 WITH ENUM INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE B4 WITH AN ENUM " &
                           "INDEX TYPE");
          END;
     END;
     DECLARE
          TYPE NCHR IS NEW CHARACTER;
          TYPE C IS ARRAY(NCHR RANGE <>) OF INTEGER;
          SUBTYPE C0 IS C('B' .. 'E');
          SUBTYPE CR1_4 IS NCHR RANGE 'B' .. 'E';
          TYPE C1 IS ARRAY(NCHR'('B') .. NCHR'('E')) OF INTEGER;
          TYPE C2 IS ARRAY(NCHR RANGE 'B' .. 'E') OF INTEGER;
          TYPE C3 IS ARRAY(CR1_4 RANGE <>) OF INTEGER;
          TYPE C4 IS ARRAY(C0'RANGE) OF INTEGER;

          OBJ_C1 : C1;
          OBJ_C2 : C2;
          OBJ_C3 : C3('B' .. 'E');
          OBJ_C4 : C4;
     BEGIN
          BEGIN
               OBJ_C1 := ('C' .. 'F' => 0);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE C1 WITH NCHR INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE C1 WITH AN NCHR " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_C2 := ('A' .. 'D' => 0);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE C2 WITH NCHR INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE C2 WITH AN NCHR " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_C3 := ('C' .. 'F' => 0);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE C3 WITH NCHR INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE C3 WITH AN NCHR " &
                           "INDEX TYPE");
          END;
          BEGIN
               OBJ_C4 := ('A' .. 'D' => 0);
               FAILED("INDEX SUBTYPE INCORRECTLY DETERMINED - " &
                      "TYPE C4 WITH NCHR INDEX TYPE");
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED("EXCEPTION OTHER THAN CONSTRAINT_ERROR " &
                           "RAISED FOR TYPE C4 WITH AN NCHR " &
                           "INDEX TYPE");
          END;
     END;

     RESULT;

END C36004A;
