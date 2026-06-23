-- B43102A.ADA

-- OBJECTIVE:
--     CHECK THAT IN A RECORD AGGREGATE, THE EXPRESSION GIVING THE
--     VALUE OF A DISCRIMINANT WHICH GOVERNS A VARIANT PART MUST BE
--     STATIC.

-- HISTORY:
--     DHH 06/16/88 CREATED ORIGINAL TEST.

PROCEDURE B43102A IS

     SUBTYPE SMALL IS INTEGER RANGE 1 .. 3;

     TYPE VAR_REC(DIS : SMALL) IS
          RECORD
               CHAR : CHARACTER;
               CASE DIS IS
                    WHEN 1 =>
                         BOOL : BOOLEAN;
                    WHEN 2 =>
                         T : CHARACTER;
                    WHEN 3 =>
                         I : INTEGER;
               END CASE;
          END RECORD;

     X : SMALL := 2;

     SUBTYPE SMALL2 IS SMALL RANGE 1..X;

     Y : CONSTANT SMALL2 := 1;

     A : VAR_REC(1) :=
                   (Y,                             -- ERROR: NOT STATIC.
                    'T',
                    TRUE);

     B2 : VAR_REC(2);

     C : VAR_REC(3);

BEGIN

     C := (3 * SMALL2'FIRST,                       -- ERROR: NOT STATIC.
          'T',
          7);

END B43102A;
