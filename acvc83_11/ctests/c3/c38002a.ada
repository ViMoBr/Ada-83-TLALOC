-- C38002A.ADA

-- OBJECTIVE:
--     CHECK THAT AN UNCONSTRAINED ARRAY TYPE OR A RECORD WITHOUT
--     DEFAULT DISCRIMINANTS CAN BE USED IN AN ACCESS_TYPE_DEFINITION
--     WITHOUT AN INDEX OR DISCRIMINANT CONSTRAINT.
--
--     CHECK THAT (NON-STATIC) INDEX OR DISCRIMINANT CONSTRAINTS CAN
--     SUBSEQUENTLY BE IMPOSED WHEN THE TYPE IS USED IN AN OBJECT
--     DECLARATION, ARRAY COMPONENT DECLARATION, RECORD COMPONENT
--     DECLARATION, ACCESS TYPE DECLARATION, PARAMETER DECLARATION,
--     DERIVED TYPE DEFINITION, PRIVATE TYPE, OR AS THE RETURN TYPE
--     IN A FUNCTION DECLARATION.
--
--     CHECK FOR UNCONSTRAINED GENERIC FORMAL TYPE.

-- HISTORY:
--     AH  09/02/86 CREATED ORIGINAL TEST.
--     DHH 08/16/88 REVISED HEADER AND ENTERED COMMENTS FOR PRIVATE TYPE
--                  AND CORRECTED INDENTATION.

WITH REPORT; USE REPORT;
PROCEDURE C38002A IS

BEGIN
     TEST ("C38002A", "NON-STATIC CONSTRAINTS CAN BE IMPOSED " &
           "ON ACCESS TYPES ACCESSING PREVIOUSLY UNCONSTRAINED " &
           "ARRAY OR RECORD TYPES");

     DECLARE
          C3 : CONSTANT INTEGER := IDENT_INT(3);

          TYPE ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;
          TYPE ARR_NAME IS ACCESS ARR;

          TYPE REC(DISC : INTEGER) IS
               RECORD
                    COMP : ARR_NAME(1..DISC);
               END RECORD;
          TYPE REC_NAME IS ACCESS REC;

          OBJ : REC_NAME(C3);
          R : REC_NAME;

          TYPE ARR2 IS ARRAY (1..10) OF REC_NAME(C3);

          TYPE REC2 IS
               RECORD
                    COMP2 : REC_NAME(C3);
               END RECORD;

          TYPE NAME_REC_NAME IS ACCESS REC_NAME(C3);

          TYPE DERIV IS NEW REC_NAME(C3);
          SUBTYPE REC_NAME_3 IS REC_NAME(C3);

          FUNCTION F (PARM : REC_NAME_3) RETURN REC_NAME_3 IS
               BEGIN
                    RETURN PARM;
               END;

     BEGIN
          R := NEW REC'(DISC => 3, COMP => NEW ARR'(1..3 => 5));
          R := F(R);
          R := NEW REC'(DISC => 4, COMP => NEW ARR'(1..4 => 5));
          R := F(R);
          FAILED ("INCOMPATIBLE CONSTRAINT ON ACCESS VALUE ACCEPTED " &
                  "BY FUNCTION");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF R = NULL OR ELSE R.DISC /= 4 THEN
                    FAILED (" ERROR IN EVALUATION/ASSIGNMENT OF " &
                            "ACCESS VALUE");
               END IF;
     END;

     DECLARE
          C3 : CONSTANT INTEGER := IDENT_INT(3);

          TYPE REC (DISC : INTEGER) IS
               RECORD
                    NULL;
               END RECORD;

          TYPE P_ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;
          TYPE P_ARR_NAME IS ACCESS P_ARR;

          TYPE P_REC_NAME IS ACCESS REC;

          GENERIC
               TYPE UNCON_ARR IS ARRAY (INTEGER RANGE <>) OF INTEGER;
          PACKAGE P IS
               TYPE ACC_REC IS ACCESS REC;
               TYPE ACC_ARR IS ACCESS UNCON_ARR;
               OBJ : ACC_REC(C3);

               TYPE ARR2 IS ARRAY (1..10) OF ACC_REC(C3);

               TYPE REC1 IS
                    RECORD
                         COMP1 : ACC_REC(C3);
                    END RECORD;

               TYPE REC2 IS
                    RECORD
                         COMP2 : ACC_ARR(1..C3);
                    END RECORD;

               SUBTYPE ACC_REC_3 IS ACC_REC(C3);
               R : ACC_REC;

               FUNCTION F (PARM : ACC_REC_3) RETURN ACC_REC_3;

               TYPE ACC1 IS PRIVATE;
               TYPE ACC2 IS PRIVATE;
               TYPE DER1 IS PRIVATE;
               TYPE DER2 IS PRIVATE;

          PRIVATE

               TYPE ACC1 IS ACCESS ACC_REC(C3);
               TYPE ACC2 IS ACCESS ACC_ARR(1..C3);
               TYPE DER1 IS NEW ACC_REC(C3);
               TYPE DER2 IS NEW ACC_ARR(1..C3);
          END P;

          PACKAGE BODY P IS
               FUNCTION F (PARM : ACC_REC_3) RETURN ACC_REC_3 IS
               BEGIN
                    RETURN PARM;
               END;
          END P;

          PACKAGE NP IS NEW P (UNCON_ARR => P_ARR);

          USE NP;
     BEGIN
          R := NEW REC(DISC => 3);
          R := F(R);
          R := NEW REC(DISC => 4);
          R := F(R);
          FAILED ("INCOMPATIBLE CONSTRAINT ON ACCESS VALUE ACCEPTED " &
                  "BY GENERIC FUNCTION");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF R = NULL OR ELSE R.DISC /= 4 THEN
                    FAILED (" ERROR IN EVALUATION/ASSIGNMENT OF " &
                            "GENERIC ACCESS VALUE");
               END IF;
     END;

     RESULT;
END C38002A;
