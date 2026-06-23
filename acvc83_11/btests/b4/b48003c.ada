-- B48003C.ADA

-- CHECK THAT ILLEGAL FORMS OF ALLOCATORS ARE FORBIDDEN. IN PARTICULAR,
-- FOR ALLOCATORS OF THE FORM "NEW T'(X)", CHECK THAT T CANNOT BE A
-- LIMITED TYPE (CONSTRAINED OR UNCONSTRAINED). IN OTHER WORDS, CHECK
-- THAT:
--    1) X CANNOT DENOTE A VALUE OF A LIMITED TYPE,
--    2) X CANNOT HAVE THE FORM OF A POSITIONAL AGGREGATE WHOSE VALUES
--       EQUAL THE CORRESPONDING DISCRIMINANT VALUES,
--    3) X CANNOT HAVE THE FORM OF A COMPLETE AND VALID AGGREGATE FOR
--       THE UNDERLYING PRIVATE TYPE DEFINITION, INCLUDING THE CASE
--       WHERE THE PRIVATE TYPE ONLY HAS DISCRIMINANT COMPONENTS.

-- EG  08/03/84

PROCEDURE B48003C IS

BEGIN

     -- C1

     DECLARE

          TASK TYPE T;
          TYPE LA IS ARRAY(1 .. 2) OF T;
          TYPE LR IS
               RECORD
                    A : INTEGER;
                    B : T;
               END RECORD;
          PACKAGE P IS
               TYPE TT IS PRIVATE;
               TYPE UP(A : INTEGER) IS LIMITED PRIVATE;
               CUP : CONSTANT UP;
          PRIVATE
               TYPE TT IS RANGE 1 .. 4;
               TYPE UP(A : INTEGER) IS
                    RECORD
                         B : TT;
                    END RECORD;
               CUP : CONSTANT UP := (1, 4);
          END P;

          SUBTYPE CP IS P.UP(1);
          TYPE A_CP IS ACCESS CP;
          TYPE A_LA IS ACCESS LA;
          TYPE A_LR IS ACCESS LR;
          TYPE A_T  IS ACCESS T;

          V_A_CP : A_CP;
          V_A_LA : A_LA;
          V_A_LR : A_LR;
          V_A_T  : A_T;

          FUNCTION FUN RETURN T IS
               VT : T;
          BEGIN
               RETURN VT;
          END FUN;

          TASK BODY T IS
          BEGIN
               NULL;
          END T;

     BEGIN

          V_A_CP := NEW CP'(P.CUP);               -- ERROR:
          V_A_LA := NEW LA'(FUN, FUN);            -- ERROR:
          V_A_LR := NEW LR'(2, FUN);              -- ERROR:
          V_A_T  := NEW T'(FUN);                  -- ERROR:

     END;

     -- C2

     DECLARE

          TYPE INT IS RANGE 1 .. 4;
          TYPE ARR IS ARRAY(INT RANGE <>) OF INTEGER;

          PACKAGE P IS
               TYPE UR(A, B : INT) IS LIMITED PRIVATE;
          PRIVATE
               TYPE UR(A, B : INT) IS
                    RECORD
                         C : ARR(A .. B);
                    END RECORD;
          END P;

          SUBTYPE CR IS P.UR(3, 2);
          TYPE A_CR IS ACCESS CR;

          V_A_CR : A_CR;

     BEGIN

          V_A_CR := NEW CR'(3, 2);                -- ERROR:

     END;

     -- C3

     DECLARE

          PACKAGE P IS
               TYPE UR(A, B, C : INTEGER) IS LIMITED PRIVATE;
          PRIVATE
               TYPE UR(A, B, C : INTEGER) IS
                    RECORD
                         NULL;
                    END RECORD;
          END P;

          TYPE A_CR IS ACCESS P.UR(1, 2, 3);
     
          V_A_CR : A_CR;

     BEGIN

          V_A_CR := NEW P.UR'(1, 2, 3);           -- ERROR:

     END;

END B48003C;
