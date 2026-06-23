-- C37007A.ADA

-- CHECK THAT ARRAY COMPONENTS OF RECORDS MAY HAVE NON-STATIC INDEX
-- CONSTRAINTS, INITIAL VALUES, AND INITIAL VALUE AGGREGATE BOUNDS.

-- DAT 3/2/81
-- SPS 10/26/82
-- SPS 1/24/83

WITH REPORT;
PROCEDURE C37007A IS

     USE REPORT;

BEGIN
     TEST ("C37007A", "CHECK THAT ARRAY COMPONENTS OF RECORDS MAY HAVE "
                 & "NON-STATIC INDEX CONSTRAINTS AND INITIAL VALUES");

     DECLARE
          TYPE TA IS ARRAY (1 .. 5) OF INTEGER;
          L : INTEGER := IDENT_INT (1);
          R : INTEGER := IDENT_INT (5);
          TYPE UA IS ARRAY (NATURAL RANGE <> )
               OF INTEGER RANGE L .. R;
          SUBTYPE DT IS INTEGER RANGE L .. R;
          TYPE UADT IS ARRAY (DT RANGE <>) OF INTEGER;
          M : INTEGER :=  ((L + R) / 2);     -- 3
          SUBTYPE ST IS INTEGER RANGE 1..5;

          TYPE A1 IS ARRAY (ST) OF DT;
          TYPE A2 IS ARRAY (ST) OF INTEGER
               RANGE L .. R;
          TYPE A3 IS ARRAY (ST) OF DT RANGE
                L ..  R;

          X1 : A1 := (DT => (L+R)/2);        -- (DT => 3)
          X2 : A2 := (A2'RANGE => 3);
          X3 : A3 := (DT RANGE L..R => M);

          TYPE REC_1 IS RECORD
               C1 : TA;
               C2 : TA := (L..R => M);
               C3 : UA(ST) := (DT => M);
               C4 : UA (1 .. 5) := (DT => DT'FIRST);
               C5 : UADT (IDENT_INT (L) .. R) := (1 .. 5 => M);
               C6 : UA (L .. R) := UA (X1);
               C7 : A1 := X1;
               C8 : A2 := (L..R => X1(M));
               C9 : A3 := X3(1..5);
               C10 : A2 := (A3'RANGE => (L + A3'LAST) / 2);
               C11 : A2 := X2(DT);
               C12 : A2 := (A2'RANGE => M);
               C13 : UA(DT):=(L, X1(L)-1, IDENT_INT(M), DT'LAST-1, R);
               C14 : A1 := (IDENT_INT(L), X3(R)-1, M, DT'FIRST+3, R);
          END RECORD;

          R1, R2 : REC_1;

     BEGIN

          R1.C1 := (L .. R => M);
          R2 := R1;
          IF R2.C1 /= (M,M,M,M,M) 
          THEN
               FAILED ("BAD ARRAY VALUE - 1");
          END IF;

          IF R2.C1 /= R2.C2
          THEN
               FAILED ("BAD ARRAY VALUE - 2");
          END IF;

          IF R2.C5 /= (DT => 3)
          THEN
               FAILED ("BAD ARRAY VALUE - 3");
          END IF;

          IF R2.C3 /= (DT => M)
          THEN
               FAILED ("BAD ARRAY VALUE - 4");
          END IF;

          IF R2.C4 /= (DT => L)
          THEN
               FAILED ("BAD ARRAY VALUE - 5");
          END IF;

          IF R2.C6 /= UA (R2.C8) 
          THEN
               FAILED ("BAD ARRAY VALUE - 6");
          END IF;

          IF A3 (R2.C7) /= R2.C9
          THEN
               FAILED ("BAD ARRAY VALUE - 7");
          END IF;

          IF R2.C10 /= R2.C11 
          THEN
               FAILED ("BAD ARRAY VALUE - 8");
          END IF;

          IF R2.C12 /= (L..R => M)
          THEN
               FAILED ("BAD ARRAY VALUE - 9");
          END IF;

          IF R2.C13 /= (1,2,3,4,5)
          THEN
               FAILED ("BAD ARRAY VALUE - 10");
          END IF;

          IF R2.C14 /= (1,2,3,4,5)
          THEN
               FAILED ("BAD ARRAY VALUE - 11");
          END IF;

     END;

     RESULT;
END C37007A;
