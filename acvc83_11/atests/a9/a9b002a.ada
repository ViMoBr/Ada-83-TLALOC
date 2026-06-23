-- A9B002A.ADA

-- OBJECTIVE:
--     CHECK THAT IF A "SHARED" PRAGMA NAMES A VARIABLE (OR A SUBCOM-
--     PONENT OF A VARIABLE) DESIGNATED BY AN ACCESS VALUE, OR DENOTED
--     BY A FORMAL PARAMETER OF A SUBPROGRAM OR GENERIC UNIT, THE PRAGMA
--     IS ACCEPTED; I.E., THE PROGRAM IS NOT REJECTED.

-- HISTORY:
--     DHH 03/28/88 CREATED ORIGINAL TEST.
--     PWB 05/19/89 REVISED OBJECTIVE STATEMENT TO CLARIFY EXPECTATION.
WITH REPORT; USE REPORT;
PROCEDURE A9B002A IS

     SUBTYPE INT IS INTEGER RANGE 0 .. INTEGER'LAST;
     TYPE Y IS ACCESS INT;

     X : Y;

     PRAGMA SHARED(X.ALL);           -- MUST BE ACCEPTED
                                     -- (BUT SHOULD BE IGNORED)
     TYPE REC IS
          RECORD
               A : INT;
               B : Y;
          END RECORD;
     TYPE PTR IS ACCESS REC;

     U : PTR;

     PRAGMA SHARED(U.A);                          -- SHOULD BE IGNORED.

     TASK TYPE CHOICE IS
          ENTRY E1;
     END CHOICE;

     T : CHOICE;

     PROCEDURE CHECK(C : IN OUT INT) IS
          PRAGMA SHARED(C);                       -- SHOULD BE IGNORED.
     BEGIN
          IF EQUAL(3,3) THEN
               C := C + 1;
          END IF;
     END CHECK;

     PACKAGE PACK IS
     GENERIC
          PROCEDURE LEFT(D : IN OUT INT);
     END PACK;

     PACKAGE BODY PACK IS
          PROCEDURE LEFT(D : IN OUT INT) IS
               PRAGMA SHARED(D);                 -- SHOULD BE IGNORED.
          BEGIN
               IF EQUAL(3,3) THEN
                    D := D-1;
               END IF;
          END LEFT;
     END PACK;
     USE PACK;

     TASK BODY CHOICE IS
     BEGIN
          ACCEPT E1 DO
               X := NEW INT;
               X.ALL := IDENT_INT(3);
               U := NEW REC;
               U.A := IDENT_INT(4);
               CHECK(U.A);

          END E1;
     END CHOICE;

BEGIN

     TEST("A9B002A", "CHECK THAT IF A ""SHARED"" PRAGMA NAMES A " &
                     "VARIABLE (OR A SUBCOMPONENT OF A VARIABLE) " &
                     "DESIGNATED BY AN ACCESS VALUE, OR DENOTED " &
                     "BY A FORMAL PARAMETER OF A SUBPROGRAM OR " &
                     "GENERIC UNIT, THE PROGRAM IS STILL LEGAL");

     T.E1;

     RESULT;

END A9B002A;
