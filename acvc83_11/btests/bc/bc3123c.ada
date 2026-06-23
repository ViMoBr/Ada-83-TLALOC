-- BC3123C.ADA

-- CHECK THAT AN ACTUAL PARAMETER MUST BE PROVIDED WHEN THE DEFAULT FOR
-- THE GENERIC FORMAL PARAMETER OF MODE IN IS MISSING.

-- TBN 12/01/86

PROCEDURE BC3123C IS

     TYPE ENUM IS (I, II, III);

     TYPE REC IS
          RECORD
               A : BOOLEAN := TRUE;
               B : ENUM := I;
          END RECORD;

BEGIN
     DECLARE
          GENERIC
               GEN_INT1 : IN INTEGER := 1;
               GEN_INT2 : IN INTEGER;
               GEN_INT3 : IN INTEGER := GEN_INT2;
          PACKAGE P IS
               PAC_INT1 : INTEGER := GEN_INT1;
               PAC_INT2 : INTEGER := GEN_INT2;
               PAC_INT3 : INTEGER := GEN_INT3;
          END P;

          PACKAGE P1 IS NEW P;                                 -- ERROR:
     BEGIN
          NULL;
     END;

     DECLARE
          GENERIC
               GEN_REC1 : IN REC;
               GEN_REC2 : IN REC;
          PROCEDURE PROC;

          PROCEDURE PROC IS
          BEGIN
               NULL;
          END PROC;

          PROCEDURE PROC1 IS NEW PROC((FALSE, II));            -- ERROR:
     BEGIN
          NULL;
     END;

     DECLARE
          TYPE ARA IS ARRAY (1 .. 2) OF REC;

          GENERIC
               GEN_ARA1 : IN ARA := (1..2 => (FALSE, III));
               GEN_ARA2 : IN ARA;

          FUNCTION FUN RETURN ARA;

          FUNCTION FUN RETURN ARA IS
               FUN_ARA : ARA;
          BEGIN
               RETURN FUN_ARA;
          END FUN;

          FUNCTION NO_FUN IS NEW FUN;                          -- ERROR:
     BEGIN
          NULL;
     END;

     DECLARE
          TYPE ARA IS ARRAY (1 .. 2) OF REC;

          GENERIC
               GEN_ARA1 : IN ARA := (1..2 => (FALSE, III));
               GEN_ARA2 : IN ARA;

          FUNCTION FUN RETURN ARA;

          FUNCTION FUN RETURN ARA IS
               FUN_ARA : ARA;
          BEGIN
               RETURN FUN_ARA;
          END FUN;

          FUNCTION NO_FUN IS
               NEW FUN(GEN_ARA1 => (1..2 => (TRUE, II)));      -- ERROR:
     BEGIN
          NULL;
     END;

     DECLARE
          TYPE ARA IS ARRAY (1 .. 2) OF REC;

          GENERIC
               GEN_ARA1 : IN ARA := (1..2 => (FALSE, III));
               GEN_ARA2 : IN ARA;

          FUNCTION FUN RETURN ARA;

          FUNCTION FUN RETURN ARA IS
               FUN_ARA : ARA;
          BEGIN
               RETURN FUN_ARA;
          END FUN;

          FUNCTION NO_FUN IS NEW FUN((1..2 => (TRUE, II)));    -- ERROR:
     BEGIN
          NULL;
     END;

END BC3123C;
