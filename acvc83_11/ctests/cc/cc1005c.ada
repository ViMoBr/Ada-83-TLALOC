-- CC1005C.ADA

-- OBJECTIVE:
--     CHECK THAT A GENERIC UNIT'S IDENTIFIER CAN BE USED IN ITS FORMAL
--     PART AS A SELECTOR TO DENOTE A COMPONENT OF A RECORD OBJECT, AS
--     THE NAME OF A RECORD OR DISCRIMINANT COMPONENT IN A RECORD
--     AGGREGATE, AND AS THE NAME OF A FORMAL PARAMETER IN A FUNCTION
--     CALL.

-- HISTORY:
--     BCB 08/03/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;

PROCEDURE CC1005C IS

     FUNCTION F (P : INTEGER) RETURN INTEGER IS
     BEGIN
          RETURN P;
     END F;

BEGIN
     TEST ("CC1005C", "CHECK THAT A GENERIC UNIT'S IDENTIFIER CAN BE " &
                      "USED IN ITS FORMAL PART AS A SELECTOR TO " &
                      "DENOTE A COMPONENT OF A RECORD OBJECT, AS THE " &
                      "NAME OF A RECORD OR DISCRIMINANT COMPONENT IN " &
                      "A RECORD AGGREGATE, AND AS THE NAME OF A " &
                      "FORMAL PARAMETER IN A FUNCTION CALL");

     BLOCK1:
        DECLARE
             TYPE REC IS RECORD
                  P : INTEGER := IDENT_INT(0);
             END RECORD;

             TYPE REC2 (P : INTEGER) IS RECORD
                  NULL;
             END RECORD;

             R : REC;
             S : REC2(5);

             J : INTEGER;

             GENERIC
                  V : INTEGER := R.P;
                  W : INTEGER := S.P;
                  X : REC := (P => IDENT_INT(10));
                  Y : REC2 := (P => IDENT_INT(15));
                  Z : INTEGER := F(P => IDENT_INT(20));
             FUNCTION P RETURN INTEGER;

             FUNCTION P RETURN INTEGER IS
             BEGIN
                  IF NOT EQUAL(V,0) THEN
                       FAILED ("WRONG VALUE OF P USED IN ASSIGNMENT " &
                               "OF V");
                  END IF;

                  IF NOT EQUAL(W,5) THEN
                       FAILED ("WRONG VALUE OF P USED IN ASSIGNMENT " &
                               "OF W");
                  END IF;

                  IF NOT EQUAL(X.P,10) THEN
                       FAILED ("WRONG VALUE USED IN ASSIGNMENT OF X.P");
                  END IF;

                  IF NOT EQUAL(Y.P,15) THEN
                       FAILED ("WRONG VALUE USED IN ASSIGNMENT OF Y.P");
                  END IF;

                  IF NOT EQUAL(Z,20) THEN
                       FAILED ("WRONG VALUE OF P USED IN ASSIGNMENT " &
                               "OF Z");
                  END IF;

                  RETURN 0;
             END P;

             FUNCTION NEW_P IS NEW P;
        BEGIN
             J := NEW_P;
        END BLOCK1;

     RESULT;
END CC1005C;
