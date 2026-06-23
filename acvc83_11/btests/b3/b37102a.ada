-- B37102A.ADA

-- CHECK THAT EXPRESSIONS CONTAINING DISCRIMINANTS MAY NOT BE USED
-- IN AN INDEX OR DISCRIMINANT CONSTRAINT IN A RECORD TYPE DEFINITION.

-- CHECK THAT A DISCRIMINANT NAME MAY NOT BE USED AS THE DEFAULT
-- INITIAL VALUE FOR ANOTHER DISCRIMINANT DECLARED LATER IN THE SAME 
-- DISCRIMINANT PART.

-- DAT 5/18/81
-- SPS 12/10/82
-- SPS 1/6/83
-- JRK 11/21/85    RENAMED FROM B37003A-AB.ADA.
-- TBN 1/20/86     REVISED COMMENTS AND INCLUDED 'SIZE ATTRIBUTE CASES
--                 AND TYPE R2.

PROCEDURE B37102A IS

     SUBTYPE D IS BOOLEAN RANGE TRUE .. TRUE;
     SUBTYPE D1 IS INTEGER RANGE 1 .. 1;
     CONST : CONSTANT ARRAY (D) OF D1 := (TRUE => 1);

     TYPE AR1 IS ARRAY (D RANGE <>) OF D;
     TYPE AR2 IS ARRAY (D1 RANGE <>) OF D;
     TYPE REC1 (Z : D1) IS RECORD NULL; END RECORD;

     TYPE R (A : D; B : D1) IS RECORD
          C1 : D1 RANGE B .. 1;                     -- ERROR: B.
          C2 : FLOAT RANGE 1.0 .. FLOAT (B);        -- ERROR: B.
          C3 : D1 := B;                             -- OK.
          C4 : AR1 (D) := (D => TRUE);              -- OK.
          C5 : FLOAT DIGITS 1 RANGE 1.0..FLOAT(B);  -- ERROR: B.
          C6 : AR1 (D) := (A => TRUE);              -- OK.
          C7 : STRING (1..CONST(A));                -- ERROR: CONST(A).
          C8 : REC1 (CONST (A));                    -- ERROR: CONST(A).
          C9 : REC1 (CONST (D) (TRUE));             -- OK.
          CA : REC1 (B);                            -- OK.
          CB : REC1 (1);                            -- OK.
          CC : STRING (1 .. B);                     -- OK.
          CD : STRING (1 .. (B));                   -- ERROR: ()'S.
          CE : STRING (1 .. +B);                    -- ERROR: +.
          CF : STRING (1 .. -(-B));                 -- ERROR: -(-B).
          CG : AR2 (1 .. B);                        -- OK.
          CH : AR2 (1 .. (B));                      -- ERROR: ()'S.
          CI : AR2 (1 .. +B);                       -- ERROR: +.
          CJ : AR2 (1 .. A'SIZE);                   -- ERROR: 'SIZE.
          CR : REC1 (D1'(B));                       -- ERROR: D1'().
          CS : REC1 ((B));                          -- ERROR: ()'S.
          CU : REC1 (+B);                           -- ERROR: +.
          CV : REC1 (B+0);                          -- ERROR: +0.
          CW : REC1 (B'SIZE);                       -- ERROR: 'SIZE.
     END RECORD;

     TYPE R2 (A : D1 := 1; B : D1 := A) IS          -- ERROR: A.
          RECORD
               NULL;
          END RECORD;

BEGIN
     NULL;
END B37102A;
