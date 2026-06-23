-- BC1001A.ADA

-- CHECK THAT A GENERIC FORMAL PARAMETER MAY NOT REFER TO
-- ITSELF IN ITS INITIALIZATION EXPRESSIONS.
-- CHECK THAT A FORMAL OPERATOR DECLARATION CANNOT HAVE THE OPERATOR
-- NAME AS THE DEFAULT AND THAT AN ENUMERATION LITERAL CANNOT BE USED
-- AS A DEFAULT NAME.

-- DAT 7/15/81
-- ABW 7/16/82
-- SPS 10/18/82
-- JBG 8/21/83
-- AH  9/29/86  ADD FORMAL OPERATOR AND ENUMERATION LITERAL.

WITH SYSTEM; USE SYSTEM;
PROCEDURE BC1001A IS

     GENERIC
          I, J : INTEGER := I;               -- ERROR: J REFS I.
     PACKAGE P1 IS END P1;

     INT_3 : INTEGER := 3;

     GENERIC
          INT_3 : INTEGER := INTEGER'(3);    -- OK.
          P1A, P1B : INTEGER := (P1A'SIZE);  -- ERROR: REFS P1A.
          P1C, P1D : INTEGER := P1D'SIZE;    -- ERROR: P1D REFS P1D.
          P2 : INTEGER := P2;                -- ERROR: SELF-REF.
          P2A : INTEGER := INTEGER(P2A'SIZE);-- ERROR: SELF-REF.
          P2D : INTEGER := INTEGER'FIRST;    -- OK.
          P2E : INTEGER := INTEGER(P2D'SIZE);-- OK.
          P4 : INTEGER := INTEGER (4);       -- OK.
          P6 : INTEGER := INTEGER'LAST;      -- OK.
          TYPE P7 IS ARRAY (INTEGER) OF INTEGER;  -- OK.
          TYPE P8 IS ARRAY (INTEGER) OF P8;  -- ERROR: SELF_REF.
          Z : P7 := (P7'RANGE => 0);         -- OK.
          Q : P7 := (Q'RANGE => 0);          -- ERROR: SELF-REF.
          WITH PROCEDURE F(A : INTEGER) IS F;-- ERROR: SELF-REF.
     PACKAGE PP IS END PP;

     GENERIC
          TYPE T1 IS ( <> );
          X1 : T1 := T1'PRED(T1'LAST);       -- OK.
          X2 : T1 := T1'BASE'FIRST;          -- OK.
          X3 : T1 := T1'FIRST;               -- OK.
          X4 : T1 := X3;                     -- OK.
          WITH FUNCTION F1 (P : 
               INTEGER := F1) RETURN INTEGER;-- ERROR: SELF_REF.
          WITH PROCEDURE P1 IS <> ;          -- OK.
          WITH PROCEDURE P2 IS P1;           -- OK.
          X6 : ADDRESS := P1'ADDRESS;        -- OK.
          B1 : BOOLEAN := INT_3 = 3;         -- OK.
          B2 : BOOLEAN := INT_3 /= 3;        -- OK.
          TYPE T2 IS LIMITED PRIVATE;
          WITH FUNCTION "=" (X, Y : T2) 
               RETURN BOOLEAN;               -- OK.
     PACKAGE P4 IS END P4;

          TYPE ENUM_LIT_TYPE IS (A, B, C);
     GENERIC
          WITH FUNCTION C (X : INTEGER)
               RETURN BOOLEAN IS C;          -- ERROR: SAME DEFAULT NAME
                                             --        AS FUNCTION NAME.
          WITH FUNCTION "+" (X, Y : INTEGER)
               RETURN INTEGER IS "+";        -- ERROR: SAME DEFAULT NAME
                                             --        AS FUNCTION NAME.
     PACKAGE P5 IS END P5;

BEGIN
     NULL;
END BC1001A;
