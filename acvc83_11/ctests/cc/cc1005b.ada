-- CC1005B.ADA

-- OBJECTIVE:
--     CHECK THAT A GENERIC UNIT'S IDENTIFIER CAN BE USED IN ITS
--     FORMAL PART AS THE SELECTOR IN AN EXPANDED NAME TO DENOTE AN
--     ENTITY IN THE VISIBLE PART OF A PACKAGE, OR TO DENOTE AN ENTITY
--     IMMEDIATELY ENCLOSED IN A CONSTRUCT OTHER THAN THE CONSTRUCT
--     IMMEDIATELY ENCLOSING THE GENERIC UNIT.

-- HISTORY:
--     BCB 08/03/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE CC1005B IS

     S : INTEGER := IDENT_INT(0);

     PACKAGE CC1005B IS
          I : INTEGER;
          S : INTEGER := IDENT_INT(5);
          GENERIC
               S : INTEGER := IDENT_INT(10);
               V : INTEGER := STANDARD.CC1005B.S;
               W : INTEGER := STANDARD.CC1005B.CC1005B.S;
          FUNCTION CC1005B RETURN INTEGER;
     END CC1005B;

     PACKAGE BODY CC1005B IS
          FUNCTION CC1005B RETURN INTEGER IS
          BEGIN
               IF NOT EQUAL(V,0) THEN
                    FAILED ("WRONG VALUE OF S USED IN ASSIGNMENT OF V");
               END IF;

               IF NOT EQUAL(W,5) THEN
                    FAILED ("WRONG VALUE OF S USED IN ASSIGNMENT OF W");
               END IF;

               RETURN 0;
          END CC1005B;

          FUNCTION NEW_CC IS NEW CC1005B;
     BEGIN
          TEST ("CC1005B", "CHECK THAT A GENERIC UNIT'S IDENTIFIER " &
                           "CAN BE USED IN ITS FORMAL PART AS THE " &
                           "SELECTOR IN AN EXPANDED NAME TO DENOTE " &
                           "AN ENTITY IN THE VISIBLE PART OF A " &
                           "PACKAGE, OR TO DENOTE AN ENTITY " &
                           "IMMEDIATELY ENCLOSED IN A CONSTRUCT " &
                           "OTHER THAN THE CONSTRUCT IMMEDIATELY " &
                           "ENCLOSING THE GENERIC UNIT");

          I := NEW_CC;
     END CC1005B;

BEGIN
     BLOCK1:
        DECLARE
             PACKAGE P IS
                  T : INTEGER := IDENT_INT(0);
                  PACKAGE P IS
                       J : INTEGER;
                       T : INTEGER := IDENT_INT(5);
                       GENERIC
                            T : INTEGER := IDENT_INT(10);
                            X : INTEGER := BLOCK1.P.T;
                            Y : INTEGER := BLOCK1.P.P.T;
                       FUNCTION P RETURN INTEGER;
                  END P;
             END P;

             PACKAGE BODY P IS
                  PACKAGE BODY P IS
                       FUNCTION P RETURN INTEGER IS
                       BEGIN
                            IF NOT EQUAL(X,0) THEN
                                 FAILED ("WRONG VALUE OF T USED IN " &
                                         "ASSIGNMENT OF X");
                            END IF;

                            IF NOT EQUAL(Y,5) THEN
                                 FAILED ("WRONG VALUE OF T USED IN " &
                                         "ASSIGNMENT OF Y");
                            END IF;

                            RETURN 0;
                       END P;

                       FUNCTION NEW_P IS NEW P;
                  BEGIN
                       J := NEW_P;
                  END P;
             END P;

             BEGIN
                  NULL;
             END BLOCK1;

     RESULT;
END CC1005B;
