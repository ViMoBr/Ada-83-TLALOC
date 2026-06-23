-- C34016B-B.ADA

-- CHECK THAT IF TWO PRIVATE TYPES ARE DECLARED IN THE SAME PACKAGE,
-- DERIVATIONS OF THE FIRST WITHIN THE PRIVATE PART INHERIT JUST THOSE
-- OPERATORS OR SUBPROGRAMS THAT ARE DECLARED IN THE VISIBLE PART.

-- DAT 4/6/81
-- SPS 12/13/82
-- VKG 1/6/83
-- JRK 2/2/83
-- JBG 9/22/83

WITH REPORT; USE REPORT;

PROCEDURE C34016B IS
BEGIN
     TEST ("C34016B", "ONLY SUBPROGRAMS IN THE VISIBLE PART ARE " &
                      "DERIVED");

     DECLARE
          PACKAGE P IS
               TYPE T1 IS PRIVATE;
               CT1 : CONSTANT T1;
               FUNCTION "-" (X : T1) RETURN T1;
               FUNCTION F1 (CX : T1) RETURN T1;
               TYPE T2 IS PRIVATE;
          PRIVATE
               FUNCTION "*" (L, R : T1) RETURN T1;
               TYPE REC1 IS
                    RECORD
                         A : T1 := -CT1;
                         B : T1 := F1(CT1);
                         C : T1 := CT1 * CT1;
                    END RECORD;
               TYPE T1 IS RANGE -10 .. 20;
               -- PREDEFINED "-" AND "*" HIDDEN BY EARLIER EXPLICIT "-"
               --    AND "*"
               CT1 : CONSTANT T1 := T1(IDENT_INT(3));

               TYPE T2 IS NEW T1;      -- DERIVES "-" AND F1
               -- REDEFINED "*" FOR T1 IS NOT DERIVED
               TYPE REC2 IS
                    RECORD
                         A : T2 := -3;                    -- DERIVED "-"
                         B : T2 := F1(3);
                         C : T2 := T2(IDENT_INT(3)) * 3;  -- PREDEF "*"
                    END RECORD;

          END P;

          PACKAGE BODY P IS

               FUNCTION "-" (X : T1) RETURN T1 IS
               BEGIN
                    RETURN T1(IDENT_INT(INTEGER(X)));
               END "-";

               FUNCTION F1 (CX : T1) RETURN T1 IS
               BEGIN
                    RETURN T1(IDENT_INT(INTEGER(CX)));
               END F1;

               FUNCTION "*" (L, R : T1) RETURN T1 IS
               BEGIN
                    RETURN T1(6 * INTEGER(L));
               END "*";

               PACKAGE VARS IS
                    XREC1 : REC1;
                    XREC2 : REC2;
               END VARS;
               USE VARS;

          BEGIN
               IF XREC2.A /= 3 THEN
                    FAILED ("DID NOT DERIVE ""-""");
               END IF;

               IF XREC2.B /= 3 THEN
                    FAILED ("DID NOT DERIVE F1");
               END IF;

               IF XREC2.C /= 9 THEN
                    FAILED ("DID NOT GET PREDEFINED ""*""");
               END IF;

               IF XREC1.A /= 3 THEN
                    FAILED ("NOT USING REDECLARED ""-""");
               END IF;

               IF XREC1.B /= 3 THEN
                    FAILED ("F1 IS INCORRECT");
               END IF;

               IF XREC1.C /= 18 THEN
                    FAILED ("NOT USING REDECLARED ""*""");
               END IF;

               IF F1 (T2'(3)) /= F1 (3) THEN
                    FAILED ("STRANGE RESULT HERE");
               END IF;

               IF -T2'(3) /= 3 THEN
                    FAILED ("INCORRECT ""-"" DERIVATION");
               END IF;

               IF -T1'(3) /= 3 THEN
                    FAILED ("INCORRECT OVERLOADING");
               END IF;

               DECLARE
                    TYPE T3 IS NEW T1;
               BEGIN
                    IF F1 (3) /= F1 (T3'(3))
                    OR -T3(3) /= 3
                    OR -T1(3) /= 3
                    THEN
                         FAILED ("INCORRECT INNER DERIVATION");
                    END IF;
               END;
          END P;
     BEGIN
          NULL;
     END;

     RESULT;
END C34016B;
