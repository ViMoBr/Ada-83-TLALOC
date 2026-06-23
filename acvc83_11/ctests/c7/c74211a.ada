-- C74211A.ADA

-- CHECK THAT WITHIN THE PACKAGE SPECIFICATION AND BODY, ANY EXPLICIT
-- DECLARATIONS OF OPERATORS AND SUBPROGRAMS HIDE ANY OPERATIONS WHICH
-- ARE IMPLICITLY DECLARED AT THE POINT OF THE FULL DECLARATION,
-- REGARDLESS OF THE ORDER OF OCCURENCE OF THE DECLARATIONS.

-- CHECK THAT IMPLICITLY DECLARED DERIVED SUBPROGRAMS HIDE IMPLICITLY
-- DECLARED PREDEFINED OPERATORS, REGARDLESS OF THE ORDER OF OCCURENCE
-- OF THE DECLARATIONS.

-- DSJ 4/28/83
-- JBG 9/23/83

--   A) EXPLICIT DECLARATION HIDES LATER IMPLICIT DECL OF PREDEFINED OP.
--   B)     "        "         "   LATER     "      "  "  DERIVED OP.
--   C)     "        "         "   EARLIER   "      "  "  PREDEFINED OP.
--   D)     "        "         "   EARLIER   "      "  "  DERIVED OP.

WITH REPORT;
PROCEDURE C74211A IS

     USE REPORT;

BEGIN

     TEST ("C74211A", "CHECK THAT HIDING OF IMPLICITLY DECLARED " &
                      "OPERATORS AND DERIVED SUBPROGRAMS IS DONE " &
                      "CORRECTLY REGARDLESS OF ORDER OF DECL'S");

     DECLARE

          PACKAGE P1 IS 
               TYPE T1 IS RANGE 1 .. 50;
               C1 : CONSTANT T1 := T1(IDENT_INT(2));
               D1 : CONSTANT T1 := C1 + C1;        -- PREDEFINED "+"
               FUNCTION "+" (L, R : T1) RETURN T1; -- C) FOR "+".
               FUNCTION "-" (L, R : T1) RETURN T1; -- C) FOR "-".
               FUNCTION "/" (L, R : T1) RETURN T1; 
          END P1;

          USE P1;

          PACKAGE BODY P1 IS
               A,B : T1 := 3;

               FUNCTION "+" (L, R : T1) RETURN T1 IS
               BEGIN
                    IF L = R THEN
                         RETURN 1;
                    ELSE RETURN 2;
                    END IF;
               END "+";

               FUNCTION "-" (L, R : T1) RETURN T1 IS
               BEGIN
                    IF L = R THEN
                         RETURN 3;
                    ELSE RETURN 4;
                    END IF;
               END "-";

               FUNCTION "/" (L, R : T1) RETURN T1 IS
               BEGIN
                    IF L = R THEN
                         RETURN T1(IDENT_INT(INTEGER(L)));
                    ELSE
                         RETURN T1(IDENT_INT(50));
                    END IF;
               END "/";

          BEGIN
               IF D1 /= 4 THEN
                    FAILED ("WRONG PREDEFINED OPERATION - '+' ");
               END IF;

               IF D1 + C1 /= 2 THEN
                    FAILED ("IMPLICIT '+' NOT HIDDEN BY EXPLICIT '+'");
               END IF;

               IF A + B /= 1 THEN
                    FAILED ("IMPLICIT DECLARATION NOT HIDDEN " &
                            "BY EXPLICIT DECLARATION - '+' ");
               END IF;

               IF A - B /= 3 THEN
                    FAILED ("IMPLICIT DECLARATION NOT HIDDEN " &
                            "BY EXPLICIT DECLARATION - '-' ");
               END IF;

               IF A * B /= 9 THEN
                    FAILED ("WRONG PREDEFINED OPERATION - '*' ");
               END IF;

               IF B / A  /=  T1(IDENT_INT(3)) THEN
                    FAILED ("NOT REDEFINED '/' ");
               END IF;
          END P1;

          PACKAGE P2 IS
               TYPE T2 IS PRIVATE;
               X , Y : CONSTANT T2;
               FUNCTION "+" (L, R : T2) RETURN T2;     -- B)
               FUNCTION "*" (L, R : T2) RETURN T2;     -- A)
          PRIVATE
               TYPE T2 IS NEW T1;                 -- B) +; A) *
               Z : T2 := T2(IDENT_INT(3))/4;      -- Z = 50 USING
                                                  -- DERIVED /
               FUNCTION "/" (L, R : T2) RETURN T2;  -- D) FOR /
               X , Y : CONSTANT T2 := 3;
          END P2;

          PACKAGE BODY P2 IS
               FUNCTION "+" (L, R : T2) RETURN T2 IS
               BEGIN
                    IF L = R THEN
                         RETURN T2(IDENT_INT(5));
                    ELSE RETURN T2(IDENT_INT(6));
                    END IF;
               END "+";

               FUNCTION "*" (L, R : T2) RETURN T2 IS
               BEGIN
                    IF L = R THEN
                         RETURN T2(IDENT_INT(7));
                    ELSE RETURN T2(IDENT_INT(8));
                    END IF;
               END "*";

               FUNCTION "/" (L, R : T2) RETURN T2 IS
               BEGIN
                    IF L = R THEN
                         RETURN T2(IDENT_INT(9));
                    ELSE RETURN T2(IDENT_INT(10));
                    END IF;
               END "/";
          BEGIN
               IF X + Y /= 5 THEN
                         FAILED ("DERIVED SUBPROGRAM NOT HIDDEN BY " &
                                 "EXPLICIT DECLARATION - '+' ");
               END IF;

               IF Y - X /= 3 THEN
                         FAILED ("PREDEFINED OPERATOR NOT HIDDEN BY " &
                                 "DERIVED SUBPROGRAM - '-' ");
               END IF;

               IF X * Y /= 7 THEN
                         FAILED ("PREDEFINED OPERATOR NOT HIDDEN BY " &
                                 "EXPLICIT DECLARATION - '*' ");
               END IF;

               IF Y / X /= T2(IDENT_INT(9)) THEN
                         FAILED ("DERIVED OPERATOR NOT HIDDEN BY " &
                                 "EXPLICIT DECLARATION - '/' ");
               END IF;

               IF Z /= 50 THEN
                    FAILED ("DERIVED OPERATOR HIDDEN PREMATURELY " &
                            " BY REDECLARED OPERATOR");
               END IF;

          END P2;

     BEGIN

          NULL;

     END;

     RESULT;

END C74211A;
