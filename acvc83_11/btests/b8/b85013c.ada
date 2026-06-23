-- B85013C.ADA

-- OBJECTIVE:
--     CHECK THAT A SUBPROGRAM OR ENTRY CAN BE RENAMED WITH:
--       A) DIFFERENT PARAMETER VALUE;
--       B) DIFFERENT DEFAULT VALUES;
--       C) DIFFERENT PARAMETERS HAVING DEFAULT VALUES;
--     AND THAT THE NEW NAMES/DEFAULTS ARE USED WHEN THE NEW NAME IS
--     USED IN A CALL.
--     CASE WHERE THE AGGREGATE CONTEXT IN A RENAMING DECLARATION COMES
--     FROM THE SUBTYPE INDICATIONS IN THE RENAMED SUBPROGRAM,
--     ESPECIALLY FOR A DEFAULT EXPRESSION.

-- HISTORY:
--     RFB 04/06/84
--     EG  05/30/84
--     DWC 10/02/87  SPLIT OUT FUNCTION BODY C1 TO
--                   B85013D.ADA.

PROCEDURE B85013C (N : INTEGER) IS

     I : INTEGER;
     O : STRING(1 .. 1);

     SUBTYPE S  IS STRING;                        -- UNCONSTRAINED.
     SUBTYPE S1 IS STRING(1 .. 2);                -- STATIC.
     SUBTYPE S2 IS STRING(1 .. N);                -- NON-STATIC.

     PROCEDURE P1 (X : S);

     PROCEDURE P2 (X : S1 := (OTHERS => '*'))     -- ERROR: OTHERS NOT
                    RENAMES P1;                   -- ALLOWED SUBTYPE IS
                                                  -- S(TRING) NOT S1.

     PROCEDURE P3 (X : S2 := (OTHERS => '*'));    -- OK - S2 CONSTRAINED

     PROCEDURE P4 (X : S1 := ('1', OTHERS => '*'))-- ERROR: MORE THAN
                    RENAMES P3;                   -- ONE CHOICE SUBTYPE
                                                  -- IS S2 NOT S1.

     FUNCTION  F1 (X : S1 := (OTHERS => '1'))     -- ERROR: OTHERS NOT
          RETURN INTEGER RENAMES INTEGER'VALUE;   -- ALLOWED SUBTYPE IS
                                                  -- STRING NOT S1.

     FUNCTION  C1 (L : S1 := (OTHERS => 'L');     -- ERROR: OTHERS NOT
                                                  -- ALLOWED.
                   R : S2) RETURN S RENAMES "&";

     --
     -- DUMMY BODIES FOR P1 AND P3
     --
     PROCEDURE P1 (X : S) IS
     BEGIN
          NULL;
     END;

     PROCEDURE P3 (X : S2 := (OTHERS => '*')) IS  -- OK - S2 CONSTRAINED
     BEGIN
          NULL;
     END;

BEGIN

     P1((OTHERS => '*'));     -- ERROR: S NOT CONSTRAINED => NO OTHERS.

     P3((1 => '1', OTHERS => '*'));-- ERROR: S2 NOT STATIC => ONE CHOICE

END B85013C;
