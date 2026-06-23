-- C34012A.ADA

-- OBJECTIVE:
--     CHECK THAT DEFAULT EXPRESSIONS IN DERIVED RECORD TYPES AND
--     DERIVED SUBPROGRAMS ARE EVALUATED USING THE ENTITIES DENOTED BY
--     THE EXPRESSIONS IN THE PARENT TYPE.

-- HISTORY:
--     RJW 06/19/86  CREATED ORIGINAL TEST.
--     BCB 08/19/87  CHANGED HEADER TO STANDARD HEADER FORMAT.  CHANGED
--                   PACKAGE B SO WOULD HAVE ONE CASE WHERE DEFAULT IS
--                   DECLARED BEFORE THE DERIVED TYPE DECLARATION.

WITH REPORT; USE REPORT;

PROCEDURE C34012A IS

BEGIN
     TEST ("C34012A", "CHECK THAT DEFAULT EXPRESSIONS IN DERIVED " &
                      "RECORD TYPES AND DERIVED SUBPROGRAMS ARE " &
                      "EVALUATED USING THE ENTITIES DENOTED BY THE " &
                      "EXPRESSIONS IN THE PARENT TYPE" );

     DECLARE
          PACKAGE P IS
               X : INTEGER := 5;
               TYPE REC IS
                    RECORD
                         C : INTEGER := X;
                    END RECORD;
          END P;

          PACKAGE Q IS
               X : INTEGER := 6;
               TYPE NEW_REC IS NEW P.REC;
               QVAR : NEW_REC;
          END Q;

          PACKAGE R IS
               X : INTEGER := 7;
               TYPE BRAND_NEW_REC IS NEW Q.NEW_REC;
               RVAR : BRAND_NEW_REC;
          END R;

          USE Q;
          USE R;
     BEGIN
          IF QVAR.C = 5 THEN
               NULL;
          ELSE
               FAILED ( "INCORRECT VALUE FOR QVAR" );
          END IF;

          IF RVAR.C = 5 THEN
               NULL;
          ELSE
               FAILED ( "INCORRECT VALUE FOR RVAR" );
          END IF;
     END;

     DECLARE
          PACKAGE A IS
               TYPE T IS RANGE 1 .. 10;
               DEFAULT : T := 5;
               FUNCTION F (X : T := DEFAULT) RETURN T;
          END A;

          PACKAGE BODY A IS
               FUNCTION F (X : T := DEFAULT) RETURN T IS
               BEGIN
                    RETURN X;
               END F;
          END A;

          PACKAGE B IS
               DEFAULT : A.T:= 6;
               TYPE NEW_T IS NEW A.T;
               BVAR : NEW_T := F;
          END B;

          PACKAGE C IS
               TYPE BRAND_NEW_T IS NEW B.NEW_T;
               DEFAULT : BRAND_NEW_T := 7;
               CVAR : BRAND_NEW_T :=F;
          END C;

          USE B;
          USE C;
     BEGIN
          IF BVAR = 5 THEN
               NULL;
          ELSE
               FAILED ( "INCORRECT VALUE FOR BVAR" );
          END IF;

          IF CVAR = 5 THEN
               NULL;
          ELSE
               FAILED ( "INCORRECT VALUE FOR CVAR" );
          END IF;

          DECLARE
               VAR : BRAND_NEW_T := F;
          BEGIN
               IF VAR = 5 THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT VALUE FOR VAR" );
               END IF;
          END;
     END;

     RESULT;
END C34012A;
