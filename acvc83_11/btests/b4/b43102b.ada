-- B43102B.ADA

-- OBJECTIVE:
--     CHECK THAT IN A RECORD AGGREGATE, THE STATICNESS OF THE
--     EXPRESSION GIVING THE VALUE OF A DISCRIMINANT WHICH GOVERNS
--     A VARIANT PART IS NOT USED TO RESOLVE THE TYPE OF THE
--     AGGREGATE.

-- HISTORY:
--     DHH 06/16/88 CREATED ORIGINAL TEST.

PROCEDURE B43102B IS

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

     TYPE REC_BOOL IS
          RECORD
               DIS : SMALL;
               CHAR : CHARACTER;
               BOOL : BOOLEAN;
          END RECORD;

     TYPE REC_CHAR IS
          RECORD
               DIS : SMALL;
               CHAR : CHARACTER;
               T : CHARACTER;
          END RECORD;

     TYPE REC_INT IS
          RECORD
               DIS : SMALL;
               CHAR : CHARACTER;
               I : INTEGER;
          END RECORD;

     X : SMALL := 2;

     FUNCTION IDENT(X : INTEGER) RETURN INTEGER IS
     BEGIN
          RETURN X;
     END IDENT;

     PROCEDURE PROC_VR(X : VAR_REC) IS
     BEGIN
          NULL;
     END PROC_VR;

     PROCEDURE PROC_VR(X : REC_BOOL) IS
     BEGIN
          NULL;
     END PROC_VR;

     PROCEDURE PROC_VR(X : REC_CHAR) IS
     BEGIN
          NULL;
     END PROC_VR;

     PROCEDURE PROC_VR(X : REC_INT) IS
     BEGIN
          NULL;
     END PROC_VR;

BEGIN
     PROC_VR((1,                                    -- ERROR: AMBIGUOUS.
             'T',
             TRUE));

     PROC_VR((IDENT(1),                             -- ERROR: AMBIGUOUS.
             'T',
             TRUE));

     PROC_VR((X,                                    -- ERROR: AMBIGUOUS.
             'T',
             'U'));

     PROC_VR((3 * X/X,                              -- ERROR: AMBIGUOUS.
             'T',
             7));
END B43102B;
